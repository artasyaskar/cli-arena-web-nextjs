#!/bin/bash

# 1. Create a checkout session
response=$(curl -s -X POST http://localhost:3000/api/stripe/create-checkout-session)
sessionId=$(echo "$response" | jq -r '.id')

if [ -z "$sessionId" ]; then
  echo "Stripe checkout session test failed. No session ID returned."
  exit 1
fi

# 2. Simulate a Stripe webhook for a completed checkout session
# In a real test, you would need to use the Stripe CLI to trigger a webhook event.
# For this simplified test, we'll just check that the webhook endpoint is accessible.
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:3000/api/stripe/webhook)
if [ "$response" -ne 400 ]; then # Expecting 400 because of missing signature
  echo "Stripe webhook test failed. Expected status code 400, but got $response"
  exit 1
fi

echo "Stripe subscription test passed!"
exit 0
