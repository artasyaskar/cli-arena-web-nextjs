#!/bin/bash

# Flush Redis before the test
redis-cli flushall

# Make 10 requests to the API
for i in {1..10}; do
  response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api)
  if [ "$response" -ne 200 ]; then
    echo "Request $i failed with status code $response"
    exit 1
  fi
done

# The 11th request should be rate-limited
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api)
if [ "$response" -ne 429 ]; then
  echo "Rate limiting test failed. Expected status code 429, but got $response"
  exit 1
fi

echo "Rate limiting test passed!"
exit 0
