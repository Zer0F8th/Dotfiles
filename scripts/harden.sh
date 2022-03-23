#!/bin/bash

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
#----------) System Hardening (-----------#
###########################################

DEBUG=true

hr() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

check_module_and_disable() {
  # Checks for the module
  if lsmod | grep -q "$1"; then
    MODULE_LOADED=true
  else
    MODULE_LOADED=false
  fi

  # Check if module is blacklisted
  if grep -E "^blacklist\s+$1" /etc/modprobe.d/*; then
    MODULE_BLACKLISTED=true
  else
    MODULE_BLACKLISTED=false
  fi

  if modprobe -n -v "$1" | grep -q "insmod"; then
    INSMOD=true
  else
    INSMOD=false
  fi

  if [[ $DEBUG == true ]]; then
    echo "${BLUE} $1 Module ${YELLOW}####################################################
|--------------------------------------------------------------------
| ${GREEN} $1 ${YELLOW} module loaded: ${GREEN}$MODULE_LOADED ${YELLOW}
| ${GREEN} $1 ${YELLOW} module blacklisted: ${GREEN}$MODULE_BLACKLISTED ${YELLOW}
| ${GREEN} $1 ${YELLOW} insmod: ${GREEN}$INSMOD ${YELLOW}
####################################################################${NC}
"
  fi

  # If module is loaded, then unload it
  if [[ "$MODULE_LOADED" == true ]]; then
    sudo modprobe -r "$1"
  fi

  # If module is loaded and not blacklisted, disable it

  if [[ "$MODULE_BLACKLISTED" == true && "$INSMOD" == true ]]; then
    echo "install $1 /bin/false
" | sudo tee -a /etc/modprobe.d/CIS.conf
  elif [[ "$MODULE_BLACKLISTED" == true && "$INSMOD" == false ]]; then
    echo "$1 module is already disabled"
  elif [[ "$MODULE_BLACKLISTED" == false && "$INSMOD" == true ]]; then
    echo "install $1 /bin/false
blacklist $1
" | sudo tee -a /etc/modprobe.d/CIS.conf
  else
    echo "blacklist $1
" | sudo tee -a /etc/modprobe.d/CIS.conf
  fi
}

# CIS Red Hat Enterprise Linux 8 Benchmark v2.0.0

###########################################
#--- 1.1.1 Disable unused filesystems ---#
###########################################
# 1.1.1.1 Ensure mounting of cramfs filesystems is disabled (Scored)

check_module_and_disable cramfs

hr

# 1.1.1.2 Ensure mounting of squashfs filesystems is disabled (Scored)
check_module_and_disable squashfs
