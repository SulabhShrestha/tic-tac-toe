const logger = require("../config/logger");

/**
 * Performance Monitoring Service
 */
class MonitoringService {
  constructor() {
    this.metrics = {
      requests: {
        total: 0,
        success: 0,
        errors: 0,
        lastMinute: [],
      },
      connections: {
        current: 0,
        peak: 0,
        total: 0,
      },
      games: {
        created: 0,
        completed: 0,
        abandoned: 0,
        average_duration: 0,
      },
      memory: {
        used: 0,
        peak: 0,
      },
      response_times: [],
      errors: [],
      alerts: [],
    };

    this.thresholds = {
      memory_mb: 500,
      error_rate_percent: 5,
      response_time_ms: 1000,
      connection_limit: 1000,
      requests_per_minute: 1000,
    };

    // Start monitoring
    this.startMonitoring();
  }

  /**
   * Record request metrics
   */
  recordRequest(success = true, responseTime = 0, endpoint = "") {
    this.metrics.requests.total++;

    if (success) {
      this.metrics.requests.success++;
    } else {
      this.metrics.requests.errors++;
    }

    // Record response time
    this.metrics.response_times.push({
      time: responseTime,
      timestamp: Date.now(),
      endpoint,
    });

    // Keep only last minute of requests
    const oneMinuteAgo = Date.now() - 60000;
    this.metrics.requests.lastMinute = this.metrics.requests.lastMinute.filter(
      (req) => req.timestamp > oneMinuteAgo
    );
    this.metrics.requests.lastMinute.push({
      success,
      timestamp: Date.now(),
      responseTime,
      endpoint,
    });

    // Keep only last 1000 response times
    if (this.metrics.response_times.length > 1000) {
      this.metrics.response_times = this.metrics.response_times.slice(-1000);
    }

    // Check for alerts
    this.checkPerformanceAlerts();
  }

  /**
   * Record connection metrics
   */
  recordConnection(type = "connect") {
    if (type === "connect") {
      this.metrics.connections.current++;
      this.metrics.connections.total++;

      if (this.metrics.connections.current > this.metrics.connections.peak) {
        this.metrics.connections.peak = this.metrics.connections.current;
      }
    } else if (type === "disconnect") {
      this.metrics.connections.current = Math.max(
        0,
        this.metrics.connections.current - 1
      );
    }

    this.checkConnectionAlerts();
  }

  /**
   * Record game metrics
   */
  recordGame(event, data = {}) {
    switch (event) {
      case "created":
        this.metrics.games.created++;
        break;
      case "completed":
        this.metrics.games.completed++;
        if (data.duration) {
          this.updateAverageGameDuration(data.duration);
        }
        break;
      case "abandoned":
        this.metrics.games.abandoned++;
        break;
    }

    logger.metrics({
      event,
      games: this.metrics.games,
      ...data,
    });
  }

  /**
   * Record error
   */
  recordError(error, context = {}) {
    const errorInfo = {
      message: error.message,
      stack: error.stack,
      context,
      timestamp: Date.now(),
    };

    this.metrics.errors.push(errorInfo);

    // Keep only last 100 errors
    if (this.metrics.errors.length > 100) {
      this.metrics.errors = this.metrics.errors.slice(-100);
    }

    logger.errorDetails(error, context);
    this.checkErrorRateAlerts();
  }

  /**
   * Update memory metrics
   */
  updateMemoryMetrics() {
    const memUsage = process.memoryUsage();
    this.metrics.memory.used = Math.round(memUsage.heapUsed / 1024 / 1024); // MB

    if (this.metrics.memory.used > this.metrics.memory.peak) {
      this.metrics.memory.peak = this.metrics.memory.used;
    }

    this.checkMemoryAlerts();
  }

  /**
   * Check for performance alerts
   */
  checkPerformanceAlerts() {
    // Check response time
    const recentResponses = this.metrics.response_times.slice(-10);
    if (recentResponses.length >= 10) {
      const avgResponseTime =
        recentResponses.reduce((sum, r) => sum + r.time, 0) /
        recentResponses.length;

      if (avgResponseTime > this.thresholds.response_time_ms) {
        this.triggerAlert("high_response_time", {
          average: avgResponseTime,
          threshold: this.thresholds.response_time_ms,
        });
      }
    }

    // Check requests per minute
    const requestsLastMinute = this.metrics.requests.lastMinute.length;
    if (requestsLastMinute > this.thresholds.requests_per_minute) {
      this.triggerAlert("high_request_rate", {
        rate: requestsLastMinute,
        threshold: this.thresholds.requests_per_minute,
      });
    }
  }

  /**
   * Check for connection alerts
   */
  checkConnectionAlerts() {
    if (this.metrics.connections.current > this.thresholds.connection_limit) {
      this.triggerAlert("high_connections", {
        current: this.metrics.connections.current,
        threshold: this.thresholds.connection_limit,
      });
    }
  }

  /**
   * Check for memory alerts
   */
  checkMemoryAlerts() {
    if (this.metrics.memory.used > this.thresholds.memory_mb) {
      this.triggerAlert("high_memory", {
        used: this.metrics.memory.used,
        threshold: this.thresholds.memory_mb,
      });
    }
  }

