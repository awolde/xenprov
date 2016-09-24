setHostName () {
   HOSTNAME=$2
   MAC=`sudo xl list -l $HOSTNAME | grep mac | cut -d'"' -f4`
   OS=$3
   echo "Setting name for $OS vm..."
   case $OS in
	"opensuse")
	   SUCCESS=1
	   until [ $SUCCESS -eq 0 ]; do
		   fping -q -c 1  -g 192.168.1.100 192.168.1.200 -r 1 > /dev/null 2>&1
		   IP=`arp | grep "$MAC" | cut -f1 -d' '`
	   	   ssh $IP -o "StrictHostKeyChecking no" "echo $HOSTNAME > /etc/HOSTNAME"
		   SUCCESS=$?
	   	   ssh $IP -o "StrictHostKeyChecking no" "rm /etc/ssh/ssh_host_* -f && systemctl restart sshd.service"
	   done
	;;
	"centos")
	   SUCCESS=1
	   until [ $SUCCESS -eq 0 ]; do
		   fping -q -c 1  -g 192.168.1.100 192.168.1.200 -r 1 > /dev/null 2>&1
		   IP=`arp | grep "$MAC" | cut -f1 -d' '`
	   	   ssh $IP -o "StrictHostKeyChecking no" "echo -e \"NETWORKING=yes\nHOSTNAME=$HOSTNAME\" > /etc/sysconfig/network"
		   SUCCESS=$?
	   	   ssh $IP -o "StrictHostKeyChecking no" "rm /etc/ssh/ssh_host_* -f && service sshd restart"
	   done
	
	;;
	"ubuntu")
	   SUCCESS=1
           until [ $SUCCESS -eq 0 ]; do
                   fping -q -c 1  -g 192.168.1.100 192.168.1.200 -r 1 > /dev/null 2>&1
                   IP=`arp | grep "$MAC" | cut -f1 -d' '`
                   ssh awolde@$IP -o "StrictHostKeyChecking no" "sudo sh -c \"echo $HOSTNAME > /etc/hostname\" "
                   SUCCESS=$?
                   ssh awolde@$IP -o "StrictHostKeyChecking no" "sudo rm /etc/ssh/ssh_host_* -f && sudo dpkg-reconfigure openssh-server"
                   ssh awolde@$IP -o "StrictHostKeyChecking no" "sudo sh -c \"sed -i 's/localhost/localhost $HOSTNAME/' /etc/hosts\" "
                   ssh awolde@$IP -o "StrictHostKeyChecking no" "sudo sh -c \"hostname $HOSTNAME\" "
                   ssh awolde@$IP -o "StrictHostKeyChecking no" "sudo sh -c \"sudo /etc/init.d/hostname.sh start\" "
                   scp -o "StrictHostKeyChecking no" rancher-setup.sh awolde@$IP:~ && ssh awolde@$IP -o "StrictHostKeyChecking no" "sudo sh -c \"./rancher-setup.sh\" "
           done
	;;
  esac
   #echo "Rebooting $HOSTNAME..."
#   sudo xl reboot $HOSTNAME
   echo -e "$HOSTNAME's IP is \e[1;34m$IP\e[0m if you wanna ssh"
   sed -i '$ d' ~/.ssh/known_hosts
  echo -e "Do \e[1;34mxl console $HOSTNAME \e[0mto login."
}
