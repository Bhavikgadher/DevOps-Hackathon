#!/bin/bash

# AIOps: Agentic AI for DevOps - Log Analyzer
# This script fetches logs from a failed Kubernetes pod and sends them to an LLM (like OpenAI/Gemini) for analysis.

if [ -z "$OPENAI_API_KEY" ]; then
  echo "Error: OPENAI_API_KEY environment variable is not set."
  echo "Please set it using: export OPENAI_API_KEY='your-key'"
  exit 1
fi

NAMESPACE=${1:-skillpulse}

echo "Finding pods with errors or crash loops in namespace: $NAMESPACE..."
FAILED_POD=$(kubectl get pods -n $NAMESPACE --field-selector=status.phase!=Running -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$FAILED_POD" ]; then
  echo "No failing pods found in namespace $NAMESPACE. Everything looks good!"
  exit 0
fi

echo "Found failing pod: $FAILED_POD. Fetching logs..."
POD_LOGS=$(kubectl logs $FAILED_POD -n $NAMESPACE --tail=50 2>/dev/null)

if [ -z "$POD_LOGS" ]; then
  echo "No logs found for pod $FAILED_POD."
  exit 1
fi

echo "Logs fetched successfully. Sending to AI for analysis..."

# Create JSON payload for OpenAI API
PAYLOAD=$(jq -n \
  --arg logs "Analyze these Kubernetes pod logs and tell me the root cause and how to fix it:\n\n$POD_LOGS" \
  '{model: "gpt-4-turbo", messages: [{role: "system", content: "You are an expert DevOps engineer and Kubernetes admin."}, {role: "user", content: $logs}]}')

RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "$PAYLOAD")

echo -e "\n=== AI Analysis & Recommendations ===\n"
echo "$RESPONSE" | jq -r '.choices[0].message.content'
echo -e "\n====================================="
