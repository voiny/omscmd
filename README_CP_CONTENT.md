# Copy Content Type from OSS to OBS

## Installation
0. Install git: yum install -y git
1. Goto install path and clone repository: clone https://github.com/joejang/omscmd.git
2. Goto omscmd script path: cd omscmd/script
3. Install basic tools, oss sdk and obs sdk: ./install_basic_tools.sh

## Basic Usage
0. Goto omscmd path.
1. Execute:
```
	./cp_content_type_from_oss_to_obs.py --ossak xxxxxxxxx --osssk xxxxxxxxx --osse oss-cn-beijing.aliyuncs.com --ossb oss_bucket_name --obsb obs_bucket_name --obs_path /destination_path/ --obsak xxxxxxxx --obssk xxxxxxxxx -t 30
```

## Skills
0. Execute:

```
	nohup ./cp_content_type_from_oss_to_obs.py --ossak xxxxxxxxx --osssk xxxxxxxxx --osse oss-cn-beijing.aliyuncs.com --ossb oss_bucket_name --obsb obs_bucket_name --obs_path /destination_path/ --obsak xxxxxxxx --obssk xxxxxxxxx -t 30 > /tmp/cp_content_type_result &
	tail -f /tmp/cp_content_type_result

```
Errors will be output to /tmp/cp_content_type_result and command is executing at background.
