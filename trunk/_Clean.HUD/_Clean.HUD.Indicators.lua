--[[****************************************************************************
  * _Clean.HUD by Saiket                                                       *
  * _Clean.HUD.Indicators.lua - Modifies all situational indicator widgets.    *
  ****************************************************************************]]


local _Clean = _Clean;
local me = {};
_Clean.HUD.Indicators = me;




--[[****************************************************************************
  * Function: _Clean.HUD.Indicators.ManageWorldState                           *
  * Description: Disables mouse input for objectives and positions them.       *
  ****************************************************************************]]
do
	local LastFrame;
	local function AddFrame ( self, Scale )
		if ( self and self:IsShown() ) then
			self:ClearAllPoints();
			self:SetPoint( "BOTTOM", LastFrame, "TOP" );
			self:EnableMouse( false );
			self:SetScale( Scale or 1.0 );
			LastFrame = self;
			return true;
		end
	end
	function me.ManageWorldState ()
		LastFrame = WorldStateAlwaysUpFrame;
		for Index = 1, NUM_EXTENDED_UI_FRAMES do
			if ( not AddFrame( _G[ "WorldStateCaptureBar"..Index ], 0.8 ) ) then
				break;
			end
		end
		for Index = 1, NUM_ALWAYS_UP_UI_FRAMES do
			if ( not AddFrame( _G[ "AlwaysUpFrame"..Index ] ) ) then
				break;
			end
		end
	end
end


--[[****************************************************************************
  * Function: _Clean.HUD.Indicators.ManageDurability                           *
  * Description: Moves the durability frame to the center of the bottom pane.  *
  ****************************************************************************]]
function me.ManageDurability ()
	DurabilityFrame:ClearAllPoints();
	DurabilityFrame:SetPoint( "CENTER" );
end


--[[****************************************************************************
  * Function: _Clean.HUD.Indicators.ManageVehicleSeats                         *
  * Description: Disables unusable seat buttons.                               *
  ****************************************************************************]]
do
	local Buttons = {};
	function me.ManageVehicleSeats ()
		if ( VehicleSeatIndicator.currSkin ) then -- In vehicle
			-- Cache any new buttons
			local Button = _G[ "VehicleSeatIndicatorButton"..( #Buttons + 1 ) ];
			while ( Button ) do
				Buttons[ #Buttons + 1 ] = Button;
				Button = _G[ "VehicleSeatIndicatorButton"..( #Buttons + 1 ) ];
			end

			-- Only mouse-enable usefull buttons
			for Index, Button in ipairs( Buttons ) do
				if ( Button:IsShown() ) then
					local Type, OccupantName = UnitVehicleSeatInfo( "player", Index );
					Button:EnableMouse( OccupantName ~= UnitName( "player" ) and ( OccupantName or CanSwitchVehicleSeats() ) );
				end
			end
		end
	end
end
--[[****************************************************************************
  * Function: _Clean.HUD.Indicators.ManageVehicle                              *
  * Description: Moves the vehicle seating to the center of the bottom pane.   *
  ****************************************************************************]]
function me.ManageVehicle ()
	VehicleSeatIndicator:ClearAllPoints();
	VehicleSeatIndicator:SetPoint( "CENTER" );
end


--[[****************************************************************************
  * Function: _Clean.HUD.Indicators.Manage                                     *
  * Description: Reposition indicators after managed frames are moved.         *
  ****************************************************************************]]
function me.Manage ()
	me.ManageWorldState();
	me.ManageDurability();
end




--------------------------------------------------------------------------------
-- Function Hooks / Execution
-----------------------------

do
	-- Move capture/worldstate frames
	WorldStateAlwaysUpFrame:SetParent( _Clean.BottomPane );
	WorldStateAlwaysUpFrame:ClearAllPoints();
	WorldStateAlwaysUpFrame:SetPoint( "BOTTOM", 0, 6 );
	WorldStateAlwaysUpFrame:SetHeight( 1 );
	WorldStateAlwaysUpFrame:EnableMouse( false );
	WorldStateAlwaysUpFrame:SetAlpha( 0.5 );
	hooksecurefunc( "WorldStateAlwaysUpFrame_Update", me.ManageWorldState );


	-- Move the durability frame to the middle
	DurabilityFrame:SetParent( _Clean.BottomPane );
	DurabilityFrame:SetScale( 2.0 );
	me.ManageDurability();


	-- Move the vehicle seat indicator to the middle
	VehicleSeatIndicator:SetParent( _Clean.BottomPane );
	VehicleSeatIndicator:SetAlpha( 0.6 );
	hooksecurefunc( "VehicleSeatIndicator_Update", me.ManageVehicleSeats );
	hooksecurefunc( "MultiActionBar_Update", me.ManageVehicle );
	me.ManageVehicle();




	-- Hook the secure frame position delegate since parts of the DefaultUI don't use the global wrapper functions
	local Frame;
	for Index = 1, 20 do -- Limit search to first 20 frames
		Frame = EnumerateFrames( Frame )
		if ( Frame and Frame.UIParentManageFramePositions ) then
			hooksecurefunc( Frame, "UIParentManageFramePositions", me.Manage );
			return;
		end
	end
	error( "FramePositionDelegate not found!" );
end