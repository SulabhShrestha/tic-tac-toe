const http = require('http');
const express = require('express');
const { Server } = require('socket.io');
require('dotenv').config();

// Import configurations and services
const logger = require('./config/logger');

// Import services
const GameService = require('./services/GameService');
const MonitoringService = require('./services/MonitoringService');

// Import controllers
const SocketController = require('./controllers/SocketController');

// Import constants
const { HTTP_STATUS, ENVIRONMENTS } = require('./constants');

/**
 * Main Server Class
 */
class TicTacToeServer {
  constructor() {
    this.app = express();
    this.httpServer = http.createServer(this.app);
    this.port = process.env.PORT || 3000;
    this.environment = process.env.NODE_ENV || ENVIRONMENTS.DEVELOPMENT;

    // Initialize services
    this.gameService = new GameService();
    this.monitoringService = new MonitoringService();

    // Initialize controllers
    this.socketController = new SocketController(
      this.gameService,
      this.monitoringService,
    );

    // Store timeout handlers for cleanup
    this.timeoutHandlers = new Map();

    // Initialize server
    this.init();
  }

  /**
   * Initialize server configuration and middleware
   */
  init() {
    try {
      // Setup Express middleware
      this.setupMiddleware();

      // Setup routes
      this.setupRoutes();

      // Setup Socket.IO
      this.setupSocketIO();

      // Setup periodic tasks
      this.setupPeriodicTasks();

      // Setup error handlers
      this.setupErrorHandlers();

      logger.info('Server initialized successfully', {
        environment: this.environment,
        port: this.port,
      });
    } catch (error) {
      logger.errorDetails(error, { phase: 'server_initialization' });
      this.monitoringService.recordError(error, { phase: 'initialization' });
      throw error;
    }
  }

  /**
   * Setup Express middleware
   */
  setupMiddleware() {
    // Body parsing
    this.app.use(express.json({ limit: '10mb' }));
    this.app.use(express.urlencoded({ extended: true, limit: '10mb' }));

    // Monitoring middleware
    this.app.use(this.monitoringService.expressMiddleware());

    // Request logging
    this.app.use((req, res, next) => {
      const start = Date.now();

      res.on('finish', () => {
        const duration = Date.now() - start;
        logger.apiCall(req.method, req.path, res.statusCode, duration, {
          ip: req.ip,
          userAgent: req.get('User-Agent'),
        });
      });

      next();
    });

    // Trust proxy for accurate IP addresses
    this.app.set('trust proxy', true);
  }

