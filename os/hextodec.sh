input_file="metadata.txt"
truncate --size 0 "dec_metadata.txt"
while IFS= read -r hex_value || [[ -n "$hex_value" ]]; do
    hex_value_upper=$(echo "$hex_value" | tr '[:lower:]' '[:upper:]')
    reversed_hex=$(echo "$hex_value_upper" | tac -rs .. | tr -d '\n')
    decimal_value=$(echo "ibase=16; $reversed_hex" | bc)
    echo "$decimal_value" >> dec_metadata.txt
done < "$input_file"
