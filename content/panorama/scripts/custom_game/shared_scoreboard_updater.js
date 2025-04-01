"use strict";

//=============================================================================
//=============================================================================
function _ScoreboardUpdater_SetTextSafe(panel, childName, textValue) {
  if (panel === null) return;
  var childPanel = panel.FindChildInLayoutFile(childName);
  if (childPanel === null) return;

  childPanel.text = textValue;
}

//=============================================================================
//=============================================================================
function _ScoreboardUpdater_UpdatePlayerPanel(scoreboardConfig, playersContainer, playerId, localPlayerTeamId, isGameEnd) {
  var playerPanelName = "_dynamic_player_" + playerId;
  var playerPanel = playersContainer.FindChild(playerPanelName);
  if (playerPanel === null) {
    playerPanel = $.CreatePanel("Panel", playersContainer, playerPanelName);
    playerPanel.SetAttributeInt("player_id", playerId);
    playerPanel.BLoadLayout(scoreboardConfig.playerXmlName, false, false);
  }

  playerPanel.SetHasClass("is_local_player", playerId == Game.GetLocalPlayerID());

  var isTeammate = false;

  var gamePlayerInfo = Game.GetPlayerInfo(playerId);

  if (gamePlayerInfo) {
    isTeammate = gamePlayerInfo.player_team_id == localPlayerTeamId;

    playerPanel.SetHasClass("player_dead", gamePlayerInfo.player_respawn_seconds >= 0);
    playerPanel.SetHasClass("local_player_teammate", isTeammate && playerId != Game.GetLocalPlayerID());
    _ScoreboardUpdater_SetTextSafe(playerPanel, "RespawnTimer", gamePlayerInfo.player_respawn_seconds + 1); // value is rounded down so just add one for rounded-up

    if (isGameEnd) {
      const givingRating = playerInfo.getPlayerGivingRating(playerId);
      const addRatingText = `${givingRating < 0 ? "-" : "+"} ${givingRating}`;

      const ratingText = `${playerInfo.getPlayerRaiting(playerId)} <font color="#${givingRating < 0 ? "ff0000" : "009900"}"> ${addRatingText}</font>`;

      _ScoreboardUpdater_SetTextSafe(playerPanel, "PlayerName", gamePlayerInfo.player_name);
      _ScoreboardUpdater_SetTextSafe(playerPanel, "Level", gamePlayerInfo.player_level);
      _ScoreboardUpdater_SetTextSafe(playerPanel, "Kills", gamePlayerInfo.player_kills);
      _ScoreboardUpdater_SetTextSafe(playerPanel, "Deaths", gamePlayerInfo.player_deaths);
      _ScoreboardUpdater_SetTextSafe(playerPanel, "Assists", gamePlayerInfo.player_assists);
      _ScoreboardUpdater_SetTextSafe(playerPanel, "Raiting", ratingText);

      if (gamePlayerInfo.player_selected_hero_id == -1) {
        _ScoreboardUpdater_SetTextSafe(playerPanel, "HeroName", $.Localize("#DOTA_Scoreboard_Picking_Hero"));
      } else {
        _ScoreboardUpdater_SetTextSafe(playerPanel, "HeroName", $.Localize("#" + gamePlayerInfo.player_selected_hero));
      }
      var heroNameAndDescription = playerPanel.FindChildInLayoutFile("HeroNameAndDescription");
      if (heroNameAndDescription) {
        if (gamePlayerInfo.player_selected_hero_id == -1) {
          heroNameAndDescription.SetDialogVariable("hero_name", $.Localize("#DOTA_Scoreboard_Picking_Hero"));
        } else {
          heroNameAndDescription.SetDialogVariable("hero_name", $.Localize("#" + gamePlayerInfo.player_selected_hero));
        }
        heroNameAndDescription.SetDialogVariableInt("hero_level", gamePlayerInfo.player_level);
      }
    }

    var playerPortrait = playerPanel.FindChildInLayoutFile("HeroIcon");
    if (playerPortrait) {
      if (gamePlayerInfo.player_selected_hero !== "") {
        playerPortrait.SetImage("file://{images}/heroes/" + gamePlayerInfo.player_selected_hero + ".png");
      } else {
        playerPortrait.SetImage("file://{images}/custom_game/unassigned.png");
      }
    }
  }

  playerPanel.SetHasClass("player_connection_abandoned", gamePlayerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED);
  playerPanel.SetHasClass("player_connection_failed", gamePlayerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_FAILED);
  playerPanel.SetHasClass("player_connection_disconnected", gamePlayerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED);

  var playerColorBar = playerPanel.FindChildInLayoutFile("PlayerColorBar");
  if (playerColorBar !== null) {
    if (GameUI.CustomUIConfig().team_colors) {
      var teamColor = GameUI.CustomUIConfig().team_colors[gamePlayerInfo.player_team_id];
      if (teamColor) {
        playerColorBar.style.backgroundColor = teamColor;
      }
    } else {
      var playerColor = "#000000";
      playerColorBar.style.backgroundColor = playerColor;
    }
  }

  if (isGameEnd) {
    var playerItemsContainer = playerPanel.FindChildInLayoutFile("PlayerItemsContainer");

    if (playerItemsContainer) {
      var playerItems = Game.GetPlayerItems(playerId);
      if (playerItems) {
        //   $.Msg("playerItems = ", playerItems);
        var i;
        for (i = playerItems.inventory_slot_min; i < playerItems.inventory_slot_max; ++i) {
          // skip over backpack items
          if (i >= playerItems.inventory_slot_max - playerItems.backpack_size) {
            continue;
          }

          var itemPanelName = "_dynamic_item_" + i;
          var itemPanel = playerItemsContainer.FindChild(itemPanelName);
          var itemInfo = playerItems.inventory[i];

          if (itemPanel === null) {
            itemPanel = $.CreatePanel("DOTAItemImage", playerItemsContainer, itemPanelName, {
              itemname: itemInfo ? itemInfo.item_name : "",
            });
            itemPanel.AddClass("PlayerItem");
          }
        }

        var itemPanelName = "_dynamic_item_" + i;
        var itemPanel = playerItemsContainer.FindChild(itemPanelName);
        if (itemPanel === null) {
          itemPanel = $.CreatePanel("Image", playerItemsContainer, itemPanelName);
          itemPanel.AddClass("PlayerItem");
        }

        var itemInfo = playerItems.neutral_item;
        if (itemInfo) {
          var item_image_name = "file://{images}/items/" + itemInfo.item_name.replace("item_", "") + ".png";
          itemPanel.SetImage(item_image_name);
        } else {
          itemPanel.SetImage("");
        }
      }
    }
  }
}

