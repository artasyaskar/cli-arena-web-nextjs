#!/bin/bash

# Check that the monolithic API returns a 410 Gone status
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/monolith)
if [ "$response" -ne 410 ]; then
  echo "Monolithic API test failed. Expected status code 410, but got $response"
  exit 1
fi

# Check that the new API modules are functional
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/v1/users)
if [ "$response" -ne 200 ]; then
  echo "Users API test failed. Expected status code 200, but got $response"
  exit 1
fi

response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/v1/products)
if [ "$response" -ne 200 ]; then
  echo "Products API test failed. Expected status code 200, but got $response"
  exit 1
fi

response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/v1/orders)
if [ "$response" -ne 200 ]; then
  echo "Orders API test failed. Expected status code 200, but got $response"
  exit 1
fi

echo "API refactoring test passed!"
exit 0
