const Router = require("express");
const router = new Router();
const playerController = require("../controller/player.controller");

router.post("/player/:id", playerController.getOrCreatePlayer);

module.exports = router;
