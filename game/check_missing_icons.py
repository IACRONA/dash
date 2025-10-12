#!/usr/bin/env python3
import os
import re

def check_talent_icons(file_path):
    """Check which talents are missing AbilityTextureName."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find all talent definitions (special_bonus_unique_*)
    talent_pattern = r'"(special_bonus_unique_[^"]+)"\s*\{([^}]*)\}'

    talents_found = []
    for match in re.finditer(talent_pattern, content, re.DOTALL):
        talent_name = match.group(1)
        talent_block = match.group(2)

        has_texture = 'AbilityTextureName' in talent_block
        talents_found.append({
            'name': talent_name,
            'has_texture': has_texture
        })

    return talents_found

def main():
    heroes_dir = r'C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs\scripts\npc\heroes'

    print("="*70)
    print("Checking for talents missing AbilityTextureName...")
    print("="*70 + "\n")

    total_talents = 0
    total_missing = 0

    # Get all .kv files in heroes directory
    for filename in os.listdir(heroes_dir):
        if not filename.endswith('.kv'):
            continue

        file_path = os.path.join(heroes_dir, filename)
        talents = check_talent_icons(file_path)

        if not talents:
            continue

        print(f"FILE: {filename}")

        file_missing = 0
        for talent in talents:
            total_talents += 1
            if not talent['has_texture']:
                print(f"   [X] {talent['name']} - MISSING ICON")
                file_missing += 1
                total_missing += 1
            else:
                print(f"   [OK] {talent['name']} - has icon")

        print(f"   -> {file_missing}/{len(talents)} missing\n")

    print("="*70)
    print(f"Summary: {total_missing}/{total_talents} talents missing icons")
    print("="*70)

if __name__ == '__main__':
    main()
