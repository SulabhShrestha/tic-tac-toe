const {
  GameInfo,
  SelectedCell,
  PlayAgainRequest,
} = require("../models/GameModels");
const {
  GAME,
  GAME_STATES,
  GAME_RESULTS,
  ERROR_MESSAGES,
} = require("../constants");
const logger = require("../config/logger");

/**
 * Game Service - Handles all game logic and state management
 */
class GameService {
  constructor() {
    this.games = new Map(); // roomID -> GameInfo
    this.playAgainRequests = new Map(); // roomID -> PlayAgainRequest
    this.timeouts = new Map(); // roomID -> timeout objects
  }

  /**
   * Create a new game room
   */
  createRoom(userId) {
    try {
      const roomId = this.generateRoomId();
      const gameInfo = new GameInfo(roomId, userId);

      this.games.set(roomId, gameInfo);

      logger.gameEvent("room-created", {
        roomID: roomId,
        createdBy: userId,
        timestamp: new Date(),
      });

      return {
        success: true,
        roomId,
        gameInfo: gameInfo.toJSON(),
      };
    } catch (error) {
      logger.errorDetails(error, { action: "createRoom", userId });
      return {
        success: false,
        error: ERROR_MESSAGES.SERVER_ERROR,
      };
    }
  }

  /**
   * Join an existing game room
   */
  joinRoom(userId, roomId) {
    try {
      const gameInfo = this.games.get(roomId);

      if (!gameInfo) {
        logger.warn("Room join failed - room not found", { roomId, userId });
        return {
          success: false,
          error: ERROR_MESSAGES.ROOM_NOT_FOUND,
        };
      }

      if (gameInfo.players.length >= GAME.MAX_PLAYERS) {
        logger.warn("Room join failed - room is full", {
          roomId,
          userId,
          currentPlayers: gameInfo.players,
        });
        return {
          success: false,
          error: ERROR_MESSAGES.ROOM_FULL,
        };
      }

      if (gameInfo.players.includes(userId)) {
        logger.warn("Room join failed - player already in room", {
          roomId,
          userId,
        });
        return {
          success: false,
          error: "Player already in this room",
        };
      }

      // Add player and start game
      gameInfo.addPlayer(userId);
      gameInfo.startGame();

      // Set up game timeout
      this.setupGameTimeout(roomId);

      logger.gameEvent("game-started", {
        roomID: roomId,
        players: gameInfo.players,
        firstPlayer: gameInfo.playerTurn,
      });

      return {
        success: true,
        gameInfo: gameInfo.toJSON(),
        gameStarted: true,
      };
    } catch (error) {
      logger.errorDetails(error, { action: "joinRoom", userId, roomId });
      return {
        success: false,
        error: error.message || ERROR_MESSAGES.SERVER_ERROR,
      };
    }
  }

  /**
   * Make a move in the game
   */
  makeMove(userId, roomId, cellIndex) {
    try {
      const gameInfo = this.games.get(roomId);

      if (!gameInfo) {
        return {
          success: false,
          error: ERROR_MESSAGES.ROOM_NOT_FOUND,
        };
      }

      // Validate game state
      if (gameInfo.gameState !== GAME_STATES.IN_PROGRESS) {
        return {
          success: false,
          error: ERROR_MESSAGES.GAME_NOT_IN_PROGRESS,
        };
      }

      // Validate turn
      if (gameInfo.playerTurn !== userId) {
        logger.security("invalid-turn-attempt", {
          roomId,
          expectedPlayer: gameInfo.playerTurn,
          attemptedBy: userId,
        });
        return {
          success: false,
          error: ERROR_MESSAGES.NOT_YOUR_TURN,
        };
      }

      // Validate cell availability
      if (gameInfo.isCellOccupied(cellIndex)) {
        return {
          success: false,
          error: ERROR_MESSAGES.CELL_OCCUPIED,
        };
      }

      // Make the move
      const move = gameInfo.makeMove(userId, cellIndex);

      // Reset turn timeout and set new one
      this.clearTurnTimeout(roomId);
      this.setupTurnTimeout(roomId);

      logger.gameEvent("move-made", {
        roomID: roomId,
        player: userId,
        cellIndex,
        nextPlayer: gameInfo.playerTurn,
        moveCount: gameInfo.selectedCells.length,
      });

      // Check for game conclusion
      const conclusion = this.checkGameConclusion(gameInfo);

      return {
        success: true,
        move: move.toJSON(),
        gameInfo: gameInfo.toJSON(),
        conclusion,
      };
    } catch (error) {
      logger.errorDetails(error, {
        action: "makeMove",
        userId,
        roomId,
        cellIndex,
      });
      return {
        success: false,
        error: error.message || ERROR_MESSAGES.SERVER_ERROR,
      };
    }
  }

