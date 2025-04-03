var load = {
  slider: $("#slider"),
  maxSlide: 0,
  currentSlide: 0,
  video: $("#hint_cinema"),
  title: $("#hint_title"),
  content: $("#hint_content"),
  dots: $("#dots"),
  hidd: $("#hidd"),
  lArr: $("#left_arrow"),
  rArr: $("#right_arrow"),

  listWrapper: $("#PlayerLists"),
  pList: $("#mainList"),
};

function ChangeCurrentSlide(n) {
  if (n == -1 || n == load.maxSlide || load.changeSlide == true) return;

  load.changeSlide = true;
  if (n == 0) $("#left_arrow").style.opacity = 0;
  else $("#left_arrow").style.opacity = 1;

  if (n == load.maxSlide - 1) $("#right_arrow").style.opacity = 0;
  else $("#right_arrow").style.opacity = 1;

  load.dots.Children()[load.currentSlide].style.backgroundColor = "rgb(110, 110, 110)";
  load.dots.Children()[n].style.backgroundColor = "rgb(201, 201, 201)";

  load.hidd.style.backgroundColor = "rgba(0, 0, 0, 1)";

  $.Schedule(0.1, () => {
    $("#hint_cinema").SetMovie(`file://{resources}/movies/${VideoPool[n]}.webm`);

    load.title.text = $.Localize(hints[n]["title"]);
    load.content.text = $.Localize(hints[n]["content"]);
  });
  $.Schedule(0.25, () => {
    load.hidd.style.backgroundColor = "rgba(0, 0, 0, 0)";
  });
  $.Schedule(0.35, () => {
    load.currentSlide = n;
    load.changeSlide = false;
  });
}

function ChangeSlide(s) {
  ChangeCurrentSlide(load.currentSlide + s);
}

// Pleyer panels
let nPlayers = 0;
let nPlayersLoaded = 0;
const formatSeconds = (s) => new Date(s * 1000).toUTCString().match(/(\d\d:\d\d:\d\d)/)[0];

function CreatePlayerPanels() {
  load.pList.RemoveAndDeleteChildren();
  load.listWrapper.style.opacity = 1;
  nPlayers = 0;

  for (let playerID of Game.GetAllPlayerIDs()) {
    let pInfo = Game.GetPlayerInfo(playerID);

    nPlayers++;
    const pPanel = $.CreatePanel("Panel", load.pList, `player_${playerID}`);
    pPanel.BLoadLayoutSnippet("playerPanel");

    if (playerID % 2 != 0) {
      pPanel.AddClass("Right");
    }
    // pPanel.FindChildTraverse('avatar').steamid = pInfo.player_steamid
    pPanel.FindChildTraverse("name").steamid = pInfo.player_steamid;

    // if (pInfo.player_id == Game.GetLocalPlayerID())
    // pPanel.AddClass('localPlayer')
  }
  UpdatePlayersConnectionState();
  GameEvents.Subscribe("dota_player_connection_state_changed", UpdatePlayersConnectionState);
}

function UpdatePlayersConnectionState() {
  nPlayersLoaded = 0;
  for (const player of Game.GetAllPlayerIDs()) {
    if ($("#player_" + player)) {
      $("#player_" + player).RemoveClass("playerConnected");
      $("#player_" + player).RemoveClass("playerConnectedFailed");
      let pState = Game.GetPlayerInfo(player).player_connection_state;
      $.Msg(player, Game.GetPlayerInfo(player));
      if (pState == DOTAConnectionState_t.DOTA_CONNECTION_STATE_CONNECTED) {
        nPlayersLoaded++;
        $.Schedule(0.3, function () {
          $("#player_" + player).AddClass("playerConnected");
        });
      } else if (
        pState == DOTAConnectionState_t.DOTA_CONNECTION_STATE_FAILED ||
        pState == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED ||
        pState == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED
      ) {
        $("#player_" + player).AddClass("playerConnectedFailed");
      }
    }
  }
  $("#listHeader").text = nPlayersLoaded + " из " + nPlayers;
}

