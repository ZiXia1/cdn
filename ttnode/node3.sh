#!/bin/sh
rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
clear
function menu ()
{
	if [ -d /root/tt/1/ ]; then
		zt1="----已安装！"
	fi
	if [ -d /root/tt/2/ ]; then
		zt2="----已安装！"
	fi
	if [ -d /root/tt/3/ ]; then
		zt3="----已安装！"
	fi
	if [ -d /root/tt/4/ ]; then
		zt4="----已安装！"
	fi
    cat << EOF

#######  #####  #######  #####   #####   #####  
#       #     # #    #  #     # #     # #     # 
#       #     #     #   #     # #     # #     # 
######   #####     #     #####   #####   #####  
      # #     #   #     #     # #     # #     # 
#     # #     #   #     #     # #     # #     # 
 #####   #####    #      #####   #####   #####                                                

==============================================
    填写邀请码：587888  免费获取15张加成卡！
==============================================
玩客云刷armbian视频教程：https://www.bilibili.com/video/BV1Va411A7MJ

`echo -e "\033[35m 1)32位设备安装（玩客云）\033[0m$zt1"`
`echo -e "\033[35m 2)64位设备安装（斐讯N1）\033[0m$zt2"`
`echo -e "\033[35m 3)更换Mac地址\033[0m"`
`echo -e "\033[35m 4)卸载甜糖\033[0m"`
`echo -e "\033[35m 5)星愿自动领取\033[0m$zt3"`
`echo -e "\033[35m 6)星愿自动提现\033[0m$zt4"`
`echo -e "\033[35m 7)重启设备\033[0m"`
`echo -e "\033[35m 8)退出\033[0m"`
EOF

read -p "请确认操作：" num
case $num in
    1)
		install32
      ;;
    2)
		install64
      ;;
    3)
		changeMac
	;;
    4)
		uninstall
	;;
	5)
	echo "本功能全自动领取星愿！

	脚本引用开源Jq解析json，部署过程中会自动安装Jq，没有安装需要输入Y回车继续。

	开发不易，新来的朋友填我的推荐码 587888 支持一下，感谢！

	"
	read -p "按任意键继续..."
	sudo apt-get install jq
	login
		;;
    6)
	echo "每周三自动提现星愿到绑定的支付宝账号！

	本功能需要开启星愿自动领取，sever酱通知同样引用自动领取通知！

	开发不易，新来的朋友填我的推荐码 587888 支持一下，感谢！

	"
	read -p "按任意键继续..."
	sudo apt-get install jq
	withdraw
		;;
    7)
		reboot
		;;
	8)
		exit 0
esac
}
function withdraw()
{
	#写监控脚本
	mkdir /root/tt/4/
	cd /root/tt/
	wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/ttnode/withdraw.sh
	chmod -R 777 *
	sed -i '16a 30 8 * * 3	root	/root/tt/withdraw.sh' /etc/crontab
	echo "部署成功，每周三8点30分准时提现星愿！5秒后返回主菜单！"
	sleep 5s
	menu
}

