#!/bin/bash

# 1. Install dependencies
npm install ws @types/ws ioredis

# 2. Create the WebSocket server
mkdir -p src/server
cat << 'EOF' > src/server/index.ts
import { WebSocketServer } from 'ws';
import Redis from 'ioredis';

const publisher = new Redis(process.env.REDIS_URL);
const subscriber = new Redis(process.env.REDIS_URL);

const wss = new WebSocketServer({ port: 8080 });

wss.on('connection', ws => {
  console.log('Client connected');

  ws.on('message', message => {
    console.log(`Received message: ${message}`);
    publisher.publish('chat', message.toString());
  });

  ws.on('close', () => {
    console.log('Client disconnected');
  });
});

subscriber.subscribe('chat', (err, count) => {
  if (err) {
    console.error('Failed to subscribe:', err);
    return;
  }
  console.log(`Subscribed to ${count} channels.`);
});

subscriber.on('message', (channel, message) => {
  console.log(`Received message from ${channel}: ${message}`);
  wss.clients.forEach(client => {
    if (client.readyState === client.OPEN) {
      client.send(message);
    }
  });
});

console.log('WebSocket server started on port 8080');
EOF

# 3. Create the chat page
mkdir -p src/pages/chat
cat << 'EOF' > src/pages/chat/index.tsx
import { useState, useEffect } from 'react';

const ChatPage = () => {
  const [ws, setWs] = useState<WebSocket | null>(null);
  const [messages, setMessages] = useState<string[]>([]);
  const [input, setInput] = useState('');

  useEffect(() => {
    const socket = new WebSocket('ws://localhost:8080/chat');
    setWs(socket);

    socket.onopen = () => {
      console.log('Connected to WebSocket server');
    };

    socket.onmessage = event => {
      setMessages(prevMessages => [...prevMessages, event.data]);
    };

    socket.onclose = () => {
      console.log('Disconnected from WebSocket server');
    };

    return () => {
      socket.close();
    };
  }, []);

  const sendMessage = () => {
    if (ws && input) {
      ws.send(input);
      setInput('');
    }
  };

  return (
    <div>
      <h1>Real-Time Chat</h1>
      <div>
        {messages.map((msg, index) => (
          <div key={index}>{msg}</div>
        ))}
      </div>
      <input
        type="text"
        value={input}
        onChange={e => setInput(e.target.value)}
      />
      <button onClick={sendMessage}>Send</button>
    </div>
  );
};

export default ChatPage;
EOF

# 4. Start the WebSocket server in the background
ts-node src/server/index.ts &
server_pid=$!

# 5. Start the Next.js app
npm run dev &
app_pid=$!

# Wait for the servers to start
sleep 10

# Kill the servers on exit
trap 'kill $server_pid $app_pid' EXIT
