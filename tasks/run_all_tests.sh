#!/bin/bash

for task in tasks/*; do
  if [ -f "$task/tests/test.sh" ]; then
    echo "Running tests for $task"
    bash "$task/tests/test.sh"
  fi
done
