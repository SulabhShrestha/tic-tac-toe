const { GAME_STATES, GAME_RESULTS } = require("../constants");

/**
 * Game Info Model
 */
class GameInfo {
  constructor(roomID, createdBy) {
    this.roomID = roomID;
    this.players = [createdBy];
    this.playerTurn = null;
    this.selectedCells = [];
    this.gameState = GAME_STATES.WAITING;
    this.winner = null;
    this.result = null;
    this.winSequence = null;
    this.createdAt = new Date();
    this.updatedAt = new Date();
    this.turnStartTime = null;
    this.gameStartTime = null;
    this.gameEndTime = null;
    this.lastActivity = new Date();
  }

  /**
   * Add a player to the game
   */
  addPlayer(playerId) {
    if (this.players.length >= 2) {
      throw new Error("Game is full");
    }
    if (this.players.includes(playerId)) {
      throw new Error("Player already in game");
    }
    this.players.push(playerId);
    this.updatedAt = new Date();
    this.lastActivity = new Date();
  }

  /**
   * Start the game with random first player
   */
  startGame() {
    if (this.players.length !== 2) {
      throw new Error("Need exactly 2 players to start");
    }

    const randomIndex = Math.floor(Math.random() * 100);
    this.playerTurn = this.players[randomIndex % 2];
    this.gameState = GAME_STATES.IN_PROGRESS;
    this.gameStartTime = new Date();
    this.turnStartTime = new Date();
    this.updatedAt = new Date();
    this.lastActivity = new Date();
  }

  /**
   * Make a move
   */
  makeMove(playerId, cellIndex) {
    if (this.gameState !== GAME_STATES.IN_PROGRESS) {
      throw new Error("Game is not in progress");
    }
    if (this.playerTurn !== playerId) {
      throw new Error("Not player's turn");
    }
    if (this.isCellOccupied(cellIndex)) {
      throw new Error("Cell is already occupied");
    }

    const move = new SelectedCell(playerId, cellIndex);
    this.selectedCells.push(move);

    // Switch turns
    const currentPlayerIndex = this.players.indexOf(playerId);
    this.playerTurn = this.players[(currentPlayerIndex + 1) % 2];
    this.turnStartTime = new Date();
    this.updatedAt = new Date();
    this.lastActivity = new Date();

    return move;
  }

  /**
   * Check if a cell is occupied
   */
  isCellOccupied(cellIndex) {
    return this.selectedCells.some((cell) => cell.selectedIndex === cellIndex);
  }

  /**
   * Get moves by player
   */
  getMovesByPlayer(playerId) {
    return this.selectedCells
      .filter((cell) => cell.selectedBy === playerId)
      .map((cell) => cell.selectedIndex);
  }

  /**
   * Get moves grouped by player
   */
  getGroupedMoves() {
    return this.selectedCells.reduce((acc, cell) => {
      const { selectedBy, selectedIndex } = cell;
      acc[selectedBy] = acc[selectedBy] || [];
      acc[selectedBy].push(selectedIndex);
      return acc;
    }, {});
  }

  /**
   * End the game
   */
  endGame(result, winner = null, winSequence = null) {
    this.gameState = GAME_STATES.COMPLETED;
    this.result = result;
    this.winner = winner;
    this.winSequence = winSequence;
    this.gameEndTime = new Date();
    this.updatedAt = new Date();
    this.lastActivity = new Date();
  }

  /**
   * Reset game for play again
   */
  resetGame() {
    this.selectedCells = [];
    this.gameState = GAME_STATES.IN_PROGRESS;
    this.winner = null;
    this.result = null;
    this.winSequence = null;
    this.gameStartTime = new Date();
    this.turnStartTime = new Date();
    this.updatedAt = new Date();
    this.lastActivity = new Date();

    // Second player goes first in new game
    if (this.selectedCells.length >= 2) {
      this.playerTurn = this.selectedCells[1].selectedBy;
    }
  }

