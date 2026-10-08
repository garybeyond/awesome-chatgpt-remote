#!/bin/zsh
set -euo pipefail

script_dir="${0:A:h}"
repo_dir="${script_dir:h}"
app_path="$repo_dir/dist/ChatGPT via Clash.app"

mkdir -p "$repo_dir/dist"
/usr/bin/osacompile -o "$app_path" "$script_dir/ChatGPT via Clash.applescript"
print "Built: $app_path"
print "Quit ChatGPT first, then double-click the new app."
