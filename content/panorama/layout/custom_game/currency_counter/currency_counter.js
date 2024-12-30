const flag = $("#FlagsCounter");
const mapName = Game.GetMapInfo().map_display_name;

if (mapName === "dash"|| mapName === "portal_trio" || mapName === "portal_duo" ) {
  // const Image = $("#FlagsCounterIcon");
  // const parent = Image.GetParent();

  // Image.DeleteAsync(0);
  // $.CreatePanel("Image", parent, "FlagsCounterIcon", {
  //   src: `file://{resources}/images/custom_game/head_counter.png`,
  // });
  flag.style.visibility = "collapse";
}
function UpdateFlags(playerId, data) { 
  if (playerId !== `${Game.GetLocalPlayerID()}`) return;
  const currency = data.counter;
  flag.SetPanelEvent("onmouseover", function () {
    $.DispatchEvent("UIShowTextTooltip", flag, `${currency}`);
  });
}

const currencyFromTable = CustomNetTables.GetTableValue("custom_currency", `${Game.GetLocalPlayerID()}`);
const currency = currencyFromTable ? currencyFromTable.counter : 0;

flag.SetPanelEvent("onmouseover", function () {
  $.DispatchEvent("UIShowTextTooltip", flag, `${currency}`);
});

flag.SetPanelEvent("onmouseout", function () {
  $.DispatchEvent("UIHideTextTooltip", flag);
});

CustomNetTables.SubscribeNetTableListener("custom_currency", (_, eventKey, eventValue) => UpdateFlags(eventKey, eventValue));
