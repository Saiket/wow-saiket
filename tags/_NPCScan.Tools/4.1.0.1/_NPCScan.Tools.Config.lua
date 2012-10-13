--[[****************************************************************************
  * _NPCScan.Tools by Saiket                                                   *
  * _NPCScan.Tools.Config.lua - Adds a configuration pane to manage the        *
  *   Overlay module.                                                          *
  ****************************************************************************]]


local Tools = select( 2, ... );
local L = Tools.L;
local me = CreateFrame( "Frame" );
Tools.Config = me;

me.Controls = CreateFrame( "Frame", nil, me );
me.TableContainer = CreateFrame( "Frame", nil, me );
me.EditBox = CreateFrame( "EditBox", "_NPCScanToolsConfigEditBox", nil, "InputBoxTemplate" );




do
	--- @return The first region in ... that is under the cursor.
	local function GetMouseoverRegion ( ... )
		for Index = 1, select( "#", ... ) do
			local Region = select( Index, ... );
			if ( Region:IsMouseOver() ) then
				return Region;
			end
		end
	end
	--- Adds additional click actions to table rows.
	function me:TableRowOnClick ( Button )
		if ( Button == "RightButton" ) then -- Select text for copying.
			me.EditBox:SetElement( GetMouseoverRegion( self:GetRegions() ) );
		else -- Clear selection if row already selected.
			me.EditBox:SetElement();
			local Table = self:GetParent().Table;
			if ( not Table:SetSelection( self ) ) then
				Table:SetSelection();
			end
		end
	end
end
do
	local function AddHooks( Row, ... )
		Row:SetScript( "OnClick", me.TableRowOnClick );
		return Row, ...;
	end
	local CreateRowBackup;
	--- Hooks row methods when a new row is created.
	function me:TableCreateRow ( ... )
		return AddHooks( CreateRowBackup( self, ... ) );
	end
	--- Enables context sensitive actions based on which row is selected.
	local function OnSelect ( self, NpcID, ... )
		for Index, Control in ipairs( me.Controls ) do
			if ( Control.OnSelect ) then
				Control:OnSelect( NpcID, ... );
			end
		end
	end
	--- Creates the data table and fills it when first shown.
	function me:OnShow ()
		self:SetScript( "OnShow", nil );
		me.OnShow = nil;

		me.Table = LibStub( "LibTextTable-1.1" ).New( nil, me.TableContainer );
		me.Table:SetAllPoints();
		me.Table.OnSelect = OnSelect;

		me.Table:SetHeader( L.CONFIG_MAPID, L.CONFIG_ID, L.CONFIG_NAME, L.CONFIG_DISPLAYID );
		me.Table:SetSortHandlers( true, true, true, true );
		me.Table:SetSortColumn( 1 ); -- Default to MapID
		CreateRowBackup = me.Table.CreateRow;
		me.Table.CreateRow = me.TableCreateRow;

		me.EditBox:SetFontObject( me.Table.ElementFont );

		local Overlay = _NPCScan.Overlay;
		for NpcID, Name in pairs( Tools.NPCNames ) do
			local MapID = Tools.NPCMapIDs[ NpcID ];
			me.Table:AddRow( NpcID,
				tostring( Overlay and Overlay.GetMapName( MapID ) or MapID or "" ),
				NpcID, Name,
				tostring( Tools.NPCDisplayIDs[ NpcID ] or "" ) );
		end
	end
end


--- Mimic region Element with this editbox to copy text contents.
function me.EditBox:SetElement ( Element )
	if ( Element ) then
		self:SetParent( Element:GetParent() );
		self:SetAllPoints( Element );
		self:SetText( Element:GetText() or "" );
		self:Show();
		self:SetFocus();
		self:HighlightText();
	else
		self:Hide();
	end
end
--- Removes the mimic editbox if its target gets hidden.
function me.EditBox:OnHide ()
	self:ClearFocus();
	self:SetText( "" );
	self:Hide(); -- Hide when parent is hidden
end


--- Register context sensitive GUI Control to update when selection changes.
function me.Controls:Add ( Control )
	Control:SetParent( self );
	if ( #self == 0 ) then
		Control:SetPoint( "BOTTOMLEFT" );
	else
		Control:SetPoint( "LEFT", self[ #self ], "RIGHT" );
	end

	self[ #self + 1 ] = Control;
	if ( Control.OnSelect ) then
		local Selection = me.Table and me.Table:GetSelection();
		if ( Selection ) then
			Control:OnSelect( Selection:GetData() );
		else
			Control:OnSelect();
		end
	end
end




me.name = L.CONFIG_TITLE;
me.parent = _NPCScan.Config.name;
me:Hide();
me:SetScript( "OnShow", me.OnShow );

-- Pane title
local Title = me:CreateFontString( nil, "ARTWORK", "GameFontNormalLarge" );
Title:SetPoint( "TOPLEFT", 16, -16 );
Title:SetText( L.CONFIG_TITLE );
local SubText = me:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" );
SubText:SetPoint( "TOPLEFT", Title, "BOTTOMLEFT", 0, -8 );
SubText:SetPoint( "RIGHT", -32, 0 );
SubText:SetHeight( 32 );
SubText:SetJustifyH( "LEFT" );
SubText:SetJustifyV( "TOP" );
SubText:SetText( L.CONFIG_DESC );


-- Control panel for selected NPC
me.Controls:SetPoint( "BOTTOMLEFT", 16, 16 );
me.Controls:SetPoint( "RIGHT", -16, 0 );
me.Controls:SetHeight( 24 );


-- Place table
me.TableContainer:SetPoint( "TOPLEFT", SubText, -2, -28 );
me.TableContainer:SetPoint( "BOTTOMRIGHT", me.Controls, "TOPRIGHT" );
me.TableContainer:SetBackdrop( { bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]]; } );

me.EditBox:Hide();
me.EditBox:SetScript( "OnHide", me.EditBox.OnHide );
me.EditBox:SetScript( "OnEnterPressed", me.EditBox.OnHide );
me.EditBox:SetScript( "OnEscapePressed", me.EditBox.OnHide );


InterfaceOptions_AddCategory( me );