const { SocketValidation } = require('../middleware/validation');
const { SOCKET_EVENTS, ERROR_MESSAGES, SUCCESS_MESSAGES } = require('../constants');
const { SocketConnection } = require('../models/GameModels');
const logger = require('../config/logger');

/**
 * Socket Controller - Handles all socket event logic with proper error handling
 */
class SocketController {
  constructor(gameService, monitoringService) {
    this.gameService = gameService;
    this.monitoringService = monitoringService;
    this.onlineConnections = new Map(); // socketId -> SocketConnection
  }

  /**
   * Handle socket connection
   */
  handleConnection(socket, io) {
    try {
      this.monitoringService.recordConnection('connect');

      logger.socketEvent('connection', socket.id, {
        totalConnections: io.engine.clientsCount,
        timestamp: new Date(),
      });

      // Set up event handlers
      this.setupEventHandlers(socket, io);

      // Set up heartbeat
      this.setupHeartbeat(socket);
    } catch (error) {
      logger.errorDetails(error, {
        action: 'handleConnection',
        socketId: socket.id,
      });
      this.monitoringService.recordError(error, { socketId: socket.id });
    }
  }

  /**
   * Setup all socket event handlers
   */
  setupEventHandlers(socket, io) {
    // Connection management
    socket.on('disconnect', () => this.handleDisconnect(socket, io));
    socket.on(SOCKET_EVENTS.PING, (data) => this.handlePing(socket, data));

    // Game events
    socket.on(SOCKET_EVENTS.CREATE_ROOM, (data) => this.handleCreateRoom(socket, data));
    socket.on(SOCKET_EVENTS.JOIN_ROOM, (data) => this.handleJoinRoom(socket, io, data));
    socket.on(SOCKET_EVENTS.GAME_MOVE, (data) => this.handleGameMove(socket, io, data));

    // Game management events
    socket.on(SOCKET_EVENTS.PLAY_AGAIN, (data) => this.handlePlayAgain(socket, io, data));
    socket.on(SOCKET_EVENTS.PLAY_AGAIN_ACCEPTED, (data) =>
      this.handlePlayAgainAccepted(socket, io, data)
    );

    // Social events
    socket.on(SOCKET_EVENTS.EMOJI, (data) => this.handleEmoji(socket, io, data));
    socket.on(SOCKET_EVENTS.QR_SCANNED, (data) => this.handleQRScanned(socket, io, data));
  }

  /**
   * Handle socket disconnection
   */
  handleDisconnect(socket, io) {
    try {
      const connection = this.onlineConnections.get(socket.id);

      if (!connection) {
        logger.warn('Socket disconnected but no connection record found', {
          socketId: socket.id,
        });
        return;
      }

      const userId = connection.userId;

      logger.socketEvent('disconnect', socket.id, {
        userId,
        connectionDuration: Date.now() - connection.connectedAt,
        eventCount: connection.eventCount,
      });

      // Handle game-related disconnection
      const gameInfo = this.gameService.handleDisconnection(userId);

      if (gameInfo) {
        // Notify other players in the room
        socket.broadcast.to(gameInfo.roomID).emit(SOCKET_EVENTS.USER_DISCONNECTED, {
          userId,
          gameInfo: gameInfo.toJSON(),
        });
      }

      // Clean up connection tracking
      this.onlineConnections.delete(socket.id);
      this.monitoringService.recordConnection('disconnect');
    } catch (error) {
      logger.errorDetails(error, {
        action: 'handleDisconnect',
        socketId: socket.id,
      });
      this.monitoringService.recordError(error, { socketId: socket.id });
    }
  }

  /**
   * Handle ping/heartbeat
   */
  handlePing(socket, data) {
    try {
      const connection = this.onlineConnections.get(socket.id);
      if (connection) {
        connection.updateActivity();
      }

      socket.emit(SOCKET_EVENTS.PONG, {
        timestamp: Date.now(),
        data,
      });
    } catch (error) {
      logger.errorDetails(error, {
        action: 'handlePing',
        socketId: socket.id,
      });
    }
  }

