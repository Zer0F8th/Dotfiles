#!/bin/bash

###########################################
#----------) System Hardening (-----------#
###########################################

DEBUG=true

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
    INSMOD_LOAD=true
  else
    INSMOD_LOAD=false
  fi

  if [[ $DEBUG == true ]]; then
    echo "$1 Module ###################################"
    echo ""
    echo "$1 module loaded: $MODULE_LOADED"
    echo "$1 module blacklisted: $MODULE_BLACKLISTED"
    echo "$1 insmod load: $INSMOD_LOAD"
    echo ""
    echo "##################################################"
  fi

  # If module is loaded, unload the module
  if [[ "$MODULE_LOADED" == true ]]; then
    sudo modprobe -r "$1"
  fi

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
