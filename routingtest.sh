#!/bin/bash

path=$(pwd)
red_f='\033[31m'
red_e='\033[0m'
green_f='\033[32m'
green_e='\033[0m'
blue_f='\033[36m'
blue_e='\033[0m'

FILE_EXIST=0
FILE_NOT_EXIST=1
DIR_EXIST=2
DIR_NOT_EXIST=3
FILE_EQUAL=4
FILE_NOT_EQUAL=5

declare -A RESULT

RESULT[FILE_EXIST]="file exists"
RESULT[FILE_NOT_EXIST]="file does not exists"
RESULT[DIR_EXIST]="directory exists"
RESULT[DIR_NOT_EXIST]="directory does not exists"
RESULT[FILE_EQUAL]="two files are equal"
RESULT[FILE_NOT_EQUAL]="two files are NOT equal"
#RESULT[]=""
#RESULT[]=""

#parameter1 is the output of other function
#parameter2 is the right status
#compare if those two parameters are the same to judge if the status is right 
Pass_or_Fail(){
	output="$1"
	judge="$2"
#	echo "($output)"
#	echo "($judge)"
        if [[ $output = $judge ]];then
                echo -e "[${green_f} pass $green_e]:${RESULT[$outout]}"
        else
                echo -e "[$red_f fail $red_e]:${RESULT[$outout]}"
        fi  
}

#print what part it is
Title(){
	echo -e "${blue_f}---- $1 ---- $blue_e "
}

#judge if file exists
FileExist(){
	if [ -f $1 ]; then
		return $FILE_EXIST
	else 
		return $FILE_NOT_EXIST
	fi
}
#judge if directory exists
DirExist(){
	if [ -d $1 ]; then
                return $DIR_EXIST
        else 
                return $DIR_NOT_EXIST
        fi

}

#compare if two files different
FileDiff(){
	diff $1 $2 > /dev/null
	compare_value=$?
	if [ $compare_value -eq 0 ];then
		return $FILE_EQUAL
	else
		return $FILE_NOT_EQUAL
 	fi
	
}

#print Specified interface's ip address and Subnet mask
ip_and_mask(){
	echo "$1"
	ifconfig $1 |grep "inet addr:" |awk '{print $2}'
	ifconfig $1 |grep "inet addr:" |awk '{print $4}'
}

#print and check interfaces informations
ifconfig(){
	Title ifconfig
	ip_and_mask enp2s0
	ip_and_mask br0 
	echo " "
}

#print and check bay_routing.service informations
service(){
	Title routing.service 
	sudo systemctl status bay_routing.service
	echo " "
}

#print and check iptables rules
iptable(){
	Title iptables 
	sudo iptables -t filter -L -nv |grep enp2s0
	sudo iptables -t nat -L -nv |grep enp2s0
	echo " "
}

#print and check if files and directory exist and correct
FileExistOutput(){
	Title $1
	if_exist=`FileExist $1`
	Pass_or_Fail "$if_exist" $2
}
FileDiffOutput(){
	if_diff=`FileDiff $1 $2`
	Pass_or_Fail "$if_diff" $3
}

# Installed Test:
#	1. Exist(/etc/network/if.backup)
#	2. Exist(/etc/network/interfaces) && Equal(/etc/network/interface ./interfaces)
#	3. Exist(/etc/Bay/routing.sh) && Equal(/etc/Bay/routing.sh ./routing.sh) 	 
#	4. Exist(/etc/systemd/system/bay_routing.service) && 
#	   Equal(/etc/systemd/system/bay_routing.service ./bay_routing.service) 
#	5. Interfaces information
#	5.0 Exist(br0)
#	5.1 Equal(br0: ip address, 192.168.0.1)
#	5.2 Equal(br0: network mask, 255.255.254.0)
#	5.3 Exist(enp2s0)
#	5.4 Equal(enp2s0: ip addres, 192.168.20.*)
#	5.5 Equal(enp2s0: network mask, 255.255.255.0)
#	6. IsUp(bay_routing.serive)
#	7. Iptables Rules
#	7.1 Exist(FORWORD between enp2s0 and br0)
#	7.2 Exist(MASQUERADE on enp2s0) 

test_install(){
	FileExistOutput /etc/network/if.backup $FILE_EXIST
	
	FileExistOutput /etc/network/interfaces $FILE_EXIST
	FileDiffOutput /etc/network/interfaces ./interfaces $FILE_EQUAL
	
	FileExistOutput /etc/Bay/routing.sh $FILE_EXIST
	FileDiffOutput /etc/Bay/routing.sh ./routing.sh $FILE_EQUAL

	FileExistOutput /etc/systemd/system/bay_routing.service $FILE_EXIST
	FileDiffOutput /etc/systemd/system/bay_routing.service ./bay_routing.service $FILE_EQUAL
	
	
}

#Uninstalled Test
#	1. NOTExist(/etc/network/if.backup)
#	2. Exist(/etc/network/interfaces) && NOTEqual(/etc/network/interface ./interfaces)
#	3. NOTExist(/etc/Bay/routing.sh)
#	4. NOTExist(/etc/systemd/system/bay_routing.service)
#	5. interfaces Information
#	5.1 NOTExist(br0)
#	5.2 NOTExist(enp2s0)
#	6. IsDown(bay_routing.serive)
#	7. Iptable Rules
#	7.1 NOTExist(FORWORD between enp2s0 and br0)
#	7.2 NOTExist(MASQUERADE on enp2s0)


test_uninstall(){
	FileExistOutput /etc/network/if.backup $FILE_NOT_EXIST
	
	FileExistOutput /etc/network/interfaces $FILE_EXIST
	FileDiffOutput /etc/network/interface ./interfaces $FILE_NOT_EQUAL
	
	FileExistOutput /etc/Bay/routing.sh $FILE_NOT_EXIST
	
	FileExistOutput /etc/systemd/system/bay_routing.service $FILE_NOT_EXIST
	

}

case "$1" in 
	IsInstalled)
		test_install
		;;
	IsUninstalled)
		test_uninstall
		;;
	*)
		echo -e "${red_f}Usage: $0 {IsInstalled | IsUninstalled} $red_e"
esac
