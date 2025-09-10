#!/bin/bash
set -e
YUPRA_PANEL_REPO="https://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@github.com/NaufalYuPra/Pterodactyl.git"
TOKEN_INLINE="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"
RAW_BASE="https://raw.githubusercontent.com/NaufalYuPra/pterodactyl-installer"
BRANCH="main"
output() { echo -e "\033[1;32m$1\033[0m"; }
error()  { echo -e "\033[1;31m$1\033[0m" >&2; }
welcome() {
cat <<'EOF'
###############################################################
#  YUPRA Pterodactyl Installer                                #
#  Private repo + Webhost Provision                           #
###############################################################
EOF
}
run_ui() {
  case "$1" in
    panel)        remote_exec installers/panel.sh ; remote_exec installers/wings.sh ;;
    wings)        remote_exec installers/wings.sh ;;
    "panel;wings")        remote_exec installers/panel.sh ; remote_exec installers/wings.sh ;;
    uninstall)        remote_exec installers/uninstall.sh ;;
    test_panel)        remote_exec installers/test_panel.sh ;;
    uninstall_test)        remote_exec installers/uninstall_test.sh ;;
    upgrade_panel)        remote_exec installers/upgrade_panel.sh ;;
    phpmyadmin)        remote_exec installers/phpmyadmin.sh ;;
    provisioner)        remote_exec installers/provisioner.sh ;;
    domain_cli)        remote_exec installers/domain.sh ;;
    panel_canary)        remote_exec installers/panel.sh ; remote_exec installers/wings.sh ;;
    wings_canary)        remote_exec installers/wings.sh ;;
    uninstall_canary)        remote_exec installers/uninstall.sh ;;
    *) error "Unknown action: $1"; exit 1 ;;
  esac
}
update_lib_source() {
  [ -f /tmp/lib.sh ] && rm -f /tmp/lib.sh
  curl -H "Authorization: token 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" -sSL -o /tmp/lib.sh "$RAW_BASE"/"$BRANCH"/lib/lib.sh
  source /tmp/lib.sh
}

remote_exec() {
  # $1: path under repo (e.g., installers/panel.sh)
  local path="$1"
  if [ -z "$path" ]; then error "remote_exec missing path"; exit 1; fi
  curl -H "Authorization: token $TOKEN_INLINE" -sSL "$RAW_BASE/$BRANCH/$path" | bash -s -- "$@"
}
