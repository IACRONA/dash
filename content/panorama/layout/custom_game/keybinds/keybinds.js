HEROES_DONT_JUMP = ["npc_dota_hero_earthshaker"];

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
  й: "q",
  ц: "w",
  у: "e",
  к: "r",
  е: "t",
  н: "y",
  г: "u",
  ш: "i",
  щ: "o",
  з: "p",
  ф: "a",
  ы: "s",
  в: "d",
  а: "f",
  п: "g",
  р: "h",
  о: "j",
  л: "k",
  д: "l",
  я: "z",
  ч: "x",
  с: "c",
  м: "v",
  и: "b",
  т: "n",
  ь: "m",
};

const english_language_button = {
  q: "й",
  w: "ц",
  e: "у",
  r: "к",
  t: "е",
  y: "н",
  u: "г",
  i: "ш",
  o: "щ",
  p: "з",
  a: "ф",
  s: "ы",
  d: "в",
  f: "а",
  g: "п",
  h: "р",
  j: "о",
  k: "л",
  l: "д",
  z: "я",
  x: "ч",
  c: "с",
  v: "м",
  b: "и",
  n: "т",
  m: "ь",
};

var init_settings = false;
var abilities_settings = playerInfo.getKeybindsPlayer();

// ОПТИМИЗАЦИЯ: Убран прыжок для улучшения FPS
var abilities_list = ["cast_ability_8"];
var saves_buttons_name = {};

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
  for (ability_number in abilities_list) {
    let ability_name = abilities_list[ability_number];
    CreateBindButton(ability_name);
  }

  let SaveBinds = $("#SaveBinds");

  SaveBinds.SetPanelEvent("onmouseover", function () {
    $.DispatchEvent("DOTAShowTextTooltip", SaveBinds, $.Localize("#keybinds_notification"));
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

  let entry_panel = $.CreatePanel("TextEntry", $.GetContextPanel(), "CustomKeybindEntry", { maxchars: 1 });
  entry_panel.AddClass("CustomKeybindEntry");

  button_panel.SetPanelEvent("onactivate", function () {
    SetPreActivateBind(button_panel, entry_panel, ability_name, bind_name);
  });
}

function SetPreActivateBind(button_panel, entry_panel, ability_name, bind_name) {
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
  // CheckFocusPanel(entry_panel, button_panel)
  entry_panel.SetPanelEvent("ontextentrychange", function () {
    OnSubmitted(bind_name, entry_panel, button_panel, ability_name);
  });
}

function OnSubmitted(bind_name, entry_panel, button_panel, ability_name) {
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
  $.DispatchEvent("DropInputFocus");
}

function CheckFocusPanel(panel, button_panel) {
  panel.ClearPanelEvent("onfocus");
  button_panel.SetHasClass("ActiveBind", false);
  button_panel.SetHasClass("HoverEffect", true);
}
// function CheckFocusPanel(panel, button_panel)
// {
//     if (panel.BHasKeyFocus())
//     {
//         $.Schedule( 1/144, () =>
//         {
//             CheckFocusPanel(panel, button_panel)
//         })
//         return
//     }
//     button_panel.SetHasClass("ActiveBind", false)
//     button_panel.SetHasClass("HoverEffect", true)
// }

function SaveKeyBinds(isInit) {
  if (!isInit) {
    ResetBindsOnSend();
    OnSettingsOpen();
  }

  for (ability_name in abilities_settings) {
    let button_keypad = abilities_settings[ability_name];
    SetKeyBindButton(ability_name, button_keypad);
    if (button_keypad != "space" && english_language_button[button_keypad]) {
      SetKeyBindButton(ability_name, english_language_button[button_keypad]);
    }
    saves_buttons_name[ability_name] = button_keypad;
  }

  if (!isInit) GameEvents.SendCustomGameEventToServer("player_change_keybinds", { keybinds: abilities_settings });
}

function SetKeyBindButton(ability_name, button_keypad) {
  const name_bind = "KeyBind_Custom_" + Math.floor(Math.random() * 99999999);

  Game.AddCommand(
    name_bind,
    () => {
      UseAbility(ability_name);
    },
    "",
    0
  );
  Game.CreateCustomKeyBind(button_keypad, name_bind);
}

function GetAbilityList() {
  // ОПТИМИЗАЦИЯ: Убран прыжок для улучшения FPS
  let abilities_list = ["none", "none"];
  let abilities = CustomNetTables.GetTableValue("abilities_list", String(Players.GetLocalPlayer()));
  if (abilities) {
    if (abilities.basic != null) {
      abilities_list[0] = abilities.basic;
    }
    if (abilities.ultimate != null) {
      abilities_list[1] = abilities.ultimate;
    }
  }
  return abilities_list;
}

function UseAbility(ability_name) {
  // ОПТИМИЗАЦИЯ: Убран прыжок для улучшения FPS
  let find_ability = {
    cast_ability_7: 0,
    cast_ability_8: 1,
  };
  let ability_name_in_skill = GetAbilityList()[find_ability[ability_name]];
  if (ability_name_in_skill != "none") {
    Abilities.ExecuteAbility(
      Entities.GetAbilityByName(Players.GetLocalPlayerPortraitUnit(), ability_name_in_skill),
      Players.GetLocalPlayerPortraitUnit(),
      true
    );
  }
}

function UpdateSkillBar() {
  let keybind_list = [];
  let abilities_list = GetAbilityList();
  // ОПТИМИЗАЦИЯ: Убран прыжок для улучшения FPS
  let find_ability = {
    cast_ability_7: 0,
    cast_ability_8: 1,
  };

  for (ability_keypad_name in find_ability) {
    if (saves_buttons_name[ability_keypad_name]) {
      keybind_list.push(saves_buttons_name[ability_keypad_name]);
    } else {
      keybind_list.push(" ");
    }
  }

  let abilities = FindDotaHudElement("abilities");
  if (abilities) {
    for (var i = 0; i < abilities.GetChildCount(); i++) {
      let ability_panel = abilities.GetChild(i);
      if (ability_panel) {
        let Hotkey = ability_panel.FindChildTraverse("Hotkey");
        let HotkeyText = ability_panel.FindChildTraverse("HotkeyText");
        let ability_name = ability_panel.FindChildTraverse("AbilityImage").abilityname;
        if (ability_name && ability_name == abilities_list[0]) {
          if (HotkeyText) {
            HotkeyText.text = String(keybind_list[0]).toUpperCase();
          }
          if (Hotkey) {
            Hotkey.style.visibility = "visible";
          }
        }
        if (ability_name && ability_name == abilities_list[1]) {
          if (HotkeyText) {
            HotkeyText.text = String(keybind_list[1]).toUpperCase();
          }
          if (Hotkey) {
            Hotkey.style.visibility = "visible";
          }
        }
        if (ability_name && ability_name == abilities_list[2]) {
          if (HotkeyText) {
            HotkeyText.text = String(keybind_list[2]).toUpperCase();
          }
          if (Hotkey) {
            Hotkey.style.visibility = "visible";
          }
        }
      }
    }
  }
  $.Schedule(1, UpdateSkillBar);
}

function ResetBinds() {
  let SettingsKeybindsList = $("#SettingsKeybindsList");
  for (var i = 0; i < SettingsKeybindsList.GetChildCount(); i++) {
    let button_bind = SettingsKeybindsList.GetChild(i);
    if (button_bind) {
      let bind_name_label = button_bind.FindChildTraverse("bind_name_label");
      if (bind_name_label) {
        bind_name_label.text = "";
      }
    }
  }

  for (ability_name in abilities_settings) {
    let button_keypad = abilities_settings[ability_name];
    ResetKeyBindName(button_keypad);
  }

  abilities_settings = {};
  saves_buttons_name = {};
}

function ResetBindsOnSend() {
  for (ability_name in saves_buttons_name) {
    let button_keypad = saves_buttons_name[ability_name];
    ResetKeyBindName(button_keypad);
  }
}

function ResetKeyBindName(button_keypad) {
  if (russian_language_button[button_keypad]) {
    button_keypad = russian_language_button[button_keypad];
  }

  let abilities_list = {
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY1]: 0,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY2]: 1,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY3]: 2,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_SECONDARY1]: 3,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_SECONDARY2]: 4,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_ULTIMATE]: 5,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY1_QUICKCAST]: 0,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY2_QUICKCAST]: 1,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY3_QUICKCAST]: 2,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_SECONDARY1_QUICKCAST]: 3,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_SECONDARY2_QUICKCAST]: 4,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_ULTIMATE_QUICKCAST]: 5,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY1_EXPLICIT_AUTOCAST]: 0,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY2_EXPLICIT_AUTOCAST]: 1,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY3_EXPLICIT_AUTOCAST]: 2,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_SECONDARY1_EXPLICIT_AUTOCAST]: 3,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_SECONDARY2_EXPLICIT_AUTOCAST]: 4,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_ULTIMATE_EXPLICIT_AUTOCAST]: 5,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY1_QUICKCAST_AUTOCAST]: 0,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY2_QUICKCAST_AUTOCAST]: 1,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY3_QUICKCAST_AUTOCAST]: 2,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_SECONDARY1_QUICKCAST_AUTOCAST]: 3,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_SECONDARY2_QUICKCAST_AUTOCAST]: 4,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_ULTIMATE_QUICKCAST_AUTOCAST]: 5,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY1_AUTOMATIC_AUTOCAST]: 0,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY2_AUTOMATIC_AUTOCAST]: 1,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY3_AUTOMATIC_AUTOCAST]: 2,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_SECONDARY1_AUTOMATIC_AUTOCAST]: 3,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_SECONDARY2_AUTOMATIC_AUTOCAST]: 4,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_ULTIMATE_AUTOMATIC_AUTOCAST]: 5,
  };
  let items_list = {
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY1]: 0,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY2]: 1,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY3]: 2,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY4]: 3,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY5]: 4,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY6]: 5,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY1_QUICKCAST]: 0,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY2_QUICKCAST]: 1,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY3_QUICKCAST]: 2,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY4_QUICKCAST]: 3,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY5_QUICKCAST]: 4,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY6_QUICKCAST]: 5,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY1_AUTOCAST]: 0,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY2_AUTOCAST]: 1,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY3_AUTOCAST]: 2,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY4_AUTOCAST]: 3,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY5_AUTOCAST]: 4,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY6_AUTOCAST]: 5,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY1_QUICKAUTOCAST]: 0,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY2_QUICKAUTOCAST]: 1,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY3_QUICKAUTOCAST]: 2,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY4_QUICKAUTOCAST]: 3,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY5_QUICKAUTOCAST]: 4,
    [DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY6_QUICKAUTOCAST]: 5,
  };

  let has_key_bind_reset = false;

  for (bind_filter in abilities_list) {
    let slot_num = abilities_list[bind_filter];
    let bind_orig_button = GetGameKeybind(Number(bind_filter));
    if (russian_language_button[bind_orig_button]) {
      bind_orig_button = russian_language_button[bind_orig_button];
    }
    if (bind_orig_button == button_keypad) {
      SetResetKeyBind(button_keypad, false, slot_num);
      SetResetKeyBind(english_language_button[button_keypad], false, slot_num);
      has_key_bind_reset = true;
    }
  }

  for (bind_filter in items_list) {
    let slot_num = items_list[bind_filter];
    let bind_orig_button = GetGameKeybind(Number(bind_filter));
    if (russian_language_button[bind_orig_button]) {
      bind_orig_button = russian_language_button[bind_orig_button];
    }
    if (bind_orig_button == button_keypad) {
      SetResetKeyBind(button_keypad, true, slot_num);
      SetResetKeyBind(english_language_button[button_keypad], true, slot_num);
      has_key_bind_reset = true;
    }
  }

  if (!has_key_bind_reset) {
    SetResetKeyBind(button_keypad, null, null, true);
    SetResetKeyBind(english_language_button[button_keypad], null, null, true);
  }
}

function SetResetKeyBind(button_keypad, is_item, slot, lose) {
  const name_bind = "KeyBind_Custom_" + Math.floor(Math.random() * 99999999);
  Game.AddCommand(
    name_bind,
    () => {
      if (is_item) {
        Abilities.ExecuteAbility(Entities.GetItemInSlot(Players.GetLocalPlayerPortraitUnit(), slot), Players.GetLocalPlayerPortraitUnit(), true);
      } else if (lose == null) {
        Abilities.ExecuteAbility(Entities.GetAbility(Players.GetLocalPlayerPortraitUnit(), slot), Players.GetLocalPlayerPortraitUnit(), true);
      } else {
      }
    },
    "",
    0
  );
  Game.CreateCustomKeyBind(button_keypad, name_bind);
}

UpdateSkillBar();
SaveKeyBinds(true);
