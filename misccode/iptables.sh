#!/bin/bash
#Simple Firewall Script.
# Adapted: Sat 28 Jun 2014 12:21:29 PM EDT (Bob Heckel -- http://ubuntuforums.org/showthread.php?t=1876124)



# Do this if 1st install!!!!!!!!!!!!!!!!!:
# sudo apt-get remove ufw gufw



# Check current IPV4 status:
# sudo iptables -L -n -v
# Save current state just in case:
# sudo iptables-save > $HOME/firewall.txt

# Stop running firewall:
# sudo iptables-save > $HOME/firewall.txt
# sudo iptables -X
# sudo iptables -t nat -F
# sudo iptables -t nat -X
# sudo iptables -t mangle -F
# sudo iptables -t mangle -X
# sudo iptables -P INPUT ACCEPT
# sudo iptables -P FORWARD ACCEPT
# sudo iptables -P OUTPUT ACCEPT


# DHCP Access - Ports 67 and 68 UDP
# Web Access - Ports 80 and 443 Protocol TCP
# Email Access - Ports 25 and 110 , 143 Protocol TCP
# DNS Access - Port 53 Protocol TCP and UDP (This is absolutely required)
# Bittorrent Access Through Transmission - Bittorrent is different in that it uses a mulitude of unregistered ports to make connections.

# sudo watch netstat -anlp

#Setting up default kernel tunings here (don't worry too much about these right now, they are acceptable defaults)
#DROP ICMP echo-requests sent to broadcast/multi-cast addresses.
sudo echo 1 >| /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

#DROP source routed packets
sudo echo 0 >| /proc/sys/net/ipv4/conf/all/accept_source_route

#Enable TCP SYN cookies
sudo echo 1 >| /proc/sys/net/ipv4/tcp_syncookies

#Do not ACCEPT ICMP redirect  30-Jun-14 overrides default
sudo echo 0 >| /proc/sys/net/ipv4/conf/all/accept_redirects

#Don't send ICMP redirect  30-Jun-14 overrides default
sudo echo 0 >| /proc/sys/net/ipv4/conf/all/send_redirects

#Enable source spoofing protection
sudo echo 1 >| /proc/sys/net/ipv4/conf/all/rp_filter

#Log impossible (martian) packets  30-Jun-14 overrides defaults
sudo echo 1 >| /proc/sys/net/ipv4/conf/all/log_martians

#Flush all existing chains
iptables --flush

#Allow traffic on loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT


#Creating default policies
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP #If we're not a router

#Allow previously established connections to continue uninterupted
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

#Allow outbound connections on the ports we previously decided.
iptables -A OUTPUT -p tcp --dport 25 -j ACCEPT #SMTP
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT #DNS
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT #HTTP
iptables -A OUTPUT -p tcp --dport 110 -j ACCEPT #POP
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT #HTTPS
iptables -A OUTPUT -p tcp --dport 51413 -j ACCEPT #BT
iptables -A OUTPUT -p tcp --dport 6969 -j ACCEPT #BT tracker
iptables -A OUTPUT -p UDP --dport 67:68 -j ACCEPT #DHCP
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT #DNS
iptables -A OUTPUT -p udp --dport 51413 -j ACCEPT #BT

#Set up logging for incoming traffic.
iptables -N LOGNDROP
iptables -A INPUT -j LOGNDROP
iptables -A LOGNDROP -j LOG
iptables -A LOGNDROP -j DROP

#Save our firewall rules
iptables-save > /etc/iptables.rules

# Restore rules after reboot:
# sudo nano /etc/network/interfaces
# Assuming wlan0 is the interface you use to connect to the network add the
# following at the end of the block. Alternatively you can add it to any
# interface you want and the rules will be loaded when that interface is
# brought up. Keep in mind this does not change the nature of the rules, or how
# they are applied.
# pre-up iptables-restore < /etc/iptables.rules

