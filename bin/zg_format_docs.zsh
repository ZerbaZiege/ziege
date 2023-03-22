#!/usr/bin/env zsh

full_path=$(readlink -f "${0}")

full_dir_path="$(dirname $full_path)"

python3 "$full_dir_path/zg_format_docs.py" "$ZIEGE_DOCS_CACHE"
