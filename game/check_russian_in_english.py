#!/usr/bin/env python3
import codecs
import re

def has_cyrillic(text):
    """Check if text contains Cyrillic characters."""
    return bool(re.search('[а-яА-ЯёЁ]', text))

def check_english_localization():
    file_path = r'C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dotawarsongs\resource\addon_english.txt'

    # Read file with UTF-16 encoding
    with codecs.open(file_path, 'r', encoding='utf-16-le') as f:
        lines = f.readlines()

    russian_lines = []

    for i, line in enumerate(lines, 1):
        if has_cyrillic(line):
            # Extract the key and value
            match = re.search(r'"([^"]+)"\s+"([^"]+)"', line)
            if match:
                key = match.group(1)
                value = match.group(2)
                if has_cyrillic(value):
                    russian_lines.append({
                        'line': i,
                        'key': key,
                        'value': value
                    })

    print("="*70)
    print("Checking English localization for Russian text...")
    print("="*70 + "\n")

    if russian_lines:
        print(f"Found {len(russian_lines)} lines with Russian text:\n")
        for item in russian_lines[:20]:  # Show first 20
            print(f"Line {item['line']}: {item['key'][:60]}")
            print(f"  [Contains Russian text]")
            print()

        if len(russian_lines) > 20:
            print(f"... and {len(russian_lines) - 20} more lines")
    else:
        print("No Russian text found in English localization!")

    print("="*70)
    print(f"Total: {len(russian_lines)} lines with Russian text")
    print("="*70)

if __name__ == '__main__':
    check_english_localization()
