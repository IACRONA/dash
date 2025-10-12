#!/usr/bin/env python3
import codecs

def fix_shadow_shaman_localization():
    file_path = r'C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs\resource\addon_english.txt'

    # Read file with UTF-16 encoding
    with codecs.open(file_path, 'r', encoding='utf-16-le') as f:
        content = f.read()

    # Fix Shadow Shaman localization
    replacements = {
        '"ДОП. УРОН:"': '"BONUS DAMAGE:"',
        '"КОЛИЧЕСТВО ТОТЕМОВ"': '"WARD COUNT"',
        '"РАДИУС"': '"RADIUS"',
    }

    changes = 0
    for old_text, new_text in replacements.items():
        if old_text in content:
            content = content.replace(old_text, new_text)
            changes += 1
            print(f"[+] Fixed Shadow Shaman localization")

    # Write back
    with codecs.open(file_path, 'w', encoding='utf-16-le') as f:
        f.write(content)

    print(f"\n{'='*50}")
    print(f"Done! Made {changes} replacements")
    print(f"{'='*50}")

if __name__ == '__main__':
    fix_shadow_shaman_localization()
