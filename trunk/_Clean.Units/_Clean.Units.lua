--[[****************************************************************************
  * _Clean.Units by Saiket                                                     *
  * _Clean.Units.lua - Modifies the default unit frames.                       *
  ****************************************************************************]]


local _Clean = _Clean;
local me = CreateFrame( "Frame" );
_Clean.Units = me;

me.DropDown = CreateFrame( "Frame", "_CleanUnitsDropDown", UIParent, "UIDropDownMenuTemplate" );




--[[****************************************************************************
  * Function: _Clean.Units.DropDown:initialize                                 *
  * Description: Constructs the unit popup menu.                               *
  ****************************************************************************]]
function me.DropDown:initialize ()
	local UnitID = self.unit or "player";
	local Which, Name, ID;

	if ( UnitIsUnit( UnitID, "player" ) ) then
		Which = "SELF";
	elseif ( UnitIsUnit( UnitID, "pet" ) ) then
		Which = "PET";
	elseif ( UnitIsPlayer( UnitID ) ) then
		ID = UnitInRaid( UnitID );
		if ( ID ) then
			Which = "RAID_PLAYER";
		elseif ( UnitInParty( UnitID ) ) then
			Which = "PARTY";
		else
			Which = "PLAYER";
		end
	else
		Which = "RAID_TARGET_ICON";
		Name = RAID_TARGET_ICON;
	end
	if ( Which ) then
		UnitPopup_ShowMenu( self, Which, UnitID, Name, ID );
	end
end
--[[****************************************************************************
  * Function: _Clean.Units:ShowGenericMenu                                     *
  * Description: Adds a unit popup based on the unit.                          *
  ****************************************************************************]]
function me:ShowGenericMenu ( UnitID )
	HideDropDownMenu( 1 );

	me.DropDown.unit = UnitID or SecureButton_GetUnit( self );

	if ( me.DropDown.unit ) then
		ToggleDropDownMenu( 1, nil, me.DropDown, "cursor" );
	end
end


--[[****************************************************************************
  * Function: _Clean.Units:PLAYER_TARGET_CHANGED                               *
  ****************************************************************************]]
function me:PLAYER_TARGET_CHANGED ( Event )
	PlaySound( UnitExists( Event == "PLAYER_FOCUS_CHANGED" and "focus" or "target" ) and "igCharacterSelect" or "igCharacterDeselect" );
end
--[[****************************************************************************
  * Function: _Clean.Units:PLAYER_FOCUS_CHANGED                                *
  ****************************************************************************]]
me.PLAYER_FOCUS_CHANGED = me.PLAYER_TARGET_CHANGED;




--------------------------------------------------------------------------------
-- Function Hooks / Execution
-----------------------------

do
	me:SetScript( "OnEvent", _Clean.OnEvent );
	me:RegisterEvent( "PLAYER_TARGET_CHANGED" );
	me:RegisterEvent( "PLAYER_FOCUS_CHANGED" );

	tinsert( UnitPopupFrames, me.DropDown:GetName() );
	UIDropDownMenu_Initialize( me.DropDown, me.DropDown.initialize, "MENU" );
end