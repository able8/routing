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
DIRECTORY_EXIST=2
DIRECTORY_NOT_EXIST=3
FILE_EQUAL=4
FILE_NOT_EQUAL=5

declare -A RESULT

RESULT[FILE_EXIST]="file exists"
RESULT[FILE_NOT_EXIST]="file does not exists"
RESULT[DIRECTORY_EXIST]="directory exists"
RESULT[DIRECTORY_NOT_EXIST]="directory does not exists"
RESULT[FILE_EQUAL]="two files are equal"
RESULT[FILE_NOT_EQUAL]="two files are NOT equal"
RESULT[]=""
RESULT[]=""

#parameter1 is the output of other function
#parameter2 is the right status
#compare if those two parameters are the same to judge if the status is right 
pass_or_fail(){
	output="$1"
	judge="$2"
#	echo "($output)"
#	echo "($judge)"
        if [[ $output = $judge ]];then
                echo -e "[${green_f} pass $green_e]:$output"
        else
                echo -e "[$red_f fail $red_e]:$output"
        fi  
}

#print what part it is
print_title(){
	echo -e "${blue_f}---- $1 ---- $blue_e "
}

#judge if file exists
fileExist(){
	if [ -f $1 ]; then
		return $FILE_EXIST
	else 
		return $FILE_NOT_EXIST
	fi
}

#compare if two files different
if_file_different(){
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
	print_title ifconfig
	ip_and_mask enp2s0
	ip_and_mask br0 
	echo " "
}

#print and check bay_routing.service informations
service(){
	print_title routing.service 
	sudo systemctl status bay_routing.service
	echo " "
}

#print and check iptables rules
iptable(){
	print_title iptables 
	sudo iptables -t filter -L -nv |grep enp2s0
	sudo iptables -t nat -L -nv |grep enp2s0
	echo " "
}

#print and check if files exist and correct
files(){
	print_title /etc/network/ if.backup
	if_exist=`if_file_exist /etc/network/if.backup`
	pass_or_fail "$if_exist" 'file exists'
	pass_or_fail 
	cat file.txt | while read line
	do
		if_exist=`if_file_exist $line | grep file`
		if_different=`if_file_different $line`
		
		print_title $line
		pass_or_fail "$if_exist" 'file exists'
		pass_or_fail "$if_different" 'equal'
	done
}

# Test:
#	1. Exist(/etc/network/if.backup)
#	2. Exist(/etc/network/interfaces) && Equal(/etc/network/interface, ./interfaces)
#	3. Exist(/etc/Bay/routing.sh) && Equal(/etc/Bay/routing.sh, ./routing.sh) 	 
#	4. Exist(/etc/systemd/system/bay_routing.service) && 
#	   Equal(/etc/systemd/system/bay_routing.service, ./bay_routing.service) 
#	5. Equal(br0 ip address, 192.168.0.1)
#	6. Equal(br0 network mask, 255.255.254.0)
#	7. Equal(enp2s0 ip addres, 192.168.20.*)
#	8. Equal(enp2s0 network mask, 255.255.255.0)
#	9. IsUp(bay_routing.serive)
#	10. iptables rules
#	10.1 FORWORD between enp2s0 and br0
#	10.2 MASQUERADE on enp2s0 

test_install(){
	
}

test_uninstall(){
	cat file.txt | while read line
		do
			if_exist=`if_file_exist $line | grep file`

			print_title $line
			pass_or_fail "$if_exist" 'file does not exists'
		done
#		status

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
