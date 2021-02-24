#!/bin/sh
rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime


text=$( curl -V )
if [[ $text == "curl "* ]]; then
	echo "crul已安装，跳过、、、"
else
apt-get install curl
fi


text=$( ls -l /bin/sh )
if [[ $text == *"bash" ]]; then
	echo "bash"
else
#dash
	clear
	echo -e "
运行环境准备\033[35m1\033[0m/2：修改dash为bash 

┌──────────────────────┤ Configuring dash ├───────────────────────┐  
│                                                                 │  
│ The system shell is the default command interpreter for shell   │  
│ scripts.                                                        │  
│                                                                 │  
│ Using dash as the system shell will improve the system's        │  
│ overall performance. It does not alter the shell presented to   │  
│ interactive users.                                              │  
│                                                                 │  
│ Use dash as the default system shell (/bin/sh)?                 │  
│                                                                 │  
│                 <Yes>                    \033[41;37m<No> \033[0m                  │  
│                                          \033[35m↑↑↑↑选他按回车\033[0m          │  
└─────────────────────────────────────────────────────────────────┘                                                                      
\033[35m在跳出如上画面中按方向键选择【NO】按回车。\033[0m"
	read -p "按回车键继续..." typ
	sudo dpkg-reconfigure dash	
fi

text=$( jq --version )
if [[ $text == "jq-"* ]]; then
	echo $text
else
	clear
	echo -e "
	运行环境准备\033[35m2\033[0m/2：安装JQ支持
	
	脚本引用开源Jq解析json，详见：https://github.com/stedolan/jq
	
	脚本会自动安装Jq，安装过程需要\033[35m输入Y按回车\033[0m继续。
	"
	read -p "按回车键继续..." typ
	sudo apt-get install jq
fi

myPath="/root/587888/"
if [ ! -d "$myPath" ]; then
	mkdir "$myPath"
fi

cd $myPath
wget -O 587888.sh https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/587888.sh
if [ ! -f "${myPath}config.json" ]; then
	wget https://cdn.jsdelivr.net/gh/zixia1/cdn@main/tt/config.json
fi

chmod -R 777 *
bash 587888.sh