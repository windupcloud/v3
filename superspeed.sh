#!/usr/bin/env bash
#
# Description: Test your server's network with Speedtest to China
#
# Copyright (C) 2017 - 2017 Oldking <oooldking@gmail.com>
#
# URL: https://www.oldking.net/305.html
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
SKYBLUE='\033[0;36m'
PLAIN='\033[0m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${RED}Error:${PLAIN} This script must be run as root!" && exit 1

# check python
if  [ ! -e '/usr/bin/python' ]; then
        echo -e
        read -p "${RED}Error:${PLAIN} python is not install. You must be install python command at first.\nDo you want to install? [y/n]" is_install
        if [[ ${is_install} == "y" || ${is_install} == "Y" ]]; then
            if [ "${release}" == "centos" ]; then
                        yum -y install python
                else
                        apt-get -y install python
                fi
        else
            exit
        fi
        
fi

# check wget
if  [ ! -e '/usr/bin/wget' ]; then
        echo -e
        read -p "${RED}Error:${PLAIN} wget is not install. You must be install wget command at first.\nDo you want to install? [y/n]" is_install
        if [[ ${is_install} == "y" || ${is_install} == "Y" ]]; then
                if [ "${release}" == "centos" ]; then
                        yum -y install wget
                else
                        apt-get -y install wget
                fi
        else
                exit
        fi
fi


clear
echo "#############################################################"
echo "# Description: Test your server's network with Speedtest    #"
echo "# Intro:  https://www.oldking.net/305.html                  #"
echo "# Author: Oldking <oooldking@gmail.com>                     #"
echo "# Github: https://github.com/oooldking                      #"
echo "#############################################################"
echo
echo "测试服务器到"
echo -ne "1.中国电信 2.中国联通 3.中国移动 4.本地默认 5.全面测速"

while :; do echo
        read -p "请输入数字选择： " telecom
        if [[ ! $telecom =~ ^[1-5]$ ]]; then
                echo "输入错误! 请输入正确的数字!"
        else
                break   
        fi
done

if [[ ${telecom} == 1 ]]; then
        telecomName="电信"
        echo -e "\n选择最靠近你的方位"
        echo -ne "1.深圳 2.杭州 3.上海 4.西安"
        while :; do echo
                read -p "请输入数字选择： " city
                if [[ ! $city =~ ^[1-4]$ ]]; then
                        echo "输入错误! 请输入正确的数字!"
                else
                        break
            fi
        done
        if [[ ${city} == 1 ]]; then
                num=21003
                cityName="深圳"
        fi
        if [[ ${city} == 2 ]]; then
                num=7509
                cityName="杭州"
        fi
        if [[ ${city} == 3 ]]; then
                num=17019
                cityName="上海"
        fi
        if [[ ${city} == 4 ]]; then
                num=4863
                cityName="西安"
        fi
fi
    #echo -ne "1.北方 2.南方"
    #while :; do echo
    #        read -p "请输入数字选择： " pos
    #        if [[ ! $pos =~ ^[1-2]$ ]]; then
    #                echo "输入错误! 请输入正确的数字!"
    #        else
    #                break
    #        fi
    #done
    #echo -e "\n选择最靠近你的城市"
    #if [[ ${pos} == 1 ]]; then
    #    echo -ne "1.郑州 2.襄阳"
    #    while :; do echo
    #            read -p "请输入数字选择： " city
    #            if [[ ! $city =~ ^[1-2]$ ]]; then
    #                    echo "输入错误! 请输入正确的数字!"
    #            else
    #                    break
    #        fi
    #    done
    #    if [[ ${city} == 1 ]]; then
    #            num=4595
    #            cityName="郑州"
    #    fi
    #    if [[ ${city} == 2 ]]; then
    #            num=12637
    #            cityName="襄阳"
    #    fi
    #fi
    #if [[ ${pos} == 2 ]]; then
    #    echo -ne "1.上海 2.杭州 3.南宁 4.南昌 5.长沙 6.深圳 7.重庆 8.成都"
    #    while :; do echo
    #            read -p "请输入数字选择： " city
    #            if [[ ! $city =~ ^[1-8]$ ]]; then
    #                    echo "输入错误! 请输入正确的数字!"
    #            else
    #                    break
    #        fi
    #    done
    #    if [[ ${city} == 1 ]]; then
    #            num=3633
    #            cityName="上海"
    #    fi
    #    if [[ ${city} == 2 ]]; then
    #            num=7509
    #            cityName="杭州"
    #    fi
    #    if [[ ${city} == 3 ]]; then
    #            num=10305
    #            cityName="南宁"
    #    fi
    #    if [[ ${city} == 4 ]]; then
    #            num=7230
    #            cityName="南昌"
    #    fi
    #    if [[ ${city} == 5 ]]; then
    #            num=6132
    #            cityName="长沙"
    #    fi
    #    if [[ ${city} == 6 ]]; then
    #            num=5081
    #            cityName="深圳"
    #    fi
    #    if [[ ${city} == 7 ]]; then
    #            num=6592
    #            cityName="重庆"
    #    fi
    #    if [[ ${city} == 8 ]]; then
    #            num=4624
    #            cityName="成都"
    #    fi
    #fi
