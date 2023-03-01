#!/bin/bash
#from https://github.com/spiritLHLS/one-click-installation-script

# 检查是否有sudo权限
if [ $(id -u) -ne 0 ]; then
  echo "This script must be run as root. Please run with sudo." >&2
  exit 1
fi

# 获取当前系统版本
CURRENT_VER=$(lsb_release -rs)

# 支持升级的版本
SUPPORTED_VERSIONS=("16.04" "17.04" "17.10" "18.04" "19.04" "19.10" "20.04" "20.10" "21.04" "21.10")

# 检查是否支持当前版本的升级
if [[ ! " ${SUPPORTED_VERSIONS[@]} " =~ " ${CURRENT_VER} " ]]; then
  echo "Unsupported Ubuntu version. This script supports Ubuntu 16, 17, 18, 19, 20 and 21 only." >&2
  exit 1
fi

# 更新软件源和安装必要的升级工具
apt-get update
apt-get install -y update-manager-core

# 升级 Ubuntu 16 到 18
if [ "$CURRENT_VER" == "16.04" ]; then
  echo "Upgrading Ubuntu 16 to 18..."
  sed -i 's/xenial/bionic/g' /etc/apt/sources.list
  do-release-upgrade -d -f DistUpgradeViewNonInteractive

# 升级 Ubuntu 17 到 18
elif [ "$CURRENT_VER" == "17.04" ] || [ "$CURRENT_VER" == "17.10" ]; then
  echo "Upgrading Ubuntu 17 to 18..."
  sed -i 's/zesty/bionic/g' /etc/apt/sources.list
  do-release-upgrade -d -f DistUpgradeViewNonInteractive

# 升级 Ubuntu 18 到 20
elif [ "$CURRENT_VER" == "18.04" ]; then
  echo "Upgrading Ubuntu 18 to 20..."
  do-release-upgrade -d -f DistUpgradeViewNonInteractive

# 升级 Ubuntu 19 到 20
elif [ "$CURRENT_VER" == "19.04" ] || [ "$CURRENT_VER" == "19.10" ]; then
  echo "Upgrading Ubuntu 19 to 20..."
  sed -i 's/disco/eoan/g' /etc/apt/sources.list
  do-release-upgrade -d -f DistUpgradeViewNonInteractive

# 升级 Ubuntu 20 或 21 到 22
else
  echo "Upgrading Ubuntu 20/21 to 22..."
  do-release-upgrade -d -f DistUpgradeViewNonInteractive
fi

