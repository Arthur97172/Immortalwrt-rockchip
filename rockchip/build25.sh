#!/bin/bash
# ImmortalWrt 25.12.x Rockchip 构建脚本 (APK 格式 - GitHub Actions)
# 运行于 imagebuilder 目录内
# 注意：第三方插件同步已在 workflow 中完成，勿重复执行

PROFILE=${PROFILE:-"friendlyarm_nanopi-r3s"}
ROOTFS_PARTSIZE=${ROOTFS_PARTSIZE:-"1024"}
INCLUDE_DOCKER=${INCLUDE_DOCKER:-"no"}

echo "Target Profile: $PROFILE"
echo "Rootfs Size: $ROOTFS_PARTSIZE"

# 加载第三方插件配置
source apk-custom-packages.sh
echo "第三方软件包: $CUSTOM_PACKAGES"

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

# 只将第三方插件纳入 PACKAGES 列表（核心包来自 ImageBuilder 捆绑包）
PACKAGES="$CUSTOM_PACKAGES"

# Docker 插件
if [ "$INCLUDE_DOCKER" = "yes" ]; then
    echo "🐳 Docker enabled, adding docker packages"
    PACKAGES="$PACKAGES docker docker-compose luci-app-dockerman luci-i18n-dockerman-zh-cn"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"

# 若构建 openclash 则下载 core
if echo "$PACKAGES" | grep -q "luci-app-openclash"; then
    echo "✅ 已选择 luci-app-openclash，添加 openclash core"
    mkdir -p files/etc/openclash/core
    META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz"
    wget -qO- $META_URL | tar xOvz > files/etc/openclash/core/clash_meta
    chmod +x files/etc/openclash/core/clash_meta
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -O files/etc/openclash/GeoIP.dat
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -O files/etc/openclash/GeoSite.dat
else
    echo "⚪️ 未选择 luci-app-openclash"
fi

# 执行构建（imagebuilder 目录下运行，FILES 使用当前目录下的 files 子目录）
make image PROFILE="$PROFILE" PACKAGES="$PACKAGES" FILES="files" ROOTFS_PARTSIZE="$ROOTFS_PARTSIZE"

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."