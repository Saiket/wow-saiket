--[[****************************************************************************
  * _NPCScan.Overlay by Saiket                                                 *
  * Locales/Locale-frFR.lua - Localized string constants (fr-FR).              *
  ****************************************************************************]]


if ( GetLocale() ~= "frFR" ) then
	return;
end


-- See http://wow.curseforge.com/addons/npcscan-overlay/localization/frFR/
local Overlay = select( 2, ... );
Overlay.L = setmetatable( {
	NPCs = setmetatable( {
		[ 18684 ] = "Bro'Gaz Sans-clan",
		[ 32491 ] = "Proto-drake perdu dans le temps",
		[ 33776 ] = "Gondria",
		[ 35189 ] = "Skoll",
		[ 38453 ] = "Arcturis",
		[ 49822 ] = "Jadecroc",
		[ 49913 ] = "Dame LaLa",
		[ 50005 ] = "Pos�idus",
		[ 50009 ] = "Mobus",
		[ 50050 ] = "Shok'sharak",
		[ 50051 ] = "Clampant fant�me",
		[ 50052 ] = "Burgy Coeur-noir",
		[ 50053 ] = "Thartuk l'Exil�",
		[ 50056 ] = "Garr",
		[ 50057 ] = "Ailembrase",
		[ 50058 ] = "Terrorpene",
		[ 50059 ] = "Golgarok",
		[ 50060 ] = "Terborus",
		[ 50061 ] = "Xariona",
		[ 50062 ] = "Aeonaxx",
		[ 50063 ] = "Akma'hat",
		[ 50064 ] = "Cyrus le Noir",
		[ 50065 ] = "Armaglyptodon",
		[ 50085 ] = "Suzerain Fractefurie",
		[ 50086 ] = "Tarvus le Vil",
		[ 50089 ] = "Julak-Dram",
		[ 50138 ] = "Karoma",
		[ 50154 ] = "Madexx",
		[ 50159 ] = "Samba",
		[ 51071 ] = "Capitaine Florence",
		[ 51079 ] = "Capitaine Souillaile",
	}, { __index = Overlay.L.NPCs; } );

	CONFIG_ALPHA = "Transparence",
	CONFIG_DESC = "D�termine sur quelles cartes les trajets des monstres seront ajout�s. La plupart des addons modifiant la carte se contr�lent avec les options de la carte du monde.",
	CONFIG_SHOWALL = "Toujours afficher tous les trajets",
	CONFIG_SHOWALL_DESC = "Normalement, quand un monstre n'est pas recherch�, son trajet n'est pas affich� sur la carte. L'activation de ce param�tre affichera tous les trajets connus.",
	CONFIG_TITLE = "Superposition",
	CONFIG_TITLE_STANDALONE = "_|cffCCCC88NPCScan|r.Overlay",
	MODULE_ALPHAMAP3 = "AddOn AlphaMap3",
	MODULE_BATTLEFIELDMINIMAP = "Carte locale",
	MODULE_MINIMAP = "Minicarte",
	MODULE_RANGERING_DESC = "Note : le cercle de port�e n'apparait que dans les zones o� des rares sont recherch�s.",
	MODULE_RANGERING_FORMAT = "Aff. un cercle de %dyd approximant la port�e de d�tection",
	MODULE_WORLDMAP = "Carte du monde principale",
	MODULE_WORLDMAP_KEY_FORMAT = "� %s",
	MODULE_WORLDMAP_TOGGLE_DESC = "Si activ�, affiche les trajets de _|cffCCCC88NPCScan|r.Overlay des PNJs recherch�s.",
}, { __index = Overlay.L; } );