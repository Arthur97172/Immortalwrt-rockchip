#!/bin/bash
# ImmortalWrt 25.12.x Rockchip 构建脚本 (APK 格式 - GitHub Actions)
# 运行于 imagebuilder 目录内
# 注意：第三方插件同步已在 workflow 中完成，勿重复执行

PROFILE=${PROFILE:-"friendlyarm_nanopi-r3s"}
ROOTFS_PARTSIZE=${ROOTFS_PARTSIZE:-"1024"}
INCLUDE_DOCKER=${INCLUDE_DOCKER:-"no"}

echo "Target Profile: $PROFILE"
echo "Rootfs Size: $ROOTFS_PARTSIZE"

#查询是否包含第三方软件包
if [ -z "$CUSTOM_PACKAGES" ]; then
  echo "⚪️ 未选择 任何第三方软件包"
else
  # ============= 同步第三方插件库==============
  # 同步第三方软件仓库run/ipk
  echo "🔄 正在同步第三方软件仓库 Cloning run file repo..."
  # 增加超时和重试机制
  rm -rf /tmp/store-run-repo 2>/dev/null
  if ! git clone --depth=1 https://github.com/Arthur97172/OpenWrt-App.git /tmp/store-run-repo; then
      echo "❌ git clone 失败！请检查网络或仓库是否可用"
      exit 1
  fi

  # === 验证克隆结果 ===
  echo "✅ git clone 完成，开始验证..."
  if [ ! -d "/tmp/store-run-repo" ]; then
      echo "❌ 仓库目录不存在，克隆失败"
      exit 1
  fi

  echo "📁 仓库目录结构："
  ls -la /tmp/store-run-repo/

  # 拷贝 arm64 下所有 apk 文件到 extra-packages 目录
  mkdir -p extra-packages
  cp -r /tmp/store-run-repo/ipk/{aarch64_generic,aarch64_cortex-a53}/* extra-packages/ 2>/dev/null || true

  echo "✅ Run files copied to extra-packages:"
  ls -lh extra-packages/*.run
  # 解压并拷贝ipk到packages目录
  sh prepare-packages.sh
  echo "打印imagebuilder/packages目录结构"
  ls -lah packages/ |grep partexp
  # 添加架构优先级信息
  sed -i '1i\
  arch aarch64_generic 10\n\
  arch aarch64_cortex-a53 15' repositories
fi

# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始构建固件..."
echo "查看repositories.conf信息——————"
cat repositories

echo "Building for profile: $PROFILE"
echo "Building for ROOTFS_PARTSIZE: $ROOTFS_PARTSIZE"

# 复制 25.12.x 自定义源配置到固件 files 目录
if [ -f "files/customfeeds/25.customfeeds.conf" ]; then
    mkdir -p files/etc/apk
    cp files/customfeeds/25.customfeeds.conf files/etc/apk/customfeeds.conf
    echo "✅ 已复制 25.customfeeds.conf 到固件"
else
    echo "⚪️ 未找到 25.customfeeds.conf，跳过"
fi

# 定义所需安装的包列表
PACKAGES=""

# [核心系统 - 不含 libc/libgcc，由 base 系统提供]
PACKAGES="base-files uci ubus dropbear logd mtd bash htop curl wget ca-bundle ca-certificates"
PACKAGES="$PACKAGES dnsmasq-full firewall4 nftables kmod-nft-offload"
PACKAGES="$PACKAGES ip-full ipset iw ppp ppp-mod-pppoe wpad-openssl"
PACKAGES="$PACKAGES kmod-xdp-sockets-diag"

# [硬件驱动]
PACKAGES="$PACKAGES -kmod-ath10k-sdio kmod-ath10k"
PACKAGES="$PACKAGES kmod-ata-ahci kmod-ata-ahci-dwc kmod-mmc kmod-r8125 kmod-r8168 kmod-r8169 r8169-firmware"

# [磁盘与文件系统]
PACKAGES="$PACKAGES block-mount fdisk lsblk blkid parted resize2fs smartmontools"
PACKAGES="$PACKAGES kmod-fs-ext4 kmod-fs-vfat kmod-fs-ntfs3 kmod-fs-exfat kmod-fs-btrfs kmod-fs-f2fs"
PACKAGES="$PACKAGES kmod-usb-storage kmod-usb-storage-uas kmod-usb2 kmod-usb3"

# [USB 网卡驱动]
PACKAGES="$PACKAGES kmod-usb-net kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 r8152-firmware"
PACKAGES="$PACKAGES kmod-usb-net-asix-ax88179 kmod-usb-net-aqc111"
PACKAGES="$PACKAGES kmod-usb-net-cdc-ether kmod-usb-net-cdc-ncm kmod-usb-net-cdc-mbim"

# [无线驱动]
PACKAGES="$PACKAGES kmod-brcmfmac kmod-brcmsmac"
PACKAGES="$PACKAGES brcmfmac-firmware-usb brcmfmac-firmware-43430-sdio brcmfmac-firmware-43455-sdio"
PACKAGES="$PACKAGES kmod-usb-ohci kmod-usb-ohci-pci kmod-usb-core kmod-usb2-pci usbutils"
PACKAGES="$PACKAGES kmod-mac80211"
PACKAGES="$PACKAGES kmod-mt7921-common kmod-mt7921-firmware kmod-mt7921e kmod-mt7921u"
PACKAGES="$PACKAGES kmod-mt7922-firmware kmod-mt7925-common kmod-mt7925-firmware kmod-mt7925e kmod-mt7925u"
PACKAGES="$PACKAGES kmod-mt792x-common kmod-mt792x-usb"
PACKAGES="$PACKAGES kmod-mt7992-23-firmware kmod-mt7992-firmware"
PACKAGES="$PACKAGES kmod-mt7996-233-firmware kmod-mt7996-firmware kmod-mt7996-firmware-common kmod-mt7996e kmod-mtk-t7xx"

# [Web 界面]
PACKAGES="$PACKAGES luci luci-base luci-i18n-base-zh-cn luci-mod-admin-full luci-theme-argon"
PACKAGES="$PACKAGES luci-app-argon-config luci-i18n-argon-config-zh-cn"
PACKAGES="$PACKAGES luci-app-cpufreq luci-i18n-cpufreq-zh-cn"
PACKAGES="$PACKAGES luci-app-ttyd luci-i18n-ttyd-zh-cn"

# [功能插件]
PACKAGES="$PACKAGES luci-app-samba4 luci-i18n-samba4-zh-cn"
PACKAGES="$PACKAGES luci-app-upnp luci-i18n-upnp-zh-cn"
PACKAGES="$PACKAGES luci-app-wol luci-i18n-wol-zh-cn"
PACKAGES="$PACKAGES luci-app-ddns luci-i18n-ddns-zh-cn"
PACKAGES="$PACKAGES luci-app-passwall luci-i18n-passwall-zh-cn"
PACKAGES="$PACKAGES luci-app-package-manager luci-i18n-package-manager-zh-cn"

# 只将第三方插件纳入 PACKAGES 列表（核心包来自 ImageBuilder 捆绑包）
PACKAGES="$CUSTOM_PACKAGES"

# Docker 插件
if [ "$INCLUDE_DOCKER" = "yes" ]; then
    echo "🐳 Docker enabled, adding docker packages"
    PACKAGES="$PACKAGES docker docker-compose luci-app-dockerman luci-i18n-dockerman-zh-cn"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"

# 执行构建（imagebuilder 目录下运行，FILES 使用当前目录下的 files 子目录）
make image PROFILE="$PROFILE" PACKAGES="$PACKAGES" FILES="files" ROOTFS_PARTSIZE="$ROOTFS_PARTSIZE"

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."
