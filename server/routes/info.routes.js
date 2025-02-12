const Router = require("express");
const router = new Router();
const infoController = require("../controller/info.controller");

router.post("/upgrades/talents", infoController.getHeroUpgradeData);

module.exports = router;
