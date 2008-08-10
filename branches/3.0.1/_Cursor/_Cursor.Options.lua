--[[****************************************************************************
  * _Cursor by Saiket                                                          *
  * _Cursor.Options.lua - Adds an options panel to the default UI config menu. *
  ****************************************************************************]]


local _Cursor = _Cursor;
local L = _CursorLocalization;
local me = CreateFrame( "Frame" );
_Cursor.Options = me;


local SetsPanel = CreateFrame( "Frame", "_CursorOptionsSets", me, "OptionFrameBoxTemplate" );
me.SetsPanel = SetsPanel;

local ModelsPanel = CreateFrame( "Frame", nil, me, "OptionFrameBoxTemplate" );
me.ModelsPanel = ModelsPanel;
ModelsPanel.ApplyButton = CreateFrame( "Button", nil, ModelsPanel, "UIPanelButtonGrayTemplate" );
ModelsPanel.Enabled = CreateFrame( "CheckButton", "_CursorOptionsEnabled", ModelsPanel, "InterfaceOptionsCheckButtonTemplate" );
ModelsPanel.Preview = CreateFrame( "Frame", nil, ModelsPanel );
ModelsPanel.X = CreateFrame( "Slider", "_CursorOptionsX", ModelsPanel.Preview, "OptionsSliderTemplate" );
ModelsPanel.Y = CreateFrame( "Slider", "_CursorOptionsY", ModelsPanel.Preview, "OptionsSliderTemplate" );
ModelsPanel.Scale = CreateFrame( "Slider", "_CursorOptionsScale", ModelsPanel.Preview, "OptionsSliderTemplate" );
ModelsPanel.Facing = CreateFrame( "Slider", "_CursorOptionsFacing", ModelsPanel.Preview, "OptionsSliderTemplate" );
ModelsPanel.Path = CreateFrame( "EditBox", "_CursorOptionsPath", ModelsPanel, "InputBoxTemplate" );

local TabsUnused = {};
ModelsPanel.TabsUnused = TabsUnused;
local TabsUsed = {};
ModelsPanel.TabsUsed = TabsUsed;

local Preset = {};
me.Preset = Preset;




--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel.GetTab                               *
  * Description: Gets an unused tab frame.                                     *
  ****************************************************************************]]
do
	local TabID = 0;
	function ModelsPanel.GetTab ()
		local Tab = next( TabsUnused );
		if ( not Tab ) then
			TabID = TabID + 1;
			Tab = CreateFrame( "Button", "_CursorOptionsTab"..TabID, ModelsPanel, "OptionsFrameTabButtonTemplate" );
			Tab:Hide();
			Tab:SetScript( "OnClick", ModelsPanel.SetTab );
			PanelTemplates_DeselectTab( Tab );
		end

		TabsUnused[ Tab ] = true;
		return Tab;
	end
end
--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel:TabEnable                            *
  * Description: Ties a tab to a settings table.                               *
  ****************************************************************************]]
function ModelsPanel:TabEnable ( Settings )
	if ( TabsUsed[ self ] ) then
		ModelsPanel.TabDisable( self );
	end

	TabsUnused[ self ] = nil;
	TabsUsed[ self ] = Settings;

	self:SetText( L[ Settings.Name ] );
	self:Show();
end
--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel:TabDisable                           *
  * Description: Frees up a tab.                                               *
  ****************************************************************************]]
function ModelsPanel:TabDisable ()
	if ( TabsUsed[ self ] ) then
		TabsUsed[ self ] = nil;
		TabsUnused[ self ] = true;

		self:Hide();
	end
end
--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel:SetTab                               *
  * Description: Highlights the tab and fills in the data.                     *
  ****************************************************************************]]
