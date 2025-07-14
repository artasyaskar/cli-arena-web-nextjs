#!/bin/bash

# 1. Make a request to an API route to generate an audit log
curl -s -X POST -H "Content-Type: application/json" -d '{"foo": "bar"}' http://localhost:3000/api/v1/users

# 2. Verify the integrity of the audit logs
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/audit/verify)
if [ "$response" -ne 200 ]; then
  echo "Audit log verification test failed. Expected status code 200, but got $response"
  exit 1
fi

echo "Audit logging test passed!"
exit 0
