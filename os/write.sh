file_to_hide=$1
partition=$2
sector_size=$3
if_offset=$4
of_offset=$5
number_of_sectors=$6
sudo dd if=$file_to_hide of=$partition bs=$sector_size skip=$if_offset seek=$of_offset count=$number_of_sectors conv=notrunc
#sudo dd if=$partition bs=1 skip=$((sector_size*of_offset)) count=34  > out
