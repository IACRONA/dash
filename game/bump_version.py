#!/usr/bin/env python3
"""
Bump the version field in addoninfo.txt.

Usage:
    python bump_version.py            # bumps patch:  1.0.0 -> 1.0.1
    python bump_version.py patch      # same as default
    python bump_version.py minor      # 1.0.5 -> 1.1.0
    python bump_version.py major      # 1.2.3 -> 2.0.0
    python bump_version.py 2.5.1      # set to exact version
"""
import re
import sys
import os

ADDONINFO = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'addoninfo.txt')

def main():
    arg = sys.argv[1] if len(sys.argv) > 1 else 'patch'

    with open(ADDONINFO, 'r', encoding='utf-8') as f:
        content = f.read()

    m = re.search(r'version\s*=\s*"(\d+)\.(\d+)\.(\d+)"', content)
    if not m:
        print('No version field found in addoninfo.txt. Add: version = "1.0.0"')
        sys.exit(1)

    major, minor, patch = int(m.group(1)), int(m.group(2)), int(m.group(3))
    old = f'{major}.{minor}.{patch}'

    if re.fullmatch(r'\d+\.\d+\.\d+', arg):
        new = arg
    elif arg == 'major':
        new = f'{major + 1}.0.0'
    elif arg == 'minor':
        new = f'{major}.{minor + 1}.0'
    elif arg == 'patch':
        new = f'{major}.{minor}.{patch + 1}'
    else:
        print(f'Unknown arg: {arg}. Use major/minor/patch or X.Y.Z')
        sys.exit(1)

    new_content = re.sub(
        r'(version\s*=\s*")\d+\.\d+\.\d+(")',
        rf'\g<1>{new}\g<2>',
        content,
        count=1,
    )

    with open(ADDONINFO, 'w', encoding='utf-8') as f:
        f.write(new_content)

    print(f'Version bumped: {old} -> {new}')

if __name__ == '__main__':
    main()
