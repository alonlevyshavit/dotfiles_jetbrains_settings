#!/usr/bin/env bash
set -eu

function install_dotfiles() {
  local source="${1:-}"
  local target="${2:-}"
  if test ! -e "${source:-}"; then return 0; fi

  while read -r file; do

      relative_file_path="${file#"${source}"/}"
      target_file="${target}/${relative_file_path}"
      target_dir="${target_file%/*}"

      if test ! -d "${target_dir}"; then
          mkdir -p "${target_dir}"
      fi

      printf 'Installing dotfiles symlink %s\n' "${target_file}"
      ln -sf "${file}" "${target_file}"

  done < <(find "${source}" -type f)
}

current_dir="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

install_dotfiles "${current_dir}/home_files" "${HOME}"
install_dotfiles "${current_dir}/workspace_repo" "${GITPOD_REPO_ROOT}"

if test ! -e /usr/bin/commitjb; then
    sudo ln -s "${current_dir}/commitjb" /usr/bin/
fi

workspace_xml="${GITPOD_REPO_ROOT}/.idea/workspace.xml"
# if test -e "${workspace_xml}"; then
  function watch_workspace_xml() {
      tail -n 0 -F "${workspace_xml}" 2>/dev/null | while read -r line; do
          commitjb
          break;
      done || true;
      watch_workspace_xml;
  }
  watch_workspace_xml & disown
# fi

