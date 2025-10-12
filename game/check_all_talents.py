#!/usr/bin/env python3
import os
import re

def check_talent_file(file_path):
    """Check a talent file for potential issues."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    issues = []

    # Check for _lua suffix in ability names
    lua_abilities = re.findall(r'"([a-z_]+_lua)"', content)
    if lua_abilities:
        for ability in lua_abilities:
            issues.append(f"Ability with _lua suffix: {ability}")

    return issues

def main():
    talents_dir = r'C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs\scripts\npc\talents\heroes'

    print("="*70)
    print("Checking ALL hero talent files for issues...")
    print("="*70 + "\n")

    heroes_with_issues = []
    total_issues = 0

    for filename in sorted(os.listdir(talents_dir)):
        if not filename.endswith('.txt'):
            continue

        file_path = os.path.join(talents_dir, filename)
        issues = check_talent_file(file_path)

        if issues:
            heroes_with_issues.append({
                'name': filename,
                'issues': issues
            })
            total_issues += len(issues)

            print(f"FILE: {filename}")
            for issue in issues:
                print(f"   [!] {issue}")
            print()

    print("="*70)
    if heroes_with_issues:
        print(f"Found {total_issues} issues in {len(heroes_with_issues)} hero files")
        print("\nHeroes with issues:")
        for hero in heroes_with_issues:
            print(f"  - {hero['name']}: {len(hero['issues'])} issues")
    else:
        print("All hero talent files are OK!")
    print("="*70)

if __name__ == '__main__':
    main()
