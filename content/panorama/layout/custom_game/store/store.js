const storeInfo = CustomNetTables.GetTableValue("server_info", "store");
const store = $("#Store");
let activeButton = "";
let items = [];

(() => {
  $.GetContextPanel().GetParent().style.zIndex = "2";
  const currency = CustomNetTables.GetTableValue("player_info", `${Players.GetLocalPlayer()}`)?.currency;

  store.SetDialogVariable("currency", currency);

  const buttons = store.FindChildrenWithClassTraverse("SwitchButton");

  const storeMenu = $("#StoreMenu");
  const storeBody = $("#StoreBody");
  storeBody.SetPanelEvent("onactivate", () => {});
  let randomBodyBackground = 0;
  buttons.forEach((button) => {
    const type = button.id;
    button.SetPanelEvent("onactivate", () => {
      if (!storeInfo) return;
      randomBodyBackground = Math.floor(Math.random() * 4) + 1;
      storeBody.style.backgroundImage = `url("file://{resources}/images/interface/store/content/store_body_${randomBodyBackground}.png")`;

      buttons.forEach((element) => {
        element.RemoveClass("IsActive");
      });
      button.AddClass("IsActive");

      activeButton = type;
      UpdateStore();
    });

    button.SetPanelEvent("onmouseover", () => {
      storeMenu.style.backgroundImage = `url("file://{resources}/images/interface/store/hover/${type}.png")`;
      storeMenu.style.backgroundSize = `100%`;
    });

    button.SetPanelEvent("onmouseout", () => {
      storeMenu.style.backgroundImage = "url('')";
    });
  });

  const buttonBack = $("#StoreButtonBack");

  buttonBack.SetPanelEvent("onactivate", () => {
    storeBody.RemoveClass("IsActive");
  });

  const storeHoverBackground = $("#StoreHoverBackground");
  buttonBack.SetPanelEvent("onmouseover", () => {
    storeHoverBackground.style.backgroundImage = `url("file://{resources}/images/interface/store/hover/store_body_${randomBodyBackground}.png")`;
    storeHoverBackground.style.backgroundSize = "100%";
  });

  buttonBack.SetPanelEvent("onmouseout", () => {
    storeHoverBackground.style.backgroundImage = "url('')";
  });
})();

const ShowStore = () => {
  const profile = $("#StoreContainer");
  Game.EmitSound("ui_topmenu_activate");
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

    $.CreatePanel("Image", item.FindChildTraverse("ShopItemImageContainer"), "ShopItemImage", {
      src: `file://{resources}/images/custom_game/store_items/${name}.png`,
    });
    item.SetHasClass("IsBought", !!playerInventory[name]);
    item.SetHasClass("IsActive", !!playerInventory[name]?.isActive);

    item.SetDialogVariable("name", $.Localize(`#DOTA_shop_${name}`));
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
