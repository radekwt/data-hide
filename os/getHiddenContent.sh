#GET METADATA
partition=$1
file_path=$2
file_size=$3
partition_offset=$(df "$partition" | awk 'NR==2 {print $6}')
file_path_partition_offset="$partition_offset/$file_path"
last_cluster_file="lastCluster.out"
partition_type=$(sudo blkid -s TYPE -o value "$partition")
if [ ! -f "$file_path_partition_offset" ] || [ ! -e "$partition" ]; then
    echo "FILE NOT FOUND"
    exit
fi 
if [ "$partition_type" = "ext4" ]; then
block_size=$(sudo tune2fs -l "$partition" | grep "Block size\|Filesystem block size" | awk '{print $3}')
./run.sh "$partition" "$file_path" "$last_cluster_file"
    if [[ -f "$last_cluster_file" ]]; then
        read -r last_cluster_index < "$last_cluster_file"
        echo "Last cluster: $last_cluster_index"
    else
        echo "File not found"
    fi 

sync && ./findHidden "$file_path_partition_offset" "$file_size" "$partition" "$((block_size/512))" "512" "$last_cluster_index"
exit
fi



#Bytes Per Sector	BPB_BytsPerSec	0x0B	16 Bits	Always 512 Bytes
sudo dd if="$partition" bs=1 skip=11 count=2 | xxd -p -c 2 > metadata.txt
#Sectors Per Cluster	BPB_SecPerClus	0x0D	8 Bits	1,2,4,8,16,32,64,128
sudo dd if="$partition" bs=1 skip=13 count=1 | xxd -p -c 1 >> metadata.txt #8 / 64
#Number of Reserved Sectors	BPB_RsvdSecCnt	0x0E	16 Bits	Usually 0x20
sudo dd if="$partition" bs=1 skip=14 count=2 | xxd -p -c 2 >> metadata.txt #32
#Number of FATs	BPB_NumFATs	0x10	8 Bits	Always 2
sudo dd if="$partition" bs=1 skip=16 count=1 | xxd -p -c 1 >> metadata.txt #2
#Sectors Per FAT	BPB_FATSz32	0x24	32 Bits	Depends on disk size
sudo dd if="$partition" bs=1 skip=36 count=4 | xxd -p -c 4 >> metadata.txt #8176 / 29344
#Root Directory First Cluster	BPB_RootClus	0x2C	32 Bits	Usually 0x00000002
sudo dd if="$partition" bs=1 skip=44 count=4 | xxd -p -c 4 >> metadata.txt #2

#CONVERT METADATA FROM HEX TO DECIMAL
input_file="metadata.txt"
truncate --size 0 "dec_metadata.txt"
while IFS= read -r hex_value || [[ -n "$hex_value" ]]; do
    hex_value_upper=$(echo "$hex_value" | tr '[:lower:]' '[:upper:]')
    reversed_hex=$(echo "$hex_value_upper" | tac -rs .. | tr -d '\n')
    decimal_value=$(echo "ibase=16; $reversed_hex" | bc)
    echo "$decimal_value" >> dec_metadata.txt
done < "$input_file"

#FIND ROOT DIRECTORY CLUSTER USING MATADATA
bytes_per_sector=$(sed -n '1p' "dec_metadata.txt")
sectors_per_cluster=$(sed -n '2p' "dec_metadata.txt")
number_of_reserved_sectors=$(sed -n '3p' "dec_metadata.txt")
number_of_fats=$(sed -n '4p' "dec_metadata.txt")
sectors_per_fat=$(sed -n '5p' "dec_metadata.txt")
root_clus=$(sed -n '6p' "dec_metadata.txt")

root_dir_sector=$((number_of_reserved_sectors + sectors_per_fat * number_of_fats))
root_dir_cluster=$((root_dir_sector / sectors_per_cluster))
echo "Root dir sector: $root_dir_sector"
echo "Number of bytes in sector: $bytes_per_sector"
echo "Root dir cluster: $root_dir_cluster"
echo "Number of bytes in cluster: $((bytes_per_sector * sectors_per_cluster))"
bytes_per_cluster=$((bytes_per_sector * sectors_per_cluster))
#Reserved sector size = (Number of Reserved Sectors) + #32
#FAT32 tables size = (Sectors Per FAT * Number of FATs) #8176 * 2
#Root dir = 32 + 8172 * 2 + ?8?
sudo dd if="$partition" bs=$bytes_per_cluster skip=$root_dir_cluster count=1 status=none | xxd -p -c "32" > dir.txt
sudo dd if="$partition" bs=$bytes_per_cluster skip=$root_dir_cluster  count=1 status=none | xxd -c "32" > dir.txt.readable

sync && ./getFileCluster.sh "$root_dir_cluster" "$bytes_per_cluster" "$file_path" "$partition"
./findLastCluster.sh "$root_dir_cluster" "$partition" "$root_clus" "$number_of_reserved_sectors" "$bytes_per_sector"

if [[ -f "$last_cluster_file" ]]; then
    read -r last_cluster_index < "$last_cluster_file"
    echo "Last cluster: $last_cluster_index"
else
    echo "File not found"
fi 

sync && ./findHidden "$file_path_partition_offset" "$file_size" "$partition" "$sectors_per_cluster" "$bytes_per_sector" "$last_cluster_index"