const Router = require("express");
const router = new Router();
const playerController = require("../controller/player.controller");

router.post("/player/:id", playerController.getOrCreatePlayer);
router.post("/player", playerController.updatePlayer);
router.post("/equip_item", playerController.equipItem);

module.exports = router;
