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
