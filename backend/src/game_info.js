// manages players state playing in different room
let game_info = [];

module.exports = {
  getGameInfo: () => game_info,
  addGameInfo: (newInfo) => {
    game_info = [...game_info, newInfo];

    console.log("Game info; ", game_info);
  },
  setGameInfo: (updatedGameInfo) => (game_info = updatedGameInfo),
};
