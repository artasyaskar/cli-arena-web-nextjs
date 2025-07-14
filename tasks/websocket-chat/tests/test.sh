#!/bin/bash

# Check if the WebSocket server is running
if ! nc -z localhost 8080; then
  echo "WebSocket server is not running on port 8080"
  exit 1
fi

# Check if the chat page is accessible
if ! curl -s http://localhost:3000/chat | grep -q "Real-Time Chat"; then
  echo "Chat page is not accessible or does not contain the correct content"
  exit 1
fi

# Use a simple WebSocket client to send and receive messages
(
  sleep 1
  echo "Hello, from test"
) | websocat ws://localhost:8080/chat > /tmp/ws_output &

sleep 2

# Check if the message was received
if ! grep -q "Hello, from test" /tmp/ws_output; then
  echo "WebSocket test failed. Did not receive the message."
  exit 1
fi

echo "WebSocket chat test passed!"
exit 0
