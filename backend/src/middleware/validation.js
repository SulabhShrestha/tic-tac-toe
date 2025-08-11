const { GAME, ERROR_MESSAGES } = require('../constants');
const logger = require('../config/logger');

/**
 * Validation utilities
 */
class ValidationUtils {
  /**
   * Validate room ID format
   */
  static isValidRoomId(roomId) {
    if (!roomId || typeof roomId !== 'string') return false;

    // Allow hardcoded test room ID
    if (roomId === 'sulabh') return true;

    // Validate normal room ID format
    const roomIdRegex = new RegExp(`^[${GAME.ROOM_ID_CHARACTERS}]{${GAME.ROOM_ID_LENGTH}}$`);
    return roomIdRegex.test(roomId);
  }

  /**
   * Validate user ID format
   */
  static isValidUserId(userId) {
    return userId && typeof userId === 'string' && userId.trim().length > 0 && userId.length <= 100;
  }

  /**
   * Validate cell index
   */
  static isValidCellIndex(index) {
    return Number.isInteger(index) && index >= 0 && index < GAME.BOARD_SIZE;
  }

  /**
   * Validate emoji path
   */
  static isValidEmojiPath(emojiPath) {
    return emojiPath && typeof emojiPath === 'string' && emojiPath.length <= 500;
  }

  /**
   * Sanitize string input
   */
  static sanitizeString(input, maxLength = 100) {
    if (typeof input !== 'string') return '';
    return input.trim().substring(0, maxLength);
  }
}

/**
 * Socket event validation middleware
 */
class SocketValidation {
  /**
   * Validate create room event
   */
  static validateCreateRoom(data) {
    const errors = [];

    if (!data) {
      errors.push('Request data is required');
      return { isValid: false, errors };
    }

    if (!ValidationUtils.isValidUserId(data.uid)) {
      errors.push(ERROR_MESSAGES.INVALID_USER_ID);
    }

    return {
      isValid: errors.length === 0,
      errors,
      sanitized: {
        uid: ValidationUtils.sanitizeString(data.uid),
      },
    };
  }

  /**
   * Validate join room event
   */
  static validateJoinRoom(data) {
    const errors = [];

    if (!data) {
      errors.push('Request data is required');
      return { isValid: false, errors };
    }

    if (!ValidationUtils.isValidUserId(data.uid)) {
      errors.push(ERROR_MESSAGES.INVALID_USER_ID);
    }

    if (!ValidationUtils.isValidRoomId(data.roomID)) {
      errors.push(ERROR_MESSAGES.INVALID_ROOM_ID);
    }

    return {
      isValid: errors.length === 0,
      errors,
      sanitized: {
        uid: ValidationUtils.sanitizeString(data.uid),
        roomID: ValidationUtils.sanitizeString(data.roomID),
      },
    };
  }

  /**
   * Validate game move event
   */
  static validateGameMove(data) {
    const errors = [];

    if (!data) {
      errors.push('Request data is required');
      return { isValid: false, errors };
    }

    if (!ValidationUtils.isValidUserId(data.uid)) {
      errors.push(ERROR_MESSAGES.INVALID_USER_ID);
    }

    if (!ValidationUtils.isValidRoomId(data.roomID)) {
      errors.push(ERROR_MESSAGES.INVALID_ROOM_ID);
    }

    if (!ValidationUtils.isValidCellIndex(data.selectedIndex)) {
      errors.push(ERROR_MESSAGES.INVALID_CELL_INDEX);
    }

    return {
      isValid: errors.length === 0,
      errors,
      sanitized: {
        uid: ValidationUtils.sanitizeString(data.uid),
        roomID: ValidationUtils.sanitizeString(data.roomID),
        selectedIndex: parseInt(data.selectedIndex),
      },
    };
  }

  /**
   * Validate play again event
   */
  static validatePlayAgain(data) {
    const errors = [];

    if (!data) {
      errors.push('Request data is required');
      return { isValid: false, errors };
    }

    if (!ValidationUtils.isValidRoomId(data.roomID)) {
      errors.push(ERROR_MESSAGES.INVALID_ROOM_ID);
    }

    if (!ValidationUtils.isValidUserId(data.uid)) {
      errors.push(ERROR_MESSAGES.INVALID_USER_ID);
    }

    return {
      isValid: errors.length === 0,
      errors,
      sanitized: {
        roomID: ValidationUtils.sanitizeString(data.roomID),
        uid: ValidationUtils.sanitizeString(data.uid),
      },
    };
  }

  /**
   * Validate emoji event
   */
  static validateEmoji(data) {
    const errors = [];

    if (!data) {
      errors.push('Request data is required');
      return { isValid: false, errors };
    }

    if (!ValidationUtils.isValidRoomId(data.roomID)) {
      errors.push(ERROR_MESSAGES.INVALID_ROOM_ID);
    }

    if (!ValidationUtils.isValidUserId(data.sender)) {
      errors.push(ERROR_MESSAGES.INVALID_USER_ID);
    }

    if (!ValidationUtils.isValidEmojiPath(data.emojiPath)) {
      errors.push('Invalid emoji path');
    }

    return {
      isValid: errors.length === 0,
      errors,
      sanitized: {
        roomID: ValidationUtils.sanitizeString(data.roomID),
        sender: ValidationUtils.sanitizeString(data.sender),
        emojiPath: ValidationUtils.sanitizeString(data.emojiPath, 500),
      },
    };
  }

  /**
   * Validate QR scanned event
   */
  static validateQRScanned(data) {
    const errors = [];

    if (!data) {
      errors.push('Request data is required');
      return { isValid: false, errors };
    }

    if (!ValidationUtils.isValidRoomId(data.roomID)) {
      errors.push(ERROR_MESSAGES.INVALID_ROOM_ID);
    }

    return {
      isValid: errors.length === 0,
      errors,
      sanitized: {
        roomID: ValidationUtils.sanitizeString(data.roomID),
      },
    };
  }
}

module.exports = {
  ValidationUtils,
  SocketValidation,
};
