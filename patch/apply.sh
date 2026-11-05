#!/bin/sh
# Opunai 前端 patch —— 在 new-api 侧边栏加「贡献上游 Key」
# 用法: sh apply.sh <web目录>
set -e

WEB="$1"
if [ -z "$WEB" ]; then
  echo "usage: apply.sh <path-to-web-dir>"
  exit 1
fi

TARGET="$WEB/src/hooks/use-sidebar-data.ts"
if [ ! -f "$TARGET" ]; then
  echo "FATAL: not found: $TARGET"
  exit 1
fi

echo "=== patching $TARGET ==="

python3 - "$TARGET" << 'PYEOF'
import io, sys, re

p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()

# 1. 加 Upload 图标到 import（如果没有）
if 'Upload,' not in s:
    s = s.replace(
        "  Ticket,\n",
        "  Ticket,\n  Upload,\n",
        1,
    )
    print('  + Upload icon')

# 2. 在 API Keys 之后插入「贡献上游 Key」
key_item = """          {
            title: t('API Keys'),
            url: '/keys',
            icon: Key,
          },"""

contrib_item = """          {
            title: t('API Keys'),
            url: '/keys',
            icon: Key,
          },
          {
            title: t('贡献上游 Key'),
            url: '/contribute',
            icon: Upload,
          },"""

if "/contribute" in s:
    print('  = contribute already present')
elif key_item in s:
    s = s.replace(key_item, contrib_item, 1)
    print('  + contribute nav item')
else:
    print('  ! API Keys item not matched, abort item insert')

io.open(p, 'w', encoding='utf-8').write(s)
PYEOF

echo "=== verify ==="
grep -n "contribute" "$TARGET" || echo "NOT_INSERTED"
echo "=== done ==="