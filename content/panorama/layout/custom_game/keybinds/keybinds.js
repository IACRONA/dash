// #8: HEROES_DONT_JUMP удалён как мёртвый код (система прыжка убрана).

const humanFriendlyToActualKeyMap = {
  TAB: "tab",
  BACKSPACE: "backspace",
  ENTER: "enter",
  SPACE: "space",
  CAPSLOCK: "capslock",
  PAGEUP: "pgup",
  PAGEDOWN: "pgdn",
  END: "end",
  HOME: "home",
  INSERT: "ins",
  DELETE: "del",
  LEFT: "leftarrow",
  UP: "uparrow",
  RIGHT: "rightarrow",
  DOWN: "downarrow",
  "KEYPAD 0": "kp_0",
  "KEYPAD 1": "kp_1",
  "KEYPAD 2": "kp_2",
  "KEYPAD 3": "kp_3",
  "KEYPAD 4": "kp_4",
  "KEYPAD 5": "kp_5",
  "KEYPAD 6": "kp_6",
  "KEYPAD 7": "kp_7",
  "KEYPAD 8": "kp_8",
  "KEYPAD 9": "kp_9",
  "KEYPAD /": "kp_divide",
  "KEYPAD +": "kp_plus",
  "KEYPAD -": "kp_minus",
  "KEYPAD *": "kp_multiply",
  "KEYPAD ENTER": "kp_enter",
};

const russian_language_button = {
  й: "q", ц: "w", у: "e", к: "r", е: "t", н: "y", г: "u", ш: "i", щ: "o", з: "p",
  ф: "a", ы: "s", в: "d", а: "f", п: "g", р: "h", о: "j", л: "k", д: "l",
  я: "z", ч: "x", с: "c", м: "v", и: "b", т: "n", ь: "m",
};

const english_language_button = {
  q: "й", w: "ц", e: "у", r: "к", t: "е", y: "н", u: "г", i: "ш", o: "щ", p: "з",
  a: "ф", s: "ы", d: "в", f: "а", g: "п", h: "р", j: "о", k: "л", l: "д",
  z: "я", x: "ч", c: "с", v: "м", b: "и", n: "т", m: "ь",
};

// #3: единый источник правды по доп-способностям.
// Если в будущем понадобится cast_ability_7 — просто добавить запись сюда,
// и она автоматически появится в UI настроек, в Save/Reset и в UpdateSkillBar.
const CUSTOM_ABILITIES = [
  { key: "cast_ability_8", net_field: "ultimate" },
];

var init_settings = false;
var abilities_settings = playerInfo.getKeybindsPlayer();

var saves_buttons_name = {};
// #1+#9: храним для каждой ability список фактически привязанных клавиш (RU+EN),
// чтобы корректно снять их при reset/смене.
var active_custom_binds = {}; // ability_name -> [keypad, ...]
var active_mouse_capture_panel = null;

const MOUSE_SIDE_BUTTONS = { 3: "mouse4", 4: "mouse5" };

function ClearMouseCapture() {
  if (active_mouse_capture_panel) {
    active_mouse_capture_panel.ClearPanelEvent("onmousebutton");
    active_mouse_capture_panel = null;
  }
}

var update_skill_bar_running = false;
// #2: запомнённый последний снапшот для UpdateSkillBar, чтобы избежать лишних
// перерисовок при идентичных входных данных.
var last_skillbar_signature = "";

function GetGameKeybind(command) {
  if (command == null || command == undefined) {
    return "";
  }
  return Game.GetKeybindForCommand(command).toLowerCase();
}

function ConvertHumanFriendlyToActual(key) {
  return humanFriendlyToActualKeyMap[key] || key.toLowerCase();
}

function OnSettingsOpen() {
  let settings = $("#SettingsRoot");
  if (settings.BHasClass("open")) {
    OnSettingsClose();
    return;
  }
  if (!init_settings) {
    init_settings = true;
    InitButtons();
  }
  settings.AddClass("open");
  settings.RemoveClass("closing");
  Game.EmitSound("ui_settings_slide_in");
}

