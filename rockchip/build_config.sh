#!/bin/bash
# Log file for debugging
source shell/custom-packages.sh
echo "第三方软件包: $CUSTOM_PACKAGES"
LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting 99-custom.sh at $(date)" >> $LOGFILE

# yml 传入的路由器型号 PROFILE
echo "Building for profile: $PROFILE"
# yml 传入的固件大小 ROOTFS_PARTSIZE
echo "Building for ROOTFS_PARTSIZE: $ROOTFS_PARTSIZE"

if [ -z "$CUSTOM_PACKAGES" ]; then
  echo "⚪️ 未选择 任何第三方软件包"
else
  # 下载 run 文件仓库
  echo "🔄 正在同步第三方软件仓库 Cloning run file repo..."
  git clone --depth=1 https://github.com/wukongdaily/store.git /tmp/store-run-repo

  # 拷贝 run/arm64 下所有 run 文件和ipk文件 到 extra-packages 目录
  mkdir -p /home/build/immortalwrt/extra-packages
  cp -r /tmp/store-run-repo/run/arm64/* /home/build/immortalwrt/extra-packages/

  echo "✅ Run files copied to extra-packages:"
  ls -lh /home/build/immortalwrt/extra-packages/*.run
  # 解压并拷贝ipk到packages目录
  sh shell/prepare-packages.sh
  ls -lah /home/build/immortalwrt/packages/
  # 添加架构优先级信息
  sed -i '1i\
  arch aarch64_generic 10\n\
  arch aarch64_cortex-a53 15' repositories.conf
fi


# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始构建固件..."
echo "查看repositories.conf信息——————"
cat repositories.conf
# 定义所需安装的包列表 下列插件你都可以自行删减
PACKAGES=""

# 基础系统与驱动
PACKAGES="$PACKAGES base-files"
PACKAGES="$PACKAGES block-mount"
PACKAGES="$PACKAGES ca-bundle"
PACKAGES="$PACKAGES dnsmasq-full"
PACKAGES="$PACKAGES -dnsmasq"
PACKAGES="$PACKAGES dropbear"
PACKAGES="$PACKAGES fdisk"
PACKAGES="$PACKAGES firewall4"
PACKAGES="$PACKAGES fstools"
PACKAGES="$PACKAGES grub2-bios-setup"
PACKAGES="$PACKAGES i915-firmware-dmc"
PACKAGES="$PACKAGES kmod-8139cp"
PACKAGES="$PACKAGES kmod-8139too"
PACKAGES="$PACKAGES kmod-button-hotplug"
PACKAGES="$PACKAGES kmod-e1000e"
PACKAGES="$PACKAGES kmod-fs-f2fs"
PACKAGES="$PACKAGES kmod-i40e"
PACKAGES="$PACKAGES kmod-igb"
PACKAGES="$PACKAGES kmod-igbvf"
PACKAGES="$PACKAGES kmod-igc"
PACKAGES="$PACKAGES kmod-ixgbe"
PACKAGES="$PACKAGES kmod-ixgbevf"
PACKAGES="$PACKAGES kmod-nf-nathelper"
PACKAGES="$PACKAGES kmod-nf-nathelper-extra"
PACKAGES="$PACKAGES kmod-nft-offload"
PACKAGES="$PACKAGES kmod-pcnet32"
PACKAGES="$PACKAGES kmod-r8101"
PACKAGES="$PACKAGES kmod-r8125"
PACKAGES="$PACKAGES kmod-r8126"
PACKAGES="$PACKAGES kmod-r8168"
PACKAGES="$PACKAGES kmod-tulip"
PACKAGES="$PACKAGES kmod-usb-hid"
PACKAGES="$PACKAGES kmod-usb-net"
PACKAGES="$PACKAGES kmod-usb-net-asix"
PACKAGES="$PACKAGES kmod-usb-net-asix-ax88179"
PACKAGES="$PACKAGES kmod-vmxnet3"
PACKAGES="$PACKAGES libc"
PACKAGES="$PACKAGES libgcc"
PACKAGES="$PACKAGES libustream-openssl"
PACKAGES="$PACKAGES logd"
PACKAGES="$PACKAGES luci-app-package-manager"
PACKAGES="$PACKAGES luci-compat"
PACKAGES="$PACKAGES luci-lib-base"
PACKAGES="$PACKAGES luci-lib-ipkg"
PACKAGES="$PACKAGES luci-light"
PACKAGES="$PACKAGES mkf2fs"
PACKAGES="$PACKAGES mtd"
PACKAGES="$PACKAGES netifd"
PACKAGES="$PACKAGES nftables"
PACKAGES="$PACKAGES odhcp6c"
PACKAGES="$PACKAGES odhcpd-ipv6only"
PACKAGES="$PACKAGES opkg"
PACKAGES="$PACKAGES partx-utils"
PACKAGES="$PACKAGES ppp"
PACKAGES="$PACKAGES ppp-mod-pppoe"
PACKAGES="$PACKAGES procd-ujail"
PACKAGES="$PACKAGES uci"
PACKAGES="$PACKAGES uclient-fetch"
PACKAGES="$PACKAGES urandom-seed"
PACKAGES="$PACKAGES urngd"
PACKAGES="$PACKAGES kmod-amazon-ena"
PACKAGES="$PACKAGES kmod-amd-xgbe"
PACKAGES="$PACKAGES kmod-bnx2"
PACKAGES="$PACKAGES kmod-e1000"
PACKAGES="$PACKAGES kmod-dwmac-intel"
PACKAGES="$PACKAGES kmod-forcedeth"
PACKAGES="$PACKAGES kmod-fs-vfat"
PACKAGES="$PACKAGES kmod-tg3"
PACKAGES="$PACKAGES kmod-drm-i915"
PACKAGES="$PACKAGES nano"
PACKAGES="$PACKAGES -libustream-mbedtls"

#Arthur添加
PACKAGES="$PACKAGES alsa-utils"
PACKAGES="$PACKAGES busybox"
PACKAGES="$PACKAGES kmod-tg3"
PACKAGES="$PACKAGES kmod-r8169"
PACKAGES="$PACKAGES kmod-usb-core"
PACKAGES="$PACKAGES kmod-usb3"
PACKAGES="$PACKAGES kmod-phy-ax88796b"
PACKAGES="$PACKAGES kmod-phy-bcm84881"
PACKAGES="$PACKAGES kmod-phy-broadcom"
PACKAGES="$PACKAGES kmod-phy-realtek"
PACKAGES="$PACKAGES qemu-ga"
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES htop"
PACKAGES="$PACKAGES iperf3"
PACKAGES="$PACKAGES ethtool"
PACKAGES="$PACKAGES kmod-nft-tproxy"
PACKAGES="$PACKAGES kmod-nft-socket"
PACKAGES="$PACKAGES shadowsocksr-libev-ssr-redir"
PACKAGES="$PACKAGES bash"

# 固件构建必要
PACKAGES="$PACKAGES -libustream-mbedtls perlbase-time"

PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES openssh-sftp-server"
PACKAGES="$PACKAGES luci-i18n-diskman-zh-cn"
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
PACKAGES="$PACKAGES luci-theme-argon"
PACKAGES="$PACKAGES luci-app-argon-config"
PACKAGES="$PACKAGES luci-i18n-argon-config-zh-cn"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES luci-i18n-passwall-zh-cn"
PACKAGES="$PACKAGES luci-app-openclash"
PACKAGES="$PACKAGES luci-i18n-homeproxy-zh-cn"
# 判断是否需要编译 Docker 插件
if [ "$INCLUDE_DOCKER" = "yes" ]; then
    PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
    echo "Adding package: luci-i18n-dockerman-zh-cn"
fi
# 文件管理器
PACKAGES="$PACKAGES luci-i18n-filemanager-zh-cn"
# 静态文件服务器dufs(推荐)
PACKAGES="$PACKAGES luci-i18n-dufs-zh-cn"
# ======== shell/custom-packages.sh =======
# 合并imm仓库以外的第三方插件
PACKAGES="$PACKAGES $CUSTOM_PACKAGES"

# 构建镜像
echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"

# 若构建openclash 则添加内核
if echo "$PACKAGES" | grep -q "luci-app-openclash"; then
    echo "✅ 已选择 luci-app-openclash，添加 openclash core"
    mkdir -p files/etc/openclash/core
    # Download clash_meta
    META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz"
    wget -qO- $META_URL | tar xOvz > files/etc/openclash/core/clash_meta
    chmod +x files/etc/openclash/core/clash_meta
    # Download GeoIP and GeoSite
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -O files/etc/openclash/GeoIP.dat
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -O files/etc/openclash/GeoSite.dat
else
    echo "⚪️ 未选择 luci-app-openclash"
fi


make image PROFILE=$PROFILE PACKAGES="$PACKAGES" FILES="/home/build/immortalwrt/files" ROOTFS_PARTSIZE=$ROOTFS_PARTSIZE

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."
