"use strict";

var g_ScoreboardHandle = null;

GameEvents.Subscribe("update_kills_duo", function (event) {
  GameUI.CustomUIConfig().kills_count_info = event.kills;
  $("#KillToWinLabel").text = event.kills;
});

function UpdateScoreboard() {
  if (
    Game.GetMapInfo().map_display_name != "warsong_duo" &&
    Game.GetMapInfo().map_display_name != "portal_duo" &&
    Game.GetMapInfo().map_display_name != "portal_trio"
  ) {
    $("#KillToWin").style.visibility = "collapse";
    return;
  }
  ScoreboardUpdater_SetScoreboardActive(g_ScoreboardHandle, true);

  $.Schedule(0.2, UpdateScoreboard);
}

(function () {
  if (
    Game.GetMapInfo().map_display_name != "warsong_duo" &&
    Game.GetMapInfo().map_display_name != "portal_duo" &&
    Game.GetMapInfo().map_display_name != "portal_trio"
  ) {
    $("#KillToWin").style.visibility = "collapse";
    return;
  }
  var shouldSort = true;

  if (GameUI.CustomUIConfig().multiteam_top_scoreboard) {
    var cfg = GameUI.CustomUIConfig().multiteam_top_scoreboard;
    if (cfg.LeftInjectXMLFile) {
      $("#LeftInjectXMLFile").BLoadLayout(cfg.LeftInjectXMLFile, false, false);
    }
    if (cfg.RightInjectXMLFile) {
      $("#RightInjectXMLFile").BLoadLayout(cfg.RightInjectXMLFile, false, false);
    }

    if (typeof cfg.shouldSort !== "undefined") {
      shouldSort = cfg.shouldSort;
    }
  }

  if (ScoreboardUpdater_InitializeScoreboard === null) {
    $.Msg("WARNING: This file requires shared_scoreboard_updater.js to be included.");
  }

  var scoreboardConfig = {
    teamXmlName: "file://{resources}/layout/custom_game/multiteam_top_scoreboard_team.xml",
    playerXmlName: "file://{resources}/layout/custom_game/multiteam_top_scoreboard_player.xml",
    shouldSort: shouldSort,
  };
  g_ScoreboardHandle = ScoreboardUpdater_InitializeScoreboard(scoreboardConfig, $("#MultiteamScoreboard"));

  UpdateScoreboard();
})();

GameEvents.Subscribe("GameTimer_2", UpdateTimer);

function UpdateTimer(data) {
  var timerText = "";
  timerText += data.timer_minute_10;
  timerText += data.timer_minute_01;
  timerText += ":";
  timerText += data.timer_second_10;
  timerText += data.timer_second_01;

  if (data.timer_minute_10 == 0 && data.timer_minute_01 == 3 && data.timer_second_10 == 0 && data.timer_second_01 == 0) {
    $("#TimeUntil").SetHasClass("TimeUntilActive", true);
    Game.EmitSound("Tutorial.TaskProgress");
    $.Schedule(2, function () {
      $("#TimeUntil").SetHasClass("TimeUntilActive", false);
    });
  }

  if (data.timer_minute_10 == 0 && data.timer_minute_01 == 1 && data.timer_second_10 == 0 && data.timer_second_01 == 0) {
    $("#TimeUntil2").SetHasClass("TimeUntilActive", true);
    Game.EmitSound("Tutorial.TaskProgress");
    $.Schedule(2, function () {
      $("#TimeUntil2").SetHasClass("TimeUntilActive", false);
    });
  }

  if (data.timer_minute_10 == 0 && data.timer_minute_01 <= 0 && data.timer_second_10 < 3) {
    Game.EmitSound("Tutorial.TaskProgress");
  }

  if ($("#FlagCounter")) {
    $("#FlagCounter").text = timerText;
  }
}
