#!/usr/bin/env python3
import os
import re
import codecs

def check_talent_icons():
    """Check all custom talent files for icons."""
    heroes_dir = r'C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs\scripts\npc\heroes'

    issues = []
    total_talents = 0

    for filename in os.listdir(heroes_dir):
        if not filename.endswith('.kv'):
            continue

        file_path = os.path.join(heroes_dir, filename)
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Find all talent definitions
        talent_pattern = r'"(special_bonus_unique_[^"]+)"\s*\{([^}]*)\}'

        for match in re.finditer(talent_pattern, content, re.DOTALL):
            talent_name = match.group(1)
            talent_block = match.group(2)
            total_talents += 1

            if 'AbilityTextureName' not in talent_block:
                issues.append(f"{filename}: {talent_name} - MISSING ICON")

    return issues, total_talents

def check_talent_files_lua():
    """Check all talent files for _lua suffixes."""
    talents_dir = r'C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs\scripts\npc\talents\heroes'

    issues = []

    for filename in os.listdir(talents_dir):
        if not filename.endswith('.txt'):
            continue

        file_path = os.path.join(talents_dir, filename)
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        lua_abilities = re.findall(r'"([a-z_]+_lua)"', content)
        if lua_abilities:
            for ability in lua_abilities:
                issues.append(f"{filename}: {ability}")

    return issues

def check_localizations():
    """Check custom talents have localizations."""
    TALENTS = [
        'special_bonus_unique_crystal_maiden_crystal_maiden_frozen_shield_shield_health',
        'special_bonus_unique_crystal_maiden_crystal_maiden_ice_spike_damage_frozen',
        'special_bonus_unique_dazzle_life_shield_health',
        'special_bonus_unique_dazzle_dispell_abilitycooldown',
        'special_bonus_unique_dazzle_grace_chance_shield',
        'special_bonus_unique_enigma_void_strike_damage',
        'special_bonus_unique_enigma_house_bolt_damage',
        'special_bonus_unique_enigma_house_bolt_damage_per_tick',
        'special_bonus_unique_enigma_void_strike_radius',
        'special_bonus_unique_enigma_house_bolt_crit_2x',
        'special_bonus_unique_axe_struck_damage',
        'special_bonus_unique_axe_charge_damage_debuff',
        'special_bonus_unique_axe_charge_reflect_damage',
        'special_bonus_unique_mirana_fire_arrow_damage',
        'special_bonus_unique_mirana_fire_arrow_damage_fire',
        'special_bonus_unique_lina_pyrablast',
        'special_bonus_unique_lina_fire_bomb_damage',
        'special_bonus_unique_lina_fire_shield_shield',
        'special_bonus_unique_lina_fiery_soul_crit',
        'special_bonus_unique_skeleton_king_curse_of_blood_amp_perid_damage',
        'special_bonus_unique_skeleton_king_hand_of_death_cooldown',
        'special_bonus_unique_skeleton_king_curse_of_cold_amp_slow_pct',
        'special_bonus_unique_skeleton_king_curse_of_blood_amp_pure_damage',
        'special_bonus_unique_skeleton_king_cursed_blast_chance_blast',
        'special_bonus_unique_skeleton_king_curse_of_blood_amp_perid_damage_count2',
        'special_bonus_unique_skeleton_king_deadman_field_amp_damage_in_field',
        'special_bonus_unique_skeleton_king_deadman_field_amp_reflect_spell_damage',
    ]

    english_path = r'C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs\resource\addon_english.txt'
    russian_path = r'C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs\resource\addon_russian.txt'

    def check_file(file_path):
        try:
            with codecs.open(file_path, 'r', encoding='utf-16-le') as f:
                content = f.read()
        except:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

        missing = []
        for talent in TALENTS:
            pattern1 = f'DOTA_Tooltip_ability_{talent}'
            pattern2 = f'DOTA_Tooltip_Ability_{talent}'
            if pattern1 not in content and pattern2 not in content:
                missing.append(talent)
        return missing

    en_missing = check_file(english_path)
    ru_missing = check_file(russian_path)

    return en_missing, ru_missing

def main():
    print("="*70)
    print("FINAL CHECK - Icons and Localizations")
    print("="*70 + "\n")

    # Check 1: Talent Icons
    print("1. Checking talent icons in hero files...")
    icon_issues, total = check_talent_icons()
    if icon_issues:
        print(f"   [!] Found {len(icon_issues)} talents without icons:")
        for issue in icon_issues:
            print(f"       {issue}")
    else:
        print(f"   [OK] All {total} custom talents have icons!")

    print()

    # Check 2: _lua suffixes
    print("2. Checking for _lua suffixes in talent files...")
    lua_issues = check_talent_files_lua()
    if lua_issues:
        print(f"   [!] Found {len(lua_issues)} abilities with _lua suffix:")
        for issue in lua_issues[:5]:
            print(f"       {issue}")
        if len(lua_issues) > 5:
            print(f"       ... and {len(lua_issues) - 5} more")
    else:
        print("   [OK] No _lua suffix issues found!")

    print()

    # Check 3: Localizations
    print("3. Checking custom talent localizations...")
    en_missing, ru_missing = check_localizations()

    print(f"   English: {27 - len(en_missing)}/27 talents have localization")
    if en_missing:
        print(f"   [!] Missing {len(en_missing)} English localizations")
        for t in en_missing[:3]:
            print(f"       {t[:50]}...")
    else:
        print("   [OK] All English localizations present!")

    print()
    print(f"   Russian: {27 - len(ru_missing)}/27 talents have localization")
    if ru_missing:
        print(f"   [!] Missing {len(ru_missing)} Russian localizations")
    else:
        print("   [OK] All Russian localizations present!")

    print()
    print("="*70)

    # Summary
    all_ok = (not icon_issues and not lua_issues and
              not en_missing and not ru_missing)

    if all_ok:
        print("SUCCESS! All checks passed!")
        print("- All custom talents have icons")
        print("- No _lua suffix issues")
        print("- All localizations present")
    else:
        print("SUMMARY:")
        if icon_issues:
            print(f"- {len(icon_issues)} talents missing icons")
        if lua_issues:
            print(f"- {len(lua_issues)} _lua suffix issues")
        if en_missing:
            print(f"- {len(en_missing)} missing English localizations")
        if ru_missing:
            print(f"- {len(ru_missing)} missing Russian localizations")

    print("="*70)

if __name__ == '__main__':
    main()
