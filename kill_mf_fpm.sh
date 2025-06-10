#!/bin/bash

CPU_LIMIT=125 #%
MAX_KILLS=2
WHITELIST=("devlnx_pl" "devlnx_com") #add more pools
LOG_FILE="/var/log/fpm-killer.log"
DISCORD_WEBHOOK="https://discordapp.com/api/webhooks/..." # add you webhook

echo "$(date '+%Y-%m-%d %H:%M:%S') 🔍 Starting analysing" >> "$LOG_FILE"

IFS=$'\n'

for POOL in "${WHITELIST[@]}"; do
    echo "--- Pool analyse $POOL ---" | tee -a "$LOG_FILE"

    # Skip not active
    if ! ps aux | grep "php-fpm: pool $POOL" | grep -v grep > /dev/null; then
        echo "⚠️ Pool $POOL inactive - skipping" | tee -a "$LOG_FILE"
        continue
    fi

    KILL_COUNT=0

    for LINE in $(ps -eo pid,pcpu,cmd --sort=-pcpu | grep "php-fpm: pool $POOL"); do
        PID=$(echo "$LINE" | awk '{print $1}')
        CPU=$(echo "$LINE" | awk '{print $2}')
        CMD=$(echo "$LINE" | cut -d ' ' -f3-)

        cpu_ok=$(echo "$CPU > $CPU_LIMIT" | bc -l)
        if [[ "$cpu_ok" -eq 1 ]]; then
            if (( KILL_COUNT < MAX_KILLS )); then
                echo "🛑 Killing PID=$PID (POOL=$POOL, CPU=$CPU%)" | tee -a "$LOG_FILE"
                kill -15 "$PID"
                sleep 2
                if ps -p "$PID" > /dev/null; then
                    echo "❌ Proces $PID didn't finish, using SIGKILL" | tee -a "$LOG_FILE"
                    kill -9 "$PID"
                fi

                # Notify Discord
                MESSAGE="💀 Killed FPM PID=$PID (POOL: $POOL, CPU: $CPU%) @ $(hostname) 🖥️"
                curl -s -H "Content-Type: application/json" \
                     -X POST \
                     -d "{\"content\": \"$MESSAGE\"}" \
                     "$DISCORD_WEBHOOK"

                ((KILL_COUNT++))
            else
                echo "⏩ Killing limit reached for $POOL (MAX_KILLS=$MAX_KILLS)" | tee -a "$LOG_FILE"
                break
            fi
        fi
    done
done

unset IFS
