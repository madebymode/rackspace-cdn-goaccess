#!/bin/bash

echo "Deleting previous CDN combined logs"
rm -rf parsed;
rm -rf parsed-combined

ls -ld */* | awk '{print $9}' | grep -v parsed | grep -v reports > allfiles.txt
ls -ld */ | awk '{print $9}' | grep -v parsed | grep -v reports > alldirs.txt


# Create location for combined file listing for CDN logs
mkdir parsed

# Create location for combined CDN or access logs
mkdir parsed-combined

#
mkdir reports

# Build a list of the CDN access logs
echo "Building list of Downloaded .CDN_ACCESS_LOG Files"
sleep 3
while read m; do
folder=$(echo "$m" | gsed 's/\/.*//g')
echo $folder
        echo "$m" | gxargs -i find ./{} -type f -name "*.log.gz" -print >> "parsed/$(echo "$folder" | cut -f 1 -d '.').log"
done < alldirs.txt

# Concatenate the files and use the xargs command to produce all of the log output, then cut processing and redirect to parsed-combined/$folder
echo "Combining .CDN_ACCESS_LOG files for bulk processing, stripping bad white-space, and converting into NCSA format"
sleep 3
while read m; do
echo $m

folder=$(echo "$m" | gsed 's@/@@g')
# clean logs that have extra whitespace/hidden tabs
cat "parsed/$folder.log" | gxargs -i gzcat {} | gsed -r 's/\s+/ /g' >> "parsed-combined/$folder.log"

done < alldirs.txt

# Process the log files by using GoAccess, generate HTML reports
echo "Generating GoAccess HTML log for CDN"
#sleep 3

for file in parsed-combined/*;
        do goaccess --log-format='%h %^ %^ %^[%d:%t %^] "%r" %s %b "%R" "%u"' --date-format="%d/%m/%Y" --time-format="%T" --ignore-status="000" -f "$(echo "$file")"  -a -o "reports/$( echo "$file" | gsed 's/\/.*//g').html"
done


