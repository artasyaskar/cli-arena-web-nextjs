#!/bin/bash

# 1. Send a GraphQL query to the endpoint
response=$(curl -s -X POST -H "Content-Type: application/json" -d '{"query": "{ hello }"}' http://localhost:3000/api/graphql)
message=$(echo "$response" | jq -r '.data.hello')

if [ "$message" != "Hello, world!" ]; then
  echo "GraphQL test failed. Expected 'Hello, world!', but got '$message'"
  exit 1
fi

# 2. Check that the existing REST APIs are still working
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/v1/users)
if [ "$response" -ne 200 ]; then
  echo "REST API test failed. Expected status code 200, but got $response"
  exit 1
fi

echo "GraphQL support test passed!"
exit 0