  /**
   * Check if game has timed out
   */
  hasTimedOut(turnTimeout, gameTimeout) {
    const now = new Date();

    // Check turn timeout
    if (this.gameState === GAME_STATES.IN_PROGRESS && this.turnStartTime) {
      if (now - this.turnStartTime > turnTimeout) {
        return { type: "turn", timeoutPlayer: this.playerTurn };
      }
    }

    // Check game timeout
    if (this.gameStartTime && now - this.gameStartTime > gameTimeout) {
      return { type: "game" };
    }

    return null;
  }

  /**
   * Validate the game state
   */
  isValid() {
    // Basic validations
    if (!this.roomID || typeof this.roomID !== "string") return false;
    if (!Array.isArray(this.players) || this.players.length > 2) return false;
    if (!Array.isArray(this.selectedCells)) return false;
    if (this.selectedCells.length > 9) return false;

    // Check for duplicate moves
    const indices = this.selectedCells.map((cell) => cell.selectedIndex);
    if (new Set(indices).size !== indices.length) return false;

    // Check if all moves are valid
    return this.selectedCells.every(
      (cell) =>
        cell.selectedIndex >= 0 &&
        cell.selectedIndex <= 8 &&
        this.players.includes(cell.selectedBy)
    );
  }

  /**
   * Convert to JSON for API responses
   */
  toJSON() {
    return {
      roomID: this.roomID,
      players: this.players,
      playerTurn: this.playerTurn,
      selectedCells: this.selectedCells,
      gameState: this.gameState,
      winner: this.winner,
      result: this.result,
      winSequence: this.winSequence,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      gameStartTime: this.gameStartTime,
      gameEndTime: this.gameEndTime,
      moveCount: this.selectedCells.length,
    };
  }
}

/**
 * Selected Cell Model
 */
class SelectedCell {
  constructor(selectedBy, selectedIndex) {
    this.selectedBy = selectedBy;
    this.selectedIndex = selectedIndex;
    this.timestamp = new Date();
  }

  /**
   * Validate the selected cell
   */
  isValid() {
    return (
      typeof this.selectedBy === "string" &&
      this.selectedBy.length > 0 &&
      Number.isInteger(this.selectedIndex) &&
      this.selectedIndex >= 0 &&
      this.selectedIndex <= 8
    );
  }

  toJSON() {
    return {
      selectedBy: this.selectedBy,
      selectedIndex: this.selectedIndex,
      timestamp: this.timestamp,
    };
  }
}

/**
 * Socket Connection Model
 */
class SocketConnection {
  constructor(socketId, userId) {
    this.socketId = socketId;
    this.userId = userId;
    this.connectedAt = new Date();
    this.lastActivity = new Date();
    this.eventCount = 0;
  }

  updateActivity() {
    this.lastActivity = new Date();
    this.eventCount++;
  }

  toJSON() {
    return {
      socketId: this.socketId,
      userId: this.userId,
      connectedAt: this.connectedAt,
      lastActivity: this.lastActivity,
      eventCount: this.eventCount,
    };
  }
}

/**
 * Play Again Request Model
 */
class PlayAgainRequest {
  constructor(roomID, requestedBy) {
    this.roomID = roomID;
    this.requestedBy = requestedBy;
    this.createdAt = new Date();
  }

  isExpired(timeout = 60000) {
    // 1 minute default
    return new Date() - this.createdAt > timeout;
  }

  toJSON() {
    return {
      roomID: this.roomID,
      requestedBy: this.requestedBy,
      createdAt: this.createdAt,
    };
  }
}

/**
 * Game Event Model for logging
 */
class GameEvent {
  constructor(type, roomID, playerId, data = {}) {
    this.type = type;
    this.roomID = roomID;
    this.playerId = playerId;
    this.data = data;
    this.timestamp = new Date();
  }

  toJSON() {
    return {
      type: this.type,
      roomID: this.roomID,
      playerId: this.playerId,
      data: this.data,
      timestamp: this.timestamp,
    };
  }
}

module.exports = {
  GameInfo,
  SelectedCell,
  SocketConnection,
  PlayAgainRequest,
  GameEvent,
};
