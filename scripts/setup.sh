#!/bin/bash

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

if [[ $OS == "Ubuntu" ]]; then
  # Update the system and install dependencies
  sudo apt-get update &&
    sudo apt-get upgrade -y &&
    sudo apt-get install -y \
      git \
      zsh \
      vim \
      zoom \
      terminator \
      build-essential \
      python-dev \
      python-pip \
      python-virtualenv \
      software-properties-common \
      apt-transport-https \
      wget

  curl -sSL https://install.python-poetry.org | python3 - &&
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add - &&
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" &&
    sudo apt-get update &&
    sudo apt-get install -y code
  # Install Oh My Zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

  # Install zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions

  # Install zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting

  # Install spaceship prompt
  git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1

  # Configure terminator

  # Make the terminator config directory only if it doesn't already exist
  mkdir -p "$HOME"/.config/terminator

  # Copy the terminator config file to the terminator config directory
  cp ../.config/terminator/config "$HOME"/.config/terminator/config

  # Replace the terminator desktop file with the one from the repo
  sudo cp -rf ../config/terminator/terminator.desktop /usr/share/applications/
fi

if [[ $OS == "Fedora Linux" ]]; then
  echo "Fedora Linux"
  echo "================================"
  # Update the system and install dependencies
  sudo dnf update &&
    sudo dnf upgrade -y &&
    sudo dnf install -y \
      git \
      zsh \
      vim \
      wget \
      terminator \
      python3-pip \
      python3-virtualenv

  # Install Discord
  sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  sudo dnf update
  sudo dnf install -y discord

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

  # Install Oh My Zsh
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # Install zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions

  # Install zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting

  # Install spaceship prompt
  git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1

  # Copy the zshrc file to the home directory, replacing the original
  cp -rf ../.zshrc "$HOME"/.zshrc

fi
