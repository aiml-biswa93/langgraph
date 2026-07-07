#!/usr/bin/env bash
# Load API keys from .env and create Studio .env files for modules 1-5.
# Usage: source setup-env.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$ROOT/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE"
  echo "Run: cp .env.example .env"
  echo "Then edit .env with your API keys."
  return 1 2>/dev/null || exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

export ANTHROPIC_API_KEY
export LANGSMITH_API_KEY
export LANGSMITH_TRACING_V2="${LANGSMITH_TRACING_V2:-false}"
export LANGSMITH_PROJECT="${LANGSMITH_PROJECT:-langchain-academy}"

if [[ "${LANGSMITH_API_KEY:-}" == "your-langsmith-api-key-here" || -z "${LANGSMITH_API_KEY:-}" ]]; then
  export LANGSMITH_TRACING_V2=false
fi

for i in {1..5}; do
  studio_env="$ROOT/module-$i/studio/.env"
  mkdir -p "$(dirname "$studio_env")"
  {
    echo "ANTHROPIC_API_KEY=\"$ANTHROPIC_API_KEY\""
    echo "LANGSMITH_API_KEY=\"$LANGSMITH_API_KEY\""
    echo "LANGSMITH_TRACING_V2=\"$LANGSMITH_TRACING_V2\""
    echo "LANGSMITH_PROJECT=\"$LANGSMITH_PROJECT\""
    if [[ -n "${LANGSMITH_ENDPOINT:-}" ]]; then
      echo "LANGSMITH_ENDPOINT=\"$LANGSMITH_ENDPOINT\""
    fi
  } > "$studio_env"
done

if [[ -n "${TAVILY_API_KEY:-}" && "${TAVILY_API_KEY}" != "your-tavily-api-key-here" ]]; then
  echo "TAVILY_API_KEY=\"$TAVILY_API_KEY\"" >> "$ROOT/module-4/studio/.env"
fi

deployment_env="$ROOT/module-6/deployment/.env"
mkdir -p "$(dirname "$deployment_env")"
{
  echo "ANTHROPIC_API_KEY=\"$ANTHROPIC_API_KEY\""
  echo "LANGSMITH_API_KEY=\"$LANGSMITH_API_KEY\""
  echo "LANGSMITH_TRACING_V2=\"$LANGSMITH_TRACING_V2\""
  echo "LANGSMITH_PROJECT=\"$LANGSMITH_PROJECT\""
  if [[ -n "${LANGSMITH_ENDPOINT:-}" ]]; then
    echo "LANGSMITH_ENDPOINT=\"$LANGSMITH_ENDPOINT\""
  fi
  if [[ -n "${TAVILY_API_KEY:-}" && "${TAVILY_API_KEY}" != "your-tavily-api-key-here" ]]; then
    echo "TAVILY_API_KEY=\"$TAVILY_API_KEY\""
  fi
} > "$deployment_env"

echo "Environment loaded from .env"
echo "Studio .env files created for modules 1-5"
echo "Deployment .env created for module-6"
