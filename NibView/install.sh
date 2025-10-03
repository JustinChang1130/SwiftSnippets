#!/bin/bash

set -e

TEMPLATE_DIR="$HOME/Library/Developer/Xcode/Templates/NibView/NibView.xctemplate"

echo "🚀 安裝 NibView + XIB 模板..."

# 建立目錄
mkdir -p "$TEMPLATE_DIR"

# 複製檔案
cp "$(dirname "$0")/TemplateInfo.plist" "$TEMPLATE_DIR/"
cp "$(dirname "$0")/___FILEBASENAME___.swift" "$TEMPLATE_DIR/"
cp "$(dirname "$0")/___FILEBASENAME___.xib" "$TEMPLATE_DIR/"

echo "✅ 安裝完成！"
echo "📌 請重新啟動 Xcode，並在 File > New > File... → User Templates 中找到 'NibView + XIB'"

