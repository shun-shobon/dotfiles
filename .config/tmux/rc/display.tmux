#!/usr/bin/env bash

# 256色表示に対応する
set -g default-terminal screen-256color
set -sa terminal-overrides ",xterm-256color:RGB"

# ステータスバーを上部にも表示
set-option -g status-position top

# ステータスバーを3秒毎に更新
set-option -g status-interval 3

# ステータスバーの最大長を設定
set-option -g status-left-length 20
set-option -g status-right-length 60