//=============================================================================
//=============================================================================
function _ScoreboardUpdater_UpdateTeamPanel(scoreboardConfig, containerPanel, teamDetails, teamsInfo, isGameEnd) {
  if (!containerPanel) return;

  var teamId = teamDetails.team_id;
  //	$.Msg( "_ScoreboardUpdater_UpdateTeamPanel: ", teamId );

  var teamPanelName = "_dynamic_team_" + teamId;
  var teamPanel = containerPanel.FindChild(teamPanelName);
  if (teamPanel === null) {
    //		$.Msg( "UpdateTeamPanel.Create: ", teamPanelName, " = ", scoreboardConfig.teamXmlName );
    teamPanel = $.CreatePanel("Panel", containerPanel, teamPanelName);
    teamPanel.SetAttributeInt("team_id", teamId);
    teamPanel.BLoadLayout(scoreboardConfig.teamXmlName, false, false);
  }

  var localPlayerTeamId = -1;
  var localPlayer = Game.GetLocalPlayerInfo();
  if (localPlayer) {
    localPlayerTeamId = localPlayer.player_team_id;
  }
  teamPanel.SetHasClass("local_player_team", localPlayerTeamId == teamId);
  teamPanel.SetHasClass("not_local_player_team", localPlayerTeamId != teamId);

  var teamPlayers = Game.GetPlayerIDsOnTeam(teamId);
  var playersContainer = teamPanel.FindChildInLayoutFile("PlayersContainer");
  if (playersContainer) {
    for (var playerId of teamPlayers) {
      _ScoreboardUpdater_UpdatePlayerPanel(scoreboardConfig, playersContainer, playerId, localPlayerTeamId, isGameEnd);
    }
  }

  teamPanel.SetHasClass("no_players", teamPlayers.length == 0);
  teamPanel.SetHasClass("one_player", teamPlayers.length == 1);
  teamPanel.SetHasClass("ten_players", teamPlayers.length == 10);

  if (teamsInfo.max_team_players < teamPlayers.length) {
    teamsInfo.max_team_players = teamPlayers.length;
  }

  let bonus_kills_morph = 0;
  let kills_morph = CustomNetTables.GetTableValue("kills_morph", String(teamId));
  if (kills_morph) {
    bonus_kills_morph = Number(kills_morph.kills);
  }

  _ScoreboardUpdater_SetTextSafe(teamPanel, "TeamScore", teamDetails.team_score + bonus_kills_morph);
  _ScoreboardUpdater_SetTextSafe(teamPanel, "TeamName", $.Localize(teamDetails.team_name));

  if (GameUI.CustomUIConfig().kills_count_info != null && teamDetails.team_score + bonus_kills_morph >= GameUI.CustomUIConfig().kills_count_info - 5) {
    let KillsRemaining = teamPanel.FindChildInLayoutFile("KillsRemaining");
    if (KillsRemaining) {
      KillsRemaining.style.visibility = "visible";
      KillsRemaining.text = $.Localize("#KillsRemaining") + " " + (GameUI.CustomUIConfig().kills_count_info - teamDetails.team_score + -bonus_kills_morph);
    }
  } else {
    let KillsRemaining = teamPanel.FindChildInLayoutFile("KillsRemaining");
    if (KillsRemaining) {
      KillsRemaining.style.visibility = "collapse";
    }
  }

  if (GameUI.CustomUIConfig().team_colors) {
    var teamColor = GameUI.CustomUIConfig().team_colors[teamId];
    var teamColorPanel = teamPanel.FindChildInLayoutFile("TeamColor");

    teamColor = teamColor.replace(";", "");

    if (teamColorPanel) {
      teamNamePanel.style.backgroundColor = teamColor + ";";
    }

    var teamColor_GradentFromTransparentLeft = teamPanel.FindChildInLayoutFile("TeamColor_GradentFromTransparentLeft");
    if (teamColor_GradentFromTransparentLeft) {
      var gradientText = "gradient( linear, 0% 0%, 800% 0%, from( #00000000 ), to( " + teamColor + " ) );";
      //			$.Msg( gradientText );
      teamColor_GradentFromTransparentLeft.style.backgroundColor = gradientText;
    }
  }

  return teamPanel;
}

