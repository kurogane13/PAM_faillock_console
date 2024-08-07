# PAM_faillock_console

### Author: Gustavo Wydler Azuaga
### Release date: 05/23/2024
### V2 Release date: 08/06/2024

PAM_faillock console is a bash console to run faillock operations on linux systems.

#### Features and functionality:

 - The unlock_time value in config files (amount of seconds an account will be locked for)
 - The deny in config files (amount of fail attempts until lockdown)
 - Provides options to change these values in all files
 - Has an sshd daemon action. This enables the user to operate with the daemon without exiting the program.
 - New features:
   - General Information
     - Show faillock status for all users
     - Show faillock status for a specific user
   - Configuration Values
     - Show unlock time value in config files
     - Show deny value in config files (attempt failures)
   - Set Configuration Values
     - Set unlock_time (Time amount in seconds an account is locked. Ex: 120=2 minutes)
     - Set deny value (amount of failed attempts)
   - Even Deny Root
     - Show even_deny_root status parameter (Show if root is included to be locked out or not)
     - Enable even_deny_root
     -Disable even_deny_root
   - SSH Daemon
     - SSH Daemon action
   - Logging Information
     - Show last 30 lines of /var/log/auth.log for sshd and pam_faillock
     - Show the number of failed login attempts and their details

#### Setup and configuration of PAM files

- To ensure pam_faillock works, follow the below mentioned procedure:
  - Log in with root
  - Backup these 4 files:
```bash
    sudo cp /etc/pam.d/system-auth /etc/pam.d/system-auth.orig
    sudo cp /etc/pam.d/password-auth /etc/pam.d/password-auth.orig
    sudo cp /etc/pam.d/sshd /etc/pam.d/sshd.orig
    sudo cp /etc/security/faillock.conf /etc/security/faillock.conf.orig
```
  - Clone the repo
  - Place these 4 configuration files attached in this repo in /etc/pam.d/, and the faillock.conf file in /etc/security.
  - Once the files are in their respective repos, proceed to run the console:
    - For version 1:
    ```bash
      . pam_console.sh
    ```
    - For version 2:
    ```bash
      . pam_console2.sh
    ```
 
  

