#!/bin/bash

# 1. Setup 2FA and get the secret
response=$(curl -s -X POST http://localhost:3000/api/auth/2fa-setup)
secret=$(echo "$response" | jq -r '.secret')

if [ -z "$secret" ]; then
  echo "Failed to set up 2FA"
  exit 1
fi

# 2. Generate a valid TOTP token
token=$(node -e "const { authenticator } = require('otplib'); console.log(authenticator.generate('$secret'))")

# 3. Attempt to verify with the valid token
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "{\"token\": \"$token\"}" http://localhost:3000/api/auth/2fa-verify)

if [ "$response" -ne 200 ]; then
  echo "2FA verification test failed. Expected status code 200, but got $response"
  exit 1
fi

# 4. Attempt to verify with an invalid token
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d '{"token": "123456"}' http://localhost:3000/api/auth/2fa-verify)

if [ "$response" -ne 401 ]; then
  echo "2FA verification test failed. Expected status code 401, but got $response"
  exit 1
fi

echo "2FA test passed!"
exit 0
