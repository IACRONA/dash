const db = require("../db");

class PlayerController {
  async getOrCreatePlayer(req, res) {
    const id = req.params.id;
    const player = await db.query("SELECT * FROM player where steam_id = $1", [id]);
    const user = player.rows[0];

    if (!user) {
      const newUser = await db.query("INSERT INTO player (steam_id) values ($1) RETURNING *", [id]);

      return res.json(newUser.rows[0]);
    }

    res.json(user);
  }
}

module.exports = new PlayerController();
