#!/bin/bash

# 1. Check that the sitemap is accessible at /sitemap.xml
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/sitemap.xml)
if [ "$response" -ne 200 ]; then
  echo "Sitemap test failed. Expected status code 200, but got $response"
  exit 1
fi

# 2. Check that the sitemap contains the expected content
sitemap=$(curl -s http://localhost:3000/sitemap.xml)
if ! echo "$sitemap" | grep -q "<loc>http://localhost:3000/</loc>"; then
  echo "Sitemap test failed. Sitemap does not contain the root URL."
  exit 1
fi

# This assumes a user with id 1 exists
if ! echo "$sitemap" | grep -q "<loc>http://localhost:3000/users/1</loc>"; then
  echo "Sitemap test failed. Sitemap does not contain the user URL."
  exit 1
fi

echo "Dynamic sitemap test passed!"
exit 0
