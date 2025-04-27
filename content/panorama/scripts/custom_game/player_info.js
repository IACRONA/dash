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
  getPlayerGivingCurrency: (playerId) => {
    const endGameInfo = CustomNetTables.GetTableValue("server_info", "end_game_info") || {};

    return endGameInfo[`${playerId}`]?.currency || 0;
  },
  getPlayerGivingRolls: (playerId) => {
    const endGameInfo = CustomNetTables.GetTableValue("server_info", "end_game_info") || {};

    return endGameInfo[`${playerId}`]?.roll || 0;
  },
  getPlayerGivingRating: (playerId) => {
    const givingRating = CustomNetTables.GetTableValue("server_info", `end_game_info`) || {};

    return givingRating[`${playerId}`]?.elo || 0;
  },
  getPlayerWinStreak: (playerId) => {
    const playerTable = CustomNetTables.GetTableValue("player_info", `${playerId}`) || {};

    return playerTable.win_streak_current || 0;
  },
  getKeybindsPlayer: () => {
    const rollTable = CustomNetTables.GetTableValue("player_info", `${Players.GetLocalPlayer()}`) || {};
    return rollTable.keybinds || {};
  },
};