#fi

if [[ ${telecom} == 2 ]]; then
        telecomName="联通"
    #echo -ne "\n1.北方 2.南方"
    #while :; do echo
    #        read -p "请输入数字选择： " pos
    #        if [[ ! $pos =~ ^[1-2]$ ]]; then
    #                echo "输入错误! 请输入正确的数字!"
    #        else
    #                break
    #        fi
    #done
    #echo -e "\n选择最靠近你的城市"
    #if [[ ${pos} == 1 ]]; then
        
        echo -ne "1.重庆 2.上海 3.北京 4.西安"
        while :; do echo
                read -p "请输入数字选择： " city
                if [[ ! $city =~ ^[1-4]$ ]]; then
                        echo "输入错误! 请输入正确的数字!"
                else
                        break
            fi
        done
        if [[ ${city} == 1 ]]; then
                num=5726
                cityName="重庆"
        fi
        if [[ ${city} == 2 ]]; then
                num=5083
                cityName="上海"
        fi
        if [[ ${city} == 3 ]]; then
                num=5145
                cityName="北京"
        fi
        if [[ ${city} == 4 ]]; then
                num=4863
                cityName="西安"
        fi
    #fi
    #if [[ ${pos} == 2 ]]; then
    #    echo -ne "1.上海 2.杭州 3.南宁 4.合肥 5.南昌 6.长沙 7.深圳 8.广州 9.重庆 10.昆明 11.成都"
    #    while :; do echo
    #            read -p "请输入数字选择： " city
    #            if [[ ! $city =~ ^(([1-9])|(1([0-1]{1})))$ ]]; then
    #                    echo "输入错误! 请输入正确的数字!"
    #            else
    #                    break
    #        fi
    #    done
    #    if [[ ${city} == 1 ]]; then
    #            num=5083
    #            cityName="上海"
    #    fi
    #    if [[ ${city} == 2 ]]; then
    #            num=5300
    #            cityName="杭州"
    #    fi
    #    if [[ ${city} == 3 ]]; then
    #            num=5674
    #            cityName="南宁"
    #    fi
    #    if [[ ${city} == 4 ]]; then
    #            num=5724
    #            cityName="合肥"
    #    fi
    #    if [[ ${city} == 5 ]]; then
    #            num=5079
    #            cityName="南昌"
    #    fi
    #    if [[ ${city} == 6 ]]; then
    #            num=4870
    #            cityName="长沙"
    #    fi
    #    if [[ ${city} == 7 ]]; then
    #            num=10201
    #            cityName="深圳"
    #    fi
    #    if [[ ${city} == 8 ]]; then
    #            num=3891
    #            cityName="广州"
    #    fi
    #    if [[ ${city} == 9 ]]; then
    #            num=5726
    #            cityName="重庆"
    #    fi
    #    if [[ ${city} == 10 ]]; then
    #            num=5103
    #            cityName="昆明"
    #    fi
    #    if [[ ${city} == 11 ]]; then
    #            num=2461
    #            cityName="成都"
    #    fi
    #fi
fi

if [[ ${telecom} == 3 ]]; then
        telecomName="移动"
    #echo -ne "\n1.北方 2.南方"
    #while :; do echo
    #        read -p "请输入数字选择： " pos
    #        if [[ ! $pos =~ ^[1-2]$ ]]; then
    #                echo "输入错误! 请输入正确的数字!"
    #        else
    #                break
    #        fi
    #done
    #echo -e "\n选择最靠近你的城市"
    #if [[ ${pos} == 1 ]]; then
        echo -ne "1.深圳 2.杭州 3.北京 4.重庆"
        while :; do echo
                read -p "请输入数字选择： " city
                if [[ ! $city =~ ^[1-4]$ ]]; then
                        echo "输入错误! 请输入正确的数字!"
                else
                        break
            fi
        done
        if [[ ${city} == 1 ]]; then
                num=4515
                cityName="深圳"
        fi
        if [[ ${city} == 2 ]]; then
                num=4647
                cityName="杭州"
        fi
        if [[ ${city} == 3 ]]; then
                num=4713
                cityName="北京"
        fi
        if [[ ${city} == 4 ]]; then
                num=17584
                cityName="重庆"
        fi
    #fi
    #if [[ ${pos} == 2 ]]; then
    #    echo -ne "1.上海 2.宁波 3.无锡 4.杭州 5.合肥 6.成都"
    #    while :; do echo
    #            read -p "请输入数字选择： " city
    #            if [[ ! $city =~ ^[1-6]$ ]]; then
    #                    echo "输入错误! 请输入正确的数字!"
    #            else
    #                    break
    #        fi
    #    done
    #    if [[ ${city} == 1 ]]; then
    #            num=4665
    #            cityName="上海"
    #    fi
    #    if [[ ${city} == 2 ]]; then
    #            num=6715
    #            cityName="宁波"
    #    fi
    #    if [[ ${city} == 3 ]]; then
    #            num=5122
    #            cityName="无锡"
    #    fi
    #    if [[ ${city} == 4 ]]; then
    #            num=4647
    #            cityName="杭州"
    #    fi
    #    if [[ ${city} == 5 ]]; then
    #            num=4377 
    #            cityName="合肥"
    #    fi
    #    if [[ ${city} == 6 ]]; then
    #            num=4575
    #            cityName="成都"
    #    fi
    #fi
