# CLAUDE.md — dotawarsongs (Dota 2 custom game)

> **ВАЖНО: это первый источник истины.** При создании/правке способностей, ультимейтов,
> героев и талантов — СНАЧАЛА читаем этот файл, потом смотрим на существующих кастомных
> героев в проекте и копируем их стиль. Не придумываем своё, если в проекте уже есть паттерн.

Язык общения с пользователем — **русский**. Комментарии в коде — русские, как в существующих файлах.

---

## 0. Золотые правила (читать всегда)

0. **Ищи всегда более простой путь.** Задавай себе вопрос: «не усложняю ли я?».
   Самый простой путь — самый верный. Чем меньше костылей, тем лучше.

1. **Стиль берём у наших кастомных героев.** Создаём нового героя/скилл → смотрим
   `scripts/vscripts/abilities/heroes/<любой_кастомный>/` и пишем в том же стиле
   (class({}), LinkLuaModifier, IsServer()-гварды, русские комментарии).
2. **Партиклы не выдумываем.** Используем только реально существующие. Проверяем:
   - базовые партиклы доты — `particles/units/heroes/hero_<name>/...` (в VPK как `.vpcf_c`);
   - кастомные — в `content/.../particles/`.
   Не уверен, что путь существует — ищи в VPK (`pak01_dir.vpk`, расширение `vpcf_c`).
3. **Любой партикл добавляем в precache** → `scripts/vscripts/precache.lua`.
   Дочерние партиклы родителя тоже добавляем, если нужны.
4. **Кастомные звуки** добавляются через **Asset Browser** и требуют перекомпиляции.
   Мы НЕ компилируем сами — мы **называем пользователю имя звукового события**, он
   перекомпилит (Full Recompile + Reload). (См. §6.)
5. **Меняется бар скиллов героя** (скрытые/подменяемые способности) → образец **Riki**.
   Лишние ванильные способности в слотах прячем через `generic_hidden` (НЕ `""` —
   пустая строка сбивает хоткеи, R уезжает на D).
6. **Таланты** (`scripts/npc/talents/heroes/`) — это поранговое авто-усиление значений
   (`value` + `operator` OP_ADD/OP_MULTIPLY + `max_count`). Делаем как у остальных,
   для НЕкастомного героя берём 3 некастомных как образец и стандартные значения.
7. **Кастомный сет/модель героя** → ищем модели в VPK через GCFScape, смотрим как
   подключено у наших героев (`npc_units_override.txt` / precache models).

---

## 1. Где что лежит

| Что | Путь |
|-----|------|
| Описание способностей (поведение, мана, КД, AbilityValues) | `scripts/npc/heroes/<hero>_abilities.kv` |
| Lua-логика способностей | `scripts/vscripts/abilities/heroes/<hero>/<spell>.lua` |
| Таланты героя (авто-скейл значений) | `scripts/npc/talents/heroes/npc_dota_hero_<hero>.txt` |
| Слоты способностей героя (Ability1..18) | `scripts/npc/npc_heroes_custom.txt` |
| Доп. определения способностей | `scripts/npc/npc_abilities_custom.txt` |
| Кастомные юниты (дамми, ловушки и т.п.) | `scripts/npc/npc_units_custom.txt` |
| Фильтр приказов (перехват кликов) | `scripts/vscripts/filters/order.lua` |
| Precache | `scripts/vscripts/precache.lua` |
| Кастомные звуковые события | `content/.../soundevents/game_sounds_custom_announcer.vsndevts` |
| Исходники звуков (.wav/.mp3) | `content/.../sounds/heroes/<hero>/` |
| Иконки способностей (.png) | `game/.../resource/flash3/images/spellicons/<hero>/<name>.png` |
| Локализация | `resource/addon_english.txt` (UTF-16LE), `resource/addon_russian.txt` (UTF-8 BOM) |

---

## 2. Полезные API-паттерны (из проекта)

