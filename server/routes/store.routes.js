const Router = require("express");
const router = new Router();
const storeController = require("../controller/store.controller");

router.post("/store/store_info", storeController.getStoreInfo);
router.post("/store/buy_item", storeController.buyItem);

module.exports = router;