function ModelsPanel:SetTab ()
	if ( ModelsPanel.Selected ) then
		PanelTemplates_DeselectTab( ModelsPanel.Selected );
	end
	ModelsPanel.Selected = self;

	if ( self ) then
		PanelTemplates_SelectTab( self );
		local Settings = TabsUsed[ self ];

		ModelsPanel[ Settings.Enabled and "EnableControls" or "DisableControls" ]();
		OptionsFrame_EnableCheckBox( ModelsPanel.Enabled );
		ModelsPanel.Enabled:SetChecked( Settings.Enabled );

		ModelsPanel.X:SetValue( Settings.X or 0 );
		ModelsPanel.Y:SetValue( Settings.Y and -Settings.Y or 0 ); -- Backwards
		ModelsPanel.Scale:SetValue( Settings.Scale or 1.0 );
		ModelsPanel.Facing:SetValue( Settings.Facing or 0 );
		-- NOTE(Set controls to match settings.)

		-- NOTE(Use a generic "SetType" function that accepts a type and a value, and handles updates.)
		if ( Settings.Type == "CUSTOM" ) then
			-- NOTE(Hide presets list; replace with edit box.)
		else
			-- NOTE(Hide edit box; replace with presets list.)
			Preset.Name, Preset.Path, Preset.Scale, Preset.Facing, Preset.X, Preset.Y
				= ( "|" ):split( _Cursor.Presets[ Settings.Type ][ Settings.Value ] );
		end

		ModelsPanel.Preview.Cursor:Show();
		ModelsPanel.Preview:SetScript( "OnUpdate", ModelsPanel.Preview.OnUpdate );
		ModelsPanel.Preview.Update();
	else
		ModelsPanel.DisableControls();

		OptionsFrame_DisableCheckBox( ModelsPanel.Enabled );
		ModelsPanel.Enabled:SetChecked( false );
		ModelsPanel.Preview.Cursor:Hide();
		ModelsPanel.Preview:SetScript( "OnUpdate", nil );
		ModelsPanel.Preview.Model:ClearModel();
		ModelsPanel.Path:SetText( "" );
	end
end


--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel.EnableControls                       *
  * Description: Enables the model controls.                                   *
  ****************************************************************************]]
do
	local function EnableSlider ( self )
		OptionsFrame_EnableSlider( self );
		self:EnableMouse( true );
	end
	function ModelsPanel.EnableControls ()
		ModelsPanel.Preview:EnableMouse( true );
		SetDesaturation( ModelsPanel.Preview.Backdrop, false );
		EnableSlider( ModelsPanel.X );
		EnableSlider( ModelsPanel.Y );
		EnableSlider( ModelsPanel.Scale );
		EnableSlider( ModelsPanel.Facing );

		ModelsPanel.Path:EnableMouse( true );
		local Color = HIGHLIGHT_FONT_COLOR;
		ModelsPanel.Path:SetTextColor( Color.r, Color.g, Color.b );
		Color = NORMAL_FONT_COLOR;
		ModelsPanel.Path.Text:SetTextColor( Color.r, Color.g, Color.b );

		-- NOTE(Enable controls.)
	end
end
--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel.DisableControls                      *
  * Description: Disables the model controls.                                  *
  ****************************************************************************]]
do
	local function DisableSlider ( self )
		OptionsFrame_DisableSlider( self );
		self:EnableMouse( false );
	end
	function ModelsPanel.DisableControls ()
		ModelsPanel.Preview:EnableMouse( false );
		SetDesaturation( ModelsPanel.Preview.Backdrop, true );
		DisableSlider( ModelsPanel.X );
		DisableSlider( ModelsPanel.Y );
		DisableSlider( ModelsPanel.Scale );
		DisableSlider( ModelsPanel.Facing );

		ModelsPanel.Path:EnableMouse( false );
		local Color = GRAY_FONT_COLOR;
		ModelsPanel.Path:SetTextColor( Color.r, Color.g, Color.b );
		ModelsPanel.Path.Text:SetTextColor( Color.r, Color.g, Color.b );
		ModelsPanel.Path:ClearFocus();

		-- NOTE(Disable controls and gray them out.)
	end
end




--[[****************************************************************************
  * Function: _Cursor.Options:ControlOnEnter                                   *
  * Description: Shows the control's tooltip.                                  *
  ****************************************************************************]]
function me:ControlOnEnter ()
	GameTooltip:SetOwner( self, "ANCHOR_TOPLEFT" );
	GameTooltip:SetText( self.tooltipText, nil, nil, nil, nil, 1 );
