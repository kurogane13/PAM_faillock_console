#!/bin/bash

check_and_create_faillock_dir() {
  if [ ! -d /var/run/faillock ]; then
    sudo mkdir -p /var/run/faillock
    sudo chown root:root /var/run/faillock
    sudo chmod 700 /var/run/faillock
  fi
}

ssh_action() {
  echo
  read -p "Select an action for SSH daemon (start|stop|status|restart): " action
  case $action in
    start)
      echo
      systemctl start sshd
      echo
      menu
      ;;
    stop)
      echo
      systemctl stop sshd
      echo
      menu
      ;;
    status)
      echo
      systemctl status sshd
      echo
      menu
      ;;
    restart)
      echo
      systemctl restart sshd
      echo
      menu
      ;;
    *)
      echo
      echo "Error: Invalid action. Please enter 'start', 'stop', 'status', or 'restart'."
      ssh_action
      ;;
  esac
}

show_unlock_time() {
  echo
  echo "-----------------------------------------------------------------------------------------"
  echo "Current unlock time in config files: "
  echo
  echo "Showing unlock time in /etc/security/faillock.conf"
  echo
  cat /etc/security/faillock.conf | grep unlock_time
  echo
  echo "-----------------------------------------------------------------------------------------"
  echo "Showing unlock time in /etc/pam.d/system-auth: "
  echo
  cat /etc/pam.d/system-auth | grep unlock_time
  echo
  echo "-----------------------------------------------------------------------------------------"
  echo "Showing unlock time in /etc/pam.d/password-auth"
  echo
  cat /etc/pam.d/password-auth | grep unlock_time
  echo
  echo "-----------------------------------------------------------------------------------------"
  echo "Showing unlock time in /etc/pam.d/sshd"
  echo
  cat /etc/pam.d/sshd | grep unlock_time
  echo
  echo "----------------------------------------------------------------------------------"
  read -p "Press enter to proceed to main menu: " enter
  menu
}

show_deny_value() {
  echo
  echo "-----------------------------------------------------------------------------------------"
  echo "Current deny (attempt failures) value:"
  echo
  echo "Showing deny (attempt failures) value in /etc/security/faillock.conf"
  echo
  cat /etc/security/faillock.conf | grep deny
  echo
  echo "-----------------------------------------------------------------------------------------"
  echo "Showing deny value (attempt failures) in /etc/pam.d/system-auth"
  echo
  cat /etc/pam.d/system-auth | grep deny
  echo
  echo "-----------------------------------------------------------------------------------------"
  echo "Showing deny value (attempt failures) in /etc/pam.d/password-auth"
  echo
  cat /etc/pam.d/password-auth | grep deny
  echo
  echo "-----------------------------------------------------------------------------------------"
  echo "Showing deny value (attempt failures) in /etc/pam.d/sshd"
  echo
  cat /etc/pam.d/sshd | grep deny
  echo
  echo "----------------------------------------------------------------------------------"
  read -p "Press enter to proceed to main menu: " enter
  menu
}

show_even_deny_root_status() {
  echo
  if grep -q "^#even_deny_root" /etc/security/faillock.conf; then
    echo "even_deny_root is currently disabled."
  else
    echo "even_deny_root is currently enabled."
  fi
  echo
  echo "----------------------------------------------------------------------------------"
  read -p "Press enter to proceed to main menu: " enter
  menu
}

unlock() {
  local unlock_time
  while true; do
    echo
    read -p "Please enter the unlock_time value (in seconds): " unlock_time
    if [[ $unlock_time =~ ^[0-9]+$ ]]; then
      sed -i "s/unlock_time=[0-9]*/unlock_time=$unlock_time/" /etc/pam.d/system-auth
      sed -i "s/unlock_time=[0-9]*/unlock_time=$unlock_time/" /etc/pam.d/password-auth
      sed -i "s/unlock_time=[0-9]*/unlock_time=$unlock_time/" /etc/pam.d/sshd
      sed -i "s/unlock_time = [0-9]*/unlock_time = $unlock_time/" /etc/security/faillock.conf
      echo
      echo "Unlock time set to $unlock_time seconds."
      echo
      echo "----------------------------------------------------------------------------------"
      read -p "Press enter to get back to the main menu: " enter
      menu
    else
      echo
      echo "Error: Please enter an integer."
      echo
      read -p "Do you want to go back to the main menu? (yes/no) To retry type n, to go back to the main menu y: " choice
      case $choice in
        [Yy]*)
          menu
          ;;
        [Nn]*)
          unlock
          ;;
        *)
          echo
          echo "Invalid choice. Please enter 'yes' or 'no'."
          echo
          ;;
      esac
    fi
  done
}

