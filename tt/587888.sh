#!/bin/sh
clear
function menu ()
{
	config=$(cat /root/tt/config.json)
	zt1=$( echo $config | jq '.ttversion' | sed 's/\"//g' )
	zt3=$( echo $config | jq '.promote' | sed 's/\"//g' )
	zt4=$( echo $config | jq '.withdraw' | sed 's/\"//g')
	zt5=$( echo $config | jq '.notice' | sed 's/\"//g' )

	if [[ $zt1 = 32 ]]; then
		zt11="----已安装！"
	elif [[ $zt1 = 64 ]]; then
		zt22="----已安装！"
	fi

	if [[ $zt3 = 1 ]]; then
		zt33="----已安装！"
	fi
	if [[ $zt4 = 1 ]]; then
		zt44="----已安装！"
	fi
	if [[ $zt5 = 1 ]]; then
		zt55="----Sever酱！"
	elif [[ $zt5 = 2 ]]; then
		zt55="----Telegram！"
	fi
    cat << EOF                                             
********************主菜单*********************
==============================================
    填写邀请码：587888  免费获取15张加成卡！
==============================================
玩客云刷armbian视频教程：https://www.bilibili.com/video/BV1Va411A7MJ

`echo -e "\033[35m 1)32位设备安装（玩客云）\033[0m$zt11"`
`echo -e "\033[35m 2)64位设备安装（斐讯N1）\033[0m$zt22"`
`echo -e "\033[35m 3)MAC地址&绑定码\033[0m"`
`echo -e "\033[35m 4)卸载甜糖\033[0m"`
`echo -e "\033[35m 5)星愿自动领取\033[0m$zt33"`
`echo -e "\033[35m 6)星愿自动提现\033[0m$zt44"`
`echo -e "\033[35m 7)通知选项\033[0m$zt55"`
`echo -e "\033[35m 8)需求&BUG提交\033[0m"`
`echo -e "\033[35m 9)重启设备\033[0m"`
`echo -e "\033[35m 0)退出\033[0m"`
EOF

read -p "请确认操作：" num
case $num in
	1)
		install 32
      ;;
	2)
		install 64
      ;;
	3)
		ttnote_menu
	;;
	4)
		uninstall
	;;
	5)
		login
	;;
	6)
		withdraw
	;;
	7)
	#通知
		notice_menu
	;;
	8)
	#bug反馈
		advice
	;;
	9)
		reboot
	;;
	0)
		exit 0
	;;
	*)
	echo "输入错误，请重新输入！"
	sleep 5s
	clear
	menu