  /**
   * Handle create room event
   */
  handleCreateRoom(socket, data) {
    const startTime = Date.now();

    try {
      // Validate input
      const validation = SocketValidation.validateCreateRoom(data);
      if (!validation.isValid) {
        this.emitError(socket, validation.errors.join(', '));
        return;
      }

      const { uid } = validation.sanitized;

      // Create connection record
      const connection = new SocketConnection(socket.id, uid);
      this.onlineConnections.set(socket.id, connection);

      // Create game room
      const result = this.gameService.createRoom(uid);

      if (!result.success) {
        this.emitError(socket, result.error);
        return;
      }

      // Join socket to room
      socket.join(result.roomId);

      // Emit success response
      socket.emit(SOCKET_EVENTS.ROOM_CREATED, {
        roomId: result.roomId,
        message: SUCCESS_MESSAGES.ROOM_CREATED,
        gameInfo: result.gameInfo,
      });

      logger.userAction('room-created', uid, result.roomId, {
        socketId: socket.id,
      });

      this.monitoringService.recordGame('created', {
        roomId: result.roomId,
        userId: uid,
      });
    } catch (error) {
      logger.errorDetails(error, {
        action: 'handleCreateRoom',
        socketId: socket.id,
        data,
      });
      this.monitoringService.recordError(error, { socketId: socket.id });
      this.emitError(socket, ERROR_MESSAGES.SERVER_ERROR);
    } finally {
      this.monitoringService.recordRequest(true, Date.now() - startTime, 'create-room');
    }
  }

  /**
   * Handle join room event
   */
  handleJoinRoom(socket, io, data) {
    const startTime = Date.now();

    try {
      // Validate input
      const validation = SocketValidation.validateJoinRoom(data);
      if (!validation.isValid) {
        this.emitError(socket, validation.errors.join(', '));
        return;
      }

      const { uid, roomID } = validation.sanitized;

      // Create connection record
      const connection = new SocketConnection(socket.id, uid);
      this.onlineConnections.set(socket.id, connection);

      // Join game room
      const result = this.gameService.joinRoom(uid, roomID);

      if (!result.success) {
        socket.emit(SOCKET_EVENTS.ROOM_NOT_FOUND, result.error);
        return;
      }

      // Join socket to room
      socket.join(roomID);

      if (result.gameStarted) {
        // Game is starting with 2 players
        const gameInfo = result.gameInfo;

        io.to(roomID).emit(SOCKET_EVENTS.GAME_INIT, {
          'Player 1': gameInfo.players[0],
          'Player 2': gameInfo.players[1],
          playerTurn: gameInfo.playerTurn,
          gameInfo: gameInfo,
        });

        logger.gameEvent('game-started', {
          roomID,
          players: gameInfo.players,
          firstPlayer: gameInfo.playerTurn,
        });
      } else {
        // Player joined waiting room
        socket.emit('joined-waiting-room', {
          roomID,
          message: 'Waiting for another player...',
        });
      }

      logger.userAction('room-joined', uid, roomID, {
        socketId: socket.id,
        gameStarted: result.gameStarted,
      });
    } catch (error) {
      logger.errorDetails(error, {
        action: 'handleJoinRoom',
        socketId: socket.id,
        data,
      });
      this.monitoringService.recordError(error, { socketId: socket.id });
      this.emitError(socket, ERROR_MESSAGES.SERVER_ERROR);
    } finally {
      this.monitoringService.recordRequest(true, Date.now() - startTime, 'join-room');
    }
  }