function OnSettingsClose() {
  let settings = $("#SettingsRoot");
  settings.RemoveClass("open");
  settings.AddClass("closing");
  Game.EmitSound("ui_settings_slide_out");
  $.DispatchEvent("DropInputFocus");
}

function GetDotaHud() {
  let hPanel = $.GetContextPanel();

  while (hPanel && hPanel.id !== "Hud") {
    hPanel = hPanel.GetParent();
  }

  if (!hPanel) {
    throw new Error("Could not find Hud root from panel with id: " + $.GetContextPanel().id);
  }

  return hPanel;
}

function FindDotaHudElement(sId) {
  return GetDotaHud().FindChildTraverse(sId);
}

function InitButtons() {
  $("#SettingsKeybindsList").RemoveAndDeleteChildren();
  // #3: итерируем по единому источнику правды.
  for (var idx = 0; idx < CUSTOM_ABILITIES.length; idx++) {
    CreateBindButton(CUSTOM_ABILITIES[idx].key);
  }

  let SaveBinds = $("#SaveBinds");
  SaveBinds.SetPanelEvent("onmouseover", function () {
    let text = SaveBinds.BHasClass("Disabled")
      ? $.Localize("#keybinds_error_busy_short")
      : $.Localize("#keybinds_notification");
    $.DispatchEvent("DOTAShowTextTooltip", SaveBinds, text);
  });
  SaveBinds.SetPanelEvent("onmouseout", function () {
    $.DispatchEvent("DOTAHideTextTooltip", SaveBinds);
  });
}

function CreateBindButton(ability_name) {
  let button_container = $.CreatePanel("Panel", $("#SettingsKeybindsList"), "");
  button_container.AddClass("CustomKeybindContainer");

  let button_panel = $.CreatePanel("Panel", button_container, "");
  button_panel.AddClass("CustomKeybinder");
  button_panel.AddClass("HoverEffect");

  let bind_name = $.CreatePanel("Label", button_panel, "bind_name_label");
  bind_name.AddClass("bind_name");
  bind_name.text = (abilities_settings[ability_name] || "").toUpperCase();

  let button_name = $.CreatePanel("Label", button_container, "");
  button_name.AddClass("CustomKeybindTitle");
  button_name.text = $.Localize("#keybind_" + ability_name);

  // #1: ярлычок для предупреждения о конфликте с системным биндом.
  let conflict_label = $.CreatePanel("Label", button_container, "conflict_label");
  conflict_label.AddClass("CustomKeybindConflict");
  conflict_label.text = "";
  conflict_label.style.visibility = "collapse";

  // #7: entry_panel создаём внутри button_container, чтобы он удалялся вместе
  // со списком при пересоздании InitButtons (а не утекал в context panel).
  let entry_panel = $.CreatePanel("TextEntry", button_container, "CustomKeybindEntry", { maxchars: 1 });
  entry_panel.AddClass("CustomKeybindEntry");

  button_panel.SetPanelEvent("onactivate", function () {
    Game.EmitSound("Flag.RollChoose");
    SetPreActivateBind(button_panel, entry_panel, ability_name, bind_name, conflict_label);
  });

  // Сразу показать конфликт для уже сохранённой клавиши (если есть).
  UpdateConflictLabel(conflict_label, abilities_settings[ability_name]);
}