//=============================================================================
//=============================================================================
function _ScoreboardUpdater_ReorderTeam(scoreboardConfig, teamsParent, teamPanel, teamId, newPlace, prevPanel) {
  //	$.Msg( "UPDATE: ", GameUI.CustomUIConfig().teamsPrevPlace );
  var oldPlace = null;
  if (GameUI.CustomUIConfig().teamsPrevPlace.length > teamId) {
    oldPlace = GameUI.CustomUIConfig().teamsPrevPlace[teamId];
  }
  GameUI.CustomUIConfig().teamsPrevPlace[teamId] = newPlace;

  if (newPlace != oldPlace) {
    //		$.Msg( "Team ", teamId, " : ", oldPlace, " --> ", newPlace );
    teamPanel.RemoveClass("team_getting_worse");
    teamPanel.RemoveClass("team_getting_better");
    if (newPlace > oldPlace) {
      teamPanel.AddClass("team_getting_worse");
    } else if (newPlace < oldPlace) {
      teamPanel.AddClass("team_getting_better");
    }
  }

  teamsParent.MoveChildAfter(teamPanel, prevPanel);
}

// sort / reorder as necessary
function compareFunc(a, b) {
  // GameUI.CustomUIConfig().sort_teams_compare_func;
  let team_id = a.team_id;
  let team_id_2 = b.team_id;

  let bonus_kills_morph_1 = 0;
  let kills_morph_1 = CustomNetTables.GetTableValue("kills_morph", String(team_id));
  if (kills_morph_1) {
    bonus_kills_morph_1 = Number(kills_morph_1.kills);
  }

  let bonus_kills_morph_2 = 0;
  let kills_morph_2 = CustomNetTables.GetTableValue("kills_morph", String(team_id_2));
  if (kills_morph_2) {
    bonus_kills_morph_2 = Number(kills_morph_2.kills);
  }

  if (a.team_score + bonus_kills_morph_1 < b.team_score + bonus_kills_morph_2) {
    return 1; // [ B, A ]
  } else if (a.team_score + bonus_kills_morph_1 > b.team_score + bonus_kills_morph_2) {
    return -1; // [ A, B ]
  } else {
    return 0;
  }
}

