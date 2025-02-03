const db = require("../db");
const STORE = require("../tables/store.table");
const TYPE_STORE = require("../tables/constants");

class StoreController {
  async getStoreInfo(req, res) {
    res.json(STORE);
  }

  async buyItem(req, res) {
    const { id, item_name, type } = req.body;
    const players = await db.query("SELECT * FROM player where steam_id = $1", [id]);
    const player = players.rows[0];
    if (!player) return res.status(403).json({ error: "Такого игрока нет" });
    if (!STORE[type]) return res.status(403).json({ error: "Такого типа нет" });

    const item = STORE[type][item_name];

    if (!item) return res.status(403).json({ error: "Такого предмета нет" });

    if (player.currency < item.price) return res.status(403).json({ error: "Не хватает денег" });

    let newCurrency = player.currency - item.price;
    let newPlayer = null;

    if (type === TYPE_STORE.roll) {
      const newRerolls = player.roll + item.count;

      newPlayer = await db.query("UPDATE player set currency = $2, roll = $3 where steam_id = $1 RETURNING *", [id, newCurrency, newRerolls]);
    } else {
      const newTable = JSON.parse(player[type]);

      if (newTable[item_name]) return res.status(403).json({ error: "Уже есть такой предмет" });

      newTable[item_name] = {};
      newPlayer = await db.query(`UPDATE player set currency = $2, ${type} = $3 where steam_id = $1 RETURNING *`, [id, newCurrency, newTable]);
    }

    if (newPlayer === null) return res.status(403).json({ error: "Ошибка" });

    res.json({ user: newPlayer.rows[0] });
  }
}

module.exports = new StoreController();
