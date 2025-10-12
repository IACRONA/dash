#!/usr/bin/env python3
import os
import re

# Define hero files and their talent-to-ability mappings
TALENT_MAPPINGS = {
    'axe_abilities.kv': {
        'special_bonus_unique_axe_struck_damage': 'axe/axe_struck',
        'special_bonus_unique_axe_charge_damage_debuff': 'axe/axe_charge',
        'special_bonus_unique_axe_charge_reflect_damage': 'axe/axe_charge',
    },
    'crystal_maiden_abilities.kv': {
        'special_bonus_unique_crystal_maiden_crystal_maiden_frozen_shield_shield_health': 'crystal_maiden/frozen_shield',
        'special_bonus_unique_crystal_maiden_crystal_maiden_ice_spike_damage_frozen': 'crystal_maiden/ice_spike',
    },
    'dazzle_abilities.kv': {
        'special_bonus_unique_dazzle_life_shield_health': 'dazzle/dazzle_life_shield',
        'special_bonus_unique_dazzle_dispell_abilitycooldown': 'dazzle/dazzle_dispell',
        'special_bonus_unique_dazzle_grace_chance_shield': 'dazzle/dazzle_grace',
    },
    'enigma_abilities.kv': {
        'special_bonus_unique_enigma_void_strike_damage': 'enigma/enigma_void_strike',
        'special_bonus_unique_enigma_house_bolt_damage': 'enigma/enigma_house_bolt',
        'special_bonus_unique_enigma_house_bolt_damage_per_tick': 'enigma/enigma_house_bolt',
        'special_bonus_unique_enigma_void_strike_radius': 'enigma/enigma_void_strike',
        'special_bonus_unique_enigma_house_bolt_crit_2x': 'enigma/enigma_house_bolt',
    },
    'lina_abilities.kv': {
        'special_bonus_unique_lina_pyrablast': 'lina/lina_pyrablast',
        'special_bonus_unique_lina_fire_shield_shield': 'lina/lina_fire_shield',
        'special_bonus_unique_lina_fire_bomb_damage': 'lina/lina_fire_bomb',
        'special_bonus_unique_lina_fiery_soul_crit': 'lina_fiery_soul',
    },
    'mirana_abilities.kv': {
        'special_bonus_unique_mirana_fire_arrow_damage': 'mirana/fire_arrow',
        'special_bonus_unique_mirana_fire_arrow_damage_fire': 'mirana/fire_arrow',
    },
}

def add_ability_texture_to_talent(file_path, talent_name, texture_name):
    """Add AbilityTextureName to a talent definition if it doesn't exist."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the talent definition
    # Pattern: "talent_name"\n{\n ... }
    pattern = rf'("{talent_name}"\s*\{{[^}}]*)\}}'

    match = re.search(pattern, content, re.DOTALL)
    if not match:
        print(f"  [!] Talent {talent_name} not found in file")
        return False

    talent_block = match.group(1)

    # Check if AbilityTextureName already exists
    if 'AbilityTextureName' in talent_block:
        print(f"  [OK] Talent {talent_name} already has AbilityTextureName")
        return False

    # Find the position to insert (after AbilityBehavior)
    insert_pattern = r'(AbilityBehavior"\s+"DOTA_ABILITY_BEHAVIOR_PASSIVE")'
    insert_match = re.search(insert_pattern, talent_block)

    if not insert_match:
        print(f"  [!] Could not find insertion point for {talent_name}")
        return False

    # Build the new talent block with AbilityTextureName
    new_talent_block = talent_block[:insert_match.end()] + f'\n\t\t"AbilityTextureName"\t\t\t"{texture_name}"' + talent_block[insert_match.end():]
    new_talent_block += '}'

    # Replace in content
    new_content = content.replace(match.group(0), new_talent_block)

    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

    print(f"  [+] Added AbilityTextureName '{texture_name}' to {talent_name}")
    return True

def main():
    heroes_dir = r'C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs\scripts\npc\heroes'

    total_fixed = 0

    for filename, talents in TALENT_MAPPINGS.items():
        file_path = os.path.join(heroes_dir, filename)

        if not os.path.exists(file_path):
            print(f"[X] File not found: {filename}")
            continue

        print(f"\nProcessing {filename}...")

        for talent_name, texture_name in talents.items():
            if add_ability_texture_to_talent(file_path, talent_name, texture_name):
                total_fixed += 1

    print(f"\n" + "="*50)
    print(f"Done! Fixed {total_fixed} talents")
    print("="*50)

if __name__ == '__main__':
    main()
