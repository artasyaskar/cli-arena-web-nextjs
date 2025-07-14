#!/bin/bash

# 1. Run the tables command and check the output
tables=$(npm run db:introspect -- tables)
if ! echo "$tables" | grep -q "users"; then
  echo "CLI tool 'tables' command failed. Expected to find 'users' table."
  exit 1
fi

# 2. Run the columns command and check the output
columns=$(npm run db:introspect -- columns users)
if ! echo "$columns" | grep -q "id"; then
  echo "CLI tool 'columns' command failed. Expected to find 'id' column in 'users' table."
  exit 1
fi

if ! echo "$columns" | grep -q "name"; then
  echo "CLI tool 'columns' command failed. Expected to find 'name' column in 'users' table."
  exit 1
fi

if ! echo "$columns" | grep -q "email"; then
  echo "CLI tool 'columns' command failed. Expected to find 'email' column in 'users' table."
  exit 1
fi

echo "DB schema introspection CLI test passed!"
exit 0
