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
1. before using ,please udpate TMP_WORKSPACE file to your prefered workspace;
2. parameter specification:
    2.1 -s: src file path, for oss;
    2.2 -d: dst file path, for obs;
    2.3 -n: thread number, for speeding;
    2.4 -e: size comparsion enable, for "true" for enable
3. after execution, go to TMP_WORKSPACE/result_files for result'
    3.1 result_same_file.txt for same object;
    3.2 result_diff_file.txt for different object;
4. executiong demo: python oms_compare.py -s src_file -d dst_file -n 2 -e true

## Tools
### Quick Compare
1. ./quick_compare.py -s /data/testdata2  -o /data/test.txt --separate_time "2018-05-10 00:00:00" --section_size 100 -t 100
2. ./quick_compare.py -s /data/conv_oss/xxx -o /data/test.txt --separate_time "2018-05-02 00:26:00" --section_size 10000 -t 64 --ak=xxx --sk=xxx -b bucket-name
## Tips
1. /tmp/omscmd/ is the workspace by default.
2. shell scripts for starting tasks are contained in the workspace's subdirectories, these scripts can be executed independently to create task(s).

## Others
1. Usage of aws client: aws s3 --endpoint-url=http://xxx --region=xxx ls xxx --recursive
