#!/bin/bash

set -euo pipefail

function set_xfce_terminal_theme() {
  local themeName=$1
  local theme=/usr/share/xfce4/terminal/colorschemes/${themeName}.theme
  if ! [[ -f $theme ]]; then
    echo "No such colorscheme: $themeName; choose from $(ls /usr/share/xfce4/terminal/colorschemes/ | sed 's/\.theme$//g')"
    exit 1
  fi
  config="$HOME/.config/xfce4/terminal/terminalrc"
  grep -v Color $config >/tmp/terminalrc
  grep Color $theme >>/tmp/terminalrc
  cp /tmp/terminalrc $config
}

function set_vscode_theme() {
  local theme="$1"
  local SETTINGS="$HOME/.config/Code/User/settings.json"
  if grep -q workbench.colorTheme $SETTINGS; then
    # setting exists already; adjust it
    sed -i -e 's/"workbench.colorTheme": ".*"/"workbench.colorTheme": "'"$theme"'"/' $SETTINGS
  else
    # setting doesn't exist yet; add it at the end
    echo adding
    sed -i -e 's/^\}$/  ,\n  "workbench.colorTheme": "'$theme'"\n}/' $SETTINGS
  fi
}

if [[ "${1:-}" == light ]]; then
  # XFCE
  xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita"
  # Terminal
  set_xfce_terminal_theme xubuntu-light
  # git diff
  sed -i 's/delta --dark/delta --light/g' ~/.gitconfig
  # vscode
  set_vscode_theme "Default Light+ Experimental"
  # mousepad
  gsettings set org.xfce.mousepad.preferences.view color-scheme 'xubuntu_light'
else
  # XFCE
  xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
  # Terminal
  set_xfce_terminal_theme tango
  # git diff
  sed -i 's/delta --light/delta --dark/g' ~/.gitconfig
  # vscode
  set_vscode_theme "Visual Studio Dark"
  # mousepad
  gsettings set org.xfce.mousepad.preferences.view color-scheme 'xubuntu_dark'
fi


