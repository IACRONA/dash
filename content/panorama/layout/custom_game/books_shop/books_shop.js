const books = CustomNetTables.GetTableValue("books_shop", "books");
let shopPanel = null;

function ShowShopPanel() {
  if (shopPanel) return;
  shopPanel = $.CreatePanel("Panel", $.GetContextPanel(), "ShopWindow", {
    hittest: false,
    class: "__Remove__",
  });

  shopPanel.BLoadLayoutSnippet("ShopWindow");
  shopPanel.AddClass("IsActive");
  const avatarPanel = shopPanel.FindChildTraverse("ShopWindowUnit");

  avatarPanel.SetUnit("npc_books_seller", "", true);
  const body = shopPanel.FindChildTraverse("ShopWindowBody");

  const crossButon = shopPanel.FindChildTraverse("ShopWindowCross");
  crossButon.SetPanelEvent("onactivate", () => {
    HideShopPanel();
  });
  const mapName = Game.GetMapInfo().map_display_name;

  Object.entries(books).forEach(([index, info]) => {
    const { name, resources } = info;
    const mapResources = resources[mapName];
    if (!mapResources) return;
    const { gold, flags, heads, purchaseType } = mapResources;
    $.Msg(index);
    const item = $.CreatePanel("Panel", body.GetChild(index > 4 ? 0 : 1), "ShopItem", {
      class: `Book${index}`,
    });
    item.BLoadLayoutSnippet("ShopItem");
    const itemImage = item.FindChildTraverse("ShopItemImage");
    itemImage.itemname = name;
    const itemPreviewImage = item.FindChildTraverse("ShopItemPreviewImage");
    itemPreviewImage.style.backgroundImage = `url("file://{resources}/images/items/${name}.png")`;
    itemPreviewImage.style.backgroundSize = "contain";
    itemPreviewImage.style.backgroundRepeat = "no-repeat";
    itemPreviewImage.style.backgroundPosition = "center";

    if (purchaseType === "both") {
      item.AddClass("BuyBoth");
      item.AddClass("CanBuyForGold");
      item.SetDialogVariable("gold", `${gold}`);
      if (flags) {
        item.AddClass("CanBuyForFlags");
        item.SetDialogVariable("flags", `${flags}`);
      }
      if (heads) {
        item.AddClass("CanBuyForHeads");
        item.SetDialogVariable("heads", `${heads}`);
      }

      const button = item.FindChildTraverse("ShopItemBuyForBoth");

      button.SetPanelEvent("onactivate", () => {
        GameEvents.SendCustomGameEventToServer("buy_book", {
          playerId: Players.GetLocalPlayer(),
          type: "both",
          itemIndex: index,
        });
      });
      return;
    }

    if (gold) {
      item.AddClass("CanBuyForGold");
      item.SetDialogVariable("gold", `${gold}`);
      const button = item.FindChildTraverse("ShopItemBuyForGold");

      button.SetPanelEvent("onactivate", () => {
        GameEvents.SendCustomGameEventToServer("buy_book", {
          playerId: Players.GetLocalPlayer(),
          type: "gold",
          itemIndex: index,
        });
      });
    }

    if (flags) {
      item.AddClass("CanBuyForFlags");
      item.SetDialogVariable("flags", `${flags}`);
      const button = item.FindChildTraverse("ShopItemBuyForFlags");

      button.SetPanelEvent("onactivate", () => {
        GameEvents.SendCustomGameEventToServer("buy_book", {
          playerId: Players.GetLocalPlayer(),
          type: "flags",
          itemIndex: index,
        });
      });
    }

    if (heads) {
      $.Msg(heads);
      item.AddClass("CanBuyForHeads");
      item.SetDialogVariable("heads", `${heads}`);
      const button = item.FindChildTraverse("ShopItemBuyForHeads");

      button.SetPanelEvent("onactivate", () => {
        GameEvents.SendCustomGameEventToServer("buy_book", {
          playerId: Players.GetLocalPlayer(),
          type: "heads",
          itemIndex: index,
        });
      });
    }
  });
}

function HideShopPanel() {
  if (shopPanel) {
    shopPanel.RemoveClass("IsActive");
    shopPanel.DeleteAsync(0.25);
    shopPanel = null;
  }
}

GameEvents.Subscribe("show_books_shop", ShowShopPanel);
GameEvents.Subscribe("hide_books_shop", HideShopPanel);