end
--[[****************************************************************************
  * Function: _Cursor.Options:ControlOnLeave                                   *
  * Description: Hides the control's tooltip.                                  *
  ****************************************************************************]]
function me:ControlOnLeave ()
	GameTooltip:Hide();
end




--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel.Enabled.OnClick                      *
  * Description: Toggles whether the model is enabled or not.                  *
  ****************************************************************************]]
function ModelsPanel.Enabled:OnClick ()
	local Checked = not not self:GetChecked();
	local Settings = TabsUsed[ ModelsPanel.Selected ];
	Settings.Enabled = Checked;
	if ( Checked ) then
		ModelsPanel.EnableControls();
	else
		ModelsPanel.DisableControls();
	end
	PlaySound( Checked and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff" );
end


--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel.Preview.OnMouseUp                    *
  * Description: Cycles animation speeds for the model preview.                *
  ****************************************************************************]]
function ModelsPanel.Preview:OnMouseUp ()
	self.Rate = self.Rate >= math.pi * 2 and 0 or self.Rate + math.pi;
	PlaySound( "igMainMenuOption" );
end
--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel.Preview.OnUpdate                     *
  * Description: Animates the preview model and maintains its scale.           *
  ****************************************************************************]]
do
	local sin = math.sin;
	local cos = math.cos;
	local type = type;
	local Hypotenuse = ( GetScreenWidth() ^ 2 + GetScreenHeight() ^ 2 ) ^ 0.5 * UIParent:GetEffectiveScale();
	local Step = 0;
	local Model, Dimension, MaxPosition, X, Y;
	function ModelsPanel.Preview:OnUpdate ( Elapsed )
		Model = self.Model;
		if ( self.ShouldUpdate ) then
			self.ShouldUpdate = false;

			local Settings = TabsUsed[ ModelsPanel.Selected ];
			Model.X = Settings.X or 0;
			Model.Y = Settings.Y or 0;
			local Scale = Settings.Scale or 1.0;
			local Facing = Settings.Facing or 0;
			local Path;
			if ( Settings.Type == "CUSTOM" ) then
				Path = Settings.Value;
			else
				Path = Preset.Path;
				Model.X = Model.X + Preset.X;
				Model.Y = Model.Y + Preset.Y;
				Scale = Scale * Preset.Scale;
				Facing = Facing + Preset.Facing;
			end

			local CurrentModel = Model:GetModel();
			if ( type( CurrentModel ) ~= "string" or Path:lower() ~= CurrentModel:sub( 1, -4 ):lower() ) then -- Compare without *.m2 extension
				Model:SetModel( Path..".mdx" );
			end
			Model:SetModelScale( Scale );
			Model:SetFacing( Facing );
		end

		Step = Step + Elapsed * self.Rate;
		Model:SetScale( 1 / self:GetEffectiveScale() );

		Dimension = Model:GetRight() - Model:GetLeft();
		MaxPosition = Dimension / Hypotenuse;
		X = 0.1 + 0.6 * ( cos( Step / 2 ) + 1 ) / 2;
		Y = 0.3 + 0.6 * ( sin( Step ) + 1 ) / 2;
		Model:SetPosition( ( X + Model.X / Dimension ) * MaxPosition, ( Y + Model.Y / Dimension ) * MaxPosition, 0 );
		self.Cursor:SetPoint( "TOPLEFT", Model, "BOTTOMLEFT", Dimension * X, Dimension * Y );
	end
end
--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel.Preview.Update                       *
  * Description: Requests a refresh of the model preview window.               *
  ****************************************************************************]]
function ModelsPanel.Preview.Update ()
	ModelsPanel.Preview.ShouldUpdate = true;
end


--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel.X:OnValueChanged                     *
  * Description: Saves X-offset value.                                         *
  ****************************************************************************]]
function ModelsPanel.X:OnValueChanged ( Value )
	local Settings = TabsUsed[ ModelsPanel.Selected ];
	if ( Settings ) then
		Settings.X = Value ~= 0 and Value or nil;
		ModelsPanel.Preview.Update();
	end
end
--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel.Y:OnValueChanged                     *
  * Description: Saves Y-offset value.                                         *
  ****************************************************************************]]
