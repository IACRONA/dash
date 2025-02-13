let acceptPopup = null;

const ShowPopupAccept = (root, successCallback) => {
  if (acceptPopup) HidePopupAccept();
  acceptPopup = $.CreatePanel("Panel", root, "PopupAccept", {
    hittest: true,
  });

  acceptPopup.BLoadLayout("file://{resources}/layout/custom_game/popups/popup_accept/popup_accept.xml", true, false);

  acceptPopup.SetPanelEvent("onactivate", () => {});

  const acceptButton = acceptPopup.FindChildTraverse("PopupAcceptYes");
  const cancelButton = acceptPopup.FindChildTraverse("PopupAcceptNo");

  acceptButton?.SetPanelEvent("onactivate", () => {
    Game.EmitSound("Flag.RollChoose");
    successCallback?.();
    HidePopupAccept();
  });

  cancelButton?.SetPanelEvent("onactivate", () => {
    Game.EmitSound("Flag.RollChoose");
    HidePopupAccept();
  });
};

const HidePopupAccept = () => {
  if (!acceptPopup) return;
  acceptPopup.DeleteAsync(0);
  acceptPopup = null;
};
