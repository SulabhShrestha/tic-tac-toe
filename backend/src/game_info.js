// manages players state playing in different room
let game_info = [];

module.exports = {
  getGameInfoByRoom: (room) => {
    return game_info.find((game) => game.room == room);
  },
  addGameInfo: (newInfo) => {
    game_info = [...game_info, newInfo];

    console.log("Game info; ", game_info);
  },
  setGameInfo: (updatedGameInfo) => (game_info = updatedGameInfo),

  updateGameInfoByRoom: (room, updatedInfo) => {
    game_info = game_info.map((game) => {
      // Check if the room property matches the provided room
      if (game.room === room) {
        // Update the matched object with the new data
        return { ...game, ...updatedInfo };
      }
      // If the room doesn't match, return the original object
      return game;
    });
  },

  // New method to add selected cells to the game info
  addSelectedCellInfo: (room, cellsInfo) => {
    game_info = game_info.map((game) => {
      // Check if the room property matches the provided room
      if (game.room === room) {
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
    console.log("game info", game_info[0]["selectedCells"], game_info);
  },
};
