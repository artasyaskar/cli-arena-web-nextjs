#!/bin/bash

# 1. Check that the dashboard page is accessible
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/dashboard)
if [ "$response" -ne 200 ]; then
  echo "Analytics dashboard test failed. Dashboard page not accessible."
  exit 1
fi

# 2. Check that the dashboard page contains an image
body=$(curl -s http://localhost:3000/dashboard)
if ! echo "$body" | grep -q "<img src="; then
  echo "Analytics dashboard test failed. Dashboard page does not contain an image."
  exit 1
fi

echo "Analytics dashboard test passed!"
exit 0