function stableCompareFunc(a, b) {
  var unstableCompare = compareFunc(a, b);
  if (unstableCompare != 0) {
    return unstableCompare;
  }

  if (GameUI.CustomUIConfig().teamsPrevPlace.length <= a.team_id) {
    return 0;
  }

  if (GameUI.CustomUIConfig().teamsPrevPlace.length <= b.team_id) {
    return 0;
  }

  //			$.Msg( GameUI.CustomUIConfig().teamsPrevPlace );

  var a_prev = GameUI.CustomUIConfig().teamsPrevPlace[a.team_id];
  var b_prev = GameUI.CustomUIConfig().teamsPrevPlace[b.team_id];
  if (a_prev < b_prev) {
    // [ A, B ]
    return -1; // [ A, B ]
  } else if (a_prev > b_prev) {
    // [ B, A ]
    return 1; // [ B, A ]
  } else {
    return 0;
  }
}

//=============================================================================
//=============================================================================
function _ScoreboardUpdater_UpdateAllTeamsAndPlayers(scoreboardConfig, teamsContainer, isGameEnd) {
  var teamsList = [];
  for (var teamId of Game.GetAllTeamIDs()) {
    teamsList.push(Game.GetTeamDetails(teamId));
  }

  var teamsInfo = { max_team_players: 0 };
  var panelsByTeam = [];
  for (var i = 0; i < teamsList.length; ++i) {
    var teamPanel = _ScoreboardUpdater_UpdateTeamPanel(scoreboardConfig, teamsContainer, teamsList[i], teamsInfo, isGameEnd);
    if (teamPanel) {
      panelsByTeam[teamsList[i].team_id] = teamPanel;
    }
  }

  if (teamsList.length > 1) {
    // sort
    if (scoreboardConfig.shouldSort) {
      teamsList.sort(stableCompareFunc);
    }

    //		$.Msg( "POST: ", teamsAndPanels );

    // reorder the panels based on the sort
    if (scoreboardConfig.shouldReorder) {
      var prevPanel = panelsByTeam[teamsList[0].team_id];
      for (var i = 0; i < teamsList.length; ++i) {
        var teamId = teamsList[i].team_id;
        var teamPanel = panelsByTeam[teamId];
        _ScoreboardUpdater_ReorderTeam(scoreboardConfig, teamsContainer, teamPanel, teamId, i, prevPanel);
        prevPanel = teamPanel;
      }
    }
    //		$.Msg( GameUI.CustomUIConfig().teamsPrevPlace );
  }

  //	$.Msg( "END _ScoreboardUpdater_UpdateAllTeamsAndPlayers: ", scoreboardConfig );
}

//=============================================================================
//=============================================================================
function ScoreboardUpdater_InitializeScoreboard(scoreboardConfig, scoreboardPanel, isGameEnd) {
  GameUI.CustomUIConfig().teamsPrevPlace = [];
  if (typeof scoreboardConfig.shouldSort === "undefined") {
    // default to true
    scoreboardConfig.shouldSort = true;
  }
  if (typeof scoreboardConfig.shouldReorder === "undefined") {
    // default to true
    scoreboardConfig.shouldReorder = true;
  }
  _ScoreboardUpdater_UpdateAllTeamsAndPlayers(scoreboardConfig, scoreboardPanel, isGameEnd);
  return { scoreboardConfig: scoreboardConfig, scoreboardPanel: scoreboardPanel };
}

//=============================================================================
//=============================================================================
function ScoreboardUpdater_SetScoreboardActive(scoreboardHandle, isActive) {
  if (scoreboardHandle.scoreboardConfig === null || scoreboardHandle.scoreboardPanel === null) {
    return;
  }

  if (isActive) {
    _ScoreboardUpdater_UpdateAllTeamsAndPlayers(scoreboardHandle.scoreboardConfig, scoreboardHandle.scoreboardPanel);
  }
}

//=============================================================================
//=============================================================================
function ScoreboardUpdater_GetTeamPanel(scoreboardHandle, teamId) {
  if (scoreboardHandle.scoreboardPanel === null) {
    return;
  }

  var teamPanelName = "_dynamic_team_" + teamId;
  return scoreboardHandle.scoreboardPanel.FindChild(teamPanelName);
}

//=============================================================================
//=============================================================================
function ScoreboardUpdater_GetSortedTeamInfoList(scoreboardHandle) {
  var teamsList = [];
  for (var teamId of Game.GetAllTeamIDs()) {
    teamsList.push(Game.GetTeamDetails(teamId));
  }

  if (teamsList.length > 1) {
    teamsList.sort(stableCompareFunc);
  }

  return teamsList;
}
