source functions.sh
STORE="/vol5/ISOs/ubuntu16"
VMSTORE="/vol5/ISOs/xenhosts"
NEWHOST=$1
CPU=$2
MEM=$3
OS=$4
MAC1=`cat /dev/urandom | tr -dc 'A-F0-9' | fold -w 2 | head -n 1`
MAC2=`cat /dev/urandom | tr -dc 'A-F0-9' | fold -w 2 | head -n 1`
MAC3=`cat /dev/urandom | tr -dc 'A-F0-9' | fold -w 2 | head -n 1`
MAC4=`cat /dev/urandom | tr -dc 'A-F0-9' | fold -w 2 | head -n 1`
#MAC4=`echo "$(($RANDOM % 100))"`
MAC="00:$MAC1:4e:$MAC2:$MAC3:$MAC4"
if [ $# -ne 4 ]; then
  echo "Usage: $0 vm_name No_of_Cpus Ram_size_in_MB ubuntu/centos/opensuse"
else
 echo -e "name = '$NEWHOST'\nmemory = $MEM\ndisk = [ 'file:$VMSTORE/$NEWHOST.img,xvda,w']\nvif = [ 'mac=$MAC, bridge=xenbr0', ]\nvcpus=$CPU\non_reboot   = 'restart'\non_crash = 'restart'" > /etc/xen/$NEWHOST.cfg
 if [ $OS == "ubuntu" ]; then
  echo -e "kernel='$STORE/vmlinuz-4.4.0-22-generic'\nramdisk='$STORE/initrd.img-4.4.0-22-generic'\nroot='/dev/xvda1'" >> /etc/xen/$NEWHOST.cfg
  echo "Copying image file...."
  cp --sparse=always -v $STORE/ubu16-bare.img $VMSTORE/$NEWHOST.img
 else
  if [ $OS == "centos" ]; then
    echo -e "kernel='/ds1/scratch/centos6/vmlinuz-1'\nramdisk='/ds1/scratch/centos6/initrd-1'\nroot='/dev/xvda2'" >> /etc/xen/$NEWHOST.cfg
    echo "Copying image file...."
    cp --sparse=always -v /store/centos-bare.img /store/$NEWHOST.img
  else
   echo -e "kernel='/ds1/scratch/opensuse/vmlinuz-3.11.10-21-xen'\nramdisk='/ds1/scratch/opensuse/initrd-3.11.10-21-xen'\nextra='console=xvc0' " >> /etc/xen/$NEWHOST.cfg
   echo "Copying image file...."
    cp --sparse=always -v /store/suse13-bare.img /store/$NEWHOST.img
  fi
 fi
 echo "Booting vm....."
 sudo xl create /etc/xen/$NEWHOST.cfg
 echo -e "$NEWHOST Created. Do \e[1;34mxl console $NEWHOST \e[0mto login."
 #### set the hostname ####
 echo "Waiting for vm to boot up to set hostname...."
 sleep 10
 setHostName $MAC $NEWHOST $OS
fi