function SetPreActivateBind(button_panel, entry_panel, ability_name, bind_name, conflict_label) {
  entry_panel.text = "";
  entry_panel.SetFocus();
  button_panel.SetHasClass("ActiveBind", true);
  button_panel.SetHasClass("HoverEffect", false);
  if (!entry_panel.BHasKeyFocus()) {
    CheckFocusPanel(entry_panel, button_panel);
  } else {
    entry_panel.SetPanelEvent("onblur", function () {
      CheckFocusPanel(entry_panel, button_panel);
    });
  }
  entry_panel.SetPanelEvent("ontextentrychange", function () {
    OnSubmitted(bind_name, entry_panel, button_panel, ability_name, conflict_label);
  });

  ClearMouseCapture();
  active_mouse_capture_panel = $.GetContextPanel();
  active_mouse_capture_panel.SetPanelEvent("onmousebutton", function (nButton) {
    var mouse_key = MOUSE_SIDE_BUTTONS[nButton];
    if (!mouse_key) return;
    ClearMouseCapture();
    abilities_settings[ability_name] = mouse_key;
    bind_name.text = mouse_key.toUpperCase();
    button_panel.SetHasClass("ActiveBind", false);
    button_panel.SetHasClass("HoverEffect", true);
    $.DispatchEvent("DropInputFocus");
    if (conflict_label) UpdateConflictLabel(conflict_label, mouse_key);
  });
}

function OnSubmitted(bind_name, entry_panel, button_panel, ability_name, conflict_label) {
  let get_key_bind_name = entry_panel.text;

  if (russian_language_button[get_key_bind_name]) {
    get_key_bind_name = russian_language_button[get_key_bind_name];
  }

  if (get_key_bind_name == " ") {
    get_key_bind_name = "space";
  }

  abilities_settings[ability_name] = get_key_bind_name;

  bind_name.text = get_key_bind_name.toUpperCase();
  button_panel.SetHasClass("ActiveBind", false);
  button_panel.SetHasClass("HoverEffect", true);
  ClearMouseCapture();
  $.DispatchEvent("DropInputFocus");

  // #1: обновляем предупреждение о конфликте сразу после выбора клавиши.
  if (conflict_label) UpdateConflictLabel(conflict_label, get_key_bind_name);
}

const CONFLICT_CHECKS = [
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY1,            label: "#keybind_conflict_ability_1" },
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY2,            label: "#keybind_conflict_ability_2" },
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY3,            label: "#keybind_conflict_ability_3" },
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_SECONDARY1,          label: "#keybind_conflict_ability_4" },
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_SECONDARY2,          label: "#keybind_conflict_ability_5" },
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_ULTIMATE,            label: "#keybind_conflict_ability_ult" },
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY1,                  label: "#keybind_conflict_inventory_1" },
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY2,                  label: "#keybind_conflict_inventory_2" },
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY3,                  label: "#keybind_conflict_inventory_3" },
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY4,                  label: "#keybind_conflict_inventory_4" },
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY5,                  label: "#keybind_conflict_inventory_5" },
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY6,                  label: "#keybind_conflict_inventory_6" },
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_TELEPORT,                    label: "#keybind_conflict_teleport" },
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_TELEPORT_QUICKCAST,          label: "#keybind_conflict_teleport" },
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY_NEUTRAL,           label: "#keybind_conflict_neutral" },
  { cmd: DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY_NEUTRAL_QUICKCAST, label: "#keybind_conflict_neutral" },
];

function GetSystemBindConflict(keypad) {
  if (!keypad) return null;
  let normalized = russian_language_button[keypad] || keypad;

  for (var i = 0; i < CONFLICT_CHECKS.length; i++) {
    let bind = GetGameKeybind(Number(CONFLICT_CHECKS[i].cmd));
    let bind_norm = russian_language_button[bind] || bind;
    if (bind_norm && bind_norm == normalized) return CONFLICT_CHECKS[i].label;
  }
  return null;
}

function UpdateConflictLabel(conflict_label, keypad) {
  if (!conflict_label) return;
  let conflict = GetSystemBindConflict(keypad);
  if (conflict) {
    conflict_label.text = $.Localize(conflict);
    conflict_label.style.visibility = "visible";
  } else {
    conflict_label.text = "";
    conflict_label.style.visibility = "collapse";
  }
  UpdateSaveButton();
}

function UpdateSaveButton() {
  let has_conflict = false;
  for (var ability_name in abilities_settings) {
    if (GetSystemBindConflict(abilities_settings[ability_name])) {
      has_conflict = true;
      break;
    }
  }
  let SaveBinds = $("#SaveBinds");
  if (SaveBinds) {
    SaveBinds.SetHasClass("Disabled", has_conflict);
  }
}