esac
}
function advice (){
	#BUG反馈
 	read -p "
仅限汉字、字母、数字、简单符号提交
写错了不能删除，重新提交一次吧~
shell限制没办法。。。
	 
请提交需求/BUG：" bug
	if [[ ${#bug} -gt 9 ]];then 
	curl -X POST -d "{\"chatId\":\"616276247\",\"text\":\"用户反馈：$bug\"}" https://telegram.dachui.workers.dev
	echo "感谢反馈，如果本脚本对你有帮助，请填写我的互助码 587888 ，感谢！"
	else
	echo "你的反馈不足10字，请重新输入"
	fi
sleep 5s
menu
}
function config (){
	#写配置
	Notation='"'$2'"'
	config=$(cat /root/tt/config.json)
	config=$( echo $config | jq ".$1=$Notation" )
	echo $config > config.json
}

function withdraw()
{
	read -p "
每周三自动提现星愿到绑定的支付宝账号！提现到银行卡有需要可以提交需求

开发不易，新来的朋友填我的推荐码 587888 支持一下，感谢！
	
取消请按Crtl+C，继续请按回车..."
	#自动提现
	cd /root/tt/
	wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/withdraw.sh
	chmod -R 777 *
	sed -i '16a 30 8 * * 3	root	/root/tt/withdraw.sh' /etc/crontab
	config withdraw 1
	read -p  "
部署成功，每周三8点30分准时提现星愿！

如需server酱或telegram通知，请按回车继续..."
notice_menu
}

function login()
{
#自动收取
	read -p "
本功能全自动领取星愿！如果token失效也可以重新获取token

开发不易，新来的朋友填我的推荐码 587888 支持一下，感谢！

取消请按Crtl+C，继续请按回车..."
cd /root/tt/
read -p "请输入手机号码：" tel
if [[ ${#tel} = 11 ]];then
	codeText=$(curl -X POST http://tiantang.mogencloud.com/web/api/login/code?phone=$tel|jq '.errCode')
	if [[ $codeText = 0 ]];then
		read -p "验证码发送成功，请输入：" code
		if [[ ${#code} = 6 ]];then
			tokenText=$(curl -X POST http://tiantang.mogencloud.com/web/api/login?phone=$tel\&authCode=$code|jq '.data.token' | sed 's/\"//g')
			if [[ $tokenText = null ]];then
				echo "登录失败，请重试！"
			else
				config token $tokenText
				#写监控脚本
				wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/promote.sh
				chmod -R 777 *
				sed -i '16a 30 4 * * *	root	/root/tt/promote.sh' /etc/crontab
				config promote 1
				read -p "
部署成功，每天凌晨4点30分准时收取星愿！

如需server酱或telegram通知，请按回车继续..." 
				notice_menu
			fi
		else
			echo "验证码输入错误！"
			sleep 5s
			menu
		fi
	else
	echo "发送验证码失败，请重试！"
	sleep 5s
	menu
	fi
else
	echo "手机号码输入错误！"
	sleep 5s
	menu
fi
}

function uninstall()
{
	read -p "
即将卸载所有服务，包括甜糖、自动收取、自动提现，此操作不可逆！

取消请按Crtl+C，继续请按回车..." 
	pkill -f ttnode
	rm -rf /etc/rc.local /etc/crontab /etc/network/interfaces /usr/node
	myPath="/root/tt/backup/"
	cp -pdr "$myPath"rc.local.default /etc/rc.local
	cp -pdr "$myPath"crontab.default /etc/crontab
	cp -pdr "$myPath"interfaces.default /etc/network/interfaces
	rm -rf /root/tt/
	echo "
卸载甜糖成功！重启生效！

10秒后自动重启系统..."
	sleep 10s
	reboot
}

function changeMac()
{
	if [ ! -d /root/tt/backup/ ]; then
	echo "甜糖未安装，请安装后修改Mac地址、、、"
	else
	rm -rf /etc/network/interfaces
	cp -pdr /root/tt/backup/interfaces.default /etc/network/interfaces
	mac=00:60:2F$(dd bs=1 count=3 if=/dev/random 2>/dev/null |hexdump -v -e '/1 ":%02X"')
	sed -i "6a hwaddress $mac" /etc/network/interfaces
	echo "
修改Mac成功，重启生效。
新Mac是：$mac 请重启后重新绑定设备！

10秒后自动重启系统..."
	sleep 10s
	reboot
	fi
}

function backup()
{
	myPath="/root/tt/backup/"
	
	if [ ! -d "$myPath" ]; then
	mkdir "$myPath"
	cp -pdr /etc/rc.local "$myPath"rc.local.default
	cp -pdr /etc/crontab "$myPath"crontab.default
	cp -pdr /etc/network/interfaces "$myPath"interfaces.default

	else
	echo "备份文件已存在，跳过备份步骤。"
	fi
}


function install()
{
	config=$(cat /root/tt/config.json)
	zt1=$( echo $config | jq '.ttversion' | sed 's/\"//g' )
	if [[ $zt1 = 32 || $zt1 = 64 ]]; then
	echo "甜糖已安装，如需重新安装，请使用本程序卸载后运行脚本： wget -O start.sh https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/start.sh && sh start.sh  重新安装！"
	else

	read -p "
欢迎使用$1位armbian甜糖CDN自动部署程序
		                                       
==============================================
    填写邀请码：587888  免费获取15张加成卡！
==============================================
		
请输入邀请码 tt 开始自动部署：" number
		 
		if [[ $number = tt ]];then
			echo "输入正确，开始部署！"         
			backup
			rm -rf /mnts
			fdisk -l
			read -p "
tips：建议看容量挂载，或者填入【 LABEL="tt" 】并把磁盘名改为【 tt 】
请填入要挂载的分区，例如/dev/sda1:" fenqu
			mount $fenqu /mnt/
		
			rm -rf /usr/node
			mkdir /usr/node
			cd /usr/node/
			
			wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/ttnode$1 -O ttnode
			wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/crash_monitor.sh
			wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/log.log
			chmod -R 777 *
			
			sed -i "12a mount $fenqu /mnt/\nservice sshd start\n/usr/node/ttnode -p /mnt" /etc/rc.local
			
			mac=00:60:2F$(dd bs=1 count=3 if=/dev/random 2>/dev/null |hexdump -v -e '/1 ":%02X"')
			
			sed -i "6a hwaddress $mac" /etc/network/interfaces
			
			sed -i '14a */1 * * * *	root	/usr/node/crash_monitor.sh' /etc/crontab
			
			cd  /root/tt/
			wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/update.sh
			chmod -R 777 *
			sed -i '15a 30 6 * * *	root	/root/tt/update.sh' /etc/crontab
			
			config ttversion $1

echo -e "
---------------------------------\033[35m部署成功，请重启设备绑定APP\033[0m------------------------------------
\033[35mtips:\033[0m
1.二次进入菜单直接运行部署命令，或者 sh /root/587888/587888.sh
2.如果APP无法发现设备，请运行主菜单 按 3 扫码绑定。
3.如果扫码提示设备已绑定，请运行主菜单，按 3 更换MAC地址 重启设备重新绑定。
4.有BUG/需求反馈请运行主菜单 按 8 反馈。

\033[1;33;41m此脚本由「折了个腾」原创发布，开发不易，新来的朋友填我的推荐码 587888 支持一下，感谢！\033[0m
------------------------------------------------------------------------------------------------
20秒后自动重启设备，取消自动重启请按Ctrl+C"
	sleep 20s
	reboot
		else
			echo "输入有误！我的邀请码是：tt"
			sleep 5s
			menu
		fi
	fi 

}

function notice_menu ()
{
clear
config=$(cat /root/tt/config.json)
notice=$( echo $config | jq '.notice'  | sed 's/\"//g')
if [[ $notice = 1 ]]; then
	sckey=$( echo $config | jq '.sckey' )
	svj="----已启用！----"$sckey
elif [[ $notice = 2 ]]; then
	chatId=$( echo $config | jq '.chatId' )
	tg="----已启用！----"$chatId
fi

 cat << EOF
----------------------------------------
|***************通知菜单****************|
----------------------------------------
`echo -e "\033[35m 1)Sever酱通知\033[0m$svj"`
`echo -e "\033[35m 2)Telegram通知\033[0m$tg"`
`echo -e "\033[35m 3)禁用通知\033[0m"`
`echo -e "\033[35m 4)返回主菜单\033[0m"`
EOF
read -p "请确认操作：" num2
case $num2 in
 1)
  read -p "
Sever酱Sckey获取页面http://sc.ftqq.com/?c=code
  
请输入Sever酱Sckey：" sckey
	if [[ ${#sckey} -gt 30 ]];then 
	  config sckey $sckey
	  config sckey $sckey
	  config notice 1
echo "sever酱通知启用成功，Sckey是：$sckey
5秒后返回通知菜单..."
	else
echo "输入的Sckey：$sckey 似乎有误，请检查...
5秒后返回通知菜单..."
	fi
  sleep 5s
  notice_menu
  ;;
 2)
  read -p "
用户ID获取请发送任意内容到 @ZLGT_bot 获取...
  
请输入Telegram用户ID：" chatId
  config chatId "$chatId"
  config notice 2
  echo "Telegram通知启用成功，用户ID是：$chatId
5秒后返回通知菜单..."
  sleep 5s
  notice_menu
  ;;
 3)
  config notice 0
  echo "通知禁用成功！
5秒后返回通知菜单..."
  sleep 5s
  notice_menu
  ;;
 4)
  clear
  menu
  ;;
 *)
  echo "输入错误，请重新输入！"
	clear
  notice_menu
esac
}

function ttnote_menu ()
{
 cat << EOF
----------------------------------------
|************MAC地址&绑定码*************|
----------------------------------------
`echo -e "\033[35m 1)修改Mac地址\033[0m$svj"`
`echo -e "\033[35m 2)获取APP绑定码\033[0m$tg"`
`echo -e "\033[35m 3)重启设备\033[0m"`
`echo -e "\033[35m 4)返回主菜单\033[0m"`
EOF
read -p "请确认操作：" num2
case $num2 in
 1)
	changeMac
  ;;
 2)
	/usr/node/ttnode -p /mnt
	/usr/node/ttnode -p /mnt > 1.txt
	while read -r line
	do
	if [[ $line = "uid"* ]]; then
		uid=$(echo $line | sed 's/uid = //g') 
	fi
	done < 1.txt
	rm -rf 1.txt
	clear
	echo -e "
\033[35mtips:\033[0m
1.请打开网页 https://cli.im/api/qrcode/code?text=$uid 扫码绑定。
2.如果扫码提示设备已绑定请运行主菜单，按 3 更换MAC地址 重启设备重新绑定。
3.有BUG/需求反馈请运行主菜单 按 8 反馈。
4.二次进入菜单直接运行部署命令，或者 sh /root/tt/587888.sh
"
  ;;
 3)
	reboot
  ;;
 4)
  clear
  menu
  ;;
 *)
  echo "输入错误，请重新输入！"
	clear
  notice_menu
esac
}

menu