fi

# install speedtest
if  [ ! -e '/tmp/speedtest.py' ]; then
    wget --no-check-certificate -P /tmp https://raw.github.com/sivel/speedtest-cli/master/speedtest.py > /dev/null 2>&1
fi
chmod a+rx /tmp/speedtest.py

result() {
    download=`cat /tmp/speed.log | awk -F ':' '/Download/{print $2}'`
    upload=`cat /tmp/speed.log | awk -F ':' '/Upload/{print $2}'`
    hostby=`cat /tmp/speed.log | awk -F ':' '/Hosted/{print $1}'`
    latency=`cat /tmp/speed.log | awk -F ':' '/Hosted/{print $2}'`
    clear
    echo "$hostby"
    echo "延迟  : $latency"
    echo "上传  : $upload"
    echo "下载  : $download"
    echo -ne "\n当前时间: "
    echo $(date +%Y-%m-%d" "%H:%M:%S)
}

speed_test(){
	temp=$(python /tmp/speedtest.py --server $1 --share 2>&1)
	is_down=$(echo "$temp" | grep 'Download') 
	if [[ ${is_down} ]]; then
        local REDownload=$(echo "$temp" | awk -F ':' '/Download/{print $2}')
        local reupload=$(echo "$temp" | awk -F ':' '/Upload/{print $2}')
        local relatency=$(echo "$temp" | awk -F ':' '/Hosted/{print $2}')
        temp=$(echo "$relatency" | awk -F '.' '{print $1}')
        if [[ ${temp} -gt 1000 ]]; then
            relatency=" 000.000 ms"
        fi
        local nodeName=$2

        printf "${YELLOW}%-17s${GREEN}%-18s${RED}%-20s${SKYBLUE}%-12s${PLAIN}\n" "${nodeName}" "${reupload}" "${REDownload}" "${relatency}"
	else
        local cerror="ERROR"
	fi
}

if [[ ${telecom} =~ ^[1-3]$ ]]; then
    python /tmp/speedtest.py --server ${num} --share 2>/dev/null | tee /tmp/speed.log 2>/dev/null
    is_down=$(cat /tmp/speed.log | grep 'Download')

    if [[ ${is_down} ]]; then
        result
        echo "测试到 ${cityName}${telecomName} 完成！"
        rm -rf /tmp/speedtest.py
        rm -rf /tmp/speed.log
    else
	    echo -e "\n${RED}ERROR:${PLAIN} 当前节点不可用，请更换其他节点。"
	fi
fi

if [[ ${telecom} == 4 ]]; then
    python /tmp/speedtest.py | tee /tmp/speed.log
    result
    echo "本地测试完成！"
    rm -rf /tmp/speedtest.py
    rm -rf /tmp/speed.log
fi

if [[ ${telecom} == 5 ]]; then
	echo ""
	printf "%-14s%-18s%-20s%-12s\n" "Node Name" "Upload Speed" "Download Speed" "Latency"
	start=$(date +%s) 
    #电信CT
    speed_test '21003' '深圳电信'
	speed_test '7509' '杭州电信'
	speed_test '17019' '上海电信'
    speed_test '4863' '西安电信'
    #
    #联通CU
    speed_test '5726' '重庆联通'
	speed_test '5083' '上海联通'
	speed_test '5145' '北京联通'
    #
    #移动CM
	speed_test '4515' '深圳移动'
	speed_test '4647' '杭州移动'
    speed_test '4713' '北京移动'
	speed_test '17584' '重庆移动'
    #
	end=$(date +%s)  
	rm -rf /tmp/speedtest.py
	echo ""
	time=$(( $end - $start ))
	if [[ $time -gt 60 ]]; then
		min=$(expr $time / 60)
		sec=$(expr $time % 60)
		echo -ne "花费时间：${min} 分 ${sec} 秒"
	else
		echo -ne "花费时间：${time} 秒"
	fi
	echo -ne "\n当前时间: "
    echo $(date +%Y-%m-%d" "%H:%M:%S)
	echo "全面测试完成！"
fi