function CheckFocusPanel(panel, button_panel) {
  panel.ClearPanelEvent("onfocus");
  ClearMouseCapture();
  button_panel.SetHasClass("ActiveBind", false);
  button_panel.SetHasClass("HoverEffect", true);
}

function SaveKeyBinds(isInit) {
  if (!isInit) {
    let SaveBinds = $("#SaveBinds");
    if (SaveBinds && SaveBinds.BHasClass("Disabled")) {
      Game.EmitSound("General.NoGold");
      return;
    }
    ResetBindsOnSend();
    OnSettingsOpen();
    Game.EmitSound("Flag.RollChoose");
  }

  for (var ability_name in abilities_settings) {
    let button_keypad = abilities_settings[ability_name];
    SetKeyBindButton(ability_name, button_keypad);
    if (button_keypad != "space" && english_language_button[button_keypad]) {
      SetKeyBindButton(ability_name, english_language_button[button_keypad]);
    }
    saves_buttons_name[ability_name] = button_keypad;
  }

  if (!isInit) GameEvents.SendCustomGameEventToServer("player_change_keybinds", { keybinds: abilities_settings });

  // #2: после сохранения принудительно обновляем скил-бар.
  RefreshSkillBar();
}

// Уникальный ID сессии — гарантирует, что имя команды каждый раз новое,
// даже если движок сохранил имена прошлых сессий между матчами.
const KB_SESSION_ID = Math.floor(Math.random() * 99999999);

function AbilityCommandName(ability_name) {
  return "KeyBind_Custom_Ability_" + ability_name + "_s" + KB_SESSION_ID;
}

function EnsureAbilityCommand(ability_name) {
  let cmd_name = AbilityCommandName(ability_name);
  Game.AddCommand(cmd_name, function () {
    UseAbility(ability_name);
  }, "", 0);
}

function SetKeyBindButton(ability_name, button_keypad) {
  if (!button_keypad) return;

  if (!active_custom_binds[ability_name]) active_custom_binds[ability_name] = [];
  let arr = active_custom_binds[ability_name];
  if (arr.indexOf(button_keypad) === -1) arr.push(button_keypad);

  EnsureAbilityCommand(ability_name);
  let cmd = AbilityCommandName(ability_name);
  Game.CreateCustomKeyBind(button_keypad, cmd);
}

// #9: снимает все клавиши, которые ranее были привязаны для данной ability.
function ClearAbilityBinds(ability_name) {
  let arr = active_custom_binds[ability_name];
  if (!arr) return;
  for (var i = 0; i < arr.length; i++) {
    if (arr[i]) Game.CreateCustomKeyBind(arr[i], "");
  }
  active_custom_binds[ability_name] = [];
}

function GetAbilityList() {
  // #3: возвращаем массив, индексы которого соответствуют CUSTOM_ABILITIES[i].
  let result = [];
  let net_value = CustomNetTables.GetTableValue("abilities_list", String(Players.GetLocalPlayer()));
  for (var i = 0; i < CUSTOM_ABILITIES.length; i++) {
    let field = CUSTOM_ABILITIES[i].net_field;
    let val = (net_value && net_value[field] != null) ? net_value[field] : "none";
    result.push(val);
  }
  return result;
}

function UseAbility(ability_name) {
  let target_idx = -1;
  for (var i = 0; i < CUSTOM_ABILITIES.length; i++) {
    if (CUSTOM_ABILITIES[i].key === ability_name) { target_idx = i; break; }
  }
  if (target_idx === -1) return;

  let ability_name_in_skill = GetAbilityList()[target_idx];
  if (ability_name_in_skill != "none") {
    Abilities.ExecuteAbility(
      Entities.GetAbilityByName(Players.GetLocalPlayerPortraitUnit(), ability_name_in_skill),
      Players.GetLocalPlayerPortraitUnit(),
      true
    );
  }
}

