#sudo fls -f ext4 /dev/sdb1 > flsFile
#look for iNode
#matched_line=$(grep -w 'file' flsFile)
#iNodeString=$(echo "$matched_line" | awk '{print $2}')
#iNode=$(echo "$iNodeString" | sed 's/.$//')
#echo "$iNode"
#look for Size of a file
#matched_line=$(grep 'size' istatFile)
#size=$(echo "$matched_line" | awk '{print $2}')
#echo "$size"
#look for starting block/sector of a file
partition=$1
file_path=$2
parse_file=$3

partition_offset=$(df "$partition" | awk 'NR==2 {print $6}')
file_path_partition_offset="$partition_offset/$file_path"
echo "$file_path_partition_offset"
node_number=$(stat -c '%i' "$file_path_partition_offset")
echo "$node_number"
sudo istat $partition $node_number > $parse_file
startingBlock=$(tail -n 1 "$parse_file" | awk '{print $NF}')
echo "$startingBlock" > $parse_file