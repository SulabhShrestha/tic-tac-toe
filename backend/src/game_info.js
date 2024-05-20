// manages players state playing in different room
let game_info = [];

module.exports = {
  getGameInfoByRoomId: (roomID) => {
    return game_info.find((game) => game.roomID == roomID);
  },
  addGameInfo: (newInfo) => {
    game_info = [...game_info, newInfo];

  },
  setGameInfo: (updatedGameInfo) => (game_info = updatedGameInfo),

  updateGameInfoByRoomId: (roomID, updatedInfo) => {
    game_info = game_info.map((game) => {
      // Check if the room property matches the provided room
      if (game.roomID === roomID) {
        // Update the matched object with the new data
        return { ...game, ...updatedInfo };
      }
      // If the room doesn't match, return the original object
      return game;
    });
  },

  // get game info by user id
  getGameInfoByUserId: (uid) => {
    console.log("Getting games: ", game_info, uid);
    return game_info.find((game) => game.players.includes(uid));
  },

  // delete game
  deleteGameInfoByUserId: (uid) => {
    
    game_info = game_info.filter((game) => !game.players.includes(uid));

    console.log("After: ", game_info);
  },

  // remove all the selected cells from the game info
  clearSelectedCellsInfoByRoomID: (roomID) => {
    
    game_info = game_info.map((game) => {
      // Check if the room property matches the provided room
      if (game.roomID === roomID) {
        // Update the matched object with new selected cells
        return { ...game, selectedCells: [] };
      }

      // If the room doesn't match, return the original object
      return game;
    });
  },

  // New method to add selected cells to the game info
  addSelectedCellInfo: (roomID, cellsInfo) => {
    game_info = game_info.map((game) => {
      // Check if the room property matches the provided room
      if (game.roomID === roomID) {
        // Check if selectedCells is an array, if not, initialize it as an empty array
        const currentSelectedCells = Array.isArray(game.selectedCells)
          ? game.selectedCells
          : [];

        // Update the matched object with new selected cells
        return { ...game, selectedCells: [...currentSelectedCells, cellsInfo] };
      }
      // If the room doesn't match, return the original object
      return game;
    });
  },

  getSelectedCellsInfoByRoomID: (roomID) => {
    const game = game_info.find((game) => game.roomID === roomID);

    return game.selectedCells;
  },
};
