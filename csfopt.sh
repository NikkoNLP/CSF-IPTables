#!/bin/bash

# Path Variable
PATH="/sbin:/bin:/usr/sbin:/usr/bin"

# Functions
funcReplace () {
   sed -i '/'"$1"'/c\'"$2"'' /etc/csf/csf.conf
}

funcGrep () {
   grep "$1" /etc/csf/csf.conf
}

# Overview Menu
clear
echo "If you run into any issues: try running this script with '"bash csfopt.sh"'"
echo "This will make a backup of the currnt csf.conf and proceed with the following optimizations:"
echo ""
echo "1. Set the csf deny limit to 1000 IPs [y/n]"
read ONE
echo "2. Set the csf temp deny limit to 1000 IPs [y/n]"
read TWO
echo "3. Prevent specific ports from being flooded [y/n]"
read THREE
echo "4. Set connection limits on ports [y/n]"
read FOUR
echo "5. Set hard connection limit to 500 connections [y/n]"
read FIVE
echo "6. Prevent Port Scanning [y/n]"
read SIX
echo "7. Disable Alert Emails? [y/n]"
read SEVEN
echo ""
echo "Proceed? [y/n]"
echo ""
read PROCEED

# Verification to proceed
if [ "$PROCEED" == y ] || [ "$PROCEED" == Y ]; then
   echo "Let the optimization begin..."
else
   exit 1   
fi

# Make a csf.conf backup
cp /etc/csf/csf.conf /etc/csf/csf.bak

### Make Changes ###
# 1. Set the csf deny limit to 1000 IPs
if [ "$ONE" == y ] || [ "$ONE" == Y ]; then
   funcReplace "DENY_IP_LIMIT = " 'DENY_IP_LIMIT = "1000"'
fi

# 2. Set the csf temp deny limit to 1000 IPs
if [ "$TWO" == y ] || [ "$TWO" == Y ]; then
funcReplace "DENY_TEMP_IP_LIMIT = " 'DENY_TEMP_IP_LIMIT = "1000"'
fi

# 3. Prevent specific ports from being flooded (Syntax for port flood temp blocking: port;tcp/udp;[Max Conns];[In X Seconds])
if [ "$THREE" == y ] || [ "$THREE" == Y ]; then
funcReplace "PORTFLOOD = " 'PORTFLOOD = "80;tcp;300;3,110;tcp;200;3,143;tcp;200;3,465;tcp;200;3,993;tcp;200;3,995;tcp;200;3,443;tcp;300;3"'
fi

# 4. Set connection limits on ports
if [ "$FOUR" == y ] || [ "$FOUR" == Y ]; then
funcReplace "CONNLIMIT = " 'CONNLIMIT = "21;200,25;200,80;700,110;200,143;200,443;700,465;200,587;200,993;200,995;200"'
fi

# 5. Set csf deny limit to 
if [ "$FIVE" == y ] || [ "$FIVE" == Y ]; then
funcReplace "CT_LIMIT = " 'CT_LIMIT = "500"'
fi

# 6. Prevent Port Scanning
if [ "$SIX" == y ] || [ "$SIX" == Y ]; then
  funcReplace "PS_INTERVAL = " 'PS_INTERVAL = "120"'
  funcReplace "PS_LIMIT = " 'PS_LIMIT = "10"'
fi

# 7. Disable Alert Emails?
if [ "$SEVEN" == y ] || [ "$SEVEN" == Y ]; then
  funcReplace "LF_EMAIL_ALERT =" 'LF_EMAIL_ALERT = "0"'
  funcReplace "LF_SSH_EMAIL_ALERT =" 'LF_SSH_EMAIL_ALERT = "0"'
  funcReplace "LF_SU_EMAIL_ALERT =" 'LF_SU_EMAIL_ALERT ="0"'
  funcReplace "LF_WEBMIN_EMAIL_ALERT =" 'LF_WEBMIN_EMAIL_ALERT ="0"'
  funcReplace "LF_CONSOLE_EMAIL_ALERT =" 'LF_CONSOLE_EMAIL_ALERT ="0"'
  funcReplace "LT_EMAIL_ALERT =" 'LT_EMAIL_ALERT ="0"'
  funcReplace "CT_EMAIL_ALERT =" 'CT_EMAIL_ALERT ="0"'
  funcReplace "PS_EMAIL_ALERT =" 'PS_EMAIL_ALERT ="0"'
fi

# Verify changes are correct
echo ""
echo "Complete, please confirm the settings (unchanged settings are still shown below):"
echo ""
funcGrep "DENY_IP_LIMIT = "
funcGrep "DENY_IP_LIMIT = "
funcGrep "PORTFLOOD = "
funcGrep "CONNLIMIT = "
funcGrep "CT_LIMIT = "
funcGrep "PS_INTERVAL = "
funcGrep "PS_LIMIT = "
funcGrep "LF_EMAIL_ALERT ="
funcGrep "LF_SSH_EMAIL_ALERT ="
funcGrep "LF_SU_EMAIL_ALERT ="
funcGrep "LF_WEBMIN_EMAIL_ALERT ="
funcGrep "LF_CONSOLE_EMAIL_ALERT ="
funcGrep "LT_EMAIL_ALERT ="
funcGrep "CT_EMAIL_ALERT ="
funcGrep "PS_EMAIL_ALERT ="
echo ""

# Restart CSF for changes
echo "Restart CSF to apply changes? [y/n]"
read RESTART

if [ "$RESTART" == y ]; then
   echo "Restarting CSF"
   csf -r
   echo ""
   echo "### CSF Optimization Complete ###"
   echo ""
elif [ "$RESTART" == Y ]; then
   echo "Restarting CSF"
   csf -r
   echo ""
   echo "### CSF Optimization Complete ###"
   echo ""
else
   echo "The changes were made in csf.conf, restart CSF to apply them"
   exit 1
fi

