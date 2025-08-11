# Tic-Tac-Toe Multiplayer Backend

A robust, production-ready backend for real-time multiplayer tic-tac-toe game built with Node.js, Express, and Socket.IO.

## 🚀 Features

- **Real-time Multiplayer**: WebSocket-based real-time game communication
- **Comprehensive Security**: Input validation, rate limiting, CORS protection
- **Performance Monitoring**: Built-in metrics, alerts, and health checks
- **Error Handling**: Graceful error handling with detailed logging
- **Production Ready**: Security headers, graceful shutdown, Docker support
- **API Documentation**: Built-in API docs and comprehensive logging

## 📋 Requirements

- Node.js >= 16.0.0
- npm >= 8.0.0

## 🛠️ Installation

1. **Clone the repository**

```bash
git clone <repository-url>
cd tic-tac-toe-backend
```

2. **Install dependencies**

```bash
npm install
```

3. **Setup environment variables**

```bash
cp .env.example .env
# Edit .env with your configuration
```

4. **Start the server**

```bash
# Development
npm run dev

# Production
npm start
```

## 🏗️ Project Structure

```
├── server.js                 # Main server entry point
├── constants.js              # Application constants
├── config/
│   ├── logger.js             # Pino logger configuration
│   └── cors.js               # CORS security configuration
├── models/
│   └── GameModels.js         # Data models and schemas
├── services/
│   ├── GameService.js        # Game logic and state management
│   └── MonitoringService.js  # Performance monitoring and alerts
├── controllers/
│   └── SocketController.js   # Socket event handlers
├── middleware/
│   └── validation.js         # Input validation and rate limiting
├── logs/                     # Application logs (auto-created)
├── __tests__/               # Test files
└── docs/                    # Additional documentation
```

## 🎮 Game Flow

1. **Room Creation**: Player 1 creates a room with `create-room` event
2. **Room Joining**: Player 2 joins using `join-room` event with room ID
3. **Game Start**: Game automatically starts when 2 players are connected
4. **Gameplay**: Players take turns making moves with `event`
5. **Game End**: Game concludes with win/draw, emits `game-conclusion`
6. **Play Again**: Players can request rematch with `play-again`

## 📡 WebSocket Events

### Client → Server Events

| Event | Payload | Description |
|-------|---------|-------------|
| `create-room` | `{ uid: string }` | Create a new game room |
| `join-room` | `{ uid: string, roomID: string }` | Join existing room |
| `event` | `{ uid: string, roomID: string, selectedIndex: number }` | Make a move |
| `play-again` | `{ uid: string, roomID: string }` | Request rematch |
| `play-again-accepted` | `{ roomID: string }` | Accept rematch |
| `emoji` | `{ roomID: string, sender: string, emojiPath: string }` | Send emoji |
| `qr-scanned` | `{ roomID: string }` | QR code scanned |
| `ping` | `any` | Heartbeat |

### Server → Client Events

| Event | Payload | Description |
|-------|---------|-------------|
| `room-created` | `{ roomId: string, gameInfo: object }` | Room created successfully |
| `room-not-found` | `string` | Room doesn't exist or is full |
| `game-init` | `{ Player 1: string, Player 2: string }` | Game started |
| `event` | `{ selectedIndex: number, uid: string, playerTurn: string }` | Move made |
| `game-conclusion` | `{ status: string, winner?: string, winSequence?: array }` | Game ended |
| `game-error` | `{ error: string, code: string }` | Error occurred |
| `user-disconnected` | `{ userId: string }` | Player disconnected |
| `turn-timeout` | `{ timeoutPlayer: string, winner: string }` | Turn timeout |
| `pong` | `{ timestamp: number, data: any }` | Heartbeat response |

## 🔒 Security Features

- **Input Validation**: All socket events validated and sanitized
- **Rate Limiting**: Prevents spam and DoS attacks
- **CORS Protection**: Configurable origin restrictions
- **Security Headers**: CSP, HSTS, XSS protection
- **Error Sanitization**: No sensitive data in error responses

## 📊 Monitoring & Health

### Health Check Endpoints

- `GET /` - Basic server status
- `GET /health` - Detailed health check with metrics
- `GET /metrics` - Performance metrics and statistics
- `GET /docs` - API documentation

### Logging

The application uses Pino for structured logging with multiple log levels:

- **Error logs**: `logs/error.log`
- **Combined logs**: `logs/combined.log`
- **Game events**: `logs/game-events.log`

### Metrics Tracked

- Request/response metrics
- WebSocket connection stats
- Game statistics (created, completed, abandoned)
- Memory usage and performance
- Error rates and response times

## ⚙️ Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

