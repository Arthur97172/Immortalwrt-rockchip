#!/bin/sh

# 在 Docker 容器内运行，使用绝对路径
IB_ROOT="/home/build/immortalwrt"
BASE_DIR="$IB_ROOT/extra-packages"
TEMP_DIR="$BASE_DIR/temp-unpack"
TARGET_DIR="$IB_ROOT/packages"

# 清理目录并重建
rm -rf "$TEMP_DIR"
rm -rf "$TARGET_DIR"/*

# 解压 .run 文件
for run_file in "$BASE_DIR"/*.run; do
    [ -e "$run_file" ] || continue
    echo "🧩 解压 $run_file -> $TEMP_DIR"
    sh "$run_file" --target "$TEMP_DIR" --noexec
done

# 收集 run 解压出的 .ipk 文件
find "$TEMP_DIR" -type f -name "*.ipk" -exec cp -v {} "$TARGET_DIR"/ \;

# 收集 extra-packages/*/ 下的 .ipk 文件
find "$BASE_DIR" -mindepth 2 -maxdepth 2 -type f -name "*.ipk" ! -path "$TEMP_DIR/*" \
  -exec echo "👉 Found ipk:" {} \; \
  -exec cp -v {} "$TARGET_DIR"/ \;

# 收集 .apk 文件（25.12.x APK 格式）
find "$TEMP_DIR" -type f -name "*.apk" -exec cp -v {} "$TARGET_DIR"/ \;
find "$BASE_DIR" -mindepth 2 -maxdepth 2 -type f -name "*.apk" ! -path "$TEMP_DIR/*" \
  -exec echo "👉 Found apk:" {} \; \
  -exec cp -v {} "$TARGET_DIR"/ \;

echo "✅ 所有安装包已整理至 $TARGET_DIR/"
ls -lah "$TARGET_DIR/"