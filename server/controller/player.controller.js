const db = require("../db");
const { TYPE_STORE } = require("../tables/constants");
const { CURRENCY_FOR_WIN } = require("../tables/constants");

class PlayerController {
  async getOrCreatePlayer(req, res) {
    const id = req.params.id;
    const player = await db.query("SELECT * FROM player where steam_id = $1", [id]);
    const user = player.rows[0];

    if (!user) {
      const newUser = await db.query(
        "INSERT INTO player (steam_id, currency, roll, aura, pet, titul, teleportation_effect, music) values ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *",
        [id, 0, 10, "{}", "{}", "{}", "{}", "{}"]
      );

      return res.json(newUser.rows[0]);
    }

    res.json(user);
  }

  async updatePlayer(req, res) {
    const { id, currency, roll, aura, pet, titul, teleportation_effect, music, isEndGame } = req.body;

    const player = await db.query("SELECT * FROM player where steam_id = $1", [id]);

    if (!player.rows[0]) return res.status(403).json({ error: "Такого игрока нет" });

    const currentPlayer = player.rows[0];
    let newCurrency = Math.max(currency !== undefined ? currency : currentPlayer.currency, 0);
    newCurrency += isEndGame ? CURRENCY_FOR_WIN : 0;

    const updatedPlayer = await db.query(
      "UPDATE player SET currency = $1, roll = $2, aura = $3, pet = $4, titul = $5, teleportation_effect = $6, music = $7 WHERE steam_id = $8 RETURNING *",
      [
        newCurrency,
        Math.max(roll !== undefined ? roll : currentPlayer.roll, 0),
        aura !== undefined ? aura : currentPlayer.aura,
        pet !== undefined ? pet : currentPlayer.pet,
        titul !== undefined ? titul : currentPlayer.titul,
        teleportation_effect !== undefined ? teleportation_effect : currentPlayer.teleportation_effect,
        music !== undefined ? music : currentPlayer.music,
        id,
      ]
    );

    res.json(updatedPlayer.rows[0]);
  }

  async equipItem(req, res) {
    const { id, type, item_name } = req.body;

    const player = await db.query("SELECT * FROM player where steam_id = $1", [id]);
    if (!player.rows[0]) return res.status(403).json({ error: "Игрок не найден" });
    if (!TYPE_STORE[type]) return res.status(403).json({ error: "Тип не найден" });

    const currentPlayer = player.rows[0];

    const newTable = JSON.parse(currentPlayer[type]);

    if (typeof newTable != "object") return res.status(403).json({ error: "Не корректный тип" });

    for (const key in newTable) {
      const item = newTable[key];
      if (key === item_name) {
        if (item.isActive) {
          delete item.isActive;
        } else {
          item.isActive = !item.isActive;
        }
      } else if (item.isActive) {
        delete item.isActive;
      }
    }

    const updatedPlayer = await db.query(`UPDATE player SET ${type} = $1 WHERE steam_id = $2 RETURNING *`, [newTable, id]);

    res.json(updatedPlayer.rows[0]);
  }
}

module.exports = new PlayerController();