  /**
   * Handle game move event
   */
  handleGameMove(socket, io, data) {
    const startTime = Date.now();

    try {
      // Validate input
      const validation = SocketValidation.validateGameMove(data);
      if (!validation.isValid) {
        this.emitError(socket, validation.errors.join(', '));
        return;
      }

      const { uid, roomID, selectedIndex } = validation.sanitized;

      // Update connection activity
      const connection = this.onlineConnections.get(socket.id);
      if (connection) {
        connection.updateActivity();
      }

      // Make move
      const result = this.gameService.makeMove(uid, roomID, selectedIndex);

      if (!result.success) {
        socket.emit(SOCKET_EVENTS.GAME_ERROR, {
          error: result.error,
          code: 'INVALID_MOVE',
        });
        return;
      }

      // Emit move to all players in room
      io.to(roomID).emit(SOCKET_EVENTS.GAME_MOVE_RESPONSE, {
        selectedIndex,
        uid,
        playerTurn: result.gameInfo.playerTurn,
        moveCount: result.gameInfo.moveCount,
        gameState: result.gameInfo.gameState,
      });

      logger.userAction('move-made', uid, roomID, {
        selectedIndex,
        nextPlayer: result.gameInfo.playerTurn,
      });

      // Check if game concluded
      if (result.conclusion && result.conclusion.concluded) {
        const conclusion = result.conclusion;

        io.to(roomID).emit(SOCKET_EVENTS.GAME_CONCLUSION, {
          status: conclusion.result,
          winner: conclusion.winner,
          winSequence: conclusion.winSequence,
          gameInfo: result.gameInfo,
        });

        this.monitoringService.recordGame('completed', {
          roomId: roomID,
          result: conclusion.result,
          winner: conclusion.winner,
          duration: result.gameInfo.gameEndTime - result.gameInfo.gameStartTime,
        });

        logger.gameEvent('game-concluded', {
          roomID,
          result: conclusion.result,
          winner: conclusion.winner,
          totalMoves: result.gameInfo.moveCount,
        });
      }
    } catch (error) {
      logger.errorDetails(error, {
        action: 'handleGameMove',
        socketId: socket.id,
        data,
      });
      this.monitoringService.recordError(error, { socketId: socket.id });
      this.emitError(socket, ERROR_MESSAGES.SERVER_ERROR);
    } finally {
      this.monitoringService.recordRequest(true, Date.now() - startTime, 'game-move');
    }
  }

  /**
   * Handle play again request
   */
  handlePlayAgain(socket, io, data) {
    try {
      // Validate input
      const validation = SocketValidation.validatePlayAgain(data);
      if (!validation.isValid) {
        this.emitError(socket, validation.errors.join(', '));
        return;
      }

      const { roomID, uid } = validation.sanitized;

      // Request play again
      const result = this.gameService.requestPlayAgain(uid, roomID);

      if (!result.success) {
        this.emitError(socket, result.error);
        return;
      }

      // Notify other player
      socket.broadcast.to(roomID).emit(SOCKET_EVENTS.PLAY_AGAIN, {
        requestedBy: uid,
        timestamp: Date.now(),
      });

      logger.userAction('play-again-requested', uid, roomID);
    } catch (error) {
      logger.errorDetails(error, {
        action: 'handlePlayAgain',
        socketId: socket.id,
        data,
      });
      this.monitoringService.recordError(error, { socketId: socket.id });
      this.emitError(socket, ERROR_MESSAGES.SERVER_ERROR);
    }
  }

  /**
   * Handle play again accepted
   */
  handlePlayAgainAccepted(socket, io, data) {
    try {
      // Basic validation
      if (!data || !data.roomID) {
        this.emitError(socket, ERROR_MESSAGES.INVALID_ROOM_ID);
        return;
      }

      const roomID = data.roomID;

      // Accept play again
      const result = this.gameService.acceptPlayAgain(roomID);

      if (!result.success) {
        this.emitError(socket, result.error);
        return;
      }

      // Notify all players that new game has started
      io.to(roomID).emit(SOCKET_EVENTS.PLAY_AGAIN_ACCEPTED, {
        firstPlayer: result.firstPlayer,
        gameInfo: result.gameInfo,
        message: 'New game started!',
      });

      logger.gameEvent('play-again-accepted', {
        roomID,
        firstPlayer: result.firstPlayer,
      });
    } catch (error) {
      logger.errorDetails(error, {
        action: 'handlePlayAgainAccepted',
        socketId: socket.id,
        data,
      });
      this.monitoringService.recordError(error, { socketId: socket.id });
      this.emitError(socket, ERROR_MESSAGES.SERVER_ERROR);
    }
  }

