--[[****************************************************************************
  * _NPCScan by Saiket                                                         *
  * Locales/Locale-zhTW.lua - Localized string constants (zh-TW) by s8095324.  *
  ****************************************************************************]]


if ( GetLocale() == "zhTW" ) then
	local LDQuo, RDQuo = GRAY_FONT_COLOR_CODE.."\226\128\156", "\226\128\157|r";

	_NPCScanLocalization = setmetatable( {
		NPCS = setmetatable( {
			[ 18684 ] = "無氏族的伯卡茲"; -- Bro'Gaz the Clanless
			[ 32491 ] = "時光流逝元龍"; -- Time-Lost Proto Drake
			[ 33776 ] = "剛卓亞"; -- Gondria
			[ 35189 ] = "史科爾"; -- Skoll
			[ 38453 ] = "大角"; -- Arcturis
		}, { __index = _NPCScanLocalization.NPCS; } );

		FOUND_FORMAT = "發現 "..LDQuo.."%s"..RDQuo.."!";
		FOUND_TAMABLE_FORMAT = "發現 "..LDQuo.."%s"..RDQuo.."!  "..RED_FONT_COLOR_CODE.."(Note: Tamable mob, may only be a pet.)|r";
		BUTTON_FOUND = "NPC 發現!";


		CONFIG_DESC = "這些選項讓你設定當_NPCScan發現稀有NPC時提醒您的方式。";

		CONFIG_ALERT = "警報選項";

		CONFIG_TEST = "測試發現警報";
		CONFIG_TEST_DESC = "模擬了 "..LDQuo.."NPC 發現"..RDQuo.." 警報，讓你知道該怎麼看出來的。";
		CONFIG_TEST_NAME = "你! (測試)";


		SEARCH_TITLE = "搜尋";

		SEARCH_NAME = "名稱:";
		SEARCH_COMPLETED = "完成";


		CMD_HELP = "指令 "..LDQuo.."/npcscan add <NpcID> <Name>"..RDQuo..", "..LDQuo.."/npcscan remove <Name>"..RDQuo..", "..LDQuo.."/npcscan cache"..RDQuo.." to list cached mobs, and simply "..LDQuo.."/npcscan"..RDQuo.." for the options menu.";
	}, { __index = _NPCScanLocalization; } );
end