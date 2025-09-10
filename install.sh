#!/bin/bash
set -e
export GITHUB_BASE_URL="https://raw.githubusercontent.com/NaufalYuPra/pterodactyl-installer"
export GITHUB_SOURCE="main"
LOG_PATH="/var/log/pterodactyl-installer.log"
if ! command -v curl >/dev/null 2>&1; then echo "* curl is required."; exit 1; fi
[ -f /tmp/lib.sh ] && rm -rf /tmp/lib.sh
curl -H "Authorization: token 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" -sSL -o /tmp/lib.sh "$GITHUB_BASE_URL"/"$GITHUB_SOURCE"/lib/lib.sh
source /tmp/lib.sh
welcome ""
done=false
while [ "$done" == false ]; do
options=(
  "Install Test Panel (theme/css testing)"
  "Uninstall Test Panel"
  "Upgrade Panel Utama (keep DB/Wings/Node)"
  "Install the panel"
  "Install Wings"
  "Install both [0] and [1] on the same machine (wings script runs after panel)"
  "Install panel with canary version of the script (the versions that lives in master, may be broken!)"
  "Install Wings with canary version of the script (the versions that lives in master, may be broken!)"
  "Install both [3] and [4] on the same machine (wings script runs after panel)"
  "Uninstall panel or wings with canary version of the script (the versions that lives in master, may be broken!)"
  "Provisioner: Install domain provision helper + sudoers"
  "Add Domain (CLI quick)"
)
actions=(
  "test_panel"
  "uninstall_test"
  "upgrade_panel"
  "panel"
  "wings"
  "panel;wings"
  "panel_canary"
  "wings_canary"
  "panel_canary;wings_canary"
  "uninstall_canary"
  "provisioner"
  "domain_cli"
)
output "What would you like to do?"
for i in "${!options[@]}"; do output "[$i] ${options[$i]}"; done
echo -n "* Input 0-$((${#actions[@]} - 1)): "
read -r action
[ -z "$action" ] && error "Input is required" && continue
valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 1)); do echo "${i}"; done)")
[[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option" && continue
done=true && IFS=";" read -r i1 i2 <<<"${actions[$action]}" && run_ui "$i1"
done
rm -rf /tmp/lib.sh
