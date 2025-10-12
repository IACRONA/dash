#!/usr/bin/env python3
import codecs

# Define replacements: old Russian text -> new English text
REPLACEMENTS = {
    # Mirana talents
    '"+{s:bonus_damage} урона от Fire arrow"': '"+{s:bonus_damage} damage to Fire Arrow"',
    '"+{s:bonus_damage_fire} урона от огня Fire arrow"': '"+{s:bonus_damage_fire} burn damage per second from Fire Arrow"',

    # Lina talents
    '"+{s:bonus_damage} к урону Pyrablast"': '"+{s:bonus_damage} damage to Pyrablast"',
    '"+{s:bonus_damage} к урону Fire Bomb"': '"+{s:bonus_damage} damage to Fire Bomb"',
    '"+{s:bonus_shield} к здоровью щита Fire Shield"': '"+{s:bonus_shield} to Fire Shield health"',
    '"+{s:bonus_bonus_crit}% к шансу крита Fiery Soul"': '"+{s:bonus_bonus_crit}% crit chance from Fiery Soul"',
}

def fix_english_localization():
    file_path = r'C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs\resource\addon_english.txt'

    # Read file with UTF-16 encoding
    with codecs.open(file_path, 'r', encoding='utf-16-le') as f:
        content = f.read()

    # Perform replacements
    changes = 0
    for old_text, new_text in REPLACEMENTS.items():
        if old_text in content:
            content = content.replace(old_text, new_text)
            changes += 1
            print(f"[+] Replaced line {changes}")

    # Write back
    with codecs.open(file_path, 'w', encoding='utf-16-le') as f:
        f.write(content)

    print(f"\n{'='*50}")
    print(f"Done! Made {changes} replacements")
    print(f"{'='*50}")

if __name__ == '__main__':
    fix_english_localization()