  /**
   * Setup Express routes
   */
  setupRoutes() {
    // Health check endpoint
    this.app.get('/', (req, res) => {
      try {
        const health = this.monitoringService.getHealthStatus();

        logger.healthCheck('server', health.status, {
          endpoint: '/',
          ip: req.ip,
        });

        res.status(HTTP_STATUS.OK).json({
          message: 'Tic-Tac-Toe Server is running',
          status: health.status,
          timestamp: new Date().toISOString(),
          environment: this.environment,
          uptime: process.uptime(),
        });
      } catch (error) {
        logger.errorDetails(error, { endpoint: '/', ip: req.ip });
        this.monitoringService.recordError(error, { endpoint: '/' });
        res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
          error: 'Internal server error',
        });
      }
    });

    // Health check endpoint
    this.app.get('/health', (req, res) => {
      try {
        const health = this.monitoringService.getHealthStatus();
        const gameStats = this.gameService.getGameStats();

        logger.healthCheck('detailed', health.status, {
          games: gameStats,
          health,
        });

        res
          .status(health.status === 'healthy' ? HTTP_STATUS.OK : HTTP_STATUS.INTERNAL_SERVER_ERROR)
          .json({
            ...health,
            games: gameStats,
          });
      } catch (error) {
        logger.errorDetails(error, { endpoint: '/health' });
        this.monitoringService.recordError(error, { endpoint: '/health' });
        res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
          status: 'unhealthy',
          error: 'Health check failed',
        });
      }
    });

    // Metrics endpoint (for monitoring systems)
    this.app.get('/metrics', (req, res) => {
      try {
        const metrics = this.monitoringService.getMetrics();
        const gameStats = this.gameService.getGameStats();
        const connectionStats = this.socketController.getConnectionStats();

        res.status(HTTP_STATUS.OK).json({
          metrics,
          games: gameStats,
          connections: connectionStats,
          timestamp: Date.now(),
        });
      } catch (error) {
        logger.errorDetails(error, { endpoint: '/metrics' });
        this.monitoringService.recordError(error, { endpoint: '/metrics' });
        res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
          error: 'Failed to retrieve metrics',
        });
      }
    });

    // API documentation endpoint
    this.app.get('/docs', (req, res) => {
      res.status(HTTP_STATUS.OK).json(this.getAPIDocumentation());
    });

    // 404 handler
    this.app.use('*', (req, res) => {
      logger.warn('Route not found', {
        path: req.originalUrl,
        method: req.method,
        ip: req.ip,
      });

      res.status(HTTP_STATUS.NOT_FOUND).json({
        error: 'Route not found',
        path: req.originalUrl,
        timestamp: new Date().toISOString(),
      });
    });
  }

  /**
   * Setup Socket.IO server
   */
  setupSocketIO() {
    this.io = new Server(this.httpServer, {
      serveClient: false,
      pingTimeout: 60000,
      pingInterval: 25000,
      transports: ['websocket', 'polling'],
      allowEIO3: true,
    });

    // Socket.IO middleware
    this.io.use(this.monitoringService.socketMiddleware());

    // Connection handler
    this.io.on('connection', (socket) => {
      this.socketController.handleConnection(socket, this.io);
    });

    // Setup timeout handlers
    this.setupTimeoutHandlers();

    logger.info('Socket.IO server configured', {
      transports: ['websocket', 'polling'],
    });
  }

  /**
   * Setup timeout handlers for game service
   */
  setupTimeoutHandlers() {
    // Handle turn timeouts
    setInterval(() => {
      // This would need to be implemented in GameService to return timeout events
      // For now, we'll just log that timeout checking is running
      logger.debug('Checking for game timeouts');
    }, 30000); // Check every 30 seconds
  }

  /**
   * Setup periodic maintenance tasks
   */
  setupPeriodicTasks() {
    // Clean up old games every hour
    setInterval(() => {
      try {
        this.gameService.performCleanup();
        this.socketController.cleanupStaleConnections();

        logger.info('Periodic cleanup completed');
      } catch (error) {
        logger.errorDetails(error, { task: 'periodic_cleanup' });
        this.monitoringService.recordError(error, { task: 'cleanup' });
      }
    }, 3600000); // 1 hour

    // Log server statistics every 10 minutes
    setInterval(() => {
      try {
        const stats = {
          games: this.gameService.getGameStats(),
          connections: this.socketController.getConnectionStats(),
          health: this.monitoringService.getHealthStatus(),
          memory: process.memoryUsage(),
          uptime: process.uptime(),
        };

        logger.info('Server statistics', stats);
      } catch (error) {
        logger.errorDetails(error, { task: 'statistics_logging' });
      }
    }, 600000); // 10 minutes

    // Memory monitoring every 5 minutes
    setInterval(() => {
      const memUsage = process.memoryUsage();
      const memoryMB = Math.round(memUsage.heapUsed / 1024 / 1024);

      logger.performance('memory_usage', memoryMB, {
        heapUsed: memUsage.heapUsed,
        heapTotal: memUsage.heapTotal,
        external: memUsage.external,
        rss: memUsage.rss,
      });

      // Trigger garbage collection if memory usage is high
      if (memoryMB > 400 && global.gc) {
        global.gc();
        logger.info('Triggered garbage collection', { memoryMB });
      }
    }, 300000); // 5 minutes
  }

  /**
   * Setup error handlers
   */
  setupErrorHandlers() {
    // Express error handler
    this.app.use((error, req, res, next) => {
      logger.errorDetails(error, {
        url: req.url,
        method: req.method,
        ip: req.ip,
        userAgent: req.get('User-Agent'),
      });

      this.monitoringService.recordError(error, {
        type: 'express_error',
        url: req.url,
        method: req.method,
      });

      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        error: 'Internal server error',
        timestamp: new Date().toISOString(),
      });
    });

    // Unhandled promise rejection
    process.on('unhandledRejection', (reason, promise) => {
      const error = new Error(`Unhandled Rejection: ${reason}`);
      logger.errorDetails(error, {
        reason,
        promise: promise.toString(),
        type: 'unhandled_rejection',
      });
      this.monitoringService.recordError(error, { type: 'unhandled_rejection' });
    });

    // Uncaught exception
    process.on('uncaughtException', (error) => {
      logger.errorDetails(error, { type: 'uncaught_exception' });
      this.monitoringService.recordError(error, { type: 'uncaught_exception' });

      // Graceful shutdown on uncaught exception
      logger.fatal('Uncaught exception, shutting down gracefully');
      this.shutdown();
    });

    // Socket.IO error handling
    this.io.engine.on('connection_error', (err) => {
      logger.errorDetails(err, {
        type: 'socket_connection_error',
        code: err.code,
        message: err.message,
        context: err.context,
      });
      this.monitoringService.recordError(err, { type: 'socket_connection' });
    });
  }

  /**
   * Start the server
   */
  start() {
    return new Promise((resolve, reject) => {
      try {
        this.httpServer.listen(this.port, () => {
          logger.info('Server started successfully', {
            port: this.port,
            environment: this.environment,
            pid: process.pid,
            nodeVersion: process.version,
            timestamp: new Date().toISOString(),
          });

          // Log startup metrics
          this.monitoringService.recordRequest(true, 0, 'server_start');

          resolve(this);
        });

        // Handle server errors
        this.httpServer.on('error', (error) => {
          logger.errorDetails(error, { phase: 'server_start' });
          this.monitoringService.recordError(error, { phase: 'server_start' });
          reject(error);
        });
      } catch (error) {
        logger.errorDetails(error, { phase: 'server_start' });
        this.monitoringService.recordError(error, { phase: 'server_start' });
        reject(error);
      }
    });
  }

  /**
   * Graceful shutdown
   */
  shutdown() {
    logger.info('Starting graceful shutdown');

    // Stop accepting new connections
    this.httpServer.close(() => {
      logger.info('HTTP server closed');

      // Close Socket.IO connections
      this.io.close(() => {
        logger.info('Socket.IO server closed');

        // Perform final cleanup
        this.gameService.performCleanup();

        logger.info('Graceful shutdown completed');
        process.exit(0);
      });
    });

    // Force shutdown after 30 seconds
    setTimeout(() => {
      logger.error('Forced shutdown after timeout');
      process.exit(1);
    }, 30000);
  }

  /**
   * Get API documentation
   */
  getAPIDocumentation() {
    return {
      title: 'Tic-Tac-Toe Multiplayer API',
      version: '1.0.0',
      description: 'Real-time multiplayer tic-tac-toe game API',
      endpoints: {
        http: {
          'GET /': 'Server status and basic information',
          'GET /health': 'Detailed health check with metrics',
          'GET /metrics': 'Performance and game metrics',
          'GET /docs': 'This API documentation',
        },
        websocket: {
          events: {
            'create-room': {
              description: 'Create a new game room',
              payload: { uid: 'string (required)' },
              response: 'room-created event with roomId',
            },
            'join-room': {
              description: 'Join an existing game room',
              payload: { uid: 'string (required)', roomID: 'string (required)' },
              response: 'game-init event when game starts',
            },
            event: {
              description: 'Make a move in the game',
              payload: {
                uid: 'string (required)',
                roomID: 'string (required)',
                selectedIndex: 'number (0-8, required)',
              },
              response: 'event with move details or game-conclusion',
            },
            'play-again': {
              description: 'Request to play again',
              payload: { uid: 'string (required)', roomID: 'string (required)' },
              response: 'play-again event to other player',
            },
            'play-again-accepted': {
              description: 'Accept play again request',
              payload: { roomID: 'string (required)' },
              response: 'play-again-accepted event to all players',
            },
            emoji: {
              description: 'Send emoji to other players',
              payload: {
                roomID: 'string (required)',
                sender: 'string (required)',
                emojiPath: 'string (required)',
              },
              response: 'emoji event to all players in room',
            },
            'qr-scanned': {
              description: 'Notify that QR code was scanned',
              payload: { roomID: 'string (required)' },
              response: 'qr-scanned event to other players',
            },
            ping: {
              description: 'Heartbeat/connection test',
              payload: 'any',
              response: 'pong event with timestamp',
            },
          },
        },
      },
      errors: {
        INVALID_MOVE: 'Move is not valid (cell occupied, wrong turn, etc.)',
        ROOM_NOT_FOUND: 'Game room does not exist',
        ROOM_FULL: 'Game room already has maximum players',
        GAME_ERROR: 'General game error with details',
        RATE_LIMIT: 'Too many requests, slow down',
      },
      gameFlow: [
        '1. Player 1 creates room with create-room',
        '2. Player 2 joins room with join-room',
        '3. Game starts automatically, game-init event sent',
        '4. Players take turns making moves with event',
        '5. Game ends with game-conclusion event',
        '6. Players can request play-again to start new game',
      ],
    };
  }
}

// Setup graceful shutdown handlers
const setupShutdownHandlers = (server) => {
  process.on('SIGINT', () => {
    logger.info('Received SIGINT, initiating graceful shutdown');
    server.shutdown();
  });

  process.on('SIGTERM', () => {
    logger.info('Received SIGTERM, initiating graceful shutdown');
    server.shutdown();
  });
};

// Start server if this file is run directly
if (require.main === module) {
  const server = new TicTacToeServer();

  server
    .start()
    .then(() => {
      setupShutdownHandlers(server);
      console.log(`🎮 Tic-Tac-Toe Server running on port ${server.port}`);
    })
    .catch((error) => {
      logger.errorDetails(error, { phase: 'server_startup' });
      console.error('Failed to start server:', error.message);
      process.exit(1);
    });
}

module.exports = TicTacToeServer;
