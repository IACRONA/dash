const showBossNotification = function () {
  const root = $.CreatePanel("Panel", $.GetContextPanel(), "BossHead");
  root.BLoadLayoutSnippet("BossHead");
  root.AddClass("IsActive");
  Game.EmitSound("NeutralLootDrop.Notification");

  $.Schedule(8, function () {
    root.RemoveClass("IsActive");
    root.DeleteAsync(0.4);
  });
};

GameEvents.Subscribe("boss_head_notification", showBossNotification);

var BOSS_HERO_MAP = {
  npc_boss_kunkka: "npc_dota_hero_kunkka",
  npc_boss_tidehunter: "npc_dota_hero_tidehunter",
};

const showBossLaneNotification = function (data) {
  var bossName = data.boss_name || "";
  var heroName = BOSS_HERO_MAP[bossName] || "npc_dota_hero_kunkka";
  var localizedName = $.Localize("#" + bossName);

  var root = $.CreatePanel("Panel", $.GetContextPanel(), "BossLaneEnemy");
  root.BLoadLayoutSnippet("BossLaneEnemy");

  var heroIcon = root.FindChildTraverse("BossLaneHeroIcon");
  if (heroIcon) {
    heroIcon.heroname = heroName;
  }

  var title = root.FindChildTraverse("BossLaneTitle");
  if (title) {
    title.text = "<font color='#FF4444'>" + localizedName + "</font>";
  }

  root.AddClass("IsActive");
  Game.EmitSound("Roshan.Death");

  $.Schedule(8, function () {
    root.RemoveClass("IsActive");
    root.DeleteAsync(0.4);
  });
};

GameEvents.Subscribe("boss_lane_notification", showBossLaneNotification);

const showFlagStolenNotification = function (data) {
  var carrierName = data.carrier_name || "Игрок";
  var carrierTeam = data.carrier_team;
  var localTeam = Players.GetLocalPlayerTeam();

  var root = $.CreatePanel("Panel", $.GetContextPanel(), "FlagStolen");
  root.BLoadLayoutSnippet("FlagStolen");

  var title = root.FindChildTraverse("FlagStolenTitle");
  if (title) {
    if (carrierTeam === localTeam) {
      title.text = "<font color='#00ff7f'>" + carrierName + "</font> <font color='#ffffff'>захватил вражеский флаг!</font>";
    } else {
      title.text = "<font color='#ff4444'>" + carrierName + "</font> <font color='#ffffff'>украл ваш флаг!</font>";
    }
  }

  root.AddClass("IsActive");
  Game.EmitSound("General.CoinDrop");

  $.Schedule(6, function () {
    root.RemoveClass("IsActive");
    root.DeleteAsync(0.4);
  });
};

GameEvents.Subscribe("flag_stolen_notification", showFlagStolenNotification);
