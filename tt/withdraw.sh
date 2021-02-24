#!/bin/sh
cd /root/tt/

config=$(cat config.json)
token=$( echo $config | jq '.token'  | sed 's/\"//g' )

text=$(curl -X POST -H "authorization:$token" -s http://tiantang.mogencloud.com/web/api/account/message/loading)
errCode=$(echo $text | jq '.errCode' )

if [ $errCode = 1003 ];then
	desp="甜糖token失效，请重新运行脚本部署一键领取程序更新token!"
else

	score=$( echo $text | jq '.data.score' )
	real_name=$( echo $text | jq '.data.zfbList[0].name' | sed 's/\"//g')
	card_id=$( echo $text | jq '.data.zfbList[0].account' | sed 's/\"//g')
	
	t_score=$( echo ${score}/100 |bc )
	if [ $t_score -gt 100 ];then
		t_score=9900
	else
		t_score=`expr $t_score \* 100`
	fi
	
	url_text="/api/v1/withdraw_logs?score="$t_score"&real_name="$real_name"&card_id="$card_id"&bank_name=支付宝&sub_bank_name=&type=zfb"
	
	ttext=$(curl -X POST -H "authorization:$token" -s http://tiantang.mogencloud.com/$url_text)
	
	errCode=$(echo $ttext | jq '.errCode' )
	msg=$(echo $ttext | jq '.msg' | sed 's/\"//g' | sed s/[[:space:]]//g)
	
	if [ $errCode = 0 ];then
		desp="甜糖自动提现:"$t_score"成功！，请留意到账情况！"
	else
		desp="甜糖自动提现失败，具体原因："$msg
	fi

fi
#通知 notice 1.sever酱  2.telegram
notice=$( echo $config | jq '.notice' | sed 's/\"//g' )
if [[ $notice = 1 ]];then
	sckey=$( echo $config | jq '.sckey'  | sed 's/\"//g' )
	curl -X POST -d "text=甜糖自动提现通知&desp=$desp" https://sc.ftqq.com/$sckey.send
elif [[ $notice = 2 ]];then
	chatId=$( echo $config | jq '.chatId'  | sed 's/\"//g')
	curl -X POST -d "{\"chatId\":\"$chatId\",\"text\":\"甜糖自动提现通知：\n$desp\"}" https://telegram.dachui.workers.dev
fi