if [ $# -ne 1 ]; then
 echo "Need to supply vm-name"
else
 HOST=$1
 read -p "Are you sure you want to delete $HOST (y/n)? " ans
 if [ $ans == 'y' ]; then
  sudo xl destroy $HOST
  rm /etc/xen/$HOST.cfg
  rm /vol5/ISOs/xenhosts/$HOST.img
  echo "Done!"
 fi
fi
