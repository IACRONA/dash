#!/usr/bin/env python3
import codecs
import re

def identify_custom_vs_vanilla():
    file_path = r'C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs\resource\addon_english.txt'

    # Read file with UTF-16 encoding
    with codecs.open(file_path, 'r', encoding='utf-16-le') as f:
        lines = f.readlines()

    # Custom keywords that indicate custom content
    custom_keywords = [
        'enigma_void_strike', 'enigma_house_bolt', 'enigma_portal', 'enigma_eidalon',
        'crystal_maiden_frozen_shield', 'crystal_maiden_ice_spike',
        'axe_struck', 'axe_charge', 'axe_culling_blade_rage',
        'lina_pyrablast', 'lina_fire_bomb', 'lina_fire_shield',
        'mirana_fire_arrow',
        'dazzle_life_shield', 'dazzle_dispell', 'dazzle_grace',
        'cursed_knight', 'skeleton_king',
        'item_usual_book', 'item_rare_book', 'item_epic_book',
        'item_manta_custom', 'item_amphisbaena',
        'head_boss', 'boss_abilities'
    ]

    custom_lines = []
    vanilla_with_russian = []

    def has_cyrillic(text):
        return bool(re.search('[а-яА-ЯёЁ]', text))

    for i, line in enumerate(lines, 1):
        if has_cyrillic(line):
            match = re.search(r'"([^"]+)"\s+"([^"]+)"', line)
            if match:
                key = match.group(1)
                value = match.group(2)

                if has_cyrillic(value):
                    # Check if it's custom content
                    is_custom = any(keyword in key.lower() for keyword in custom_keywords)

                    if is_custom:
                        custom_lines.append({'line': i, 'key': key})
                    else:
                        vanilla_with_russian.append({'line': i, 'key': key})

    print("="*70)
    print("Analyzing Russian text in English localization...")
    print("="*70 + "\n")

    print(f"CUSTOM CONTENT (keep Russian): {len(custom_lines)} lines")
    print("These are custom abilities/items, can keep Russian for now:\n")
    for item in custom_lines[:10]:
        print(f"  Line {item['line']}: {item['key'][:60]}")
    if len(custom_lines) > 10:
        print(f"  ... and {len(custom_lines) - 10} more\n")

    print("\n" + "="*70 + "\n")

    print(f"VANILLA CONTENT (need English): {len(vanilla_with_russian)} lines")
    print("These should be copied from original Dota 2:\n")
    for item in vanilla_with_russian[:15]:
        print(f"  Line {item['line']}: {item['key'][:60]}")
    if len(vanilla_with_russian) > 15:
        print(f"  ... and {len(vanilla_with_russian) - 15} more\n")

    print("\n" + "="*70)
    print(f"Summary: {len(custom_lines)} custom, {len(vanilla_with_russian)} vanilla")
    print("="*70)

if __name__ == '__main__':
    identify_custom_vs_vanilla()