```bash
# Basic Configuration
PORT=3000
NODE_ENV=development
LOG_LEVEL=info

# Rate Limiting
SOCKET_EVENTS_PER_MINUTE=60
CREATE_ROOM_PER_HOUR=10

# Game Timeouts
TURN_TIMEOUT=30000
GAME_TIMEOUT=300000
```

### CORS Configuration

Configure allowed origins in `config/cors.js`:

```javascript
// Development - more permissive
development: {
  origin: ['http://localhost:3000', 'http://localhost:3001'],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  credentials: true
}

// Production - restrictive
production: {
  origin: ['https://yourdomain.com'],
  methods: ['GET', 'POST'],
  credentials: true
}
```

## 🧪 Testing

```bash
# Run all tests
npm test

# Watch mode for development
npm run test:watch

# Generate coverage report
npm run test:coverage
```

## 📝 Scripts

```bash
# Development
npm run dev              # Start with nodemon
npm run logs:tail        # Tail combined logs
npm run logs:error       # Tail error logs
npm run health           # Check server health

# Production
npm start                # Start production server
npm run metrics          # Get server metrics

# Code Quality
npm run lint             # ESLint check
npm run lint:fix         # Auto-fix ESLint issues
npm run format           # Prettier formatting

# Docker
npm run docker:build     # Build Docker image
npm run docker:run       # Run in container
```

## 🐳 Docker Deployment

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

```bash
# Build and run
docker build -t tic-tac-toe-backend .
docker run -p 3000:3000 -e NODE_ENV=production tic-tac-toe-backend
```

## 🚀 Production Deployment

1. **Environment Setup**

```bash
NODE_ENV=production
LOG_LEVEL=info
PORT=3000
```

2. **Security Checklist**

- [ ] Update CORS origins to production domains
- [ ] Set secure rate limits
- [ ] Configure SSL/TLS certificates
- [ ] Set up monitoring and alerting
- [ ] Configure log rotation
- [ ] Remove hardcoded test values

3. **Monitoring Setup**

- Health checks at `/health`
- Metrics endpoint at `/metrics`
- Log aggregation (ELK stack, Splunk, etc.)
- APM tools (New Relic, DataDog)

## 🔧 Troubleshooting

### Common Issues

**Socket Connection Fails**

- Check CORS configuration
- Verify WebSocket support
- Check rate limiting

**Memory Issues**

- Monitor `/metrics` endpoint
- Check for memory leaks in game cleanup
- Enable garbage collection in production

**Rate Limiting Triggered**

- Adjust limits in `.env`
- Check client-side connection logic
- Monitor logs for patterns

### Debug Commands

```bash
# Check server health
curl http://localhost:3000/health

# Get detailed metrics
curl http://localhost:3000/metrics

# Test WebSocket connection
npm install -g wscat
wscat -c ws://localhost:3000

# Monitor logs in real-time
tail -f logs/combined.log | grep ERROR
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow ESLint configuration
- Write tests for new features
- Update documentation for API changes
- Use conventional commit messages
- Ensure all tests pass before submitting

## 📚 API Examples

### Creating and Joining a Game

```javascript
// Client-side Socket.IO connection
const socket = io('http://localhost:3000');

// Create a room
socket.emit('create-room', { uid: 'player1' });

socket.on('room-created', (data) => {
  console.log('Room created:', data.roomId);
  // Share room ID with other player
});

// Join a room
socket.emit('join-room', { uid: 'player2', roomID: 'sulabh' });

socket.on('game-init', (data) => {
  console.log('Game started!', data);
  // Game UI initialization
});
```

### Making Moves

```javascript
// Make a move (cell index 0-8)
socket.emit('event', {
  uid: 'player1',
  roomID: 'sulabh',
  selectedIndex: 4 // center cell
});

socket.on('event', (data) => {
  console.log('Move made:', data);
  // Update game board UI
});

socket.on('game-conclusion', (data) => {
  console.log('Game ended:', data);
  if (data.status === 'win') {
    console.log('Winner:', data.winner);
  }
});
```

### Error Handling

```javascript
socket.on('game-error', (error) => {
  console.error('Game error:', error);
  // Display error to user
});

socket.on('room-not-found', (message) => {
  console.error('Room error:', message);
  // Show room not found message
});
```

## 🔍 Performance Tuning

### Memory Optimization

```javascript
// Enable garbage collection
node --expose-gc server.js

