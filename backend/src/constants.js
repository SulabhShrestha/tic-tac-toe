module.exports = {
  // Game Constants
  GAME: {
    MAX_PLAYERS: 2,
    MIN_PLAYERS: 1,
    BOARD_SIZE: 9,
    BOARD_INDICES: [0, 1, 2, 3, 4, 5, 6, 7, 8],
    WINNING_SEQUENCES: [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8], // Rows
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8], // Columns
      [0, 4, 8],
      [2, 4, 6], // Diagonals
    ],
    ROOM_ID_LENGTH: 5,
    ROOM_ID_CHARACTERS:
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
    TURN_TIMEOUT: 30000, // 30 seconds
    GAME_TIMEOUT: 300000, // 5 minutes
    RECONNECT_TIMEOUT: 60000, // 1 minute
  },

  // Game States
  GAME_STATES: {
    WAITING: "waiting",
    IN_PROGRESS: "in_progress",
    COMPLETED: "completed",
    ABANDONED: "abandoned",
    TIMEOUT: "timeout",
  },

  // Game Results
  GAME_RESULTS: {
    WIN: "win",
    DRAW: "draw",
    FORFEIT: "forfeit",
    TIMEOUT: "timeout",
  },

  // Socket Events
  SOCKET_EVENTS: {
    // Client to Server
    CREATE_ROOM: "create-room",
    JOIN_ROOM: "join-room",
    GAME_MOVE: "event",
    PLAY_AGAIN: "play-again",
    PLAY_AGAIN_ACCEPTED: "play-again-accepted",
    QR_SCANNED: "qr-scanned",
    EMOJI: "emoji",
    PING: "ping",

    // Server to Client
    ROOM_CREATED: "room-created",
    ROOM_NOT_FOUND: "room-not-found",
    GAME_INIT: "game-init",
    GAME_MOVE_RESPONSE: "event",
    GAME_CONCLUSION: "game-conclusion",
    USER_DISCONNECTED: "user-disconnected",
    GAME_ERROR: "game-error",
    TURN_TIMEOUT: "turn-timeout",
    PONG: "pong",
  },

  // Error Messages
  ERROR_MESSAGES: {
    ROOM_NOT_FOUND: "The room you are searching for does not exist.",
    ROOM_FULL: "The room is full. Maximum 2 players allowed.",
    INVALID_MOVE: "Invalid move. Please try again.",
    NOT_YOUR_TURN: "It is not your turn.",
    CELL_OCCUPIED: "This cell is already occupied.",
    GAME_NOT_IN_PROGRESS: "Game is not in progress.",
    INVALID_ROOM_ID: "Invalid room ID format.",
    INVALID_USER_ID: "Invalid user ID.",
    INVALID_CELL_INDEX: "Cell index must be between 0 and 8.",
    DUPLICATE_PLAY_AGAIN: "Play again request already sent.",
    TURN_TIMEOUT: "Turn timeout. Game forfeited.",
    SERVER_ERROR: "Internal server error occurred.",
  },

  // Success Messages
  SUCCESS_MESSAGES: {
    ROOM_CREATED: "Room created successfully.",
    GAME_STARTED: "Game started successfully.",
    MOVE_SUCCESSFUL: "Move made successfully.",
    GAME_CONCLUDED: "Game concluded.",
  },

  // HTTP Status Codes
  HTTP_STATUS: {
    OK: 200,
    CREATED: 201,
    BAD_REQUEST: 400,
    UNAUTHORIZED: 401,
    FORBIDDEN: 403,
    NOT_FOUND: 404,
    CONFLICT: 409,
    INTERNAL_SERVER_ERROR: 500,
  },

  // Rate Limiting
  RATE_LIMITS: {
    SOCKET_EVENTS_PER_MINUTE: 60,
    CREATE_ROOM_PER_HOUR: 10,
    JOIN_ROOM_PER_MINUTE: 20,
  },

  // Logging Levels
  LOG_LEVELS: {
    TRACE: "trace",
    DEBUG: "debug",
    INFO: "info",
    WARN: "warn",
    ERROR: "error",
    FATAL: "fatal",
  },

  // Environment
  ENVIRONMENTS: {
    DEVELOPMENT: "development",
    PRODUCTION: "production",
    TEST: "test",
  },

  // Test Constants (for development only)
  TEST: {
    HARDCODED_ROOM_ID: "sulabh", // TODO: Remove in production
  },
};
