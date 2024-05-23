# PAM_faillock_console

### Author: Gustavo Wydler Azuaga
### Release date: 05/23/2024

PAM_faillock console is a bash console to view pam unlock time and failed attempts values, and setup/reconfigure these as needed.

#### Features and functionality:

 - The unlock_time value in config files (amount of seconds an account will be locked for)
 - The deny in config files (amount of fail attempts until lockdown)
 - Provides options to change these values in all files
 - Has an sshd daemon action. This enables the user to operate with the daemon without exiting the program.

#### Setup and configuration of PAM files

- To ensure pam_faillock works, follow the below mentioned procedure:
  - Log in with root
  - Backup these 4 files:
    - cp /etc/pam.d/system-auth /etc/pam.d/system-auth.orig
    - cp /etc/pam.d/password-auth /etc/pam.d/password-auth.orig
    - cp /etc/pam.d/sshd /etc/pam.d/sshd.orig
    - cp /etc/security/faillock.conf /etc/security/faillock.conf.orig
  - Clone the repo
  - Place these 4 configuration files attached in this repo in /etc/pam.d/, and the faillock.conf file in /etc/security.
  - Once the files are in their respective repos, proceed to run the console with: . pam_console.sh
 
  

