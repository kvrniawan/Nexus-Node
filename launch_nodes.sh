#!/bin/bash
SESSION="nexus"
LOG_DIR="/tmp/nexus_logs"
NODE_LIST="$HOME/nodes.txt"
NODES_PER_WINDOW=4

mkdir -p "$LOG_DIR"
tmux has-session -t $SESSION 2>/dev/null && tmux kill-session -t $SESSION
tmux new-session -d -s $SESSION -n window0

i=0
window_index=0

while read -r NODE_ID; do
    [ -z "$NODE_ID" ] && continue
    core=$((i % $(nproc)))

    if (( i > 0 && i % NODES_PER_WINDOW == 0 )); then
        window_index=$((window_index + 1))
        tmux new-window -t $SESSION -n window$window_index
    fi

    target_window="${SESSION}:window$window_index"

    if (( i % NODES_PER_WINDOW != 0 )); then
        tmux split-window -t "$target_window"
    fi

    tmux select-layout -t "$target_window" tiled

    CMD=$(cat <<EOF
attempt=0; max_backoff=60
while true; do
    echo "🟢 Starting node $NODE_ID on core $core at \$(date)"
    nice -n -5 taskset -c $core nexus-network start --node-id "$NODE_ID" 2>&1 | tee "$LOG_DIR/node_$NODE_ID.log"
    echo "🔁 Node $NODE_ID exited. Restarting after delay..."
    attempt=\$((attempt + 1))
    delay=\$((attempt * 3))
    if [ \$delay -gt \$max_backoff ]; then delay=\$max_backoff; fi
    sleep \$delay
done
EOF
)
    tmux send-keys -t "$target_window" "$CMD" C-m
    i=$((i + 1))
done < "$NODE_LIST"

exec sleep infinity