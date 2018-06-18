#!/bin/bash
# Search for email addresses in file, extract, turn into csv with designated file name
INPUT=${1}
OUTPUT=${2}
{
if [ ! $1 -o ! $2 ]; then
    echo "Input file not found, or output file not specified. Exiting script."
    exit 0
fi
}
grep --only-matching -E '[.[:alnum:]]+@[.[:alnum:]]+' $INPUT > $OUTPUT
sed -i 's/$/,/g' $OUTPUT
sort -u $OUTPUT -o $OUTPUT
sed -i '{:q;N;s/\n/ /g;t q}' $OUTPUT
echo "Data file extracted to" $OUTPUT
read -t5 -n1 -r -p "Press any key to see the list, sorted and with unique record"
if [ $? -eq 0 ]; then
    echo A key was pressed
    else
    echo No key was pressed
    exit
fi
less $OUTPUT | \
# Output file piped through sort and uniq
sort | uniq 
exit

