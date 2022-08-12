#!/bin/bash
###########################################
#-------------) Functions (---------------#
###########################################
_DEBUG="on"
function DEBUG() {
  [ "$_DEBUG" == "on" ] && "$@"
}

###########################################
#---------------) Colors (----------------#
###########################################

C=$(printf '\033')
RED="${C}[1;31m"
SED_RED="${C}[1;31m&${C}[0m"
GREEN="${C}[1;32m"
SED_GREEN="${C}[1;32m&${C}[0m"
YELLOW="${C}[1;33m"
SED_YELLOW="${C}[1;33m&${C}[0m"
SED_RED_YELLOW="${C}[1;31;103m&${C}[0m"
BLUE="${C}[1;34m"
SED_BLUE="${C}[1;34m&${C}[0m"
ITALIC_BLUE="${C}[1;34m${C}[3m"
LIGHT_MAGENTA="${C}[1;95m"
SED_LIGHT_MAGENTA="${C}[1;95m&${C}[0m"
LIGHT_CYAN="${C}[1;96m"
SED_LIGHT_CYAN="${C}[1;96m&${C}[0m"
LG="${C}[1;37m" #LightGray
SED_LG="${C}[1;37m&${C}[0m"
DG="${C}[1;90m" #DarkGray
SED_DG="${C}[1;90m&${C}[0m"
NC="${C}[0m"
UNDERLINED="${C}[5m"
ITALIC="${C}[3m"

###########################################
#----------) Terminal Setup (-------------#
###########################################

# Paths passed to by main.sh
script_root_dir=$1
script_scripts_dir=$2
script_config_dir=$3

# Setup Automatic Updates for Fedora
auto_updates=true
projects_dir=true

# Oh My Zsh custom directory
zsh_custom="$HOME"/.oh-my-zsh/custom

# Update the system and install dependencies

sudo dnf check-update
sudo dnf upgrade -y &&
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
    gnome-extensions-app \
    ffmpeg-free \
    sassc \
    stacer

# Add RPM Fusion Repository
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm -y

# Install VS Code & Discord
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install -y discord \
  code

# Install fonts
if [ ! -d "$script_root_dir"/fonts/hack ]; then
  echo "Hack font not found. Exiting..."
  exit 1
fi
if [ ! -d "$script_root_dir"/fonts/jetbrains-mono ]; then
  echo "Hack font not found. Exiting..."
  exit 1
fi
sudo cp -rf "$script_root_dir"/fonts/hack/ /usr/share/fonts/
sudo cp -rf "$script_root_dir"/fonts/jetbrains-mono/ /usr/share/fonts/

# Install wallpaper
mkdir -p "$HOME"/Pictures/wallpapers
wallpaper_dir="$HOME"/Pictures/wallpapers
wallpaper_file="$wallpaper_dir"/wallpaper.jpg
cp -rf "$script_root_dir"/images/ "$wallpaper_dir"

gsettings set org.gnome.desktop.background picture-uri file:///"$wallpaper_file"
gsettings set org.gnome.desktop.background picture-uri-dark file:///"$wallpaper_file"

# Fix permissions on the font directory and the ttf files
sudo chown -R root:root /usr/share/fonts/hack
sudo chown -R root:root /usr/share/fonts/jetbrains-mono
sudo chmod 755 /usr/share/fonts/hack && sudo chmod 644 /usr/share/fonts/hack/*.ttf
sudo chmod 755 /usr/share/fonts/jetbrains-mono && sudo chmod 644 /usr/share/fonts/jetbrains-mono/*.ttf

# Refresh the font directory cache
sudo fc-cache -fv

# Install Docker
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager \
  --add-repo \
  https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker "$USER"
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
curl -LO "https://desktop.docker.com/linux/main/amd64/docker-desktop-4.11.1-x86_64.rpm?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64"
sudo dnf install -y ./docker-desktop-4.11.1-x86_64.rpm
# Kubernetes Install
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
sudo rpm -Uvh minikube-latest.x86_64.rpm

sudo rm -rf docker-desktop-4.11.1-x86_64.rpm
sudo rm -rf minikube-latest.x86_64.rpm

# Setup Terminator
# Check if the terminator config directory exists
if [[ ! -d "$HOME"/.config/terminator ]]; then
  mkdir -p "$HOME"/.config/terminator
fi

# Copy the terminator config file to the terminator config directory
DEBUG echo "Copying terminator config file $script_config_dir/terminator/config to $HOME/.config/terminator"
cp -rf "$script_config_dir"/terminator/config "$HOME"/.config/terminator/config

# Replace the terminator desktop file with the one from the repo
sudo cp -rf "$script_config_dir"/terminator/terminator.desktop /usr/share/applications/

# Fix permissions on the terminator desktop file
sudo chown root:root /usr/share/applications/terminator.desktop &&
  sudo chmod 644 /usr/share/applications/terminator.desktop

# Fix padding issues with terminator
cp -rf "$script_config_dir"/gtk/gtk.css "$HOME"/.config/gtk-3.0/

# Install Oh My Zsh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom"/plugins/zsh-autosuggestions

# Install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom"/plugins/zsh-syntax-highlighting

# Install spaceship prompt
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$zsh_custom"/themes/spaceship-prompt --depth=1
ln -s "$zsh_custom"/themes/spaceship-prompt/spaceship.zsh-theme "$zsh_custom"/themes/spaceship.zsh-theme

# Copy the zshrc file to the home directory, replacing the original
cp -rf "$script_config_dir"/zsh/.zshrc "$HOME"/.zshrc

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
rm -rf minikube-latest.x86_64.rpm

# Install dnf automatic updates
if [[ $auto_updates == true ]]; then
  echo -"Automatic Updates enabled."
  sudo dnf check-update
  sudo dnf upgrade -y && sudo dnf install -y dnf-automatic
  systemctl enable --now dnf-automatic.timer
fi

if [[ $projects_dir == true ]]; then
  echo -"Projects directory enabled."
  cd "$HOME" || {
    echo "Error: Could not change to the '$HOME/' directory."
    exit 1
  }
  mkdir -p Projects/VSCode Projects/JetBrains/IntelliJ Projects/JetBrains/PyCharm Project/JetBrains/CLion
fi

# Change the default shell to zsh
chsh -s "$(which zsh)"
