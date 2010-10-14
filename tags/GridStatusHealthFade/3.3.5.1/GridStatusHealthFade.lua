--[[****************************************************************************
  * GridStatusHealthFade by Saiket (Originally by North101)                    *
  * GridStatusHealthFade.lua - Adds a health status that fades from one color  *
  *   at max health to another at no health.                                   *
  ****************************************************************************]]


local L = GridStatusHealthFadeLocalization;
local me = Grid:GetModule( "GridStatus" ):NewModule( "GridStatusHealthFade" );

local STATUS_ID = "alert_healthFade";

local ColorTables = {};
me.ColorTables = ColorTables;

me.menuName = L.TITLE;
me.options = false;

me.defaultDB = {
	debug = false;
	[ STATUS_ID ] = {
		text = L.TITLE;
		enable = true;
		priority = 1;
		range = false;
		ColorHigh = { r = 0; g = 1; b = 0; a = 1; };
		ColorLow = { r = 1; g = 0; b = 0; a = 1; };
	};
};




--[[****************************************************************************
  * Function: GridStatusHealthFade:OnInitialize                                *
  * Description: Registers the HealthFade status and its options with Grid.    *
  ****************************************************************************]]
do
	local Options = {
		color = false; -- Don't use original color picker
	};
	local Count = 0;
	local function AddColorPicker ( Property, Name, Description )
		Count = Count + 1;
		Options[ Property ] = {
			type = "color"; hasAlpha = true; order = Count;
			name = Name; desc = Description;
			get = function ()
				local Color = me.db.profile[ STATUS_ID ][ Property ];
				return Color.r, Color.g, Color.b, Color.a;
			end;
			set = function ( R, G, B, A )
				local Color = me.db.profile[ STATUS_ID ][ Property ];
				Color.r = R;
				Color.g = G;
				Color.b = B;
				Color.a = A or 1;
				me:UpdateAllUnits();
			end;
		};
	end
	function me:OnInitialize ()
		self.super.OnInitialize( self );
		AddColorPicker( "ColorHigh", L.COLOR_HIGH, L.COLOR_HIGH_DESC );
		AddColorPicker( "ColorLow", L.COLOR_LOW, L.COLOR_LOW_DESC );
		self:RegisterStatus( STATUS_ID, L.TITLE, Options, true );
	end
end
--[[****************************************************************************
  * Function: GridStatusHealthFade:OnStatusEnable                              *
  * Description: Called when this status is enabled and used.                  *
  ****************************************************************************]]
function me:OnStatusEnable ( Status )
	if ( Status == STATUS_ID ) then
		self:RegisterEvent( "Grid_UnitJoined", "UpdateUnit" );
		self:RegisterEvent( "Grid_UnitLeft", "RemoveUnit" );
		self:RegisterEvent( "Grid_UnitChanged", "UpdateUnit" );
		self:RegisterEvent( "UNIT_HEALTH" );
		self:RegisterEvent( "UNIT_MAXHEALTH" );
		self:UpdateAllUnits();
	end
end
--[[****************************************************************************
  * Function: GridStatusHealthFade:OnStatusDisable                             *
  * Description: Called when this status gets disabled or becomes unused.      *
  ****************************************************************************]]
function me:OnStatusDisable ( Status )
	if ( Status == STATUS_ID ) then
		self:UnregisterAllEvents();
		self.core:SendStatusLostAllUnits( STATUS_ID );
		wipe( ColorTables );
	end
end
--[[****************************************************************************
  * Function: GridStatusHealthFade:Reset                                       *
  * Description: Completely reinitializes the status.                          *
  ****************************************************************************]]
function me:Reset ()
	self.super.Reset( self );
	self:OnDisable();
	self:OnEnable();
end




--[[****************************************************************************
  * Function: GridStatusHealthFade:UNIT_HEALTH                                 *
  ****************************************************************************]]
do
	local UnitGUID = UnitGUID;
	function me:UNIT_HEALTH( UnitID )
		self:UpdateUnit( UnitGUID( UnitID ), UnitID );
	end
end
--[[****************************************************************************
  * Function: GridStatusHealthFade:UNIT_MAXHEALTH                              *
  ****************************************************************************]]
do
	local UnitGUID = UnitGUID;
	function me:UNIT_MAXHEALTH( UnitID )
		self:UpdateUnit( UnitGUID( UnitID ), UnitID );
	end
end


--[[****************************************************************************
  * Function: GridStatusHealthFade:RemoveUnit                                  *
  * Description: Removes the unit's color table from the cache.                *
  ****************************************************************************]]
function me:RemoveUnit ( GUID, UnitID )
	ColorTables[ GUID ] = nil;
end
--[[****************************************************************************
  * Function: GridStatusHealthFade:UpdateAllUnits                              *
  * Description: Runs UpdateUnit for all active units.                         *
  ****************************************************************************]]
do
	local GridRoster = Grid:GetModule( "GridRoster" );
	function me:UpdateAllUnits ()
		for GUID, UnitID in GridRoster:IterateRoster() do
			self:UpdateUnit( GUID, UnitID );
		end
	end
end
--[[****************************************************************************
  * Function: GridStatusHealthFade:UpdateUnit                                  *
  * Description: Updates or removes the health fade status.                    *
  ****************************************************************************]]
do
	local UnitHealth = UnitHealth;
	local UnitHealthMax = UnitHealthMax;
	local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
	local ceil = ceil;
	function me:UpdateUnit( GUID, UnitID )
		local HealthMax = UnitHealthMax( UnitID );
		if ( HealthMax == 0 ) then -- Unit info is bogus
			return;
		end

		if ( UnitIsDeadOrGhost( UnitID ) ) then
			self.core:SendStatusLost( GUID, STATUS_ID );
		else
			local Percentage = UnitHealth( UnitID ) / HealthMax;
			local Settings = self.db.profile[ STATUS_ID ];
			local High, Low = Settings.ColorHigh, Settings.ColorLow;

			local Color = ColorTables[ GUID ] or {};
			ColorTables[ GUID ] = Color;
			Color.r = High.r * Percentage + Low.r * ( 1 - Percentage );
			Color.g = High.g * Percentage + Low.g * ( 1 - Percentage );
			Color.b = High.b * Percentage + Low.b * ( 1 - Percentage );
			Color.a = High.a * Percentage + Low.a * ( 1 - Percentage );

			-- Hack to force updates when the color changes
			local Cache = self.core:GetCachedStatus( GUID, STATUS_ID );
			if ( Cache ) then
				Cache.color = nil;
			end
			self.core:SendStatusGained( GUID, STATUS_ID,
				Settings.priority,
				( Settings.range and 40 ),
				Color,
				L.LABEL_FORMAT:format( ceil( Percentage * 100 ) ),
				Percentage,
				1,
				Settings.icon );
		end
	end
end