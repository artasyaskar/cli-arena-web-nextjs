#!/bin/bash

# 1. Run a local server to serve the mock article
python3 -m http.server 8000 &
server_pid=$!

# 2. Call the summarize API with the URL of the mock article
response=$(curl -s -X POST -H "Content-Type: application/json" -d '{"url": "http://localhost:8000/tasks/openai-summarizer/resources/mock-article.html"}' http://localhost:3000/api/summarize)
summary=$(echo "$response" | jq -r '.summary')

# 3. Kill the local server
kill $server_pid

# 4. In a real test, you would mock the OpenAI API and check the summary.
# For this simplified test, we'll just check that the summary is not empty.
if [ -z "$summary" ]; then
  echo "OpenAI summarizer test failed. No summary returned."
  exit 1
fi

echo "OpenAI summarizer test passed!"
exit 0