// Timer
function UpdateTimerLoad() {
  let transitionTime = Game.GetStateTransitionTime();
  let time;

  if (transitionTime == -1) time = formatSeconds(delay - Game.GetGameTime());
  else time = formatSeconds(transitionTime - Game.GetGameTime());

  $("#dial").text = Number(time.slice(3, 5)) + ":" + time.slice(6, 8);

  if (Game.GetState() != DOTA_GameState.DOTA_GAMERULES_STATE_HERO_SELECTION) $.Schedule(0.1, UpdateTimerLoad);
}

function CreateDots() {
  for (let i = 0; i < VideoPool.length; i++) {
    $.CreatePanel("Panel", $("#dots"), "", {
      onactivate: `ChangeCurrentSlide(${i})`,
    });
  }
  $("#slider").style.opacity = 1;
  $("#Timer").style.opacity = 1;
  ChangeCurrentSlide(0);
}

function ModeDefinition() {
  let map = Game.GetMapInfo().map_display_name;
  if (map == "warsong") {
    $("#logo").style.backgroundImage = 'url("file://{images}/loading_screen/logo-warsong.png");';
    $("#logo").style.backgroundSize = "100%";
    hints = [
      {
        title: "#loading_screen_hint_warsong_1_name",
        content: "#loading_screen_hint_warsong_1_description",
      },
      {
        title: "#loading_screen_hint_warsong_2_name",
        content: "#loading_screen_hint_warsong_2_description",
      },
      {
        title: "#loading_screen_hint_warsong_3_name",
        content: "#loading_screen_hint_warsong_3_description",
      },
      {
        title: "#loading_screen_hint_warsong_4_name",
        content: "#loading_screen_hint_warsong_4_description",
      },
      {
        title: "#loading_screen_hint_warsong_5_name",
        content: "#loading_screen_hint_warsong_5_description",
      },
    ];
    VideoPool = ["v1", "Skill", "v2", "v3", "v4"];
  } else if (map == "portal_duo") {
    $("#logo").style.backgroundImage = 'url("file://{images}/loading_screen/logo-duo.png");';
    $("#logo").style.backgroundSize = "100%";
    hints = [
      {
        title: "#loading_screen_hint_portal_duo_1_name",
        content: "#loading_screen_hint_portal_duo_1_description",
      },
      {
        title: "#loading_screen_hint_portal_duo_2_name",
        content: "#loading_screen_hint_portal_duo_2_description",
      },
    ];
    VideoPool = ["Skill", "portal"];
  } else if (map == "portal_trio") {
    $("#logo").style.backgroundImage = 'url("file://{images}/loading_screen/logo-trio.png");';
    $("#logo").style.backgroundSize = "100%";
    hints = [
      {
        title: "#loading_screen_hint_portal_duo_1_name",
        content: "#loading_screen_hint_portal_duo_1_description",
      },
      {
        title: "#loading_screen_hint_portal_duo_2_name",
        content: "#loading_screen_hint_portal_duo_2_description",
      },
    ];
    VideoPool = ["Skill", "portal"];
  } else if (map == "dash") {
    $("#logo").style.backgroundImage = 'url("file://{images}/loading_screen/l");';
    $("#logo").style.backgroundSize = "100%";
    hints = [
      {
        title: "#loading_screen_hint_dash_1_name",
        content: "#loading_screen_hint_dash_1_description",
      },
      {
        title: "#loading_screen_hint_dash_2_name",
        content: "#loading_screen_hint_dash_2_description",
      },
      {
        title: "#loading_screen_hint_dash_3_name",
        content: "#loading_screen_hint_dash_3_description",
      },
    ];
    VideoPool = ["dash_1", "dash_2", "dash_3"];
  }

  load.maxSlide = VideoPool.length;
  CreateDots();
}

