const playerInfo = {
  getRollPlayer: () => {
    const rollTable = CustomNetTables.GetTableValue("rolls_player", `${Players.GetLocalPlayer()}`);
    return rollTable ? rollTable.roll : 0;
  },
  getMusicPlayer: (playerId) => {
    const playerInfo = CustomNetTables.GetTableValue("player_info", `${playerId}`);
    const music = CustomNetTables.GetTableValue("server_info", `music`) || {};

    if (!playerInfo || !playerInfo.music) return "";

    for (const [itemName, itemData] of Object.entries(playerInfo.music)) {
      if (itemData.isActive && music[itemName]) {
        const sound = music[itemName].sound;

        return sound || "";
      }
    }

    return "";
  },
  getPlayerRaiting: (playerId) => {
    const playerTable = CustomNetTables.GetTableValue("player_info", `${playerId}`) || {};

    return playerTable.rating_elo?.[Game.GetMapInfo().map_display_name] || 0;
  },

  getPlayerGivingRating: (playerId) => {
    const givingRating = CustomNetTables.GetTableValue("server_info", `get_raiting`) || {};

    return givingRating[`${playerId}`] || 0;
  },
  getPlayerWinStreak: (playerId) => {
    const playerTable = CustomNetTables.GetTableValue("player_info", `${playerId}`) || {};

    return playerTable.win_streak_current || 0;
  },
};
