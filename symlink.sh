#!/usr/bin/env bash
# Symlinks dotfiles from $PWD to $HOME
# Existing non-symlinked files are copied as .bak before overwriting

# Do not symlink these files
EXCLUDE_FILES=(
  ".DS_Store"
  "README.md"
  "LICENSE"
  $(basename "$0")
)

# Do not symlink these directories
EXCLUDE_DIRS=(
  ".git"
)

is_excluded() {
  local file="$1"
  for exclude in "${EXCLUDE_FILES[@]}"; do
    if [[ "$file" == "$exclude" ]]; then
      return 0
    fi
  done
  return 1
}

# Build find arguments with directory pruning
find_args=("$PWD")
for dir in "${EXCLUDE_DIRS[@]}"; do
  find_args+=(-name "$dir" -prune -o)
done
find_args+=(-type f -print)

find "${find_args[@]}" | while read -r full_path; do
  file="${full_path#"$PWD"/}"
  filename="$(basename "$file")"

  if is_excluded "$filename"; then
    echo -e "\e[33mSkipping $file\e[0m"
    continue
  fi

  src_path="$PWD/$file"
  dst_path="$HOME/$file"

  dst_dir="$(dirname "$dst_path")"
  mkdir -p "$dst_dir"


  if [[ -e "$dst_path" && ! -L "$dst_path" ]]; then
    cp "$dst_path" "$dst_path.bak"
    echo -e "\e[36mFound existing file: $file - backed up to ${file}.bak\e[0m"
  fi

  rm -f "$dst_path"

  if ln -s "$src_path" "$dst_path"; then
    echo -e "\e[32mSymlinked $file\e[0m"
  else
    echo -e "\e[31mFailed to symlink $file\e[0m"
  fi
done