// #2+#5: единая функция обновления скил-бара (event-driven, без polling).
function RefreshSkillBar() {
  let current_abilities = GetAbilityList();

  // Собираем подпись текущего состояния для дедупликации.
  let keys_snapshot = [];
  for (var i = 0; i < CUSTOM_ABILITIES.length; i++) {
    keys_snapshot.push(saves_buttons_name[CUSTOM_ABILITIES[i].key] || " ");
  }
  let signature = current_abilities.join("|") + "::" + keys_snapshot.join("|");
  if (signature === last_skillbar_signature) return;
  last_skillbar_signature = signature;

  let abilities = FindDotaHudElement("abilities");
  if (!abilities) return;

  for (var ci = 0; ci < abilities.GetChildCount(); ci++) {
    let ability_panel = abilities.GetChild(ci);
    if (!ability_panel) continue;
    let ability_image = ability_panel.FindChildTraverse("AbilityImage");
    let ability_name = ability_image ? ability_image.abilityname : null;
    if (!ability_name) continue;

    for (var k = 0; k < current_abilities.length; k++) {
      if (ability_name == current_abilities[k]) {
        let HotkeyText = ability_panel.FindChildTraverse("HotkeyText");
        let Hotkey = ability_panel.FindChildTraverse("Hotkey");
        if (HotkeyText) HotkeyText.text = String(keys_snapshot[k]).toUpperCase();
        if (Hotkey) Hotkey.style.visibility = "visible";
      }
    }
  }
}

// #2: подписки заменяют $.Schedule(1, UpdateSkillBar).
function InitSkillBarSubscriptions() {
  if (update_skill_bar_running) return;
  update_skill_bar_running = true;

  CustomNetTables.SubscribeNetTableListener("abilities_list", function (_, key, _value) {
    if (key === String(Players.GetLocalPlayer())) RefreshSkillBar();
  });
  // Скил-бар может пересоздаваться (смена героя, ресспаун), а DOM-элементы #abilities —
  // тоже. Поэтому держим лёгкий редкий перепрогон раз в 2 секунды, который ничего не делает,
  // если signature не изменилась. Это в 2 раза реже прежнего polling и без обходов по умолчанию.
  function HeartbeatTick() {
    RefreshSkillBar();
    $.Schedule(2, HeartbeatTick);
  }
  HeartbeatTick();
}

function ResetBinds() {
  Game.EmitSound("Flag.RollChoose");
  let SettingsKeybindsList = $("#SettingsKeybindsList");
  for (var i = 0; i < SettingsKeybindsList.GetChildCount(); i++) {
    let button_bind = SettingsKeybindsList.GetChild(i);
    if (button_bind) {
      let bind_name_label = button_bind.FindChildTraverse("bind_name_label");
      if (bind_name_label) bind_name_label.text = "";
      let conflict_label = button_bind.FindChildTraverse("conflict_label");
      if (conflict_label) {
        conflict_label.text = "";
        conflict_label.style.visibility = "collapse";
      }
    }
  }

  // Снимаем все привязанные клавиши (RU+EN) для каждой ability.
  for (var ab_name in active_custom_binds) {
    ClearAbilityBinds(ab_name);
  }
  active_custom_binds = {};

  abilities_settings = {};
  saves_buttons_name = {};

  // #6: сообщаем серверу, что пользователь сбросил биндинги.
  GameEvents.SendCustomGameEventToServer("player_change_keybinds", { keybinds: {} });

  // #2: обновим UI скил-бара (хоткеи пропадут).
  last_skillbar_signature = "";
  RefreshSkillBar();
}

function ResetBindsOnSend() {
  // Снимаем все наши кастомные привязки, чтобы перед повторным SaveKeyBinds
  // не оставалось «фантомных» биндингов на старые клавиши.
  for (var ab_name in active_custom_binds) {
    ClearAbilityBinds(ab_name);
  }
}

InitSkillBarSubscriptions();
SaveKeyBinds(true);
