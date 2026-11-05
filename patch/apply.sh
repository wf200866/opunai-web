#!/bin/sh
# Opunai 前端 patch —— 在 new-api 侧边栏加「贡献上游 Key」
set -e

# 自动找 web 目录
if [ -d "$1/src/hooks" ]; then
  WEB="$1"                    # 传进来的是 web 目录
elif [ -d "$1/web/src/hooks" ]; then
  WEB="$1/web"                # 传进来的是仓库根
elif [ -d "/home/runner/work/opunai-web/opunai-web/src/web/src/hooks" ]; then
  WEB="/home/runner/work/opunai-web/opunai-web/src/web"
else
  echo "FATAL: cannot locate web dir (arg=$1)"
  ls -la "$1" 2>/dev/null | head
  exit 1
fi

TARGET="$WEB/src/hooks/use-sidebar-data.ts"
echo "=== target: $TARGET ==="
test -f "$TARGET" || { echo "FATAL: no use-sidebar-data.ts"; exit 1; }

python3 - "$TARGET" << 'PYEOF_INNER'
import io, sys

p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()

if 'Upload,' not in s:
    s = s.replace("  Ticket,\n", "  Ticket,\n  Upload,\n", 1)
    print('  + Upload icon')

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
            title: t('\u8d21\u732e\u4e0a\u6e38 Key'),
            url: '/contribute',
            icon: Upload,
          },"""

if '/contribute' in s:
    print('  = already present')
elif key_item in s:
    s = s.replace(key_item, contrib_item, 1)
    print('  + contribute item')
else:
    print('  ! API Keys anchor not found')

io.open(p, 'w', encoding='utf-8').write(s)
PYEOF_INNER

echo "=== verify ==="
grep -n 'contribute' "$TARGET" || echo NOT_INSERTED
echo "=== done ==="