deny() {
  local deny_value
  while true; do
    echo
    read -p "Please enter the amount of failed attempts (deny value): " deny_value
    if [[ $deny_value =~ ^[0-9]+$ ]]; then
      sed -i "s/deny=[0-9]*/deny=$deny_value/" /etc/pam.d/system-auth
      sed -i "s/deny=[0-9]*/deny=$deny_value/" /etc/pam.d/password-auth
      sed -i "s/deny=[0-9]*/deny=$deny_value/" /etc/pam.d/sshd
      sed -i "s/deny = [0-9]*/deny = $deny_value/" /etc/security/faillock.conf
      echo
      echo "Deny value set to $deny_value."
      echo
      echo "----------------------------------------------------------------------------------"
      read -p "Press enter to get back to the main menu: " enter
      menu
    else
      echo
      echo "Error: Please enter an integer."
      echo
      read -p "Do you want to go back to the main menu? (yes/no) To retry type n, to go back to the main menu y: " choice
      case $choice in
        [Yy]*)
          menu
          ;;
        [Nn]*)
          deny
          ;;
        *)
          echo
          echo "Invalid choice. Please enter 'yes' or 'no'."
          echo
          ;;
      esac
    fi
  done
}

allow_even_deny_root() {
  echo
  if grep -q "^#even_deny_root" /etc/security/faillock.conf; then
    sed -i 's/^#even_deny_root/even_deny_root/' /etc/security/faillock.conf
    echo "Enabled even_deny_root."
  else
    echo "even_deny_root is already enabled."
  fi
  echo
  echo "----------------------------------------------------------------------------------"
  read -p "Press enter to proceed to main menu: " enter
  menu
}

deny_even_deny_root() {
  echo
  if grep -q "^even_deny_root" /etc/security/faillock.conf; then
    sed -i 's/^even_deny_root/#even_deny_root/' /etc/security/faillock.conf
    echo "Disabled even_deny_root."
  else
    echo "even_deny_root is already disabled."
  fi
  echo
  echo "----------------------------------------------------------------------------------"
  read -p "Press enter to proceed to main menu: " enter
  menu
}

show_faillock_all_users() {
  echo
  echo "Showing faillock status for all users:"
  faillock
  echo
  echo "----------------------------------------------------------------------------------"
  read -p "Press enter to proceed to main menu: " enter
  menu
}

show_faillock_specific_user() {
  local user
  echo
  read -p "Enter the username to check faillock status: " user
  echo "Showing faillock status for user $user:"
  faillock --user "$user"
  echo
  echo "----------------------------------------------------------------------------------"
  read -p "Press enter to proceed to main menu: " enter
  menu
}

show_last_30_log_entries() {
  echo
  echo "Showing last 30 log entries from /var/log/auth.log containing 'sshd' and 'pam_faillock':"
  echo
  tail -n 30 /var/log/auth.log | grep -E 'sshd|pam_faillock'
  echo
  echo "----------------------------------------------------------------------------------"
  read -p "Press enter to proceed to main menu: " enter
  menu
}