function login()
{
cd /root/tt/
read -p "请输入手机号码：" tel
if [ ${#tel} = 11 ];then
	codeText=$(curl -X POST http://tiantang.mogencloud.com/web/api/login/code?phone=$tel|jq '.errCode')
	if [ $codeText = 0 ];then
		read -p "验证码发送成功，请输入：" code
		if [ ${#code} = 6 ];then
			tokenText=$(curl -X POST http://tiantang.mogencloud.com/web/api/login?phone=$tel\&authCode=$code|jq '.data.token' | sed 's/\"//g')
			if [ $tokenText = null ];then
				echo "登录失败，请重试！"
			else
				if [ -d /root/tt/token.txt ]; then
					rm -f token.txt
					echo $tokenText > token.txt
					read -p "甜糖token更新成功，如需更新Server酱监控SCKEY请直接输入,不更新请按回车：" sckey
					if [ ${#sckey} -gt 30 ];then 
						rm -f sckey.txt
						echo $sckey > sckey.txt
					fi
				else
					echo $tokenText > token.txt
					read -p "登录成功，请输入Server酱监控SCKEY,不使用直接按回车：" sckey
					if [ ${#sckey} -gt 30 ];then 
						echo $sckey > sckey.txt
					fi
					#写监控脚本
					wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/ttnode/587888.sh
					chmod -R 777 *
					sed -i '15a 30 4 * * *	root	/root/tt/587888.sh' /etc/crontab
					mkdir /root/tt/3/
					echo "部署成功，每天凌晨4点30分准时收取星愿！5秒后返回主菜单！"
				fi
				sleep 5s
				menu
			fi
		else
			echo "验证码输入错误！"
		fi
	else
	echo "发送验证码失败，请重试！"
	fi
else
	echo "手机号码输入错误！"
fi
}





function uninstall()
{
	rm -rf /etc/rc.local
	rm -rf /etc/crontab
	rm -rf /etc/network/interfaces

	cp -pdr /root/tt/rc.local.default /etc/rc.local
	cp -pdr /root/tt/crontab.default /etc/crontab
	cp -pdr /root/tt/interfaces.default /etc/network/interfaces
	rm -rf /root/tt/

	echo "卸载甜糖成功！重启生效！

	3秒后返回主菜单..."
	sleep 3s
	menu
}

function changeMac()
{
	if [ ! -d /root/tt/1/ ]; then
	echo "甜糖未安装，请安装后修改Mac地址、、、"
	else
	rm -rf /etc/network/interfaces
	cp -pdr /root/tt/interfaces.default /etc/network/interfaces
	mac=00:60:2F$(dd bs=1 count=3 if=/dev/random 2>/dev/null |hexdump -v -e '/1 ":%02X"')
	sed -i "6a hwaddress $mac" /etc/network/interfaces
	echo "修改Mac成功，重启生效。
	新Mac是：$mac 请重启后重新绑定设备！

	3秒后返回主菜单..."
	sleep 3s
	menu
	fi
}

function backup()
{
	myPath="/root/tt/"

	if [ ! -d "$myPath" ]; then
	mkdir "$myPath"
	cp -pdr /etc/rc.local "$myPath"rc.local.default
	cp -pdr /etc/crontab "$myPath"crontab.default
	cp -pdr /etc/network/interfaces "$myPath"interfaces.default

	else
	echo "备份文件已存在，跳过备份步骤。"
	fi
}



function install32()
{
			read -p '
欢迎使用32位armbian甜糖CDN自动部署程序
		                                       
==============================================
    填写邀请码：587888  免费获取15张加成卡！
==============================================
		
请输入邀请码 587888 开始自动部署：' number
		 
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
			
			wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/ttnode/ttnode32 -O ttnode
			wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/ttnode/crash_monitor.sh
			wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/ttnode/log.log
			chmod -R 777 *
			
			sed -i "12a mount $fenqu /mnt/\nservice sshd start\n/usr/node/ttnode -p /mnt" /etc/rc.local
			
			mac=00:60:2F$(dd bs=1 count=3 if=/dev/random 2>/dev/null |hexdump -v -e '/1 ":%02X"')
			
			sed -i "6a hwaddress $mac" /etc/network/interfaces
			
			sed -i '14a */1 * * * *	root	/usr/node/crash_monitor.sh' /etc/crontab
			mkdir /root/tt/1/
			clear
			echo "
--------------------------------------------------------------------------------------------------
			
部署成功，请输入命令：reboot 重启！

bug反馈链接：https://www.right.com.cn/forum/forum.php?mod=viewthread&tid=4057372
			
===================================================
===================================================
      请大力填写我的甜糖发财邀请码：587888
===================================================
===================================================
			
此脚本由「折了个腾」原创发布，没有shell开发经验，现学现卖写的
			
开发不易，新来的朋友填我的推荐码 587888 支持一下，感谢！
			
--------------------------------------------------------------------------------------------------
			"
		
		else
			echo "输入有误！我的邀请码是：tt"
		fi


}

function install64()
{
			read -p '
欢迎使用64位armbian甜糖CDN自动部署程序
		                                       
==============================================
    填写邀请码：587888  免费获取15张加成卡！
==============================================
		
请输入邀请码 587888 开始自动部署：' number
		 
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
			
			wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/ttnode/ttnode64 -O ttnode
			wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/ttnode/crash_monitor.sh
			wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/ttnode/log.log
			chmod -R 777 *
			
			sed -i "12a mount $fenqu /mnt/\nservice sshd start\n/usr/node/ttnode -p /mnt" /etc/rc.local
			
			mac=00:60:2F$(dd bs=1 count=3 if=/dev/random 2>/dev/null |hexdump -v -e '/1 ":%02X"')
			
			sed -i "6a hwaddress $mac" /etc/network/interfaces
			
			sed -i '14a */1 * * * *	root	/usr/node/crash_monitor.sh' /etc/crontab
			mkdir /root/tt/2/
			clear
			echo "
--------------------------------------------------------------------------------------------------
			
部署成功，请输入命令：reboot 重启！

bug反馈链接：https://www.right.com.cn/forum/forum.php?mod=viewthread&tid=4057372
			
===================================================
===================================================
      请大力填写我的甜糖发财邀请码：587888
===================================================
===================================================
			
此脚本由「折了个腾」原创发布，没有shell开发经验，现学现卖写的
			
开发不易，新来的朋友填我的推荐码 587888 支持一下，感谢！
			
--------------------------------------------------------------------------------------------------
			"
		
		else
			echo "输入有误！我的邀请码是：587888"
			sleep 3s
			menu
		fi

}

menu