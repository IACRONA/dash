# Инструкция по добавлению/замене звуков для кастомных героев (dotawarsongs)

## Структура файлов

- Исходники (mp3): `content/dota_addons/dotawarsongs/sounds/heroes/<hero>/file.mp3`
- Скомпилированные: `game/dota_addons/dotawarsongs/sounds/heroes/<hero>/file.vsnd_c`
- Звуковые события: `content/dota_addons/dotawarsongs/soundevents/game_sounds_custom_announcer.vsndevts`
- Скомпилированные события: `game/dota_addons/dotawarsongs/soundevents/game_sounds_custom_announcer.vsndevts_c`

## Формат звукового события (добавлять в game_sounds_custom_announcer.vsndevts)

```
MySoundEvent.Name =
{
    type = "dota_src1_3d"
    vsnd_files =
    [
        "sounds/heroes/<hero>/file.vsnd",
    ]
    volume = "1.500000"
    pitch_rand_min = "0"
    pitch_rand_max = "0"
    pitch = "1.000000"
    soundlevel = "95.000000"
    distance_max = "1600.000000"
    event_type = "1.000000"
}
```

## Шаги добавления звука

1. Положить mp3 в `content/.../sounds/heroes/<hero>/`
2. Добавить событие в `content/.../soundevents/game_sounds_custom_announcer.vsndevts`
3. В Lua вызывать: `EmitSoundOn("MySoundEvent.Name", unit)`
4. Открыть **Dota 2 Workshop Tools → Asset Browser**
5. Найти `game_sounds_custom_announcer.vsndevts` → правый клик → **Full Recompile + Reload**
6. Перезапустить игру

## Важно

- Файл редактировать только в `content/` — компилятор читает оттуда
- НЕ нужен `Precache` в Lua если звук в `game_sounds_custom_announcer.vsndevts`
- Звуки рики: `Riki.StunStrike.Cast`, `Riki.SecondLife.Cast`, `Riki.VenousStrike.Cast`
- mp3 файлы рики лежат в `content/.../sounds/heroes/riki/`: `stun.mp3`, `plash.mp3`, `garrota.mp3`
