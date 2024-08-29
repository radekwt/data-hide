#skip = number of reserved sectors * 512 / 4 + wartość w pliku(cluster n)
# bs = 4
cluster_n=$(head -n 1 "cluster_output")
root_dir_cluster=$1
partition=$2
root_clus=$3
number_of_reserved_sectors=$4
bytes_per_sector=$5
decimal_value=$((cluster_n - root_dir_cluster + root_clus))
while [ $decimal_value -ne 0 ] && [ $decimal_value -ne 268435455 ]; do
    prev="$decimal_value"
    skip=$(((number_of_reserved_sectors*bytes_per_sector/4)+decimal_value))
    cluster_n=$(sudo dd if="$partition" bs=4 skip="$skip" count=1 | xxd -p -c 4)
    hex_value_upper=$(echo "$cluster_n" | tr '[:lower:]' '[:upper:]')
    reversed_hex=$(echo "$hex_value_upper" | tac -rs .. | tr -d '\n')
    decimal_value=$(echo "ibase=16; $reversed_hex" | bc)
done
skip=$((prev+root_dir_cluster-2))
echo "$skip" > lastCluster.out