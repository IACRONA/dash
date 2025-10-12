#!/usr/bin/env python3
import re

# List of all talents from npc_heroes_custom.txt
TALENTS = [
    # Crystal Maiden
    'special_bonus_unique_crystal_maiden_crystal_maiden_frozen_shield_shield_health',
    'special_bonus_unique_crystal_maiden_crystal_maiden_ice_spike_damage_frozen',
    # Dazzle
    'special_bonus_unique_dazzle_life_shield_health',
    'special_bonus_unique_dazzle_dispell_abilitycooldown',
    'special_bonus_unique_dazzle_grace_chance_shield',
    # Enigma
    'special_bonus_unique_enigma_void_strike_damage',
    'special_bonus_unique_enigma_house_bolt_damage',
    'special_bonus_unique_enigma_house_bolt_damage_per_tick',
    'special_bonus_unique_enigma_void_strike_radius',
    'special_bonus_unique_enigma_house_bolt_crit_2x',
    # Axe
    'special_bonus_unique_axe_struck_damage',
    'special_bonus_unique_axe_charge_damage_debuff',
    'special_bonus_unique_axe_charge_reflect_damage',
    # Mirana
    'special_bonus_unique_mirana_fire_arrow_damage',
    'special_bonus_unique_mirana_fire_arrow_damage_fire',
    # Lina
    'special_bonus_unique_lina_pyrablast',
    'special_bonus_unique_lina_fire_bomb_damage',
    'special_bonus_unique_lina_fire_shield_shield',
    'special_bonus_unique_lina_fiery_soul_crit',
    # Skeleton King
    'special_bonus_unique_skeleton_king_curse_of_blood_amp_perid_damage',
    'special_bonus_unique_skeleton_king_hand_of_death_cooldown',
    'special_bonus_unique_skeleton_king_curse_of_cold_amp_slow_pct',
    'special_bonus_unique_skeleton_king_curse_of_blood_amp_pure_damage',
    'special_bonus_unique_skeleton_king_cursed_blast_chance_blast',
    'special_bonus_unique_skeleton_king_curse_of_blood_amp_perid_damage_count2',
    'special_bonus_unique_skeleton_king_deadman_field_amp_damage_in_field',
    'special_bonus_unique_skeleton_king_deadman_field_amp_reflect_spell_damage',
]

def check_localization(file_path, language):
    """Check which talents are missing in localization file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        with open(file_path, 'r', encoding='utf-16') as f:
            content = f.read()

    missing = []
    found = []

    for talent in TALENTS:
        # Look for DOTA_Tooltip_ability_{talent} or DOTA_Tooltip_Ability_{talent}
        pattern1 = f'DOTA_Tooltip_ability_{talent}'
        pattern2 = f'DOTA_Tooltip_Ability_{talent}'
        if pattern1 in content or pattern2 in content:
            found.append(talent)
        else:
            missing.append(talent)

    return found, missing

def main():
    english_path = r'C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs\resource\addon_english.txt'
    russian_path = r'C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs\resource\addon_russian.txt'

    print("="*70)
    print("Checking talent localizations...")
    print("="*70 + "\n")

    print("ENGLISH LOCALIZATION:")
    print("-" * 70)
    en_found, en_missing = check_localization(english_path, 'english')
    print(f"Found: {len(en_found)}/{len(TALENTS)}")
    if en_missing:
        print("\nMissing:")
        for talent in en_missing:
            print(f"  [X] {talent}")
    else:
        print("  All talents have English localization!")

    print("\n" + "="*70 + "\n")

    print("RUSSIAN LOCALIZATION:")
    print("-" * 70)
    ru_found, ru_missing = check_localization(russian_path, 'russian')
    print(f"Found: {len(ru_found)}/{len(TALENTS)}")
    if ru_missing:
        print("\nMissing:")
        for talent in ru_missing:
            print(f"  [X] {talent}")
    else:
        print("  All talents have Russian localization!")

    print("\n" + "="*70)
    print(f"SUMMARY: EN={len(en_found)}/{len(TALENTS)}, RU={len(ru_found)}/{len(TALENTS)}")
    print("="*70)

if __name__ == '__main__':
    main()
