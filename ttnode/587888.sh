#!/bin/bash
token=$(cat /root/tt/token.txt)
rm -rf msg.txt

text=$(curl -X POST -H "authorization:$token" -s http://tiantang.mogencloud.com/web/api/account/message/loading)
#text=$(cat id.json)

errCode=$(echo $text | jq '.errCode' )
if [ $errCode = 1003 ];then
	desp="甜糖token失效，请重新运行脚本部署一键领取程序更新token!"
else
	promoteScore=$( echo $text | jq '.data.promoteScore' )
	inactivedPromoteScore=$( echo $text | jq '.data.inactivedPromoteScore' )
	score=$( echo $text | jq '.data.score' )
	add_up_score=$( echo $text | jq '.data.add_up_score' )
	
	devList=$( echo $text | jq '.data.devList' )
	lengthdevList=$( echo $text | jq '.data.devList|length' )
	
	echo "***" >> msg.txt
	echo "*账户总星愿："$score >> msg.txt
	echo >> msg.txt
	echo >> msg.txt
	echo "*累计星愿："$add_up_score >> msg.txt
	echo >> msg.txt
	echo >> msg.txt
	echo "*总推广星愿："$promoteScore >> msg.txt
	echo >> msg.txt
	echo >> msg.txt
	echo "*今日推广星愿："$inactivedPromoteScore >> msg.txt
	echo >> msg.txt
	echo >> msg.txt
	
	curl -X POST -H "authorization:$token" -s http://tiantang.mogencloud.com/api/v1/promote/score_logs?score=$inactivedPromoteScore
	curl -X POST -H "authorization:$token" -s http://tiantang.mogencloud.com/web/api/account/sign_in
	
	echo "***" >> msg.txt
	echo "设备星愿详情：" >> msg.txt
	echo >> msg.txt
	echo >> msg.txt
	for index in `seq 0 $lengthdevList`
	do
		devId=$( echo $devList | jq ".[$index].devId" | sed 's/\"//g' )
		if [ $devId != null ];then
			devSore=$( echo $devList | jq ".[$index].score" )
			curl -X POST -H "authorization:$token" -s http://tiantang.mogencloud.com/api/v1/score_logs?device_id=$devId\&score=$devSore
			echo $devId"星愿："$devSore >> msg.txt
			echo >> msg.txt
			echo >> msg.txt
		fi
		sleep 5s
	done
	
	echo "***" >> msg.txt
	echo "甜糖APP-我的-填写推荐码、填入推荐码 587888 免费获取15张星愿加速卡！" >> msg.txt
	desp=$(cat msg.txt)
fi
sckey=$(cat /root/tt/sckey.txt)
curl -X POST -d "text=甜糖日报&desp=$desp" https://sc.ftqq.com/$sckey.send