  /**
   * Check if game has concluded (win/draw)
   */
  checkGameConclusion(gameInfo) {
    const groupedMoves = gameInfo.getGroupedMoves();

    // Check for win
    for (const [playerId, moves] of Object.entries(groupedMoves)) {
      const winSequence = this.getWinningSequence(moves);
      if (winSequence) {
        gameInfo.endGame(GAME_RESULTS.WIN, playerId, winSequence);

        this.clearAllTimeouts(gameInfo.roomID);

        logger.gameEvent("game-won", {
          roomID: gameInfo.roomID,
          winner: playerId,
          winSequence,
          totalMoves: gameInfo.selectedCells.length,
        });

        return {
          concluded: true,
          result: GAME_RESULTS.WIN,
          winner: playerId,
          winSequence,
        };
      }
    }

    // Check for draw (all cells filled)
    if (gameInfo.selectedCells.length === GAME.BOARD_SIZE) {
      gameInfo.endGame(GAME_RESULTS.DRAW);

      this.clearAllTimeouts(gameInfo.roomID);

      logger.gameEvent("game-draw", {
        roomID: gameInfo.roomID,
        totalMoves: gameInfo.selectedCells.length,
      });

      return {
        concluded: true,
        result: GAME_RESULTS.DRAW,
      };
    }

    return { concluded: false };
  }

  /**
   * Get winning sequence if exists
   */
  getWinningSequence(moves) {
    return (
      GAME.WINNING_SEQUENCES.find((sequence) =>
        sequence.every((index) => moves.includes(index))
      ) || null
    );
  }

  /**
   * Handle play again request
   */
  requestPlayAgain(userId, roomId) {
    try {
      const gameInfo = this.games.get(roomId);

      if (!gameInfo) {
        return {
          success: false,
          error: ERROR_MESSAGES.ROOM_NOT_FOUND,
        };
      }

      if (gameInfo.gameState !== GAME_STATES.COMPLETED) {
        return {
          success: false,
          error: "Game is not completed yet",
        };
      }

      if (this.playAgainRequests.has(roomId)) {
        return {
          success: false,
          error: ERROR_MESSAGES.DUPLICATE_PLAY_AGAIN,
        };
      }

      const request = new PlayAgainRequest(roomId, userId);
      this.playAgainRequests.set(roomId, request);

      logger.gameEvent("play-again-requested", {
        roomID: roomId,
        requestedBy: userId,
      });

      return {
        success: true,
        request: request.toJSON(),
      };
    } catch (error) {
      logger.errorDetails(error, {
        action: "requestPlayAgain",
        userId,
        roomId,
      });
      return {
        success: false,
        error: ERROR_MESSAGES.SERVER_ERROR,
      };
    }
  }

  /**
   * Accept play again request
   */
  acceptPlayAgain(roomId) {
    try {
      const gameInfo = this.games.get(roomId);
      const request = this.playAgainRequests.get(roomId);

      if (!gameInfo || !request) {
        return {
          success: false,
          error: "No play again request found",
        };
      }

      // Determine who goes first (second player from previous game)
      let firstPlayer;
      if (gameInfo.selectedCells.length >= 2) {
        firstPlayer = gameInfo.selectedCells[1].selectedBy;
      } else {
        // Fallback to random if no previous moves
        const randomIndex = Math.floor(Math.random() * 2);
        firstPlayer = gameInfo.players[randomIndex];
      }

      // Reset game
      gameInfo.resetGame();
      gameInfo.playerTurn = firstPlayer;

      // Remove play again request
      this.playAgainRequests.delete(roomId);

      // Setup new timeouts
      this.setupGameTimeout(roomId);
      this.setupTurnTimeout(roomId);

      logger.gameEvent("game-restarted", {
        roomID: roomId,
        firstPlayer,
      });

      return {
        success: true,
        gameInfo: gameInfo.toJSON(),
        firstPlayer,
      };
    } catch (error) {
      logger.errorDetails(error, { action: "acceptPlayAgain", roomId });
      return {
        success: false,
        error: ERROR_MESSAGES.SERVER_ERROR,
      };
    }
  }

  /**
   * Handle user disconnection
   */
  handleDisconnection(userId) {
    try {
      const gameInfo = this.findGameByUserId(userId);

      if (!gameInfo) {
        logger.warn("User disconnected but no game found", { userId });
        return null;
      }

      logger.gameEvent("user-disconnected", {
        roomID: gameInfo.roomID,
        userId,
        gameState: gameInfo.gameState,
      });

      // If game is in progress, mark as abandoned
      if (gameInfo.gameState === GAME_STATES.IN_PROGRESS) {
        const winner = gameInfo.players.find((p) => p !== userId);
        gameInfo.endGame(GAME_RESULTS.FORFEIT, winner);

        logger.gameEvent("game-forfeited", {
          roomID: gameInfo.roomID,
          forfeiter: userId,
          winner,
        });
      }

      // Clean up timeouts
      this.clearAllTimeouts(gameInfo.roomID);

      // Clean up game after some time
      setTimeout(() => {
        this.cleanupGame(gameInfo.roomID);
      }, 60000); // 1 minute

      return gameInfo;
    } catch (error) {
      logger.errorDetails(error, { action: "handleDisconnection", userId });
      return null;
    }
  }

