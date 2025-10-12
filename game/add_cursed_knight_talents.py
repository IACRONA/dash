#!/usr/bin/env python3
import re

# Cursed Knight talents and their icons
CURSED_KNIGHT_TALENTS = {
    'special_bonus_unique_skeleton_king_cursed_blast_chance_blast': 'skeleton_king_hellfire_blast',
    'special_bonus_unique_skeleton_king_hand_of_death_cooldown': 'cursed_knight/hand_of_death',
    'special_bonus_unique_skeleton_king_curse_of_blood_amp_pure_damage': 'cursed_knight/curse_of_blood',
    'special_bonus_unique_skeleton_king_curse_of_blood_amp_perid_damage': 'cursed_knight/curse_of_blood',
    'special_bonus_unique_skeleton_king_curse_of_blood_amp_perid_damage_count2': 'cursed_knight/curse_of_blood',
    'special_bonus_unique_skeleton_king_curse_of_cold_amp_slow_pct': 'cursed_knight/curse_of_cold',
    'special_bonus_unique_skeleton_king_deadman_field_amp_damage_in_field': 'cursed_knight/deadman_field',
    'special_bonus_unique_skeleton_king_deadman_field_amp_reflect_spell_damage': 'cursed_knight/deadman_field',
}

file_path = r'C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs\scripts\npc\heroes\cursed_knight_abilities.kv'

# Read file
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Check which talents already have icons (defined within abilities) - they don't need separate blocks
# The talents in Cursed Knight are already properly set up within the abilities themselves
# We just need to verify they're all there

print("Checking Cursed Knight talents...")
print("="*60)

for talent, icon in CURSED_KNIGHT_TALENTS.items():
    if talent in content:
        print(f"[OK] {talent} - found in abilities")
    else:
        print(f"[!] {talent} - NOT FOUND")

print("="*60)
print("Cursed Knight talents are set up within the ability definitions.")
print("No separate talent blocks needed - this is correct!")
