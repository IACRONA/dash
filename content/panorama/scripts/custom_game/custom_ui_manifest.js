hidden = false;

GameUI.CustomUIConfig().team_colors = {};
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_GOODGUYS] = "#3dd296;"; // { 61, 210, 150 }	--		Teal
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_BADGUYS] = "#F3C909;"; // { 243, 201, 9 }		--		Yellow
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_1] = "#c54da8;"; // { 197, 77, 168 }	--		Pink
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_2] = "#FF6C00;"; // { 255, 108, 0 }		--		Orange
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_3] = "#3455FF;"; // { 52, 85, 255 }		--		Blue
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_4] = "#65d413;"; // { 101, 212, 19 }	--		Green
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_5] = "#815336;"; // { 129, 83, 54 }		--		Brown
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_6] = "#1bc0d8;"; // { 27, 192, 216 }	--		Cyan
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_7] = "#c7e40d;"; // { 199, 228, 13 }	--		Olive
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_8] = "#8c2af4;"; // { 140, 42, 244 }	--		Purple

HidePickScreen();
function HidePickScreen() {
  var PreGame = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("PreGame");
  var StrategyMinimap = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("StrategyMinimap");
  if (StrategyMinimap) {
    for (var i = 0; i < StrategyMinimap.GetChildCount(); i++) {
      StrategyMinimap.GetChild(i).style.opacity = "0";
    }
    let map = Game.GetMapInfo().map_display_name;
    if (map == "portal_duo") {
      map = "portal_duo";
    }
    if (map == "dash") {
      map = "dash";
    }
    if (map == "portal_trio") {
      map = "portal_trio_strat";
    }
    StrategyMinimap.style.backgroundImage = 'url("file://{images}/custom_game/' + map + '.png")';
    StrategyMinimap.style.backgroundSize = "100% 100%";
  }
  if (!Game.GameStateIsAfter(2)) {
    if (hidden == false) {
      hidden = true;
      PreGame.style.opacity = "0";
    }
    $.Schedule(0.1, HidePickScreen);
  } else {
    PreGame.style.opacity = "1";
    delete hidden;
  }
}

GameEvents.Subscribe("CreateIngameErrorMessage", function (data) {
  GameEvents.SendEventClientSide("dota_hud_error_message", {
    splitscreenplayer: 0,
    reason: data.reason || 80,
    message: data.message,
  });
});

GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_GAME_NAME, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false);

if (Game.GetMapInfo().map_display_name == "portal_duo" || Game.GetMapInfo().map_display_name == "portal_trio") {
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false); //Time of day (clock).
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false); //Heroes and team score at the top of the HUD.
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false); //Top-left menu buttons in the HUD.
}

if (Game.GetMapInfo().map_display_name == "dash") {
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, true);
}

GameEvents.Subscribe("print", (event) => {
  $.Msg(event.message);
});
