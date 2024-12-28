"use strict";

var hContext = $.GetContextPanel();
hContext.SetDialogVariable("radiant_flags_remaining", "7");
hContext.SetDialogVariable("dire_flags_remaining", "7"); 

(function () {
  GameEvents.Subscribe("update_flags_count", function (event) {
    var hContext = $.GetContextPanel();
    hContext.SetDialogVariable("radiant_flags_remaining", `${event.radiant}`);
    hContext.SetDialogVariable("dire_flags_remaining", `${event.dire}`);
    if (
      Game.GetMapInfo().map_display_name == "warsong_duo" ||
      Game.GetMapInfo().map_display_name == "portal_duo" ||
      Game.GetMapInfo().map_display_name == "portal_trio" ||
      Game.GetMapInfo().map_display_name == "dota" ||
      Game.GetMapInfo().map_display_name == "dash"
    ) {
      hContext.style.visibility = "collapse";
      if (hContext.GetChild(0)) {
        hContext.GetChild(0).style.visibility = "collapse";
      }
    }
  });
  if (
    Game.GetMapInfo().map_display_name == "warsong_duo" ||
    Game.GetMapInfo().map_display_name == "portal_duo" ||
    Game.GetMapInfo().map_display_name == "portal_trio" ||
    Game.GetMapInfo().map_display_name == "dota" ||
    Game.GetMapInfo().map_display_name == "dash"
  ) {
    if (hContext) {
      if (hContext.GetChild(0)) {
        hContext.GetChild(0).style.visibility = "collapse";
      }
    }
  }

  const SoundOnClient = (event) => {
    Game.EmitSound(event.sound);
  };

  GameEvents.Subscribe("GameTimer", UpdateTimer);
  GameEvents.SendCustomGameEventToServer("Request_RemainingFlags", {});
  GameEvents.Subscribe("sound_on_client", SoundOnClient);
})();

function UpdateTimer(data) {
  var timerText = "";
  timerText += data.timer_minute_10;
  timerText += data.timer_minute_01;
  timerText += ":";
  timerText += data.timer_second_10;
  timerText += data.timer_second_01;

  if ($("#TimeCounter")) {
    $("#TimeCounter").text = timerText;
  }
}
