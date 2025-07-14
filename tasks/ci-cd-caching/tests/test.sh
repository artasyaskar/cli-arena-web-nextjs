#!/bin/bash

# This task is difficult to test automatically in a local environment.
# The success of this task would be verified by observing the CI/CD pipeline
# on GitHub and confirming that the caching is working as expected.

# For the purpose of this test, we will just check that the ci.yml file
# has been updated to include the caching step.

if ! grep -q "actions/cache@v3" .github/workflows/ci.yml; then
  echo "CI/CD caching test failed. The ci.yml file does not include the caching step."
  exit 1
fi

echo "CI/CD caching test passed!"
exit 0