count_failed_attempts() {
  local failed_attempts
  local successful_attempts
  local last_failed_timestamp
  local last_failed_ip
  local last_failed_user
  local last_successful_timestamp
  local last_successful_ip
  local last_successful_user
  local temp_log="/tmp/recent_auth_log.txt"

  # Extract the last 30 lines of /var/log/auth.log
  tail -n 30 /var/log/auth.log > "$temp_log"

  # Count of failed and successful attempts
  failed_attempts=$(grep "Failed password" "$temp_log" | wc -l)
  successful_attempts=$(grep "Accepted password" "$temp_log" | wc -l)

  # Extract details of the last failed attempt
  if [[ $failed_attempts -gt 0 ]]; then
    last_failed_entry=$(grep "Failed password" "$temp_log" | tail -n 1)
    last_failed_timestamp=$(echo "$last_failed_entry" | awk '{print $1, $2, $3}')
    last_failed_ip=$(echo "$last_failed_entry" | grep -oP 'from \K[^\s]*' || echo "N/A")
    last_failed_user=$(echo "$last_failed_entry" | grep -oP 'for \K[^\s]*' || echo "N/A")

    echo "-----------------------------------------------------------------------------------------"
    echo "There have been $failed_attempts failed login attempts."
    echo "Last failed attempt was on $last_failed_timestamp from IP address $last_failed_ip for user $last_failed_user."
  else
    echo "-----------------------------------------------------------------------------------------"
    echo "No failed login attempts found in the last 30 lines of /var/log/auth.log."
  fi

  # Extract details of the last successful attempt
  if [[ $successful_attempts -gt 0 ]]; then
    last_successful_entry=$(grep "Accepted password" "$temp_log" | tail -n 1)
    last_successful_timestamp=$(echo "$last_successful_entry" | awk '{print $1, $2, $3}')
    last_successful_ip=$(echo "$last_successful_entry" | grep -oP 'from \K[^\s]*' || echo "N/A")
    last_successful_user=$(echo "$last_successful_entry" | grep -oP 'for \K[^\s]*' || echo "N/A")

    echo "-----------------------------------------------------------------------------------------"
    echo "There have been $successful_attempts successful login attempts."
    echo "Last successful login was on $last_successful_timestamp from IP address $last_successful_ip for user $last_successful_user."
  else
    echo "-----------------------------------------------------------------------------------------"
    echo "No successful login attempts found in the last 30 lines of /var/log/auth.log."
  fi

  # Clean up
  rm "$temp_log"

  echo
  echo "-----------------------------------------------------------------------------------------"
  read -p "Press enter to proceed to main menu: " enter
  menu
}


menu() {
  clear
  echo "========================================="
  echo "      $(date +'%Y-%m-%d %H:%M:%S')       "
  echo
  echo " *** PAM FAILLOCK OPERATIONS CONSOLE *** "
  echo
  echo "========================================="
  echo
  echo "**** General Information ****"
  echo "1. Show faillock status for all users"
  echo "2. Show faillock status for a specific user"
  
  echo
  echo "**** Configuration Values ****"
  echo "3. Show unlock time value in config files"
  echo "4. Show deny value in config files (attempt failures)"
  
  echo
  echo "**** Set Configuration Values ****"
  echo "5. Set unlock_time (Time amount in seconds an account is locked. Ex: 120=2 minutes)"
  echo "6. Set deny value (amount of failed attempts)"
  
  echo
  echo "**** Even Deny Root ****"
  echo "7. Show even_deny_root status parameter (Show if root is included to be locked out or not)"
  echo "8. Enable even_deny_root"
  echo "9. Disable even_deny_root"
  
  echo
  echo "**** SSH Daemon ****"
  echo "10. SSH Daemon action"
  
  echo
  echo "**** Logging Information ****"
  echo "11. Show last 30 lines of /var/log/auth.log for sshd and pam_faillock"
  echo "12. Show the number of failed login attempts and their details"
  echo
  read -p "Please select an option: " choice
  case $choice in
    1)
      echo
      show_faillock_all_users
      ;;
    2)
      echo
      show_faillock_specific_user
      ;;
    3)
      echo
      show_unlock_time
      ;;
    4)
      echo
      show_deny_value
      ;;
    5)
      echo
      unlock
      ;;
    6)
      echo
      deny
      ;;
    7)
      echo
      show_even_deny_root_status
      ;;
    8)
      echo
      allow_even_deny_root
      ;;
    9)
      echo
      deny_even_deny_root
      ;;
    10)
      echo
      ssh_action
      ;;
    11)
      echo
      show_last_30_log_entries
      ;;
    12)
      echo
      count_failed_attempts
      ;;
    *)
      echo
      echo "Error: Invalid option. Please select a valid option."
      echo
      menu
      ;;
  esac
}

check_and_create_faillock_dir
menu
