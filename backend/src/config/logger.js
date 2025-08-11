const pino = require('pino');
const fs = require('fs');
const path = require('path');

// Create logs directory if it doesn't exist
const logDir = 'logs';
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir);
}

// Base logger configuration - SIMPLIFIED
const loggerConfig = {
  level: process.env.LOG_LEVEL || 'info',
  base: {
    service: 'tic-tac-toe-backend',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
  },
  timestamp: pino.stdTimeFunctions.isoTime,
};

// Create logger instance - SIMPLIFIED APPROACH
let logger;

if (process.env.NODE_ENV === 'production') {
  // Production: File logging only
  logger = pino(
    {
      ...loggerConfig,
    },
    pino.destination(path.join(logDir, 'combined.log'))
  );
} else {
  // Development: Pretty console logging
  logger = pino({
    ...loggerConfig,
    transport: {
      target: 'pino-pretty',
      options: {
        colorize: true,
        translateTime: 'SYS:yyyy-mm-dd HH:MM:ss',
        ignore: 'hostname,pid',
      },
    },
  });
}

// Custom logging methods for specific use cases
logger.gameEvent = function (event, data) {
  this.info(
    {
      category: 'game',
      event,
      ...data,
    },
    `Game Event: ${event}`
  );
};

logger.userAction = function (action, userId, roomId, data = {}) {
  this.info(
    {
      category: 'user',
      action,
      userId,
      roomId,
      ...data,
    },
    `User Action: ${action}`
  );
};

logger.socketEvent = function (event, socketId, data = {}) {
  this.info(
    {
      category: 'socket',
      event,
      socketId,
      ...data,
    },
    `Socket Event: ${event}`
  );
};

logger.performance = function (operation, duration, data = {}) {
  this.info(
    {
      category: 'performance',
      operation,
      duration,
      ...data,
    },
    `Performance: ${operation} took ${duration}ms`
  );
};

logger.security = function (event, data = {}) {
  this.warn(
    {
      category: 'security',
      event,
      ...data,
    },
    `Security Event: ${event}`
  );
};

logger.apiCall = function (method, path, statusCode, duration, data = {}) {
  this.info(
    {
      category: 'api',
      method,
      path,
      statusCode,
      duration,
      ...data,
    },
    `API: ${method} ${path} ${statusCode} ${duration}ms`
  );
};

// Error serialization
logger.errorDetails = function (error, context = {}) {
  this.error(
    {
      category: 'error',
      error: {
        name: error.name,
        message: error.message,
        stack: error.stack,
        code: error.code,
      },
      ...context,
    },
    `Error: ${error.message}`
  );
};

// Metrics logging
logger.metrics = function (metrics) {
  this.info(
    {
      category: 'metrics',
      ...metrics,
    },
    'System Metrics'
  );
};

// Rate limiting logs
logger.rateLimitHit = function (identifier, limit, window) {
  this.warn(
    {
      category: 'rate-limit',
      identifier,
      limit,
      window,
    },
    `Rate limit hit for ${identifier}`
  );
};

// Health check logs
logger.healthCheck = function (component, status, details = {}) {
  const logLevel = status === 'healthy' ? 'info' : 'error';
  this[logLevel](
    {
      category: 'health',
      component,
      status,
      ...details,
    },
    `Health Check: ${component} is ${status}`
  );
};

module.exports = logger;
