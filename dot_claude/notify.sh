#!/usr/bin/env bash

# JSONから最後のエージェント発言を抽出
LAST_MESSAGE=$(echo "$1" | jq -r '.message // "Claude Code needs your action."')

# osascriptで通知表示
osascript -e "display notification \"$LAST_MESSAGE\" with title \"Claude Code\" sound name \"Glass\""

# パーティクルを出す
open -g "raycast://extensions/raycast/raycast/confetti"
