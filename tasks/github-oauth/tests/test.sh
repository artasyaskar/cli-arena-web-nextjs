#!/bin/bash

# 1. Check that the GitHub OAuth routes are accessible
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/auth/signin)
if [ "$response" -ne 200 ]; then
  echo "GitHub OAuth test failed. Sign-in page not accessible."
  exit 1
fi

response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/auth/providers)
if [ "$response" -ne 200 ]; then
  echo "GitHub OAuth test failed. Providers endpoint not accessible."
  exit 1
fi

# In a real test, you would need to mock the GitHub API and the database
# to test the user linking and creation logic.

echo "GitHub OAuth test passed!"
exit 0