function ModelsPanel.Y:OnValueChanged ( Value )
	local Settings = TabsUsed[ ModelsPanel.Selected ];
	if ( Settings ) then
		Settings.Y = Value ~= 0 and -Value or nil;
		ModelsPanel.Preview.Update();
	end
end
--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel.Scale:OnValueChanged                 *
  * Description: Saves scale value.                                            *
  ****************************************************************************]]
function ModelsPanel.Scale:OnValueChanged ( Value )
	local Settings = TabsUsed[ ModelsPanel.Selected ];
	if ( Settings ) then
		Settings.Scale = Value ~= 1.0 and Value or nil;
		ModelsPanel.Preview.Update();
	end
end
--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel.Facing:OnValueChanged                *
  * Description: Saves facing value.                                           *
  ****************************************************************************]]
function ModelsPanel.Facing:OnValueChanged ( Value )
	local Settings = TabsUsed[ ModelsPanel.Selected ];
	if ( Settings ) then
		Settings.Facing = ( Value ~= 0 and Value ~= math.pi * 2 ) and Value or nil;
		ModelsPanel.Preview.Update();
	end
end
--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel.Path:OnEnterPressed                  *
  * Description: Saves custom path value.                                      *
  ****************************************************************************]]
function ModelsPanel.Path:OnEnterPressed ()
	local Settings = TabsUsed[ ModelsPanel.Selected ];
	local Value = self:GetText();
	local Extension = Value:match( "%.[^%.]+$" );
	if ( Extension ) then
		Extension = Extension:upper();
		if ( Extension == ".M2" or Extension == ".MDX" ) then
			Value = Value:sub( 1, -#Extension - 1 ); -- Remove extension
			self:SetText( Value );
		end
	end

	Settings.Value = Value;
	ModelsPanel.Preview.Update();
	self:ClearFocus();
end
--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel.Path:OnEscapePressed                 *
  * Description: Cancels custom path value.                                    *
  ****************************************************************************]]
function ModelsPanel.Path:OnEscapePressed ()
	local Settings = TabsUsed[ ModelsPanel.Selected ];
	self:SetText( Settings.Value );
	self:ClearFocus();
end

--[[****************************************************************************
  * Function: _Cursor.Options.ModelsPanel.ApplyButton:OnClick                  *
  * Description: Updates the actual cursor models.                             *
  ****************************************************************************]]
function ModelsPanel.ApplyButton:OnClick ()
	_Cursor.Update();
end




--[[****************************************************************************
  * Function: _Cursor.Options:OnHide                                           *
  * Description: Updates the actual cursor models when settings are closed.    *
  ****************************************************************************]]
function me:OnHide ()
	_Cursor.Update();
end
--[[****************************************************************************
  * Function: _Cursor.Options.Update                                           *
  * Description: Full update that syncronizes tabs to actual saved settings.   *
  ****************************************************************************]]
function me.Update ()
	for Tab in pairs( TabsUsed ) do
		ModelsPanel.TabDisable( Tab );
	end

	local LastTab;
	for Index, Settings in ipairs( _CursorOptionsCharacter.Models ) do
		local Tab = ModelsPanel.GetTab( Settings );

		ModelsPanel.TabEnable( Tab, Settings );
		if ( LastTab ) then
			Tab:SetPoint( "BOTTOMLEFT", LastTab, "BOTTOMRIGHT", -16, 0 );
		else
			Tab:SetPoint( "BOTTOMLEFT", ModelsPanel, "TOPLEFT", 6, -2 );
			ModelsPanel.SetTab( Tab );
		end
		LastTab = Tab;
	end
	if ( not LastTab ) then -- Has no models
		ModelsPanel.SetTab( nil );
	end
end




--------------------------------------------------------------------------------
-- Function Hooks / Execution
-----------------------------

