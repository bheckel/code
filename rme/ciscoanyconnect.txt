$ sudo Downloads/anyconnect-linux64-4.4.00243-core-vpn-webdeploy-k9.sh 
Installing Cisco AnyConnect Secure Mobility Client...
Extracting installation files to /tmp/vpn.aFlBGD/vpninst322302329.tgz...
Unarchiving installation files to /tmp/vpn.aFlBGD...
Starting Cisco AnyConnect Secure Mobility Client Agent...
Done!
0 bheckel@appa ~/ Sun Nov 05 07:31:48  
$ cd /opt/.cisco/certificates/
0 bheckel@appa certificates/ Sun Nov 05 07:31:58  
$ ls
ca
0 bheckel@appa certificates/ Sun Nov 05 07:32:01  
$ sudo mv ca ca.orig
0 bheckel@appa certificates/ Sun Nov 05 07:32:12  
$ sudo ln -sf /etc/ssl/certs/ ca
0 bheckel@appa certificates/ Sun Nov 05 07:32:31  
$ sudo /etc/init.d/vpnagentd restart
[ ok ] Restarting vpnagentd (via systemctl): vpnagentd.service.
0 bheckel@appa certificates/ Sun Nov 05 07:32:43  
$ /opt/cisco/anyconnect/bin/vpn