  /**
   * Handle emoji event
   */
  handleEmoji(socket, io, data) {
    try {
      // Validate input
      const validation = SocketValidation.validateEmoji(data);
      if (!validation.isValid) {
        this.emitError(socket, validation.errors.join(', '));
        return;
      }

      const { roomID, emojiPath, sender } = validation.sanitized;

      // Broadcast emoji to room
      io.to(roomID).emit(SOCKET_EVENTS.EMOJI, {
        emojiPath,
        sender,
        timestamp: Date.now(),
      });

      logger.userAction('emoji-sent', sender, roomID, { emojiPath });
    } catch (error) {
      logger.errorDetails(error, {
        action: 'handleEmoji',
        socketId: socket.id,
        data,
      });
      this.monitoringService.recordError(error, { socketId: socket.id });
    }
  }

  /**
   * Handle QR scanned event
   */
  handleQRScanned(socket, io, data) {
    try {
      // Validate input
      const validation = SocketValidation.validateQRScanned(data);
      if (!validation.isValid) {
        this.emitError(socket, validation.errors.join(', '));
        return;
      }

      const { roomID } = validation.sanitized;

      // Broadcast QR scanned event
      socket.broadcast.to(roomID).emit(SOCKET_EVENTS.QR_SCANNED, {
        timestamp: Date.now(),
      });

      logger.gameEvent('qr-scanned', { roomID, socketId: socket.id });
    } catch (error) {
      logger.errorDetails(error, {
        action: 'handleQRScanned',
        socketId: socket.id,
        data,
      });
      this.monitoringService.recordError(error, { socketId: socket.id });
    }
  }

  /**
   * Setup heartbeat for connection
   */
  setupHeartbeat(socket) {
    const heartbeatInterval = setInterval(() => {
      const connection = this.onlineConnections.get(socket.id);
      if (!connection) {
        clearInterval(heartbeatInterval);
        return;
      }

      // Check if connection is stale (no activity for 5 minutes)
      const fiveMinutesAgo = Date.now() - 300000;
      if (connection.lastActivity < fiveMinutesAgo) {
        logger.warn('Stale connection detected', {
          socketId: socket.id,
          userId: connection.userId,
          lastActivity: connection.lastActivity,
        });

        socket.disconnect(true);
        clearInterval(heartbeatInterval);
      }
    }, 60000); // Check every minute

    socket.on('disconnect', () => {
      clearInterval(heartbeatInterval);
    });
  }

  /**
   * Handle timeout events from game service
   */
  handleTimeout(io, timeoutData) {
    try {
      if (timeoutData.type === 'turn') {
        io.to(timeoutData.roomID).emit(SOCKET_EVENTS.TURN_TIMEOUT, {
          timeoutPlayer: timeoutData.timeoutPlayer,
          winner: timeoutData.winner,
          gameInfo: timeoutData.gameInfo,
        });

        logger.gameEvent('turn-timeout', {
          roomID: timeoutData.roomID,
          timeoutPlayer: timeoutData.timeoutPlayer,
          winner: timeoutData.winner,
        });
      }
    } catch (error) {
      logger.errorDetails(error, { action: 'handleTimeout', timeoutData });
      this.monitoringService.recordError(error, { timeoutData });
    }
  }

  /**
   * Emit error to socket
   */
  emitError(socket, message, code = 'GENERAL_ERROR') {
    socket.emit(SOCKET_EVENTS.GAME_ERROR, {
      error: message,
      code,
      timestamp: Date.now(),
    });

    logger.warn('Socket error emitted', {
      socketId: socket.id,
      error: message,
      code,
    });
  }

  /**
   * Get connection statistics
   */
  getConnectionStats() {
    return {
      totalConnections: this.onlineConnections.size,
      connections: Array.from(this.onlineConnections.values()).map((conn) => conn.toJSON()),
    };
  }

  /**
   * Cleanup stale connections
   */
  cleanupStaleConnections() {
    const now = Date.now();
    const fiveMinutesAgo = now - 300000;

    for (const [socketId, connection] of this.onlineConnections.entries()) {
      if (connection.lastActivity < fiveMinutesAgo) {
        this.onlineConnections.delete(socketId);
        logger.info('Cleaned up stale connection', {
          socketId,
          userId: connection.userId,
        });
      }
    }
  }
}

module.exports = SocketController;
