#!/usr/bin/env bash
MODE=${1:-all}

if [[ "$MODE" == "all" || "$MODE" == "usage" ]]; then
    CREDENTIALS=~/.claude/.credentials.json
    TOKEN=$(jq -r '.claudeAiOauth.accessToken' "$CREDENTIALS")
    DATA=$(curl -sf -H "Authorization: Bearer $TOKEN" https://api.anthropic.com/api/oauth/usage)
    FIVE_H=$(echo "$DATA" | jq -r '.five_hour.utilization | round | tostring + "%"')
    WEEK=$(echo "$DATA"   | jq -r '.seven_day.utilization  | round | tostring + "%"')

    # Horário (local) em que a janela de 5h reinicia
    FIVE_RESET=$(echo "$DATA" | jq -r '.five_hour.resets_at // empty')
    if [[ -n "$FIVE_RESET" ]]; then
        FIVE_H="${FIVE_H} ($(printf '')$(date -d "$FIVE_RESET" '+%H:%M'))"
    fi

    # Meta do dia: 100% da cota divididos em 7 dias. O início do ciclo vem da
    # própria API (seven_day.resets_at é o próximo reset; ciclo = 7 dias antes).
    RESETS_AT=$(echo "$DATA" | jq -r '.seven_day.resets_at // empty')
    if [[ -n "$RESETS_AT" ]]; then
        NOW=$(date +%s)
        NEXT_RESET=$(date -d "$RESETS_AT" +%s)
        CYCLE_START=$(( NEXT_RESET - 7 * 86400 ))
        DAY_IDX=$(( (NOW - CYCLE_START) / 86400 + 1 ))
        (( DAY_IDX < 1 )) && DAY_IDX=1
        (( DAY_IDX > 7 )) && DAY_IDX=7
        TARGET=$(awk "BEGIN{printf \"%d\", $DAY_IDX*100/7 + 0.5}")
        WEEK="${WEEK} (↑${TARGET}%)"
    fi
fi

if [[ "$MODE" == "all" || "$MODE" == "status" ]]; then
    STATUS=$(curl -sf --connect-timeout 3 --max-time 5 https://status.claude.com/api/v2/status.json 2>/dev/null | jq -r '.status.indicator // "unknown"' 2>/dev/null)
    STATUS=${STATUS:-unknown}
fi

case "$MODE" in
    usage)  echo "Claude  5h: $FIVE_H  |  7d: $WEEK" ;;
    status) echo "$STATUS" ;;
    *)      echo "Claude  5h: $FIVE_H  |  7d: $WEEK::$STATUS" ;;
esac