  /**
   * Setup turn timeout
   */
  setupTurnTimeout(roomId) {
    this.clearTurnTimeout(roomId);

    const timeout = setTimeout(() => {
      this.handleTurnTimeout(roomId);
    }, GAME.TURN_TIMEOUT);

    if (!this.timeouts.has(roomId)) {
      this.timeouts.set(roomId, {});
    }
    this.timeouts.get(roomId).turn = timeout;
  }

  /**
   * Setup game timeout
   */
  setupGameTimeout(roomId) {
    this.clearGameTimeout(roomId);

    const timeout = setTimeout(() => {
      this.handleGameTimeout(roomId);
    }, GAME.GAME_TIMEOUT);

    if (!this.timeouts.has(roomId)) {
      this.timeouts.set(roomId, {});
    }
    this.timeouts.get(roomId).game = timeout;
  }

  /**
   * Handle turn timeout
   */
  handleTurnTimeout(roomId) {
    const gameInfo = this.games.get(roomId);
    if (!gameInfo || gameInfo.gameState !== GAME_STATES.IN_PROGRESS) {
      return;
    }

    const timeoutPlayer = gameInfo.playerTurn;
    const winner = gameInfo.players.find((p) => p !== timeoutPlayer);

    gameInfo.endGame(GAME_RESULTS.TIMEOUT, winner);

    logger.gameEvent("turn-timeout", {
      roomID: roomId,
      timeoutPlayer,
      winner,
    });

    return {
      type: "turn",
      timeoutPlayer,
      winner,
      gameInfo: gameInfo.toJSON(),
    };
  }

  /**
   * Handle game timeout
   */
  handleGameTimeout(roomId) {
    const gameInfo = this.games.get(roomId);
    if (!gameInfo) return;

    gameInfo.gameState = GAME_STATES.TIMEOUT;
    this.clearAllTimeouts(roomId);

    logger.gameEvent("game-timeout", {
      roomID: roomId,
      duration: Date.now() - gameInfo.gameStartTime,
    });

    return gameInfo;
  }

  /**
   * Clear turn timeout
   */
  clearTurnTimeout(roomId) {
    const timeouts = this.timeouts.get(roomId);
    if (timeouts?.turn) {
      clearTimeout(timeouts.turn);
      delete timeouts.turn;
    }
  }

  /**
   * Clear game timeout
   */
  clearGameTimeout(roomId) {
    const timeouts = this.timeouts.get(roomId);
    if (timeouts?.game) {
      clearTimeout(timeouts.game);
      delete timeouts.game;
    }
  }

  /**
   * Clear all timeouts for a room
   */
  clearAllTimeouts(roomId) {
    this.clearTurnTimeout(roomId);
    this.clearGameTimeout(roomId);
    this.timeouts.delete(roomId);
  }

  /**
   * Generate room ID
   */
  generateRoomId() {
    // For testing purposes, return hardcoded value
    // TODO: Remove this in production
    return "sulabh";

    // Uncomment for production:
    // let result = '';
    // for (let i = 0; i < GAME.ROOM_ID_LENGTH; i++) {
    //   const randomIndex = Math.floor(Math.random() * GAME.ROOM_ID_CHARACTERS.length);
    //   result += GAME.ROOM_ID_CHARACTERS.charAt(randomIndex);
    // }
    // return result;
  }

  /**
   * Find game by user ID
   */
  findGameByUserId(userId) {
    for (const gameInfo of this.games.values()) {
      if (gameInfo.players.includes(userId)) {
        return gameInfo;
      }
    }
    return null;
  }

  /**
   * Get game by room ID
   */
  getGameByRoomId(roomId) {
    return this.games.get(roomId) || null;
  }

  /**
   * Clean up game data
   */
  cleanupGame(roomId) {
    this.games.delete(roomId);
    this.playAgainRequests.delete(roomId);
    this.clearAllTimeouts(roomId);

    logger.gameEvent("game-cleaned-up", { roomID: roomId });
  }

  /**
   * Get game statistics
   */
  getGameStats() {
    const stats = {
      totalGames: this.games.size,
      activeGames: 0,
      waitingGames: 0,
      completedGames: 0,
      playAgainRequests: this.playAgainRequests.size,
    };

    for (const game of this.games.values()) {
      switch (game.gameState) {
        case GAME_STATES.IN_PROGRESS:
          stats.activeGames++;
          break;
        case GAME_STATES.WAITING:
          stats.waitingGames++;
          break;
        case GAME_STATES.COMPLETED:
          stats.completedGames++;
          break;
      }
    }

    return stats;
  }

  /**
   * Periodic cleanup of old games and requests
   */
  performCleanup() {
    const now = new Date();
    const cleanupAge = 24 * 60 * 60 * 1000; // 24 hours

    // Clean up old games
    for (const [roomId, game] of this.games.entries()) {
      if (now - game.lastActivity > cleanupAge) {
        this.cleanupGame(roomId);
      }
    }

    // Clean up expired play again requests
    for (const [roomId, request] of this.playAgainRequests.entries()) {
      if (request.isExpired()) {
        this.playAgainRequests.delete(roomId);
      }
    }

    logger.info("Performed periodic cleanup", {
      activeGames: this.games.size,
      playAgainRequests: this.playAgainRequests.size,
    });
  }
}

module.exports = GameService;
