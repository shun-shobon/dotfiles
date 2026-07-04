#!/usr/bin/env bash
# Claude Code statusLine（settings.json の statusLine.command から呼ばれる）
# stdin で Claude Code から JSON を受け取り、1行を stdout に出力する
# 表示順: モデル+コンテキスト(バー+%) │ ディレクトリ(末尾2要素) │ ブランチ+PR │ 追加/削除行数 │ レート制限(5h/7d)
# レート制限・PR・行数は該当データがあるときだけ表示される
# Nerd Font 必須。私用領域(PUA)グリフは編集経由で消失しやすいため printf のバイト列で生成する

input=$(cat)

# フィールド抽出は jq 1回にまとめる（1行1フィールド。タブ区切りだと空フィールドが潰れるため）
{
  read -r model
  read -r dir
  read -r ctx
  read -r rate5h
  read -r rate7d
  read -r lines_add
  read -r lines_del
  read -r pr_num
  read -r pr_state
} < <(echo "$input" | jq -r '
  (.model.display_name // "?"),
  (.workspace.current_dir // "?"),
  (.context_window.used_percentage // ""),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.seven_day.used_percentage // ""),
  ((.cost.total_lines_added // 0) | floor),
  ((.cost.total_lines_removed // 0) | floor),
  (.pr.number // ""),
  (.pr.review_state // "")
')

RESET=$'\033[0m'
DIM=$'\033[90m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
SEP="${DIM}│${RESET}"
BG_TRACK=$'\033[48;5;238m' # バー未使用部分の背景色（ダークグレーのトラック）

ICON_CHIP=$(printf '\357\213\233')   # U+F2DB nf-fa-microchip
ICON_FOLDER=$(printf '\357\201\274') # U+F07C nf-fa-folder_open
ICON_BRANCH=$(printf '\356\234\245') # U+E725 nf-dev-git_branch
ICON_GAUGE=$(printf '\357\203\244')  # U+F0E4 nf-fa-tachometer

# 使用率のしきい値色（コンテキスト・レート制限で共通）: 50%/80% で 緑→黄→赤
pct_color() {
  if   [ "$1" -lt 50 ]; then printf '%s' "$GREEN"
  elif [ "$1" -lt 80 ]; then printf '%s' "$YELLOW"
  else                        printf '%s' "$RED"
  fi
}

# モデル+コンテキスト: アイコン・モデル名に続けて使用率の10マスバーと%。
# 使用率が取れない間（セッション開始直後など）はモデル名のみ
line="${MAGENTA}${ICON_CHIP} ${model}${RESET}"
if [ -n "$ctx" ]; then
  pct=$(printf '%.0f' "$ctx")
  color=$(pct_color "$pct")
  # バーは 1/8 ブロック単位で描画（10マス×8段階 = 1.25%刻み）
  eighths=$(awk -v p="$ctx" 'BEGIN { e = int(p * 0.8 + 0.5); if (e < 0) e = 0; if (e > 80) e = 80; print e }')
  full=$(( eighths / 8 ))
  rem=$(( eighths % 8 ))
  partial=("" "▏" "▎" "▍" "▌" "▋" "▊" "▉")
  bar_on=""
  for ((i = 0; i < full; i++)); do bar_on+="█"; done
  used=$full
  if [ "$rem" -gt 0 ]; then
    bar_on+="${partial[rem]}"
    used=$(( full + 1 ))
  fi
  bar_off=""
  for ((i = used; i < 10; i++)); do bar_off+=" "; done
  line+=" ${BG_TRACK}${color}${bar_on}${bar_off}${RESET} ${color}${pct}%${RESET}"
fi

# ディレクトリ: ホームを ~ に短縮したうえで、パスの末尾2要素だけ表示
display_dir="${dir/#$HOME/\~}"
short_dir=$(echo "$display_dir" | awk -F/ '{ if (NF <= 2) print; else print $(NF-1) "/" $NF }')
line+=" ${SEP} ${CYAN}${ICON_FOLDER} ${short_dir}${RESET}"

# ブランチ+PR: リポジトリ内のみ表示。クリーン=緑、未コミット変更あり=黄+*。
# デタッチHEAD時は短縮SHA。オープンPRがあれば #番号 をレビュー状態の色で続ける
# （approved=緑 / changes_requested=赤 / pending=黄 / 状態なし=シアン）
if git -C "$dir" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$(git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
    seg="${YELLOW}${ICON_BRANCH} ${branch}*${RESET}"
  else
    seg="${GREEN}${ICON_BRANCH} ${branch}${RESET}"
  fi
  if [ -n "$pr_num" ]; then
    case "$pr_state" in
      approved)          pr_color=$GREEN ;;
      changes_requested) pr_color=$RED ;;
      pending)           pr_color=$YELLOW ;;
      *)                 pr_color=$CYAN ;;
    esac
    seg+=" ${pr_color}#${pr_num}${RESET}"
  fi
  line+=" ${SEP} ${seg}"
fi

# 追加/削除行数: セッション中にどちらかが 1 行以上あるときだけ表示
if [ "$lines_add" -gt 0 ] || [ "$lines_del" -gt 0 ]; then
  line+=" ${SEP} ${GREEN}+${lines_add}${RESET} ${RED}-${lines_del}${RESET}"
fi

# レート制限: 5時間/7日の使用率。Claude.ai サブスク時のみ JSON に含まれる。
# アイコンは悪い方の値の色になる
if [ -n "$rate5h" ] || [ -n "$rate7d" ]; then
  rate_txt=""
  worst=0
  if [ -n "$rate5h" ]; then
    p=$(printf '%.0f' "$rate5h")
    rate_txt+="${DIM}5h${RESET} $(pct_color "$p")${p}%${RESET}"
    [ "$p" -gt "$worst" ] && worst=$p
  fi
  if [ -n "$rate7d" ]; then
    p=$(printf '%.0f' "$rate7d")
    [ -n "$rate_txt" ] && rate_txt+=" "
    rate_txt+="${DIM}7d${RESET} $(pct_color "$p")${p}%${RESET}"
    [ "$p" -gt "$worst" ] && worst=$p
  fi
  line+=" ${SEP} $(pct_color "$worst")${ICON_GAUGE}${RESET} ${rate_txt}"
fi

printf '%s' "$line"
