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
