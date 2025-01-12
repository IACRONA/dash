const storeInfo = CustomNetTables.GetTableValue("server_info", "store");

const playerInfo = {
  getRollPlayer: (playerId) => {
    const rollTable = CustomNetTables.GetTableValue("rolls_player", `${Players.GetLocalPlayer()}`);
    return rollTable ? rollTable.roll : 0;
  },
};
