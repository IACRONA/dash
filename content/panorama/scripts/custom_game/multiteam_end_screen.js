"use strict";

(function () {
  if (ScoreboardUpdater_InitializeScoreboard === null) {
    $.Msg("WARNING: This file requires shared_scoreboard_updater.js to be included.");
  }

  var scoreboardConfig = {
    teamXmlName: "file://{resources}/layout/custom_game/multiteam_end_screen_team.xml",
    playerXmlName: "file://{resources}/layout/custom_game/multiteam_end_screen_player.xml",
  };

  var endScoreboardHandle = ScoreboardUpdater_InitializeScoreboard(scoreboardConfig, $("#TeamsContainer"));
  $.GetContextPanel().SetHasClass("endgame", 1);

  var teamInfoList = ScoreboardUpdater_GetSortedTeamInfoList(endScoreboardHandle);
  var delay = 0.2;
  var delay_per_panel = 1 / teamInfoList.length;
  for (var teamInfo of teamInfoList) {
    var teamPanel = ScoreboardUpdater_GetTeamPanel(endScoreboardHandle, teamInfo.team_id);
    teamPanel.SetHasClass("team_endgame", false);
    var callback = (function (panel) {
      return function () {
        panel.SetHasClass("team_endgame", 1);
      };
    })(teamPanel);
    $.Schedule(delay, callback);
    delay += delay_per_panel;
  }

  var winningTeamId = Game.GetGameWinner();
  var winningTeamDetails = Game.GetTeamDetails(winningTeamId);
  var endScreenVictory = $("#WinLabelContainer");
  if (endScreenVictory) {
    if ($("#VictoryLabel")) {
      if (winningTeamId == 3) {
        $("#VictoryLabel").text = $.Localize("#Victory_DOTA_GoodGuys");
        $("#ContinueButton").style.washColor = "white";
      } else if (winningTeamId == 2) {
        $("#VictoryLabel").text = $.Localize("#Victory_DOTA_BadGuys");
        $("#ContinueButton").style.washColor = "white";
      } else if (winningTeamId == 6) {
        $("#VictoryLabel").text = $.Localize("#Victory_DOTA_Custom1");
        $("#ContinueButton").style.washColor = "white";
      } else if (winningTeamId == 7) {
        $("#VictoryLabel").text = $.Localize("#Victory_DOTA_Custom2");
        $("#ContinueButton").style.washColor = "white";
      } else if (winningTeamId == 8) {
        $("#VictoryLabel").text = $.Localize("#Victory_DOTA_Custom3");
        $("#ContinueButton").style.washColor = "white";
      } else if (winningTeamId == 9) {
        $("#VictoryLabel").text = $.Localize("#Victory_DOTA_Custom4");
        $("#ContinueButton").style.washColor = "white";
      }
    }
    endScreenVictory.SetDialogVariable("VictoryLabel", $.Localize(winningTeamDetails.team_name));
    if (GameUI.CustomUIConfig().team_colors) {
      var teamColor = GameUI.CustomUIConfig().team_colors[winningTeamId];
      teamColor = teamColor.replace(";", "");
      endScreenVictory.style.color = teamColor + ";";
    }
  }

  var dotahud = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent();

  var chat = dotahud.FindChildTraverse("HudChat");
  if (chat) {
    chat.style.y = "-50px";
  }

  var winningTeamLogo = $("#WinningTeamLogo");
  if (winningTeamLogo) {
    var logo_xml = GameUI.CustomUIConfig().team_logo_large_xml;
    if (logo_xml) {
      winningTeamLogo.SetAttributeInt("team_id", winningTeamId);
      winningTeamLogo.BLoadLayout(logo_xml, false, false);
    }
  }

  $.Schedule(1, () => {
    StartMvp();
  });
})();

function StartMvp() {
  let table_mvp = CustomNetTables.GetTableValue("mvp_score", "mvp_score");
  $("#MVPScreen").style.visibility = "visible";
  PlayMusic(table_mvp);

  $.Schedule(0.5, () => {
    SpawnMvp(1, table_mvp);
    $.Schedule(3, () => {
      SpawnMvp(2, table_mvp);
      $.Schedule(3, () => {
        SpawnMvp(3, table_mvp);
        $.Schedule(5, () => {
          OpenDefaultTable();
        });
      });
    });
  });
}

function OpenDefaultTable() {
  $("#MVPScreen").style.visibility = "collapse";
  $("#WinLabelContainer").style.visibility = "visible";
  $("#EndScreenWindow").style.visibility = "visible";
}

function PlayMusic(table_mvp) {
  if (table_mvp[1] == null) return Game.EmitSound("Flag.MvpBackground");

  let player_id = table_mvp[1].player_id;

  Game.EmitSound(playerInfo.getMusicPlayer(player_id) || "Flag.MvpBackground");
}
function SpawnMvp(num, table_mvp) {
  if (table_mvp[num] == null) {
    return;
  }

  let player_id = table_mvp[num].player_id;
  let playerInfo = Game.GetPlayerInfo(player_id);
  let hero_name = playerInfo.player_selected_hero;
  if (hero_name == null) {
    hero_name = "npc_dota_hero_pudge";
  }

  let main_panel = $("#MvpHeroes");

  let mvp_panel_player = $.CreatePanel("Panel", main_panel, "MvpHero" + num);
  mvp_panel_player.AddClass("mvp_panel_player_pos" + num);
  mvp_panel_player.AddClass("mvp_panel_player");

  $.Schedule(0.1, () => {
    Game.EmitSound("Flag.MvpSpawn");
    mvp_panel_player.AddClass("mvp_panel_player_spawn");
  });

  $.CreatePanel("DOTAScenePanel", mvp_panel_player, "hero_model", {
    class: "hero_model",
    drawbackground: false,
    unit: hero_name,
    particleonly: "false",
    antialias: "false",
    allowrotation: "true",
  });

  let hero_name_mvp = $.CreatePanel("Label", mvp_panel_player, "");
  hero_name_mvp.AddClass("hero_name_mvp");
  hero_name_mvp.text = $.Localize("#" + hero_name);

  let player_name_mvp = $.CreatePanel("Label", mvp_panel_player, "");
  player_name_mvp.AddClass("player_name_mvp");
  player_name_mvp.text = playerInfo.player_name;

  let player_scores = $.CreatePanel("Label", mvp_panel_player, "");
  player_scores.AddClass("player_scores");
  player_scores.text = playerInfo.player_kills + " / " + playerInfo.player_deaths + " / " + playerInfo.player_assists;

  let player_best_inf = $.CreatePanel("Label", mvp_panel_player, "");
  player_best_inf.AddClass("player_best_inf");

  if (num <= 1) {
    player_best_inf.text = $.Localize("#mpv_best");
  } else {
    player_best_inf.text = $.Localize("#mvp_no_best");
  }

  if (Game.GetMapInfo().map_display_name == "warsong") {
    let player_flags = $.CreatePanel("Label", mvp_panel_player, "");
    player_flags.AddClass("player_flags");
    player_flags.text = $.Localize("#mvp_flag_label") + " " + table_mvp[num].flags_count;
  }
}