- Урон: `ApplyDamage({victim=, attacker=, damage=, damage_type=DAMAGE_TYPE_*, ability=})`
- Поиск целей: `FindUnitsInRadius(team, pos, nil, radius, TEAM, TYPE, FLAGS, ORDER, false)`
- Рывок/полёт: `LUA_MODIFIER_MOTION_HORIZONTAL` + `ApplyHorizontalMotionController()`
  + `UpdateHorizontalMotion(me, dt)` (см. `templar_assassin/ta_lethal_surge.lua`).
- Объект на земле: юнит-варда `CreateUnitByName(...)` (даёт вижен + кликабельность)
  или `CreateModifierThinker(...)` (только эффект, без клика).
- Анимация поверх движения: `unit:StartGestureWithPlaybackRate(ACT_DOTA_RUN, rate)` +
  `unit:RemoveGesture(ACT_DOTA_RUN)` в конце. (НЕ `FadeGesture` — глушит анимацию.)
- Звук: `EmitSoundOn(name, unit)` / `EmitSoundOnLocationWithCaster(pos, name, caster)` / `StopSoundOn`.
- Перехват клика по юниту: `SetExecuteOrderFilter` (в проекте — `filters/order.lua`),
  ловим `DOTA_UNIT_ORDER_MOVE_TO_TARGET` (клик по юниту) и `MOVE_TO_POSITION` (по земле).

---

## 3. Заряды (charges) — важный нюанс движка

- Движковые `AbilityCharges` рисуют кружок с числом + КД на иконке, НО **блокируют каст
  при 0 зарядов**. Если способность двухстадийная и второй каст должен работать при 0 —
  движковые заряды не подходят для этого каста (выноси действие на правый клик / отдельно).
- Scepter-условный максимум зарядов: ставим `AbilityCharges` = максимум (2), а без аганима
  режем интринзик-модификатором (`SetCurrentAbilityCharges(1)` каждый тик, если нет скипетра).

---

## 4. Звуки (workflow)

1. `.wav`/`.mp3` → `content/.../sounds/heroes/<hero>/`.
2. Событие → `content/.../soundevents/game_sounds_custom_announcer.vsndevts` (тип `dota_src1_3d`).
3. В Lua: `EmitSoundOn("MySoundEvent.Name", unit)`.
4. **Перекомпиляция — у пользователя:** Asset Browser → найти .wav → Compile;
   найти `game_sounds_custom_announcer.vsndevts` → Full Recompile + Reload → перезапуск.
5. **Действие Claude:** написать код и **сообщить пользователю имя события**.

---

## 5. Иконки способностей

- Кладём `.png` в `game/.../resource/flash3/images/spellicons/<hero>/<name>.png`.
- В KV: `"AbilityTextureName" "<hero>/<name>"`.
- Компиляция .png — у пользователя через Asset Browser.

---

## 6. Локализация

- EN: `resource/addon_english.txt` (UTF-16LE), RU: `resource/addon_russian.txt` (UTF-8 BOM).
- Токены: `DOTA_Tooltip_ability_<name>` (имя), `_Description`, `_Lore`,
  `_scepter_description` (аганим), `_<special_value>` (подпись значения; ведущий `%` = проценты).
- Редактируем через Edit (сохраняет кодировку). Старые/конфликтующие токены убираем.

---

## 7. Кастомные герои в проекте

`axe, broodmother, chen, crystal_maiden, cursed_knight, dazzle, earthshaker, enigma,
juggernaut, lina, lion, mirana, riki, shadow_fiend, sniper, templar_assassin, windranger`
(см. `scripts/vscripts/abilities/heroes/`).

---

## 8. Память (claude-mem)

В проекте установлен плагин **claude-mem** (хуки в `~/.claude/settings.json`). Но
**первоисточник правил — этот CLAUDE.md**: при работе с героями/скиллами/талантами
начинаем отсюда.
