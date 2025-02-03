let loader = null;

const ShowLoader = (root) => {
  if (loader) HideLoader();
  loader = $.CreatePanel("Panel", root, "Loader");
  loader.SetPanelEvent("onactivate", () => {});

  loader.BLoadLayout("file://{resources}/layout/custom_game/ui/loader/loader.xml", true, false);
};

const HideLoader = () => {
  if (!loader) return;
  loader.DeleteAsync(0);
  loader = null;
};