do
	me.name = L.OPTIONS_TITLE;
	me:Hide();
	me:SetScript( "OnHide", me.OnHide );


	-- Pane title
	me.Title = me:CreateFontString( nil, "ARTWORK", "GameFontNormalLarge" );
	me.Title:SetPoint( "TOPLEFT", 16, -16 );
	me.Title:SetText( L.OPTIONS_TITLE );
	local SubText = me:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" );
	me.SubText = SubText;
	SubText:SetPoint( "TOPLEFT", me.Title, "BOTTOMLEFT", 0, -8 );
	SubText:SetPoint( "RIGHT", -32, 0 );
	SubText:SetHeight( 32 );
	SubText:SetJustifyH( "LEFT" );
	SubText:SetJustifyV( "TOP" );
	SubText:SetText( L.OPTIONS_DESC );




	-- Sets pane
	_G[ SetsPanel:GetName().."Title" ]:SetText( L.OPTIONS.SETS );
	SetsPanel:SetPoint( "TOPLEFT", SubText, "BOTTOMLEFT", -2, -16 );
	SetsPanel:SetPoint( "RIGHT", -14, 0 );
	SetsPanel:SetHeight( 96 );




	-- Models tabbed pane
	ModelsPanel:SetPoint( "TOPLEFT", SetsPanel, "BOTTOMLEFT", 0, -32 );
	ModelsPanel:SetPoint( "BOTTOMRIGHT", -14, 16 );


	-- Apply button
	local ApplyButton = ModelsPanel.ApplyButton;
	ApplyButton:SetScript( "OnClick", ApplyButton.OnClick );
	ApplyButton:SetPoint( "BOTTOMRIGHT", ModelsPanel, "TOPRIGHT", 0, 2 );
	ApplyButton:SetWidth( 64 );
	ApplyButton:SetHeight( 16 );
	ApplyButton:SetText( L.OPTIONS.APPLY );

	-- Enable button
	local Enabled = ModelsPanel.Enabled;
	Enabled:SetPoint( "TOPLEFT", 16, -8 );
	Enabled:SetScale( 0.75 );
	Enabled:SetScript( "OnClick", Enabled.OnClick );
	Enabled.tooltipText = L.OPTIONS.ENABLED_DESC;
	_G[ Enabled:GetName().."Text" ]:SetText( L.OPTIONS.ENABLED );

	-- Preview window
	local Preview = ModelsPanel.Preview;
	Preview:SetPoint( "TOPRIGHT", -16, -8 );
	Preview:SetWidth( 96 );
	Preview:SetHeight( 96 );
	Preview:SetBackdrop( {
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border"; edgeSize = 16;
	} );
	Preview:SetScript( "OnMouseUp", Preview.OnMouseUp );
	Preview:SetScript( "OnEnter", me.ControlOnEnter );
	Preview:SetScript( "OnLeave", me.ControlOnLeave );
	Preview.Rate = math.pi;
	Preview.tooltipText = L.OPTIONS.PREVIEW_DESC;

	local Backdrop = Preview:CreateTexture( nil, "BACKGROUND" );
	Preview.Backdrop = Backdrop;
	Backdrop:SetPoint( "TOPRIGHT", -4, -4 );
	Backdrop:SetPoint( "BOTTOMLEFT", 4, 4 );
	Backdrop:SetTexture( "textures\\ShaneCube.blp" );
	Backdrop:SetGradient( "VERTICAL", 0.5, 0.5, 0.5, 0.25, 0.25, 0.25 );

	Preview.Model = CreateFrame( "Model", nil, Preview );
	Preview.Model:SetAllPoints( Backdrop );

	local Cursor = Preview.Model:CreateTexture( nil, "OVERLAY" );
	Preview.Cursor = Cursor;
	Cursor:SetWidth( 24 );
	Cursor:SetHeight( 24 );
	Cursor:SetTexture( "Interface\\Cursor\\Point.blp" );
	Cursor:SetVertexColor( 0.4, 0.4, 0.4 );

	-- X-axis slider
	local X = ModelsPanel.X;
	X:SetPoint( "LEFT", Preview, "BOTTOMLEFT" );
	X:SetPoint( "RIGHT", Preview );
	X:SetHeight( 14 );
	X:SetScale( 0.8 );
	X:SetMinMaxValues( -16, 16 );
	X:SetScript( "OnValueChanged", X.OnValueChanged );
	X.tooltipText = L.OPTIONS[ "X_DESC" ];
	local Text = _G[ X:GetName().."Low" ];
	Text:SetText( -16 );
	Text:ClearAllPoints();
	Text:SetPoint( "LEFT" );
	Text = _G[ X:GetName().."High" ];
	Text:SetText( 16 );
	Text:ClearAllPoints();
	Text:SetPoint( "RIGHT" );

	-- Y-axis slider
	local Y = ModelsPanel.Y;
	Y:SetOrientation( "VERTICAL" );
	Y:SetPoint( "TOP", Preview, "TOPLEFT" );
	Y:SetPoint( "BOTTOM", Preview );
	Y:SetWidth( 10 );
	Y:SetScale( 0.8 );
	Y:SetThumbTexture( "Interface\\Buttons\\UI-SliderBar-Button-Vertical" );
	Y:SetMinMaxValues( -16, 16 );
	Y:SetScript( "OnValueChanged", Y.OnValueChanged );
	Y.tooltipText = L.OPTIONS[ "Y_DESC" ];
	Text = _G[ Y:GetName().."Low" ];
	Text:SetText( -16 );
	Text:ClearAllPoints();
	Text:SetPoint( "BOTTOM", 0, 6 );
	Text = _G[ Y:GetName().."High" ];
	Text:SetText( 16 );
	Text:ClearAllPoints();
	Text:SetPoint( "TOP", 0, -2 );

	-- Scale slider
	local Scale = ModelsPanel.Scale;
	Scale:SetPoint( "LEFT", Y );
	Scale:SetPoint( "RIGHT", Preview );
	Scale:SetPoint( "TOP", X, "BOTTOM", 0, -8 );
	Scale:SetMinMaxValues( 1 / 2, 4 );
	Scale:SetScript( "OnValueChanged", Scale.OnValueChanged );
	Scale.tooltipText = L.OPTIONS[ "SCALE_DESC" ];
	_G[ Scale:GetName().."Low" ]:SetText( 0.5 );
	_G[ Scale:GetName().."High" ]:SetText( 4 );
	Text = _G[ Scale:GetName().."Text" ];
	Text:SetText( L.OPTIONS.SCALE );
	Text:SetPoint( "BOTTOM", Scale, "TOP", 0, -2 );

	-- Facing slider
	local Facing = ModelsPanel.Facing;
	Facing:SetPoint( "TOPLEFT", Scale, "BOTTOMLEFT", 0, -8 );
	Facing:SetPoint( "RIGHT", Scale );
	Facing:SetMinMaxValues( 0, math.pi * 2 );
	Facing:SetScript( "OnValueChanged", Facing.OnValueChanged );
	Facing.tooltipText = L.OPTIONS[ "FACING_DESC" ];
	_G[ Facing:GetName().."Low" ]:SetText( L.OPTIONS.FACING_LOW );
	_G[ Facing:GetName().."High" ]:SetText( L.OPTIONS.FACING_HIGH );
	Text = _G[ Facing:GetName().."Text" ];
	Text:SetText( L.OPTIONS.FACING );
	Text:SetPoint( "BOTTOM", Facing, "TOP", 0, -2 );

	-- Path editbox
	local Path = ModelsPanel.Path;
	Path:SetPoint( "BOTTOMLEFT", 16, 8 );
	Path:SetPoint( "RIGHT", Facing, "LEFT", -16, 0 );
	Path:SetHeight( 20 );
	Path:SetAutoFocus( false );
	Path:SetScript( "OnEnterPressed", Path.OnEnterPressed );
	Path:SetScript( "OnEscapePressed", Path.OnEscapePressed );
	Path:SetScript( "OnEnter", me.ControlOnEnter );
	Path:SetScript( "OnLeave", me.ControlOnLeave );
	Path.tooltipText = L.OPTIONS[ "PATH_DESC" ];
	Text = Path:CreateFontString( nil, "ARTWORK", "GameFontNormalSmall" );
	Path.Text = Text;
	Text:SetPoint( "BOTTOMLEFT", Path, "TOPLEFT", -6, 0 );
	Text:SetText( L.OPTIONS.PATH );




	me.Update();

	InterfaceOptions_AddCategory( me );
end
