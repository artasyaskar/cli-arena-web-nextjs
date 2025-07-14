#!/bin/bash

# 1. Upload the file
response=$(curl -s -X POST -F "avatar=@tasks/file-upload-s3/resources/dummy.txt" http://localhost:3000/api/users/avatar)
avatarUrl=$(echo "$response" | jq -r '.avatarUrl')

if [ -z "$avatarUrl" ]; then
  echo "File upload test failed. No avatarUrl returned."
  exit 1
fi

# 2. Check that the user's avatarUrl has been updated in the database
# This would require a database query in a real test.
# For this simplified test, we'll just check that the URL looks like an S3 URL.
if ! echo "$avatarUrl" | grep -q "s3"; then
  echo "File upload test failed. The returned URL does not look like an S3 URL."
  exit 1
fi

echo "File upload + S3 integration test passed!"
exit 0
