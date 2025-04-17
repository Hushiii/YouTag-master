#!/bin/bash

# 项目根目录（可手动设置或使用当前目录）
ROOT_DIR=$(pwd)

# 你想替换成的新作者信息
NEW_AUTHOR="Created by Smartphone Group9 on 2025."
NEW_COPYRIGHT=""

# 替换所有 swift 文件头部的 Created by 信息
find "$ROOT_DIR" -name "*.swift" -exec sed -i '' \
  "s|^//  Created by .* on .*|//  $NEW_AUTHOR|g" {} +

# 替换所有 swift 文件头部的 Copyright 信息
find "$ROOT_DIR" -name "*.swift" -exec sed -i '' \
  "s|^//  Copyright © [0-9]\{4\} .*|//  $NEW_COPYRIGHT|g" {} +

echo "✅ 所有文件头部信息已更新为："
echo "   $NEW_AUTHOR"
echo "   $NEW_COPYRIGHT"
