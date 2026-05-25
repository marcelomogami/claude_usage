#!/usr/bin/env bash
MODE=${1:-all}

CREDENTIALS=~/.claude/.credentials.json
CACHE_DIR=~/.cache/claudebar
CACHE_FILE="$CACHE_DIR/usage.json"
CACHE_TTL=60
LOCK_FILE="$CACHE_DIR/.fetch.lock"

# Garante que o token está válido; faz refresh se expirado.
ensure_token() {
    local expires_at
    expires_at=$(jq -r '.claudeAiOauth.expiresAt // 0' "$CREDENTIALS")
    local now_ms=$(( $(date +%s) * 1000 ))

    if (( now_ms < expires_at - 30000 )); then
        jq -r '.claudeAiOauth.accessToken' "$CREDENTIALS"
        return
    fi

    local refresh_token client_id
    refresh_token=$(jq -r '.claudeAiOauth.refreshToken' "$CREDENTIALS")
    client_id="9d1c250a-e61b-44d9-88ed-5944d1962f5e"

    local resp
    resp=$(curl -sf --max-time 25 -X POST https://platform.claude.com/v1/oauth/token \
        -H "Content-Type: application/json" \
        -d "{\"grant_type\":\"refresh_token\",\"client_id\":\"$client_id\",\"refresh_token\":\"$refresh_token\"}")

    if [[ -z "$resp" ]]; then
        jq -r '.claudeAiOauth.accessToken' "$CREDENTIALS"
        return
    fi

    local new_token new_refresh new_expires
    new_token=$(echo "$resp"   | jq -r '.access_token  // empty')
    new_refresh=$(echo "$resp" | jq -r '.refresh_token // empty')
    new_expires=$(echo "$resp" | jq -r '.expires_in    // empty')

    if [[ -n "$new_token" ]]; then
        local new_expires_ms=$(( $(date +%s) * 1000 + new_expires * 1000 ))
        local tmp
        tmp=$(mktemp)
        jq --arg t "$new_token" --arg r "$new_refresh" --argjson e "$new_expires_ms" \
            '.claudeAiOauth.accessToken  = $t |
             .claudeAiOauth.refreshToken = $r |
             .claudeAiOauth.expiresAt    = $e' \
            "$CREDENTIALS" > "$tmp" && mv "$tmp" "$CREDENTIALS"
        echo "$new_token"
    else
        jq -r '.claudeAiOauth.accessToken' "$CREDENTIALS"
    fi
}

# Retorna o JSON de usage, usando cache se ainda válido.
fetch_usage() {
    mkdir -p "$CACHE_DIR"
    exec 9>"$LOCK_FILE"
    flock -w 10 9 || { jq -r '.claudeAiOauth.accessToken' "$CREDENTIALS"; return; }

    if [[ -f "$CACHE_FILE" ]]; then
        local age=$(( $(date +%s) - $(date -r "$CACHE_FILE" +%s) ))
        if (( age < CACHE_TTL )); then
            cat "$CACHE_FILE"
            return
        fi
    fi

    local token
    token=$(ensure_token)
    local data
    data=$(curl -sf -H "Authorization: Bearer $token" https://api.anthropic.com/api/oauth/usage)

    if [[ -n "$data" ]]; then
        echo "$data" > "$CACHE_FILE"
        echo "$data"
    elif [[ -f "$CACHE_FILE" ]]; then
        cat "$CACHE_FILE"
    fi
}

if [[ "$MODE" == "all" || "$MODE" == "usage" ]]; then
    DATA=$(fetch_usage)
    FIVE_H=$(echo "$DATA" | jq -r '.five_hour.utilization | round | tostring + "%"')
    WEEK=$(echo "$DATA"   | jq -r '.seven_day.utilization  | round | tostring + "%"')

    # Horário (local) em que a janela de 5h reinicia
    FIVE_RESET=$(echo "$DATA" | jq -r '.five_hour.resets_at // empty')
    if [[ -n "$FIVE_RESET" ]]; then
        FIVE_H="${FIVE_H} ($(printf '')$(date -d "$FIVE_RESET" '+%H:%M'))"
    fi

    # Meta em tempo real: minutos decorridos desde o início do ciclo de 7 dias.
    RESETS_AT=$(echo "$DATA" | jq -r '.seven_day.resets_at // empty')
    if [[ -n "$RESETS_AT" ]]; then
        NOW=$(date +%s)
        NEXT_RESET=$(date -d "$RESETS_AT" +%s)
        CYCLE_START=$(( NEXT_RESET - 7 * 86400 ))
        CYCLE_MINUTES=$(( 7 * 24 * 60 ))
        ELAPSED_MINUTES=$(( (NOW - CYCLE_START) / 60 ))
        (( ELAPSED_MINUTES < 0 )) && ELAPSED_MINUTES=0
        (( ELAPSED_MINUTES > CYCLE_MINUTES )) && ELAPSED_MINUTES=$CYCLE_MINUTES
        TARGET=$(awk "BEGIN{printf \"%d\", $ELAPSED_MINUTES*100/$CYCLE_MINUTES + 0.5}")
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
