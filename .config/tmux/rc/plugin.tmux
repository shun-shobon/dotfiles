#!/usr/bin/env bash

run "[ -d \"${TMUX_DATA_DIR}/plugins/tpm\" ] || git clone https://github.com/tmux-plugins/tpm \"${TMUX_DATA_DIR}/plugins/tpm\""

setenv -g TMUX_PLUGIN_MANAGER_PATH "${TMUX_DATA_DIR}/plugins"

set -g @tpm_plugins ' \
  tmux-plugins/tpm \
  arcticicestudio/nord-tmux \
'

run "${TMUX_DATA_DIR}/plugins/tpm/tpm"