// Monitor memory usage
const used = process.memoryUsage();
console.log('Memory usage:', {
  rss: Math.round(used.rss / 1024 / 1024) + ' MB',
  heapTotal: Math.round(used.heapTotal / 1024 / 1024) + ' MB',
  heapUsed: Math.round(used.heapUsed / 1024 / 1024) + ' MB'
});
```

### Socket.IO Optimization

```javascript
// Recommended production settings
const io = new Server(httpServer, {
  transports: ['websocket'], // Disable polling in production
  pingTimeout: 60000,
  pingInterval: 25000,
  upgradeTimeout: 30000,
  maxHttpBufferSize: 1e6 // 1MB
});
```

## 🛡️ Security Best Practices

### Rate Limiting Configuration

```javascript
// Adjust based on your needs
const RATE_LIMITS = {
  SOCKET_EVENTS_PER_MINUTE: 60,    // Total events per socket
  CREATE_ROOM_PER_HOUR: 10,        // Room creation limit
  JOIN_ROOM_PER_MINUTE: 20,        // Room join attempts
  MOVES_PER_MINUTE: 30             // Game moves limit
};
```

### Input Validation

```javascript
// All inputs are validated and sanitized
const validation = SocketValidation.validateGameMove(data);
if (!validation.isValid) {
  socket.emit('game-error', {
    error: validation.errors.join(', '),
    code: 'VALIDATION_ERROR'
  });
  return;
}
```

## 📈 Scaling Considerations

### Horizontal Scaling

For multiple server instances, consider:

1. **Redis for shared state**

```javascript
// Future: Redis adapter for Socket.IO
const redisAdapter = require('@socket.io/redis-adapter');
const { createClient } = require('redis');

const pubClient = createClient({ url: 'redis://localhost:6379' });
const subClient = pubClient.duplicate();

io.adapter(redisAdapter(pubClient, subClient));
```

2. **Database persistence**

```javascript
// Future: MongoDB for game persistence
const gameSchema = {
  roomId: String,
  players: [String],
  moves: [{ player: String, cell: Number, timestamp: Date }],
  status: String,
  createdAt: Date
};
```

3. **Load balancing**

```nginx
# Nginx configuration for sticky sessions
upstream backend {
  ip_hash;
  server backend1:3000;
  server backend2:3000;
  server backend3:3000;
}
```

## 🚨 Monitoring & Alerting

### Custom Alerts

```javascript
// Example: Set up Slack webhook alerts
const sendSlackAlert = (alert) => {
  const webhook = process.env.SLACK_WEBHOOK_URL;
  if (!webhook) return;
  
  fetch(webhook, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      text: `🚨 Alert: ${alert.type}`,
      attachments: [{
        color: 'danger',
        fields: Object.entries(alert.data).map(([key, value]) => ({
          title: key,
          value: value,
          short: true
        }))
      }]
    })
  });
};
```

### Health Check Integration

```bash
# Add to your monitoring system
#!/bin/bash
# health-check.sh

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health)

if [ $RESPONSE -eq 200 ]; then
  echo "✅ Service healthy"
  exit 0
else
  echo "❌ Service unhealthy (HTTP $RESPONSE)"
  exit 1
fi
```

## 🔮 Future Enhancements

### Planned Features

- [ ] **Database Persistence**: MongoDB/Redis integration
- [ ] **Authentication**: JWT-based user authentication
- [ ] **Tournament Mode**: Multi-game tournaments
- [ ] **Spectator Mode**: Watch games in progress
- [ ] **Chat System**: In-game messaging
- [ ] **Game Recording**: Replay functionality
- [ ] **AI Opponent**: Single-player mode
- [ ] **Mobile Push**: Notifications for turns
- [ ] **Analytics**: Game statistics and insights

### Integration Ideas

- **Discord Bot**: Game notifications and commands
- **Twitch Integration**: Streamer tournament features
- **Mobile App**: React Native companion app
- **Web Dashboard**: Admin panel for monitoring
- **API Gateway**: Rate limiting and authentication

## 📞 Support

### Getting Help

1. **Check the logs**: `npm run logs:tail`
2. **Health status**: `curl http://localhost:3000/health`
3. **GitHub Issues**: Report bugs and feature requests
4. **Documentation**: Check this README and `/docs` endpoint

### Common Error Codes

| Code | Description | Solution |
|------|-------------|----------|
| `VALIDATION_ERROR` | Invalid input data | Check payload format |
| `RATE_LIMIT_EXCEEDED` | Too many requests | Slow down requests |
| `ROOM_NOT_FOUND` | Invalid room ID | Verify room exists |
| `INVALID_TURN` | Not player's turn | Wait for turn |
| `CELL_OCCUPIED` | Cell already taken | Choose empty cell |
| `GAME_NOT_IN_PROGRESS` | Game not active | Check game state |

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Your Name** - *Initial work* - [YourGitHub](https://github.com/yourusername)

## 🙏 Acknowledgments

- Socket.IO team for excellent WebSocket library
- Pino team for high-performance logging
- Express.js team for robust web framework
- Open source community for inspiration and tools

---

**Happy Gaming! 🎮**

For more information, visit the `/docs` endpoint when the server is running, or check the health status at `/health`.
