#!/bin/bash

inode_search_value=1000

###########################################################

	# Convert any of the strings found in the $size variable
convert_input_to_bytes(){
	read_size=$(echo $1 | awk '/[0-9]$/{print $1} /[gG]$/{printf "%u\n", $1*(1024*1024)} /[mM]$/{printf "%u\n", $1*(1024)} /[kK]$/{printf "%u\n", $1}')
}

###########################################################

	# This is the main command used for checking everything. 
disk_usage_check(){
	du -ax $1 --max-depth=1 --exclude={virtfs,"/proc","/dev"} | sort -rh | tail -n +2 | over_threshold_check
}

###########################################################

over_threshold_check(){
	while read line
	do
			# Split each of those lines into variables, first column ($res1) is size and represents the filesize in kbytes while the second column ($res2) represents the file path
        res1=$(echo $line | awk '{print $1}'); res2="$(echo $line | awk '{print $2}')"
        if [[ -d $res2 ]]; then
                res2="${res2}/"
        fi

        	# Set up an indent in regards to how much / are there, the more slashes are in place, the more the directory hierarchy gets indented.
        indent=$(echo "${res2}" | awk -F"/" '{print NF-1}')

        	# This is where the threshold check occurs - it checks if the filesize is greater than the threshold we have set.
        if [[ "$res1" -gt $read_size ]]
        then
        		# If the file that was checked if a _file_, indent it once more (due to the fact that a directory gets a trailing slash at the end to indicate it being a directory and due to that would have more indentation in comparison to files if this was not done)
            if [[ -f "$res2" ]]; then
                    indent="$((${indent}+1))"
            fi

            	# Prints out the indentaion based on the number of slashes then
            if [[ $indent -gt $start_indent ]]; then
                    printf '%0.s| ' $(seq $((start_indent+1)) $indent)
            fi

            	# Check if the file is a _file_ again - if true, prints out the rest of the file information
            if [[ -f "$res2" ]]; then
                    printf "%.2f GB %s\n" $(bc -l <<< "$res1 / ( 1024 * 1024 )") "$res2"
            fi

            	# Check if the file is a _directory_, in case it is, there needs to be a check to see if the this directory is above the threshold.
            if [[ -d "$res2" ]]; then

            		# If the file amount within a directory is too large, it cancels the check to prevent going into directories where there are hundreds of thousands of session files or emails. This is the variable to check for the directory inode usage.
            	inode_usage=$(find $res2 -maxdepth 1 | wc -l)

            		# If the inode usage of the directory is below threshold, it proceeds with the check 
            	if [[ "$inode_usage" -lt "$inode_search_value" ]]
            	then
            			# Prints out the information related to the directory found
            		printf "%.2f GB %s\n" $(bc -l <<< "$res1 / ( 1024 * 1024 )") "$res2"

            			# Since this is a recursive function, it proceeds with checking the directory below again and goes down like that until the threshold is reached and cannot check any further down.
                    disk_usage_check "$res2"
                
                	# In case the unode usage of the directory itself is above the threshold, it will only print out the disk usage but will not search within it to avoid bottlenecks from having to `du` too many files.
                else
                    printf "%.2f GB %s <- Directory has more than %s files in it, skipping it.\n" $(bc -l <<< "$res1 / ( 1024 * 1024 )") "$res2" "$inode_search_value"
                fi
            fi
        fi

        	# This is just to add another line aftear each "starter block", just for styling
        if [[ $indent -eq $start_indent ]] && [[ ! -f $res2 ]] && [[ "$res1" -gt $read_size ]]
        then
                echo
        fi

    done
}

###########################################################

	# Try finding a suitable location, if not, exit
printf "\nLocation: "
read location
if [[ ! -d "$location" ]] || [[ -z "$location" ]]; then
	printf "\nLocation does not exist, exiting.\n"
	exit
fi

	# Use the location as a pointer in regards to when to indent subsequent directories due to the fact that the indent is dependant on the number of "/" in the filename
start_indent=$(echo "${location}" | awk -F"/" '{print NF}')
if [[ "$location" != "/" ]]; then
	start_indent=$(($start_indent+1))
fi

###########################################################

	# Try and set up a size range, if nothing is found, defaulting to 1GB. (This needs to be set to see if the variable is an accetable number/size)
printf "Search size: "
read size
if [[ -z "$size" ]]; then
	printf "Defaulting to 1GB.\n"
	size="1g"
fi

###########################################################

convert_input_to_bytes $size; echo
disk_usage_check "$location"; echo
