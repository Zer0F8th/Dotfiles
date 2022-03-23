#!/bin/bash

###########################################
#----------) Terminal Setup (-------------#
###########################################

# Check which distro is running
if [[ -f /etc/os-release ]]; then
  # freedesktop.org and systemd
  . /etc/os-release
  OS=$NAME
  VER=$VERSION_ID
else
  echo "Unsupported OS"
  # Fallback to uname, e.g. "Linux <version>"
  OS=$(uname -s)
  VER=$(uname -r)
fi

if [[ $OS == "Fedora Linux" ]]; then
  echo "================================"
  echo "Fedora Linux"
  echo "================================"

  # Setup Automatic Updates for Fedora
  AUTOMATIC_UPDATES=true
  # Oh My Zsh custom directory
  ZSH_CUSTOM="$HOME"/.oh-my-zsh/custom

  # Update the system and install dependencies

  sudo dnf check-update
  sudo dnf upgrade -y
  sudo dnf install -y git \
    zsh \
    vim \
    wget \
    htop \
    terminator \
    python3-pip \
    python3-virtualenv \
    util-linux-user \
    gnome-tweaks \
    gtk-murrine-engine \
    gnome-shell-extensions \
    stacer

  # Install Discord
  sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm -y

  # Install VS Code
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
  sudo dnf check-update
  sudo dnf install -y discord \
    code

  # Install fonts
  sudo cp -rf ../fonts/Hack/ /usr/share/fonts/
  sudo cp -rf ../fonts/JetBrainsMono/ /usr/share/fonts/

  # Fix permissions on the font directory and the ttf files
  sudo chown -R root:root /usr/share/fonts/Hack
  sudo chown -R root:root /usr/share/fonts/JetBrainsMono
  sudo chmod 755 /usr/share/fonts/Hack && sudo chmod 644 /usr/share/fonts/Hack/*.ttf
  sudo chmod 755 /usr/share/fonts/JetBrainsMono && sudo chmod 644 /usr/share/fonts/JetBrainsMono/*.ttf

  # Refresh the font directory cache
  sudo fc-cache -fv

  # Setup Terminator
  # Check if the terminator config directory exists
  if [[ ! -d "$HOME"/.config/terminator ]]; then
    mkdir -p "$HOME"/.config/terminator
  fi

  # Copy the terminator config file to the terminator config directory
  cp -rf ../config/terminator/config "$HOME"/.config/terminator/config

  # Replace the terminator desktop file with the one from the repo
  sudo cp -rf ../config/terminator/terminator.desktop /usr/share/applications/

  # Fix permissions on the terminator desktop file
  sudo chown root:root /usr/share/applications/terminator.desktop &&
    sudo chmod 644 /usr/share/applications/terminator.desktop

  # Fix padding issues with terminator
  cp -rf ../config/gtk/gtk.css "$HOME"/.config/gtk-3.0/

  # Install Oh My Zsh
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # Install zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM"/plugins/zsh-autosuggestions

  # Install zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM"/plugins/zsh-syntax-highlighting

  # Install spaceship prompt
  git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM"/themes/spaceship-prompt --depth=1
  ln -s "$ZSH_CUSTOM"/themes/spaceship-prompt/spaceship.zsh-theme "$ZSH_CUSTOM"/themes/spaceship.zsh-theme

  # Copy the zshrc file to the home directory, replacing the original
  cp -rf ../config/zsh/.zshrc "$HOME"/.zshrc

  # Install Orchis Theme and Tela Circle Icons
  cd "$HOME"/Downloads || {
    echo "Error: Could not change to the '$HOME/Downloads/' directory."
    exit 1
  }
  git clone https://github.com/vinceliuice/Orchis-theme.git
  git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git

  cd Orchis-theme || {
    echo "Error: Could not change to the '$HOME/Downloads/Orchis-theme/' directory."
    exit 1
  }
  ./install.sh

  cd "$HOME"/Downloads/Tela-circle-icon-theme/ || {
    echo "Error: Could not change to the '$HOME/Downloads/' directory."
    exit 1
  }
  ./install.sh

  # Cleanup
  cd "$HOME"/Downloads || {
    echo "Error: Could not change to the '$HOME/Downloads/' directory."
    exit 1
  }
  rm -rf Orchis-theme
  rm -rf Tela-circle-icon-theme

  # Install Tela Circle Icons

  # Install dnf automatic updates
  if [[ $AUTOMATIC_UPDATES == true ]]; then
    sudo dnf check-update
    sudo dnf upgrade -y && sudo dnf install -y dnf-automatic
    systemctl enable --now dnf-automatic.timer
  fi

  # Change the default shell to zsh
  chsh -s "$(which zsh)"
fi
