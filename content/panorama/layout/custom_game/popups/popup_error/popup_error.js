let errorPopup = null;

const ShowPopupError = (root, message) => {
  if (errorPopup) HidePopupError();
  errorPopup = $.CreatePanel("Panel", root, "PopupError");

  errorPopup.BLoadLayout("file://{resources}/layout/custom_game/popups/popup_error/popup_error.xml", true, false);
  errorPopup.SetDialogVariable("error", message);
  errorPopup.SetPanelEvent("onactivate", () => {});

  const closeButton = errorPopup.FindChildTraverse("PopupErrorClose");

  closeButton?.SetPanelEvent("onactivate", () => {
    HidePopupError();
  });
};

const HidePopupError = () => {
  if (!errorPopup) return;
  errorPopup.DeleteAsync(0);
  errorPopup = null;
};
