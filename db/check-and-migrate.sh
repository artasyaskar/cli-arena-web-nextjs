#!/bin/bash
set -e

# Run prisma migrate dev and capture the output
output=$(npx prisma migrate dev --name init 2>&1) || true

# Check if the output contains the drift error message
if [[ $output == *"Drift detected"* ]]; then
  echo "Prisma drift detected. Checking for dev environment."
  # Check for a non-CI environment to ensure this only runs in dev
  if [ -z "$CI" ]; then
    echo "Dev environment detected. Resetting the database."
    npx prisma migrate reset --force
  else
    echo "CI environment detected. Skipping automatic reset."
    echo "$output"
    exit 1
  fi
else
  echo "$output"
  if [[ $output == *"Error"* ]]; then
    exit 1
  fi
fi

echo "Migration check complete."