  /**
   * Check for error rate alerts
   */
  checkErrorRateAlerts() {
    const totalRequests = this.metrics.requests.total;
    const totalErrors = this.metrics.requests.errors;

    if (totalRequests > 100) {
      // Only check after sufficient requests
      const errorRate = (totalErrors / totalRequests) * 100;

      if (errorRate > this.thresholds.error_rate_percent) {
        this.triggerAlert("high_error_rate", {
          rate: errorRate,
          threshold: this.thresholds.error_rate_percent,
          errors: totalErrors,
          requests: totalRequests,
        });
      }
    }
  }

  /**
   * Trigger an alert
   */
  triggerAlert(type, data) {
    const alert = {
      type,
      data,
      timestamp: Date.now(),
      id: `${type}_${Date.now()}`,
    };

    // Check if we already have a recent alert of the same type
    const recentAlerts = this.metrics.alerts.filter(
      (a) => a.type === type && Date.now() - a.timestamp < 300000 // 5 minutes
    );

    if (recentAlerts.length === 0) {
      this.metrics.alerts.push(alert);

      // Keep only last 50 alerts
      if (this.metrics.alerts.length > 50) {
        this.metrics.alerts = this.metrics.alerts.slice(-50);
      }

      logger.warn(`Alert triggered: ${type}`, data);

      // In production, you would send this to external monitoring service
      this.sendExternalAlert(alert);
    }
  }

  /**
   * Send alert to external monitoring service
   */
  sendExternalAlert(alert) {
    // TODO: Implement external alert system (Slack, PagerDuty, etc.)
    logger.warn("External alert would be sent", { alert });
  }

  /**
   * Update average game duration
   */
  updateAverageGameDuration(newDuration) {
    const currentAvg = this.metrics.games.average_duration;
    const completedGames = this.metrics.games.completed;

    this.metrics.games.average_duration =
      (currentAvg * (completedGames - 1) + newDuration) / completedGames;
  }

  /**
   * Get current metrics
   */
  getMetrics() {
    return {
      ...this.metrics,
      uptime: process.uptime(),
      timestamp: Date.now(),
    };
  }

  /**
   * Get health status
   */
  getHealthStatus() {
    const recentErrors = this.metrics.errors.filter(
      (e) => Date.now() - e.timestamp < 300000 // Last 5 minutes
    );

    const recentAlerts = this.metrics.alerts.filter(
      (a) => Date.now() - a.timestamp < 300000 // Last 5 minutes
    );

    const health = {
      status: "healthy",
      timestamp: Date.now(),
      uptime: process.uptime(),
      memory: this.metrics.memory,
      connections: this.metrics.connections.current,
      recent_errors: recentErrors.length,
      recent_alerts: recentAlerts.length,
      checks: {
        memory: this.metrics.memory.used < this.thresholds.memory_mb,
        connections:
          this.metrics.connections.current < this.thresholds.connection_limit,
        error_rate: this.getErrorRate() < this.thresholds.error_rate_percent,
      },
    };

    // Determine overall health status
    const failedChecks = Object.values(health.checks).filter(
      (check) => !check
    ).length;

    if (failedChecks > 0) {
      health.status = failedChecks > 1 ? "unhealthy" : "degraded";
    }

    return health;
  }

  /**
   * Get error rate percentage
   */
  getErrorRate() {
    if (this.metrics.requests.total === 0) return 0;
    return (this.metrics.requests.errors / this.metrics.requests.total) * 100;
  }

  /**
   * Start monitoring processes
   */
  startMonitoring() {
    // Update memory metrics every 30 seconds
    setInterval(() => {
      this.updateMemoryMetrics();
    }, 30000);

    // Log metrics every 5 minutes
    setInterval(() => {
      logger.metrics(this.getMetrics());
    }, 300000);

    // Clean up old data every hour
    setInterval(() => {
      this.cleanupOldData();
    }, 3600000);

    logger.info("Monitoring service started");
  }

  /**
   * Clean up old monitoring data
   */
  cleanupOldData() {
    const oneHourAgo = Date.now() - 3600000;

    // Clean old response times
    this.metrics.response_times = this.metrics.response_times.filter(
      (r) => r.timestamp > oneHourAgo
    );

    // Clean old errors
    this.metrics.errors = this.metrics.errors.filter(
      (e) => e.timestamp > oneHourAgo
    );

    // Clean old alerts
    this.metrics.alerts = this.metrics.alerts.filter(
      (a) => a.timestamp > oneHourAgo
    );

    logger.info("Cleaned up old monitoring data");
  }

  /**
   * Create middleware for Express requests
   */
  expressMiddleware() {
    return (req, res, next) => {
      const start = Date.now();

      res.on("finish", () => {
        const duration = Date.now() - start;
        const success = res.statusCode < 400;

        this.recordRequest(success, duration, req.path);
      });

      next();
    };
  }

  /**
   * Create middleware for Socket.IO events
   */
  socketMiddleware() {
    return (socket, next) => {
      const originalEmit = socket.emit;

      socket.emit = function (...args) {
        const start = Date.now();
        const result = originalEmit.apply(this, args);
        const duration = Date.now() - start;

        // Record socket event
        logger.performance("socket_emit", duration, {
          event: args[0],
          socketId: socket.id,
        });

        return result;
      };

      next();
    };
  }
}

module.exports = MonitoringService;
