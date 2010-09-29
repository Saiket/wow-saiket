﻿--[[****************************************************************************
  * _NPCScan.Overlay by Saiket                                                 *
  * Locales/Locale-zhTW.lua - Localized string constants (zh-TW).              *
  ****************************************************************************]]


if ( GetLocale() ~= "zhTW" ) then
	return;
end


-- See http://wow.curseforge.com/addons/npcscan-overlay/localization/zhTW/
local Overlay = select( 2, ... );
Overlay.L = setmetatable( {
	NPCs = setmetatable( {
		[ 1140 ] = "刺喉龍族母",
		[ 5842 ] = "『跳躍者』塔克",
		[ 6581 ] = "暴掠龍族母",
		[ 14232 ] = "達爾特",
		[ 18684 ] = "無氏族的伯卡茲",
		[ 32491 ] = "時光流逝元龍",
		[ 33776 ] = "剛卓亞",
		[ 35189 ] = "史科爾",
		[ 38453 ] = "大角",
	}, { __index = Overlay.L.NPCs; } );

	CONFIG_ALPHA = "透明度",
	CONFIG_DESC = "設定在哪張地圖顯示怪物移動路徑。大部分的地圖插件都針對世界地圖做設定。",
	CONFIG_SHOWALL = "永遠顯示所有路徑",
	CONFIG_SHOWALL_DESC = "通常地圖上不會顯示非搜尋中的怪物的路徑圖。開啟這個選項將永遠顯示所有已知的路徑圖。",
	CONFIG_TITLE = "路徑圖",
	CONFIG_TITLE_STANDALONE = "_|cffCCCC88NPCScan|r.Overlay",
	MODULE_ALPHAMAP3 = "AlphaMap3 插件",
	MODULE_BATTLEFIELDMINIMAP = "顯示戰場迷你地圖",
	MODULE_MINIMAP = "小地圖",
	MODULE_RANGERING_DESC = "提示： 在有稀有怪的地圖才顯示距離環(例如主城跟冬握就不會顯示).",
	MODULE_RANGERING_FORMAT = "顯示大概 %d碼的偵測距離環",
	MODULE_WORLDMAP = "主要世界地圖",
	MODULE_WORLDMAP_KEY = "_|cffCCCC88NPCScan|r.Overlay",
	MODULE_WORLDMAP_KEY_FORMAT = "• %s",
}, { __index = Overlay.L; } );