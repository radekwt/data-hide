root_dir_cluster=$1
bytes_per_cluster=$2
file_path=$3
partition=$4
sync && IFS='/' read -ra words <<< "$file_path"

isFile=1

array_size=${#words[@]}
echo "$array_size"
for ((i=0; i < array_size; i++)); do
    if [ $i -eq $((array_size - 1)) ]; then
        isFile=2
    else
        isFile=1
    fi
    echo "${words[i]}"
    echo "$isFile"
    ./findfileindir.sh "$root_dir_cluster" "$bytes_per_cluster" "${words[i]}" "$isFile" "$partition"
done
