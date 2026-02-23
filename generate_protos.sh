#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROTO_SRC="$SCRIPT_DIR/foc-companion/proto"
OUTPUT_DIR="$SCRIPT_DIR/foc-companion/lib/generated/protobuf"

mkdir -p "$OUTPUT_DIR"

# Ensure protoc-gen-dart is in path (usually in ~/.pub-cache/bin)
export PATH="$PATH":"$HOME/.pub-cache/bin"

protoc --dart_out="$OUTPUT_DIR" \
  -I="$PROTO_SRC" \
  "$PROTO_SRC/constants.proto" \
  "$PROTO_SRC/messages.proto" \
  "$PROTO_SRC/notifications.proto" \
  "$PROTO_SRC/focstim_rpc.proto"

echo "Done! Files generated in $OUTPUT_DIR"
