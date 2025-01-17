#!/usr/bin/env bash

# shellcheck disable=SC2155

PANE_PATH=$(tmux display-message -p -F "#{pane_current_path}")
cd "${PANE_PATH}" || return

git_changes() {
  local changes=$(git diff --shortstat | sed 's/^[^0-9]*\([0-9]*\)[^0-9]*\([0-9]*\)[^0-9]*\([0-9]*\)[^0-9]*/\1;\2;\3/')
  local changes_array=("${changes//;/ }")
  local untracked=$(git status --porcelain 2>/dev/null| grep -c "^??")
  local result=()

  [[ $untracked != 0 ]] && result+=("?$untracked")
  [[ -n ${changes_array[0]} ]] && result+=("~${changes_array[0]}")
  [[ -n ${changes_array[1]} ]] && result+=("+${changes_array[1]}")
  [[ -n ${changes_array[2]} ]] && result+=("-${changes_array[2]}")

  local joined=$(printf " %s" "${result[@]}")
  local joined=${joined:1}

  [[ -n $joined ]] && echo "$joined"
}

git_status() {
  local status=$(git rev-parse --abbrev-ref HEAD)
  local changes=$(git_changes)

  [[ -n $status ]] && printf "%s %s" "${status}" "${changes}"
}

main() {
  git_status
}

main
