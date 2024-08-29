input_file="dir.txt"
record_zeros="0000000000000000000000000000000000000000000000000000000000000000"
root_dir_cluster=$1
bytes_per_cluster=$2
search_file=$3
is_file=$4
partition=$5

search_file_upper=$(echo -n "$search_file" | tr '[:lower:]' '[:upper:]')
search_file_extension=$(awk -F '.' '{print $NF}' <<< "$search_file_upper")
search_file_name=$(sed 's/\(.*\)\..*/\1/' <<< "$search_file_upper")
echo "$search_file_extension"
echo "$search_file_name"

found_file=0

if [ "$is_file" = 1 ]; then
    search_file_extension=""
fi
while IFS= read -r record && [[ "$record" != "$record_zeros" ]]; do
    if [ "${record:22:1}" = "$is_file" ]; then
        file_name_num="${record:0:24}"
        file_name_ascii=$(echo -n "$file_name_num" | xxd -r -p | tr -d '\0' | tr '[:lower:]' '[:upper:]')
        file_extension="${file_name_ascii:8:${#search_file_extension}}"
        file_name_first="${file_name_ascii:0:${#search_file_name}}"
        if [ "$file_name_first" = "$search_file_name" ] && [ "$file_extension" = "$search_file_extension" ]; then
            found_file=1
            break
        fi
    fi
done < "$input_file"
if [ "$found_file" -eq 1 ]; then
    file_block_hex="${record:52:4}"
    echo "$file_block_hex"
    hex_value_upper=$(echo "$file_block_hex" | tr '[:lower:]' '[:upper:]')
    reversed_hex=$(echo "$hex_value_upper" | tac -rs .. | tr -d '\n')
    file_block_dec=$(echo "ibase=16; $reversed_hex" | bc)
    echo "$((file_block_dec - 2))"
    skip=$((root_dir_cluster + file_block_dec - 2))
    echo "skip: $skip"
    sudo echo "$skip" > cluster_output
    sudo dd if="$partition" bs=$bytes_per_cluster skip="$skip" count=1 status=none | xxd -p -c "32" > dir.txt
    sudo dd if="$partition" bs=$bytes_per_cluster skip="$skip" count=1 status=none | xxd -c "32" > dir.txt.readable
    sync && exit 
fi
echo "ERROR"
