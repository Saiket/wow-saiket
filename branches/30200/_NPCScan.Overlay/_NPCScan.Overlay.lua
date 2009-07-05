--[[****************************************************************************
  * _NPCScan.Overlay by Saiket                                                 *
  * _NPCScan.Overlay.lua - Adds mob patrol paths to your map.                  *
  ****************************************************************************]]


local _NPCScan = _NPCScan;
local me = CreateFrame( "Frame" );
_NPCScan.Overlay = me;
me.Version = GetAddOnMetadata( "_NPCScan.Overlay", "Version" ):match( "^([%d.]+)" );

me.ModulesEnabled = {};
me.ModulesDisabled = {};

me.NPCMaps = {};
me.NPCsEnabled = {};

local TexturesUnused = {};
local TexturesUsed = {};




--[[****************************************************************************
  * Function: _NPCScan.Overlay:TextureDraw                                     *
  * Description: Sets a triangle texture's texcoords to a set of real coords.  *
  ****************************************************************************]]
do
	local Det, AF, BF, CD, CE;
	local function ApplyTransform( self, A, B, C, D, E, F )
		Det = A * E - B * D;
		AF, BF, CD, CE = A * F, B * F, C * D, C * E;

		self:SetTexCoord(
			( BF - CE ) / Det, ( CD - AF ) / Det,
			( BF - CE - B ) / Det, ( CD - AF + A ) / Det,
			( BF - CE + E ) / Det, ( CD - AF - D ) / Det,
			( BF - CE + E - B ) / Det, ( CD - AF - D + A ) / Det );
	end
	local MinX, MinY, WindowX, WindowY;
	local ABx, ABy, BCx, BCy;
	local ScaleX, ScaleY, ShearFactor, Sin, Cos;
	local Parent, Width, Height;
	local BorderScale, BorderOffset = 256 / 254, -1 / 256; -- Removes one-pixel transparent border
	function me:TextureDraw ( Ax, Ay, Bx, By, Cx, Cy )
		--[[ Transform parallelogram so its corners lie on the tri's points:
		1. Translate by BorderOffset to hide top and left transparent borders.
		2. Scale by BorderScale to push bottom and left transparent borders out.
		3. Scale to counter the effects of resizing the image.
		4. Translate to negate moving the image region relative to its parent.
		5. Rotate so point A lies on a line parallel to line BC.
		6. Scale X by the length of line BC, and Y by the length of the perpendicular line from BC to point A.
		7. Shear the image so its bottom left corner aligns with point A.
		]]
		ABx, ABy, BCx, BCy = Ax - Bx, Ay - By, Bx - Cx, By - Cy;
		ScaleX = ( BCx * BCx + BCy * BCy ) ^ 0.5;
		ScaleY = ( ABx * BCy - BCx * ABy ) / ScaleX;
		ShearFactor = -( ABx * BCx + ABy * BCy ) / ( ScaleX * ScaleX );
		Sin, Cos = BCy / ScaleX, -BCx / ScaleX;

		-- Note: The texture region is made as small as possible to improve framerates.
		MinX, MinY = min( Ax, Bx, Cx ), min( Ay, By, Cy );
		WindowX = max( Ax, Bx, Cx ) - MinX;
		WindowY = max( Ay, By, Cy ) - MinY;

		Parent = self:GetParent();
		Width, Height = Parent:GetWidth(), Parent:GetHeight();
		self:SetPoint( "TOPLEFT", MinX * Width, -MinY * Height );
		self:SetWidth( WindowX * Width );
		self:SetHeight( WindowY * Height );

		WindowX = BorderScale / WindowX;
		WindowY = BorderScale / WindowY;
		ApplyTransform( self,
			WindowX * Cos * ScaleX,
			WindowX * ( Cos * ScaleX * ShearFactor + Sin * ScaleY ),
			WindowX * ( Bx - MinX ) + BorderOffset,
			WindowY * -Sin * ScaleX,
			WindowY * ( Cos * ScaleY - Sin * ScaleX * ShearFactor ),
			WindowY * ( By - MinY ) + BorderOffset );
	end
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay:TextureAdd                                      *
  * Description: Gets an unused texture and adds it to the given frame.        *
  ****************************************************************************]]
