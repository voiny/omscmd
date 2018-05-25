# omscmd

## Installation
0. configure: vim ./conf.sh
1. install: ./init.sh
2. install ossutil/awscli
3. configure ossutil and awscli, check if 'ls' command can be executed successfully.

## Basic Usage
1. download list: ./download_list.sh
2. split list into sub lists: ./split_list.sh
3. convert lists into shell script to start tasks: ./lists2tasks.sh
4. start tasks: ./start_tasks.sh <START> <END>, START and END is optional
5. help information for monitoring tasks: ./task.sh 

## Download Object List
1. [OSS] ossutil ls oss://bucket-name > original_object_list_file
2. or [S3 compatible storage systems] aws s3aws --endpoint-url=http://[endpoint-url] s3 ls --recursive > original_object_list_file
  
## Convert Format (OSF)
Convert ossutil/awscli/others output format to omscmd standard format. In following steps, all omscmd related operations are based on omscmd standard format(OSF).
1. cd script && ./convert_list_format.sh [original_object_list_file] (awscli/ossutil/customized1/customized2...) (remove_string), for ossutil, remove_string is oss://, for awscli/customized1/customized2 leave empty
2. output location is: ${WORKSPACE}/converted_list (OSF file)

## Migrate Using OMS
Using OSF-based object list file as input, call OMS API to create tasks in OMS.
0. Get TOKEN by invoking IAM API and configure TOKEN in conf.sh
1. copy OSF file into ${WORKSPACE}/list
2. ./split_list.sh
3. plit list into sub lists: ./split_list.sh
3. convert lists into shell script to start tasks: ./lists2tasks.sh
4. start tasks: ./start_tasks.sh <START> <END>, START and END is optional
5. help information for monitoring tasks: ./task.sh 

## Migrate Using omscmd
omscmd-based migration is based on migrating ability of third-party tools such as osstil and awscli.
1. convert OSF-based object list file into purified object list file (containing only key of objects): cd script && ./convert_list_fomrat.sh [OSF file] customized2, outputs  purified object list file
2. configure conf.sh to setup source and destination bucket information
3. migrate: cd script && ./migrate_list.sh [purified object list file]

## Complete Comparison
1. download object list from both source and destination object storage systems. (refer to section: Doanload Object List)
2. convert output from step1 into OSF. (refer to section: Convert Format (OSF))
3. ./oms_compare.py -s src_osf -d dst_osf -n 1 -e
    2.1 -s: source file path
    2.2 -d: destination file path
    2.3 -n: thread number, currently 1 thread is the fastest
    2.4 -e: size comparsion enable, for "true" for enable
3. after execution, go to TMP_WORKSPACE/result_files for result
    3.1 result_same_file.txt for same object;
    3.2 result_diff_file.txt for different object;

## Direct Compare
Compare given list with destination storage using GetObjectMetadata method.
1. ./direct_compare_obs.py -s osf_file -o output.txt -t thread_num --ak=xxx --sk=xxx -b bucket-name

## Download Increment Object Lists
0. Setup SDKs (oss2, obs, ...)
1. ./download_increment_xxx.py -s /data/testdata2  -o /data/test.txt --separate_time "2018-05-10 00:00:00" --section_size 100 -t 100
2. ./download_increment_xxx.py -s /data/conv_oss/xxx -o /data/test.txt --separate_time "2018-05-02 00:26:00" --section_size 10000 -t 64 --ak=xxx --sk=xxx -b bucket-name

## Tips
1. /tmp/omscmd/ is the workspace by default.
2. shell scripts for starting tasks are contained in the workspace's subdirectories, these scripts can be executed independently to create task(s).

## Others
1. Usage of aws client: aws s3 --endpoint-url=http://xxx --region=xxx ls xxx --recursive
