#!/usr/bin/env bash
CREDENTIALS=~/.claude/.credentials.json
TOKEN=$(jq -r '.claudeAiOauth.accessToken' "$CREDENTIALS")
DATA=$(curl -sf -H "Authorization: Bearer $TOKEN" https://api.anthropic.com/api/oauth/usage)
FIVE_H=$(echo "$DATA" | jq -r '.five_hour.utilization | round | tostring + "%"')
WEEK=$(echo "$DATA"   | jq -r '.seven_day.utilization  | round | tostring + "%"')
echo "Claude  5h:$FIVE_H  7d:$WEEK"