function me:TextureAdd ( ID )
	local Texture = TexturesUnused[ #TexturesUnused ];
	if ( Texture ) then
		TexturesUnused[ #TexturesUnused ] = nil;
		Texture:SetParent( self );
		Texture:Show();
	else
		Texture = self:CreateTexture();
		Texture:SetTexture( [[Interface\AddOns\_NPCScan.Overlay\Skin\Triangle]] );
	end
	Texture.ID = ID;

	local UsedCache = TexturesUsed[ self ];
	if ( not UsedCache ) then
		UsedCache = {};
		TexturesUsed[ self ] = UsedCache;
	end
	UsedCache[ #UsedCache + 1 ] = Texture;
	return Texture;
end


--[[****************************************************************************
  * Function: _NPCScan.Overlay:PolygonRemoveAll                                *
  * Description: Removes all polygon artwork from a frame.                     *
  ****************************************************************************]]
function me:PolygonRemoveAll ()
	if ( TexturesUsed[ self ] ) then
		for _, Texture in ipairs( TexturesUsed[ self ] ) do
			TexturesUnused[ #TexturesUnused + 1 ] = Texture;
			Texture:Hide();
		end
		wipe( TexturesUsed[ self ] );
	end
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay:PolygonRemove                                   *
  * Description: Reclaims all textures associated with a polygon set ID.       *
  ****************************************************************************]]
function me:PolygonRemove ( ID )
	local UsedCache = TexturesUsed[ self ];
	if ( UsedCache ) then
		for Index = #UsedCache, 1, -1 do
			local Texture = UsedCache[ Index ];
			if ( Texture.ID == ID ) then
				tremove( UsedCache, Index );
				TexturesUnused[ #TexturesUnused + 1 ] = Texture;
				Texture:Hide();
			end
		end
	end
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay:PolygonAdd                                      *
  * Description: Draws the given polygon onto a frame.                         *
  ****************************************************************************]]
do
	local Max = 2 ^ 16 - 1;
	local function Decode ( Ax1, Ax2, Ay1, Ay2, Bx1, Bx2, By1, By2, Cx1, Cx2, Cy1, Cy2 )
		return
			( Ax1 * 256 + Ax2 ) / Max, ( Ay1 * 256 + Ay2 ) / Max,
			( Bx1 * 256 + Bx2 ) / Max, ( By1 * 256 + By2 ) / Max,
			( Cx1 * 256 + Cx2 ) / Max, ( Cy1 * 256 + Cy2 ) / Max;
	end
	function me:PolygonAdd ( ID, PolyData, Layer, R, G, B, A )
		for Index = 1, #PolyData, 12 do
			local Texture = me.TextureAdd( self, ID );
			me.TextureDraw( Texture, Decode( PolyData:byte( Index, Index + 11 ) ) );
			Texture:SetVertexColor( R, G, B, A );
			Texture:SetDrawLayer( Layer );
		end
	end
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay:PolygonSetZone                                  *
  * Description: Repaints a given zone's polygons on the frame.                *
  ****************************************************************************]]
do
	local Colors = {
		RED_FONT_COLOR,
		RAID_CLASS_COLORS.PALADIN,
		GREEN_FONT_COLOR,
		RAID_CLASS_COLORS.MAGE,
		RAID_CLASS_COLORS.DRUID,
	};
	function me:PolygonSetZone ( MapName, Layer )
		me.PolygonRemoveAll( self );

		local MapData = me.PathData[ MapName ];
		if ( MapData ) then
			local ColorIndex = 0;

			for NPCID, PolyData in pairs( MapData ) do
				ColorIndex = ColorIndex + 1;
				if ( me.NPCsEnabled[ NPCID ] ) then
					local Color = Colors[ ( ColorIndex - 1 ) % #Colors + 1 ];
					me.PolygonAdd( self, NPCID, PolyData, Layer, Color.r, Color.g, Color.b, 0.5 );
				end
			end
		end
	end
end




--[[****************************************************************************
  * Function: _NPCScan.Overlay.ModuleRegister                                  *
  * Description: Registers a canvas module to paint polygons on.               *
  ****************************************************************************]]
function me.ModuleRegister ( Name, Module )
	me.ModulesDisabled[ Name ] = Module;
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay.ModuleEnable                                    *
  ****************************************************************************]]
function me.ModuleEnable ( Name )
	local Module = me.ModulesDisabled[ Name ];
	if ( Module ) then
		me.ModulesDisabled[ Name ] = nil;
		me.ModulesEnabled[ Name ] = Module;
		Module:Enable();
		Module:Update();
		return true;
	end
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay.ModuleDisable                                   *
  ****************************************************************************]]
function me.ModuleDisable ( Name )
	local Module = me.ModulesEnabled[ Name ];
	if ( Module ) then
		me.ModulesEnabled[ Name ] = nil;
		me.ModulesDisabled[ Name ] = Module;
		Module:Disable();
		return true;
	end
end




--[[****************************************************************************
  * Function: _NPCScan.Overlay.NPCEnable                                       *
  ****************************************************************************]]
function me.NPCEnable ( ID )
	local Map = me.NPCMaps[ ID ];
	if ( Map and not me.NPCsEnabled[ ID ] ) then
		me.NPCsEnabled[ ID ] = true;

		for Name, Module in pairs( me.ModulesEnabled ) do
			Module:Update( Map );
		end
		return true;
	end
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay.NPCDisable                                      *
  ****************************************************************************]]
function me.NPCDisable ( ID )
	if ( me.NPCsEnabled[ ID ] ) then
		me.NPCsEnabled[ ID ] = nil;

		local Map = me.NPCMaps[ ID ];
		for Name, Module in pairs( me.ModulesEnabled ) do
			Module:Update( Map );
		end
		return true;
	end
end




--[[****************************************************************************
  * Function: _NPCScan.Overlay:ADDON_LOADED                                    *
  ****************************************************************************]]
function me:ADDON_LOADED ( Event, AddOn )
	if ( AddOn:lower() == "_npcscan.overlay" ) then
		me:UnregisterEvent( Event );
		me[ Event ] = nil;

		-- Build a reverse lookup of NPC IDs to zones
		for ZoneName, ZoneData in pairs( me.PathData ) do
			for ID in pairs( ZoneData ) do
				me.NPCMaps[ ID ] = ZoneName;
			end
		end

		-- Enable all modules
		for Name in pairs( me.ModulesDisabled ) do
			me.ModuleEnable( Name );
		end
	end
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay:OnEvent                                         *
  ****************************************************************************]]
me.OnEvent = _NPCScan.OnEvent;




--------------------------------------------------------------------------------
-- Function Hooks / Execution
-----------------------------

do
	me:SetScript( "OnEvent", me.OnEvent );
	me:RegisterEvent( "ADDON_LOADED" );
end
