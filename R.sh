#!/usr/bin/env bash
#by spiritlhl
#from https://github.com/spiritLHLS/one-click-installation-script
#version: 2023.04.01

ver="2022.04.01"
changeLog="一键安装R环境"
source ~/.bashrc
red(){ echo -e "\033[31m\033[01m$1$2\033[0m"; }
green(){ echo -e "\033[32m\033[01m$1$2\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$1$2\033[0m"; }
blue() { echo -e "\033[36m\033[01m$@\033[0m"; }
reading(){ read -rp "$(green "$1")" "$2"; }
REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'" "fedora" "arch")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Fedora" "Arch")
PACKAGE_UPDATE=("! apt-get update && apt-get --fix-broken install -y && apt-get update" "apt-get update" "yum -y update" "yum -y update" "yum -y update" "pacman -Sy")
PACKAGE_INSTALL=("apt-get -y install" "apt-get -y install" "yum -y install" "yum -y install" "yum -y install" "pacman -Sy --noconfirm --needed")
PACKAGE_REMOVE=("apt-get -y remove" "apt-get -y remove" "yum -y remove" "yum -y remove" "yum -y remove" "pacman -Rsc --noconfirm")
PACKAGE_UNINSTALL=("apt-get -y autoremove" "apt-get -y autoremove" "yum -y autoremove" "yum -y autoremove" "yum -y autoremove" "")
CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)" "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)" "$(grep . /etc/redhat-release 2>/dev/null)" "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')" "$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)") 
SYS="${CMD[0]}"
[[ -n $SYS ]] || exit 1
for ((int = 0; int < ${#REGEX[@]}; int++)); do
    if [[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]]; then
        SYSTEM="${RELEASE[int]}"
        [[ -n $SYSTEM ]] && break
    fi
done
apt-get --fix-broken install -y > /dev/null 2>&1
clear
echo "#######################################################################"
echo "#                     ${YELLOW}一键安装R环境${PLAIN}                             #"
echo "# 版本：$ver                                                    #"
echo "# 更新日志：$changeLog                                       #"
echo "# ${GREEN}作者${PLAIN}: spiritlhl                                                     #"
echo "# ${GREEN}仓库${PLAIN}: https://github.com/spiritLHLS/one-click-installation-script #"
echo "#######################################################################"
echo "验证已支持的系统："
echo "Ubuntu 18/20/22 - 推荐，脚本自动挂起到后台"
echo "Debian 9/10/11 - 还行，需要手动挂起到后台，详看脚本运行安装完毕的后续提示"
echo "可能支持的系统：centos 7+，Fedora，Almalinux 8.5+"
yellow "如若已经安装jupyter环境则安装完毕后需要重启jupyter加载内核，安装jupyter环境详见对应仓库目录"
yellow "如果是初次安装无脑回车即可，按照提示进行操作即可"

checkupdate(){
  yellow "Updating package management sources"
  ${PACKAGE_UPDATE[int]} > /dev/null 2>&1
  apt-key update > /dev/null 2>&1
}

checkroot(){
	[[ $EUID -ne 0 ]] && echo -e "${RED}请使用 root 用户运行本脚本！${PLAIN}" && exit 1
}

checkR(){
  if ! command -v R &> /dev/null
  then
	reading "R is not installed on this system. Do you want to install it? (y/n) " confirminstall
	echo ""
	if [ "$confirminstall" != "y" ]; then
		exit 0
	fi
	echo "R is not installed, install R language and dependent libraries..."
	${PACKAGE_INSTALL[int]} r-base libssl-dev libcurl4-openssl-dev libxml2-dev
  else
	echo "R is already installed, skip..."
  fi
    
  if ! R -q -e "library('IRkernel')" &> /dev/null
  then
	reading "IRkernel is not installed on this system. Do you want to install it? (y/n) " confirminstall
	echo ""
	if [ "$confirminstall" != "y" ]; then
		exit 0
	fi
	R -q -e "install.packages('IRkernel', repos='https://cran.r-project.org/'); IRkernel::installspec()"
	green "Installed IRkernel package and registered kernel"
  else
	blue "IRkernel is installed"
  fi
}

checkroot
checkupdate
checkR
green "R语言已安装完毕"