function ExpectationLoad() {
  const pInfo = Game.GetPlayerInfo(Game.GetLocalPlayerID());
  if (!pInfo || pInfo.player_connection_state != DOTAConnectionState_t.DOTA_CONNECTION_STATE_CONNECTED) return void $.Schedule(0.1, ExpectationLoad);

  ModeDefinition();
  UpdateTimerLoad();
  CreatePlayerPanels();
}

function StartingGame() {
  if (Game.GetState() == 2) {
    $.Schedule(0.5, function () {
      Game.AutoAssignPlayersToTeams();
      Game.SetTeamSelectionLocked(true);
      Game.SetAutoLaunchEnabled(false);
      Game.SetRemainingSetupTime(GameStartDelay);

      if (Game.GetMapInfo().map_display_name == "portal_duo" || Game.GetMapInfo().map_display_name == "portal_trio") {
        ChooseKills();
      }
    });
  }
}

function ChooseKills() {
  let selected_kills = CustomNetTables.GetTableValue("selected_kills", "selected_kills");

  if (selected_kills) {
    $("#ChooseKillsPanel").style.opacity = "1";

    var kills_1 = $.CreatePanel("Panel", $("#ChooseKillsPanelList"), "");
    kills_1.AddClass("ChooseKill");
    var kills_2 = $.CreatePanel("Panel", $("#ChooseKillsPanelList"), "");
    kills_2.AddClass("ChooseKill");
    var kills_3 = $.CreatePanel("Panel", $("#ChooseKillsPanelList"), "");
    kills_3.AddClass("ChooseKill");

    var kills_1_label = $.CreatePanel("Label", kills_1, "");
    kills_1_label.AddClass("ChooseKillLabel");
    kills_1_label.text = selected_kills[1];

    var kills_2_label = $.CreatePanel("Label", kills_2, "");
    kills_2_label.AddClass("ChooseKillLabel");
    kills_2_label.text = selected_kills[2];

    var kills_3_label = $.CreatePanel("Label", kills_3, "");
    kills_3_label.AddClass("ChooseKillLabel");
    kills_3_label.text = selected_kills[3];

    kills_1.SetPanelEvent("onactivate", function () {
      ChooseKillsEvent(kills_1, selected_kills[1]);
    });
    kills_2.SetPanelEvent("onactivate", function () {
      ChooseKillsEvent(kills_2, selected_kills[2]);
    });
    kills_3.SetPanelEvent("onactivate", function () {
      ChooseKillsEvent(kills_3, selected_kills[3]);
    });
  }
}

function ChooseKillsEvent(panel, kills) {
  for (var i = 0; i < $("#ChooseKillsPanelList").GetChildCount(); i++) {
    $("#ChooseKillsPanelList").GetChild(i).SetHasClass("selected", false);
  }
  panel.SetHasClass("selected", true);
  GameEvents.SendCustomGameEventToServer("select_kills_event", { kills: kills });
}

// function AbilityDraftClick(panel, vote)
// {
//     for (var i = 0; i < $("#ChooseDraftPanelList").GetChildCount(); i++)
//     {
//         $("#ChooseDraftPanelList").GetChild(i).SetHasClass("selected", false)
//     }
//     $("#ChooseDraftPanelList").FindChildTraverse(panel).SetHasClass("selected", true)
//     GameEvents.SendCustomGameEventToServer( "select_draft_event", {vote : vote} );
// }

(() => {
  ExpectationLoad();
  const dotaLoadingScreen = (() => {
    let panel = $.GetContextPanel();
    while (panel) {
      if (panel.id === "LoadingScreen") return panel;
      panel = panel.GetParent();
    }
  })();
  dotaLoadingScreen.FindChildTraverse("SidebarAndBattleCupLayoutContainer").visible = false;
  GameEvents.Subscribe("game_rules_state_change", StartingGame);

  let dota = $.GetContextPanel().GetParent().GetParent().GetParent();
  dota.FindChildTraverse("LoadingScreenChat").style.width = "450px";
  dota.FindChildTraverse("ChatLinesContainer").style.backgroundColor = "transparent";
})();
