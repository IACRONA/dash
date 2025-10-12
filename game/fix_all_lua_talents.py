#!/usr/bin/env python3
import os
import re

def fix_lua_suffixes(file_path):
    """Remove _lua suffix from ability names in talent file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find all _lua abilities
    original = content

    # Replace all ability names ending with _lua
    content = re.sub(r'"([a-z_]+)_lua"', r'"\1"', content)

    if content != original:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

def main():
    talents_dir = r'C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs\scripts\npc\talents\heroes'

    print("="*70)
    print("Fixing _lua suffixes in all hero talent files...")
    print("="*70 + "\n")

    fixed_files = []

    for filename in sorted(os.listdir(talents_dir)):
        if not filename.endswith('.txt'):
            continue

        file_path = os.path.join(talents_dir, filename)
        if fix_lua_suffixes(file_path):
            fixed_files.append(filename)
            print(f"[+] Fixed: {filename}")

    print("\n" + "="*70)
    print(f"Done! Fixed {len(fixed_files)} files")
    if fixed_files:
        print("\nFixed files:")
        for f in fixed_files:
            print(f"  - {f}")
    print("="*70)

if __name__ == '__main__':
    main()
