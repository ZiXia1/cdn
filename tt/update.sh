#!/bin/sh
cd /root/tt/
rm -rf msg.txt
config=$(cat config.json)
version1=$( echo $config | jq '.version'  | sed 's/\"//g')
version2=$(curl https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/config.json | jq '.version')
if [ $version1 != $version2 ];then
	#更新程序 
	#587888.sh 部署主程序
	#withdraw.sh 自动提现
	#promote.sh 自动收取
	
	rm -f withdraw.sh promote.sh 587888.sh update.sh
	wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/587888.sh
	wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/withdraw.sh
	wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/promote.sh
	wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/update.sh
	chmod -R 777 *
	config=$( echo $config | jq ".version=$version2" )
	echo $config > config.json
	wget -O /root/start.sh https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/start.sh
	#更新通知 notice 1.sever酱  2.telegram
	notice=$( echo $config | jq '.notice' | sed 's/\"//g' )
	update_log=$(curl https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/config.json | jq '.update_log' | sed 's/\"//g')
	if [[ $notice = 1 ]];then
		if [[ $update_log == *"\\n"* ]]; then
		OLD_IFS="$IFS"
		IFS="\\n" 
		arr=($update_log)
		IFS="$OLD_IFS"
		
		for s in "${arr[@]}"
		do
			if [ "$s" != "" ]; then
			echo $s >> msg.txt
			echo >> msg.txt
			echo >> msg.txt
			fi
		done
		
		echo "***" >> msg.txt
		echo "甜糖APP-我的-填写推荐码 587888 免费获取15张星愿加速卡！" >> msg.txt
		update_log=$(cat msg.txt)
		fi

		sckey=$( echo $config | jq '.sckey'  | sed 's/\"//g' )
		curl -X POST -d "text=甜糖脚本更新日志&desp=$update_log" https://sc.ftqq.com/$sckey.send
	elif [[ $notice = 2 ]];then
		chatId=$( echo $config | jq '.chatId'  | sed 's/\"//g')
		curl -X POST -d "{\"chatId\":\"$chatId\",\"text\":\"甜糖脚本更新日志：\n$update_log\"}" https://telegram.dachui.workers.dev
	fi
fi
