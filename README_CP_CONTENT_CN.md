# USAGE: cp_conotent_type_from_oss_to_obs.py

1. 创建一台目的桶所在区ECS(4C8G以上)
2. 安装git: yum install -y git
3. 下载omscmd: git clone https://github.com/joejang/omscmd.git
4. 安装omscmd:
	cd omscmd/script
	./install_basic_tools.sh
5. 执行ContentType复制（30线程）：
	cd omscmd 
	nohup ./cp_content_type_from_oss_to_obs.py --ossak xxxxxxxxx --osssk xxxxxxxxx --osse oss-cn-beijing.aliyuncs.com --ossb oss_bucket_name --obsb obs_bucket_name --obs_path /destination_path/ --obsak xxxxxxxx --obssk xxxxxxxxx -t 30 > /tmp/cp_content_type_result &
	tail -f /tmp/cp_content_type_result
