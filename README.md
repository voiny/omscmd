# omscmd

## Basic Usage
0. configure: vim ./conf.sh
1. install: ./init.sh
2. download list: ./download_list.sh
3. split list into sub lists: ./split_list.sh
4. convert lists into shell script to start tasks: ./lists2tasks.sh
5. start tasks: ./start_tasks.sh <START> <END>, START and END is optional
6. help information for monitoring tasks: ./task.sh 

## Convert Format
1. ./convert_lists_format (awscli/ossutil/customized1/...) (remove_string)
2. output - ${WORKSPACE}/converted_list

## Compare
1. [compare command] -s source_file -d destination_file -o output_difference (--compare-size/--compare-time)

## Tips
1. /tmp/omscmd/ is the workspace by default.
2. shell scripts for starting tasks are contained in the workspace's subdirectories, these scripts can be executed independently to create task(s).

## Others
1. aws s3 --endpoint-url=http://xxx --region=xxx ls xxx --recursive
