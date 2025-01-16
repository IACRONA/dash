const storeInfo = CustomNetTables.GetTableValue("server_info", "store");
const store = $("#Store");
let activeButton = "";
let items = [];

(() => {
  const currency = CustomNetTables.GetTableValue("player_info", `${Players.GetLocalPlayer()}`)?.currency;

  store.SetDialogVariable("currency", currency);

  const buttons = store.FindChildrenWithClassTraverse("SwitchButton");

  buttons.forEach((button) => {
    button.SetPanelEvent("onactivate", () => {
      if (!storeInfo) return;
      buttons.forEach((element) => {
        element.RemoveClass("IsActive");
      });
      button.AddClass("IsActive");

      activeButton = button.id;
      UpdateStore();
    });
  });

  $("#StoreButtonBack").SetPanelEvent("onactivate", () => {
    $("#StoreBody").RemoveClass("IsActive");
  });
})();

const ShowStore = () => {
  const profile = $("#StoreContainer");

  profile.ToggleClass("is-active");
};

const UpdateStore = () => {
  const body = $("#StoreInside");
  const storeMain = $("#StoreBody");
  storeMain.AddClass("IsActive");
  const playerInfo = CustomNetTables.GetTableValue("player_info", `${Players.GetLocalPlayer()}`);
  items.forEach((panel) => panel.DeleteAsync(0));
  items = [];
  const parseGamesInfo = Object.entries(storeInfo[activeButton]);
  parseGamesInfo.sort((a, b) => {
    return a[1].price - b[1].price;
  });
  const playerInventory = playerInfo[activeButton];

  parseGamesInfo.forEach(([name, info]) => {
    const item = $.CreatePanel("Panel", body, name);
    items.push(item);

    item.BLoadLayoutSnippet("ShopItem");
    $.Msg(`file://{resources}/images/custom_game/store_items/${name}.png`);
    $.CreatePanel("Image", item.FindChildTraverse("ShopItemImageContainer"), "ShopItemImage", {
      src: `file://{resources}/images/custom_game/store_items/${name}.png`,
    });
    item.SetHasClass("IsBought", !!playerInventory[name]);
    item.SetHasClass("IsActive", !!playerInventory[name]?.isActive);

    item.SetDialogVariable("name", $.Localize(`#DOTA_Tooltip_ability_item_${name}`));
    item.SetDialogVariable("price", info.price);
    const shopItem = item.FindChildTraverse("ShopItemImage");

    const buyButton = item.FindChildTraverse("ShopItemBuy");
    buyButton.SetPanelEvent("onactivate", () => {
      ShowPopupAccept($("#StoreContainer"), () => {
        ShowLoader($("#StoreContainer"));
        GameEvents.SendCustomGameEventToServer("buy_item", { playerId: Players.GetLocalPlayer(), item: name, type: activeButton });
      });
    });
    const activeElement = item.FindChildTraverse("ShopItemActivate");
    activeElement.SetPanelEvent("onactivate", () => {
      ShowLoader($("#StoreContainer"));
      GameEvents.SendCustomGameEventToServer("equip_shop_item", { playerId: Players.GetLocalPlayer(), item: name, type: activeButton });
    });
  });
};

const OnUpdatePlayerInfo = (playerId, data) => {
  if (playerId !== `${Game.GetLocalPlayerID()}`) return;

  store.SetDialogVariable("currency", data.currency);
  const playerInventory = data[activeButton];
  if (!playerInventory || typeof playerInventory !== "object") return;
  const shopItems = store.FindChildrenWithClassTraverse("ShopItem");

  shopItems.forEach((panel) => {
    const name = panel.id;
    panel.SetHasClass("IsBought", !!playerInventory[name]);
    panel.SetHasClass("IsActive", !!playerInventory[name]?.isActive);
  });
};

const ShowError = (data) => {
  ShowPopupError($("#StoreContainer"), data.error);
};

const OnRequestFinally = () => {
  HideLoader();
};

GameEvents.Subscribe("store_error", ShowError);
GameEvents.Subscribe("store_request_finally", OnRequestFinally);
CustomNetTables.SubscribeNetTableListener("player_info", (_, eventKey, eventValue) => OnUpdatePlayerInfo(eventKey, eventValue));
