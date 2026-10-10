#!/usr/bin/env bash

set -e

echo "Initializing Boutaba NetRadar Multi-Engine Hardened Suite..."

PIPE_PATH="/tmp/netradar_stream.fifo"
if [ ! -p "$PIPE_PATH" ]; then
    mkfifo "$PIPE_PATH"
fi

echo "Compiling Hardware Core (packet_sniffer.c + inline_asm.h)..."
gcc -O3 -I./src src/packet_sniffer.c -o src/packet_sniffer -lpthread

echo "Injecting Low-Level Raw Socket Sniffer Engine (Ring 0 Level)..."
./src/packet_sniffer > "$PIPE_PATH" &
SNIFFER_PID=$!

echo "Injecting Asynchronous Logic Analyst Engine..."
python3 src/core_analyst.py < "$PIPE_PATH" &
ANALYST_PID=$!

cleanup() {
    kill $SNIFFER_PID 2>/dev/null || true
    kill $ANALYST_PID 2>/dev/null || true
    rm -f "$PIPE_PATH"
    echo "Shared Pipeline Flushed. System Secured and Cleared."
}
trap cleanup EXIT

echo "NetRadar Suite Framework is running dynamically. Capturing Telemetry..."
wait
