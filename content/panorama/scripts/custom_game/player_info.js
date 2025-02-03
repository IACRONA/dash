const storeInfo = CustomNetTables.GetTableValue("server_info", "store");

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
};
