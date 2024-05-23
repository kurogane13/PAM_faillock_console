
ssh_action() {
  echo
  read -p "Select an action for SSH daemon (start|stop|status|restart): " action
  case $action in
    start)
      systemctl start sshd
      echo
      menu
      ;;
    stop)
      systemctl stop sshd
      echo
      menu
      ;;
    status)
      systemctl status sshd
      echo
      menu
      ;;
    restart)
      systemctl restart sshd
      echo
      menu
      ;;
    *)
      echo
      echo "Error: Invalid action. Please enter 'start', 'stop', or 'reload'."
      ssh_action
      ;;
  esac
}

show_unlock_time() {
  echo "Current unlock time in config files: "
  echo
  echo "Showing unlock time in /etc/security/faillock.conf"
  echo
  cat  /etc/security/faillock.conf | grep unlock_time
  echo
  echo "Showing unlock time in /etc/pam.d/system-auth: "
  echo
  cat  /etc/pam.d/system-auth | grep unlock_time
  echo
  echo "Showing unlock time in /etc/pam.d/password-auth"
  echo
  cat /etc/pam.d/password-auth | grep unlock_time
  echo
  echo "Showing unlock time in /etc/pam.d/sshd_config"
  echo
  cat /etc/pam.d/sshd | grep unlock_time
  echo
  read -p "Press enter to proceed to main menu: " enter
  menu
}

show_deny_value() {
  echo "Current deny (attempt failures) value:"
  echo 
  echo "Showing deny (attempt failures) time in /etc/security/faillock.conf"
  echo
  cat  /etc/security/faillock.conf | grep deny
  echo
  echo "Showing deny value (attempt failures) in: /etc/pam.d/system-auth"
  echo
  cat /etc/pam.d/system-auth | grep deny
  echo
  echo "Showing deny value (attempt failures) in: /etc/pam.d/password-auth"
  echo
  cat /etc/pam.d/password-auth | grep deny
  echo
  echo "Showing deny value (attempt failures) in: /etc/pam.d/sshd"
  echo
  cat /etc/pam.d/sshd  | grep deny
  #grep -Eo 'deny=[0-9]+' /etc/pam.d/sshd
  echo
  read -p "Press enter to proceed to main menu: " enter
  menu
}

unlock() {
  local unlock_time
  while true; do
    read -p "Please enter the unlock_time value (in seconds): " unlock_time
    if [[ $unlock_time =~ ^[0-9]+$ ]]; then
      sed -i "s/unlock_time=[0-9]*/unlock_time=$unlock_time/" /etc/pam.d/system-auth
      sed -i "s/unlock_time=[0-9]*/unlock_time=$unlock_time/" /etc/pam.d/password-auth
      sed -i "s/unlock_time=[0-9]*/unlock_time=$unlock_time/" /etc/pam.d/sshd
      sed -i "s/unlock_time = [0-9]*/unlock_time = $unlock_time/" /etc/security/faillock.conf
      echo
      echo "Unlock time set to $unlock_time seconds."
      echo 
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
          echo
          unlock
          menu
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
    read -p "Please enter the amount of failed attempts (deny value): " deny_value
    if [[ $deny_value =~ ^[0-9]+$ ]]; then
      sed -i "s/deny=[0-9]*/deny=$deny_value/" /etc/pam.d/system-auth
      sed -i "s/deny=[0-9]*/deny=$deny_value/" /etc/pam.d/password-auth
      sed -i "s/deny=[0-9]*/deny=$deny_value/" /etc/pam.d/sshd
      sed -i "s/deny = [0-9]*/deny = $deny/" /etc/security/faillock.conf
      echo
      echo "Deny value set to $deny_value."
      read -p "Press enter to get back to the main menu: " enter
      menu
    else
      echo
      echo "Error: Please enter an integer. "
      echo
      read -p "Do you want to go back to the main menu? (yes/no). To retry type n, to go back to the main menu y: " choice
      case $choice in
        [Yy]*)
          menu
          ;;
        [Nn]*)
          echo
          deny
          menu
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

menu() {
  echo "#########################"
  echo
  echo "#  PAM faillock console #"
  echo
  echo "1. Show unlock time value in config files"
  echo "2. Show deny value in config files (attempt failures)"
  echo "3. Set unlock_time"
  echo "4. Set deny value (amount of failed attempts)"
  echo "5. SSH Daemon action"
  echo "6. Exit"
  echo
  read -p "Select an option: " option

  case $option in
    1)
      echo
      show_unlock_time
      ;;
    2)
      echo
      show_deny_value
      ;;
    3)echo
      unlock
      ;;
    4)echo
      deny
      ;;
    5)echo
      ssh_action
      ;;
    6)
      exit
      ;;
    *)
      echo
      read -p "Invalid option. Please provide a valid option form the menu. Press enter to continue" enter
      menu
      ;;
  esac
}

# Main loop
while true; do
  menu
done
