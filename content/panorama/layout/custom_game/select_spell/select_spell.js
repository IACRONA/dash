let queue = {};
const OPERATOR = {
  ADD: 1,
  MULTIPLY: 2,
};
const reverse_increment = ["cooldown_and_manacost"];
CustomNetTables.SubscribeNetTableListener("rolls_player", (_, eventKey, eventValue) => OnUpdateRoll(eventKey, eventValue));

const OnUpdateRoll = (playerId, data) => {
  if (playerId !== `${Game.GetLocalPlayerID()}`) return;

  const rerollPanels = $.GetContextPanel().FindChildrenWithClassTraverse("RerollBlock");
  const rerollTexts = $.GetContextPanel().FindChildrenWithClassTraverse("RerollText");
  const rerollCount = playerInfo.getRollPlayer();
  rerollPanels.forEach((panel) => {
    if (rerollCount > 0) {
      if (!panel.BHasClass("IsActive")) panel.AddClass("IsActive");
    } else {
      if (panel.BHasClass("IsActive")) panel.RemoveClass("IsActive");
    }
  });
  rerollTexts.forEach((panel) => {
    panel.text = GetTextForRerollPanel(rerollCount);
  });
};

const GetTextForRerollPanel = (reroll_count) => {
  return $.Localize("#swap_abilities") + " x" + reroll_count;
};
GameEvents.Subscribe("spell_select_open_panel", spell_select_open_panel);

function show_queue_panels() {
  const queuePanel = Object.keys(queue)[0];

  if (queuePanel) {
    if (queuePanel === "spell") {
      $("#SpellSelectedMain").style.opacity = "1";
    } else if (queuePanel === "fate") {
      $("#FateSelectedMain").style.opacity = "1";
    } else if (queuePanel === "sphere") {
      $("#SphereSelectedMain").style.opacity = "1";
    } else if (queuePanel === "sphere") {
      $("#SphereSelectedMain").style.opacity = "1";
    } else if (queuePanel === "talent") {
      $("#TalentsSelectedMain").style.opacity = "1";
    }
  }
}
// spell_select_open_panel({"spell_list":{"1":"earthshaker_echo_slam","2":"primal_beast_pulverize","3":"void_spirit_astral_step"},"is_ultimate":1,"is_reroll":0})

function spell_select_open_panel(params) {
  const isReroll = params.is_reroll;

  if (!isReroll) Game.EmitSound("Flag.NewAbility");
  $("#SpellSelectedMain").RemoveAndDeleteChildren();
  if (isReroll) {
    $("#SpellSelectedMain").style.opacity = "1";
  } else {
    if (Object.values(queue).length > 0) {
      if (!queue.spell) {
        queue.spell = true;
      }
    } else {
      queue.spell = true;
      $("#SpellSelectedMain").style.opacity = "1";
    }
  }
  let actions_block = $.CreatePanel("Panel", $("#SpellSelectedMain"), "SpellActions");

  // let Choose_Your_Spell = $.CreatePanel("Label", actions_block, "");
  // Choose_Your_Spell.AddClass("Choose_Your_Spell");
  // Choose_Your_Spell.AddClass(params.is_ultimate ? "IsUltimate" : "IsSpell");
  // Choose_Your_Spell.text = $.Localize(params.is_ultimate ? "#Choose_Your_Spell_Ultimate" : "#Choose_Your_Spell");

  $.Schedule(0.1, function () {
    $("#SpellSelectedMain").SetHasClass("SpawnPanelSelected", false);
  });
  CreateRerollPanel(params.is_ultimate);
  for (let i = 1; i <= Object.keys(params.spell_list).length; i++) {
    CreateSpellBlock(params.spell_list[i], params.is_ultimate);
  }
}

function CreateSpellBlock(spell_name, is_ultimate) {
  let spell_block = $.CreatePanel("Panel", $("#SpellSelectedMain"), "");
  spell_block.AddClass("spell_block");
  spell_block.AddClass("IsSpell");

  let spell_block_bg = $.CreatePanel("Panel", spell_block, "");
  spell_block_bg.AddClass("spell_block_bg");
  if (is_ultimate) spell_block_bg.AddClass("IsUltimate");

  let spell_block_image = $.CreatePanel("DOTAAbilityImage", spell_block, "");
  spell_block_image.AddClass("spell_block_image");
  spell_block_image.abilityname = spell_name;

  let spell_block_text = $.CreatePanel("Label", spell_block, "");
  spell_block_text.AddClass("spell_block_text");
  spell_block_text.text = $.Localize("#DOTA_Tooltip_ability_" + spell_name);
  let spell_block_particle = $.CreatePanel("DOTAParticleScenePanel", spell_block, "",{
    id: "hoverParticle",
    particleName: "particles/rebuild/ui/debris/debris_pitch_purple_fx.vpcf",
    lookAt: "0 0 0",
    cameraOrigin: "0 0 60",
    fov: 90,
    hittest: false});
  spell_block_particle.AddClass("hoverParticle");

  // Принудительно запускаем партикл для стабильности
  $.Schedule(0.01, function() {
    if (spell_block_particle && spell_block_particle.IsValid()) {
      spell_block_particle.StartParticles();
    }
  });

  spell_block.SetPanelEvent("onactivate", function () {
    GameEvents.SendCustomGameEventToServer("ability_select_to_hero", { spell_name: spell_name, is_ultimate: is_ultimate });
    $("#SpellSelectedMain").style.opacity = "0";
    $("#SpellSelectedMain").SetHasClass("SpawnPanelSelected", true);
    Game.EmitSound("Flag.KillSelect");
    CancelChooseAbilities();
  }); 
}

function CancelChooseAbilities() {
  delete queue.spell;
  for (let i = 0; i < $("#SpellSelectedMain").GetChildCount(); i++) {
    $("#SpellSelectedMain")
      .GetChild(i)
      .SetPanelEvent("onactivate", function () {});
  }

  show_queue_panels();
}

function CreateRerollPanel(is_ultimate) {
  const reroll_count = playerInfo.getRollPlayer();
  let reroll_block = $.CreatePanel("Panel", $("#SpellSelectedMain").FindChildTraverse("SpellActions"), "", {
    class: "RerollBlock",
  });

  if (reroll_count > 0) reroll_block.AddClass("IsActive");
  reroll_block.AddClass("reroll_block");
  reroll_block.AddClass(is_ultimate ? "IsUltimate" : "IsSpell");

  let reroll_block_text = $.CreatePanel("Label", reroll_block, "", {
    class: "RerollText",
  });
  reroll_block_text.AddClass("reroll_block_text");
  reroll_block_text.text = GetTextForRerollPanel(reroll_count);

  let reroll_block_image = $.CreatePanel("Panel", reroll_block, "");
  reroll_block_image.AddClass("reroll_block_image");

  reroll_block.SetPanelEvent("onactivate", function () {
    if (!reroll_block.BHasClass("IsActive")) return;
    GameEvents.SendCustomGameEventToServer("swap_abilities_to_select", { is_ultimate: is_ultimate });
    $("#SpellSelectedMain").style.opacity = "0";
    Game.EmitSound("Flag.RollChoose");
  });
}

GameEvents.Subscribe("open_fates_choose_players", open_fates_choose_players);
// open_fates_choose_players()
function open_fates_choose_players(params) {
  $("#FateSelectedMain").RemoveAndDeleteChildren();

  let list = {
    1: "fate_defender",
    2: "fate_immortal",
    3: "fate_murder",
    4: "fate_one_punchman",
    5: "fate_himaron",
  };
  // let actions_block = $.CreatePanel("Panel", $("#FateSelectedMain"), "SpellActions");

  // let Choose_Your_Fate = $.CreatePanel("Label", actions_block, "");
  // Choose_Your_Fate.AddClass("Choose_Your_Fate");
  // Choose_Your_Fate.text = $.Localize("#Choose_Your_Fate");
  // let rerollPanel = $.CreatePanel("Panel", actions_block, "SpellReroll");

  for (let i = 1; i <= Object.keys(list).length; i++) {
    CreateFate(list[i]);
  }

  if (Object.values(queue).length > 0) {
    if (!queue.fate) {
      queue.fate = true;
    }
  } else {
    queue.fate = true;
    $("#FateSelectedMain").style.opacity = "1";
  }
  $.Schedule(0.5, function () {
    $("#FateSelectedMain").SetHasClass("SpawnPanelSelected", false);
    Game.EmitSound("fate_chos");
  });
}

function CreateFate(fate_name) {
  let spell_block = $.CreatePanel("Panel", $("#FateSelectedMain"), "");
  spell_block.AddClass("fate_block");

  let spell_block_bg = $.CreatePanel("Panel", spell_block, "");
  spell_block_bg.AddClass("fate_block_bg"); 

  let spell_block_icon = $.CreatePanel("Panel", spell_block, "");
  spell_block_icon.AddClass("spell_block_icon_fate");
  spell_block_icon.style.backgroundImage = 'url("file://{images}/custom_game/' + fate_name + '.png")';
  spell_block_icon.style.backgroundSize = "100%";
 
  let spell_block_text = $.CreatePanel("Label", spell_block, "");
  spell_block_text.AddClass("fate_block_text");
  spell_block_text.text = $.Localize("#" + fate_name);
 
  let spell_block_description = $.CreatePanel("Label", spell_block, "", {
    class: "fate_block_description",
    text: $.Localize("#" + fate_name + "_description"), 
  });
  let spell_block_particle = $.CreatePanel("DOTAParticleScenePanel", spell_block, "",{
    id: "hoverParticle",
    particleName: "particles/rebuild/ui/debris/debris_pitch_purple_fx.vpcf",
    lookAt: "0 0 0",
    cameraOrigin: "0 0 60",
    fov: 90,
    hittest: false});
  spell_block_particle.AddClass("hoverParticle");

  // Принудительно запускаем партикл для стабильности
  $.Schedule(0.01, function() {
    if (spell_block_particle && spell_block_particle.IsValid()) {
      spell_block_particle.StartParticles();
    }
  });


  let fate_level = 0; 

  let fate_selected_table = CustomNetTables.GetTableValue("fate_selected", String(Players.GetLocalPlayer()));
  if (fate_selected_table) { 
    if (fate_selected_table[fate_name]) {
      fate_level = fate_selected_table[fate_name];
    }
  }

  let spell_fate_levels = $.CreatePanel("Panel", spell_block, "");
  spell_fate_levels.AddClass("spell_fate_levels");

  for (let i = 1; i <= 3; i++) {
    let spell_fate_level = $.CreatePanel("Panel", spell_fate_levels, "");
    spell_fate_level.AddClass("spell_fate_level");
    if (fate_level >= i) {
      spell_fate_level.AddClass("spell_fate_level_active");
    }
  }

  if (fate_level < 3) {
    spell_block.SetPanelEvent("onactivate", function () {
      GameEvents.SendCustomGameEventToServer("player_fate_selected", { fate_name: fate_name });
      $("#FateSelectedMain").style.opacity = "0";
      $("#FateSelectedMain").SetHasClass("SpawnPanelSelected", true);
      Game.EmitSound("Flag.KillSelect");
      Game.EmitSound(fate_name);
      CancelChooseFates();
    });
  }

  spell_block.SetPanelEvent("onmouseover", function () {
    $.DispatchEvent("DOTAShowTextTooltip", spell_block, $.Localize("#" + fate_name + "_tooltip"));
  });
  spell_block.SetPanelEvent("onmouseout", function () {
    $.DispatchEvent("DOTAHideTextTooltip", spell_block);
  });
}

function CancelChooseFates() {
  delete queue.fate;

  for (let i = 0; i < $("#FateSelectedMain").GetChildCount(); i++) {
    $("#FateSelectedMain")
      .GetChild(i)
      .SetPanelEvent("onactivate", function () {});
  }

  show_queue_panels();
}

GameEvents.Subscribe("open_sphere_choose_players", open_sphere_choose_players);
// open_sphere_choose_players({"sphereList":{"1":{"name":"modifier_sphere_shield_all","level":0},"2":{"name":"modifier_sphere_miss","level":0}}})
// open_fates_choose_players()
function open_sphere_choose_players(params) {
  let body = $("#SphereSelectedMain");
  body.RemoveAndDeleteChildren();

  let block_actions = $.CreatePanel("Panel", $("#SphereSelectedMain"), "SpellActions");

  // let Choose_Your_Fate = $.CreatePanel("Label", block_actions, "");
  // Choose_Your_Fate.AddClass("Choose_Your_Sphere");
  // Choose_Your_Fate.text = $.Localize("#Choose_Your_Sphere");

  // CreateSphereRerollPanel();

  for (let i = 1; i <= Object.keys(params.sphereList).length; i++) {
    CreateSphere(params.sphereList[i]);
  }

  if (Object.values(queue).length > 0) {
    if (!queue.sphere) {
      queue.sphere = true; 
    }
  } else {
    queue.sphere = true;
    body.style.opacity = "1";
  }

  $.Schedule(0.5, function () {
    body.SetHasClass("SpawnPanelSelected", false);
    if (!params.isReroll) Game.EmitSound("sphere_choice");
  });
}

function CreateSphere(data) {
  let { name, level } = data;
  let spell_block = $.CreatePanel("Panel", $("#SphereSelectedMain"), "");
  spell_block.AddClass("sphere_block");

  let spell_block_bg = $.CreatePanel("Panel", spell_block, "");
  spell_block_bg.AddClass("sphere_block_bg");

  let spell_block_wrapper = $.CreatePanel("Panel", spell_block, "");
  spell_block_wrapper.AddClass("spell_block_icon");

  let spell_block_icon = $.CreatePanel("Panel", spell_block_wrapper, "");
  spell_block_icon.AddClass("spell_block_icon");
  spell_block_icon.style.backgroundImage = 'url("file://{images}/custom_game/spheres/' + name + '.png")';
  spell_block_icon.style.backgroundSize = "120% 110%";
  spell_block_icon.style.backgroundPosition = "center";
  spell_block_icon.style.margin = "0px";

  let spell_block_text = $.CreatePanel("Label", spell_block, "");
  spell_block_text.AddClass("spell_block_text");
  spell_block_text.AddClass("IsSphere");
  const description = $.Localize("#" + name + "_description");
  spell_block_text.text = description;

  if (description.length > 18) spell_block_text.AddClass("IsBig");
  let spell_block_particle = $.CreatePanel("DOTAParticleScenePanel", spell_block, "",{
    id: "hoverParticle",
    particleName: "particles/rebuild/ui/spheres/sphere_pitch_fx.vpcf",
    lookAt: "0 0 0",
    cameraOrigin: "0 0 60",
    fov: 90,
    hittest: false});
  spell_block_particle.AddClass("hoverParticle");

  // Принудительно запускаем партикл для стабильности
  $.Schedule(0.01, function() {
    if (spell_block_particle && spell_block_particle.IsValid()) {
      spell_block_particle.StartParticles();
    }
  });

  let spell_fate_levels = $.CreatePanel("Panel", spell_block, "");
  spell_fate_levels.AddClass("spell_sphere_levels");
  for (let i = 1; i <= 4; i++) {
    let spell_fate_level = $.CreatePanel("Panel", spell_fate_levels, "");
    spell_fate_level.AddClass("spell_fate_level");
    if (level >= i) {
      spell_fate_level.AddClass("spell_fate_level_active");
    }
  }
  spell_block.SetPanelEvent("onactivate", function () {
    GameEvents.SendCustomGameEventToServer("player_sphere_selected", { sphere_name: name });
    $("#SphereSelectedMain").style.opacity = "0";
    $("#SphereSelectedMain").SetHasClass("SpawnPanelSelected", true);
    Game.EmitSound("Flag.KillSelect");
    CancelChooseSphere();
  });

  spell_block.SetPanelEvent("onmouseover", function () {
    $.DispatchEvent("DOTAShowTextTooltip", spell_block, $.Localize("#" + name + "_description"));
  });
  spell_block.SetPanelEvent("onmouseout", function () {
    $.DispatchEvent("DOTAHideTextTooltip", spell_block);
  });
}

function CancelChooseSphere() {
  delete queue.sphere;

  for (let i = 0; i < $("#SphereSelectedMain").GetChildCount(); i++) {
    $("#SphereSelectedMain")
      .GetChild(i)
      .SetPanelEvent("onactivate", function () {});
  }

  show_queue_panels();
}

function CreateSphereRerollPanel() {
  const reroll_count = playerInfo.getRollPlayer();
  let reroll_block = $.CreatePanel("Panel", $("#SphereSelectedMain").FindChildTraverse("SpellActions"), "", {
    class: "RerollBlock",
  });

  if (reroll_count > 0) reroll_block.AddClass("IsActive");

  reroll_block.AddClass("reroll_block");

  let reroll_block_text = $.CreatePanel("Label", reroll_block, "", {
    class: "RerollText",
  });
  reroll_block_text.AddClass("reroll_block_text");
  reroll_block_text.text = GetTextForRerollPanel(reroll_count);

  let reroll_block_image = $.CreatePanel("Panel", reroll_block, "");
  reroll_block_image.AddClass("reroll_block_image");

  reroll_block.SetPanelEvent("onactivate", function () {
    if (!reroll_block.BHasClass("IsActive")) return;
    GameEvents.SendCustomGameEventToServer("reroll_spheres", { reroll: reroll_count });
    $("#SpellSelectedMain").style.opacity = "0";
    Game.EmitSound("Flag.RollChoose");
  });
}

GameEvents.Subscribe("open_talents_choose_players", open_talents_choose_players);

const RARITY = {
  COMMON: 1,
  RARE: 2,
  EPIC: 4,
};
const ParticleForRarity = {
  [RARITY.COMMON] : "particles/rebuild/ui/books/default/sphere_pitch_fx_default.vpcf",
  [RARITY.RARE] : "particles/rebuild/ui/books/rare/sphere_pitch_fx_rare.vpcf",
  [RARITY.EPIC] : "particles/rebuild/ui/books/epic/sphere_pitch_fx_epic.vpcf", 
} 
const rarityClass = {
  [RARITY.COMMON]: "IsCommon",
  [RARITY.RARE]: "IsRare",
  [RARITY.EPIC]: "IsEpic", 
}; 
// open_talents_choose_players({
//   upgrades: {
//     reroll: true,
//     upgrade_rarity: RARITY.EPIC,
//     choices: {
//       1: {
//         upgrade_name: "cooldown_and_manacost",
//         ability_name: "tinker_laser",
//         value: 10,
//         operator: OPERATOR.ADD,
//         rarity: RARITY.COMMON,
//         count: 1
//       },
//       2: {
//         upgrade_name: "damage",
//         ability_name: "tinker_march_of_the_machines",
//         value: 15,
//         operator: OPERATOR.MULTIPLY,
//         rarity: RARITY.RARE,
//         count: 2
//       },
//       3: {
//         upgrade_name: "damage_absorb",
//         ability_name: "tinker_defense_matrix",
//         value: 20,
//         operator: OPERATOR.ADD,
//         rarity: RARITY.EPIC,
//         count: 3
//       }
//     }
//   }
// });

function open_talents_choose_players(params) {
  let body = $("#TalentsSelectedMain");
  body.RemoveAndDeleteChildren();
  const isReroll = params.upgrades.reroll;
  const selection_rarity = params.upgrades.upgrade_rarity || RARITY.COMMON;
  const imageBooks = {
    [RARITY.COMMON]: "item_usual_book",
    [RARITY.RARE]: "item_rare_book",
    [RARITY.EPIC]: "item_epic_book",
  };
  let actions_block = $.CreatePanel("Panel", $("#TalentsSelectedMain"), "TalentActions");
  actions_block.AddClass(rarityClass[selection_rarity]);
 
  let TitleBlock = $.CreatePanel("Panel", actions_block, "TitleBlock");

  // let Choose_Your_Fate = $.CreatePanel("Label", TitleBlock, "");
  // Choose_Your_Fate.AddClass("Choose_Your_Talent");
  // Choose_Your_Fate.text = $.Localize("#Choose_Your_Talent");
  // const itemPreviewImage = $.CreatePanel("Panel", TitleBlock, "ImageBookTalent")
  // itemPreviewImage.style.backgroundImage = `url("file://{resources}/images/items/${imageBooks[selection_rarity]}.png")`;
  // itemPreviewImage.style.backgroundSize = "200% 101%";
  // itemPreviewImage.style.backgroundRepeat = "no-repeat";
  // itemPreviewImage.style.backgroundPosition = "50% 60%";

  CreateTalentRerollPanel(actions_block);

  for (let i = 1; i <= Object.keys(params.upgrades.choices).length; i++) {
    CreateTalent(params.upgrades, params.upgrades.choices[i]);
  }

  if (isReroll) {
    $("#TalentsSelectedMain").style.opacity = "1";
  } else {
    if (Object.values(queue).length > 0) {
      if (!queue.talent) {
        queue.talent = true;
      }
    } else {
      queue.talent = true;
      body.style.opacity = "1";
    }
  }

  $.Schedule(0.5, function () {
    body.SetHasClass("SpawnPanelSelected", false);
  });
}

function CreateTalentRerollPanel(body) {
  const reroll_count = playerInfo.getRollPlayer();
  let reroll_block = $.CreatePanel("Panel", body, "", {
    class: "RerollBlock",
  });

  if (reroll_count > 0) reroll_block.AddClass("IsActive");

  reroll_block.AddClass("reroll_talent_block");

  let reroll_block_text = $.CreatePanel("Label", reroll_block, "", {
    class: "RerollText",
  });
  reroll_block_text.AddClass("reroll_talent_block_text");
  reroll_block_text.text = GetTextForRerollPanel(reroll_count);

  let reroll_block_image = $.CreatePanel("Panel", reroll_block, "");
  reroll_block_image.AddClass("reroll_talent_block_image");

  reroll_block.SetPanelEvent("onactivate", function () {
    if (!reroll_block.BHasClass("IsActive")) return;
    GameEvents.SendCustomGameEventToServer("reroll_talents", {});
    $("#TalentsSelectedMain").style.opacity = "0";
    Game.EmitSound("Flag.RollChoose");
  });
}
function UppercaseConvert(line) {
  line = line.toLowerCase();
  line = line.charAt(0).toUpperCase() + line.substring(1);
  return line;
}
function CreateTalent(upgradeInfo, data) {
  let { upgrade_name, ability_name, value, operator, rarity, count, max_count } = data;
  let { upgrade_rarity } = upgradeInfo;
  let spell_block = $.CreatePanel("Panel", $("#TalentsSelectedMain"), "");
  spell_block.AddClass("talent_block");

  const selection_rarity = upgrade_rarity || RARITY.COMMON;
  const min_rarity = data.min_rarity || rarity || RARITY.COMMON;
  const current_count = (count || 0) / min_rarity;
  const hero_idx = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
  let max_upgrades_count = current_count + selection_rarity;
  
  // Проверка: если max_count задан и max_upgrades_count превышает его - ограничиваем
  if (max_count && max_upgrades_count > max_count) {
    max_upgrades_count = max_count;
  }
  
  // Если талант уже на максимуме - делаем его неактивным
  const is_maxed_out = max_count && current_count >= max_count;
  let spell_block_bg = $.CreatePanel("Panel", spell_block, "");
  spell_block_bg.AddClass("talent_block_bg");
  spell_block_bg.AddClass(rarityClass[selection_rarity]);
  
  // Визуально отключаем если талант на максимуме
  if (is_maxed_out) {
    spell_block.AddClass("talent_maxed_out");
    spell_block_bg.style.opacity = "0.3";
  }

  let spell_block_wrapper = $.CreatePanel("Panel", spell_block, "");
  spell_block_wrapper.AddClass("talent_block_icon");
  spell_block_wrapper.style.backgroundColor = "#010329";
  spell_block_wrapper.style.borderRadius = "2px";
  let spell_block_icon = $.CreatePanel("DOTAAbilityImage", spell_block_wrapper, "", {
    abilityname: ability_name,
  });

  let title = $.CreatePanel("Label", spell_block, "", {
    class: "talent_title",
    text: $.Localize("#DOTA_Tooltip_ability_" + ability_name),
  });

  let spell_block_text = $.CreatePanel("Label", spell_block, "", {
    class: "talent_description",
    html: true,
  });

  let levels = $.CreatePanel("Label", spell_block, "", {
    class: "talent_levels",
    text: `с ${current_count}  уровень до ${max_upgrades_count} уровень`,
  });
  // Частица в зависимости от редкости книги (с фоллбэком на COMMON если undefined)
  let particleName = ParticleForRarity[selection_rarity] || ParticleForRarity[RARITY.COMMON];

  let spell_block_particle = $.CreatePanel("DOTAParticleScenePanel", spell_block, "",{
    id: "hoverParticle",
    particleName: particleName,
    lookAt: "0 0 0",
    cameraOrigin: "0 0 60",
    fov: 90,
    hittest: false});
  spell_block_particle.AddClass("hoverParticle");

  // Запускаем партикл сразу
  if (spell_block_particle && spell_block_particle.IsValid()) {
    spell_block_particle.StartParticles();
  }
  let loc_upgrade = "";
  let b_check_hidden = true;
  let multiply_value;
  if (operator == OPERATOR.ADD) {
    value = CalculateUpgradeValue(hero_idx, value, max_upgrades_count - current_count, data);
  } else if (operator == OPERATOR.MULTIPLY) {
    multiply_value = GetMultiplyValueDiff(data, hero_idx, value, max_upgrades_count, current_count);
  }
  const localize_upgrade = (_ability_name, _upgrade_name, b_check_orb_generic_localize) => {
    let check_localize = (key) => {
      let loc_line = $.Localize(`#${key}`);

      if (loc_line != `#${key}`) {
        loc_upgrade = loc_line;
      }
    };

    check_localize(`${_upgrade_name}_talent`);
    check_localize(`DOTA_Tooltip_ability_${_ability_name}_${_upgrade_name}`);
    check_localize(`Custom_Talent_ability_${_ability_name}_${_upgrade_name}`);
    check_localize(`DOTA_Tooltip_ability_${_ability_name.replace("_lua", "")}_${_upgrade_name}`);
    check_localize(`Custom_Talent_ability_${_ability_name.replace("_lua", "")}_${_upgrade_name}`);
    if (b_check_orb_generic_localize) {
      check_localize(_upgrade_name);

      if (!b_check_hidden) {
        check_localize(`DOTA_Tooltip_demo_generic_orb_${_upgrade_name}`);
        loc_upgrade = loc_upgrade.replace(/<b>.*<\/b>/, "");
      }
    }
  };

  localize_upgrade(ability_name, upgrade_name);

  if (loc_upgrade == "") localize_upgrade(ability_name, upgrade_name);
  if (!b_check_hidden && loc_upgrade == "") loc_upgrade = upgrade_name;
  if (loc_upgrade == "") return;

  const is_pct = loc_upgrade.charAt(0) == "%";

  loc_upgrade = loc_upgrade.replace(/%|:/g, "").trim();

  let base_line_localized = $.Localize(`#talent_description_${value > 0 && reverse_increment.indexOf(upgrade_name) < 0 ? `inc` : `dec`}`);
  const line = `<b>${UppercaseConvert(loc_upgrade)}</b> ${base_line_localized} <b>${Math.abs(multiply_value || value)}${is_pct ? "%" : ""}</b>`;

  spell_block_text.text = line;

  let spell_fate_levels = $.CreatePanel("Panel", spell_block, "");
  spell_fate_levels.AddClass("spell_fate_levels");

  spell_block.SetPanelEvent("onactivate", function () {
    $.Msg("[TALENT CLICK] ability:", ability_name, "upgrade:", upgrade_name, "is_maxed:", is_maxed_out, "current:", current_count, "max:", max_count);
    
    // Блокируем выбор если талант на максимуме
    if (is_maxed_out) {
      $.Msg("⚠️ Талант достиг максимального уровня!");
      return;
    }
    
    $.Msg("[TALENT CLICK] Отправка на сервер...");
    GameEvents.SendCustomGameEventToServer("player_talent_selected", { upgrade_name, ability_name });
    $("#TalentsSelectedMain").style.opacity = "0";
    $("#TalentsSelectedMain").SetHasClass("SpawnPanelSelected", true);
    Game.EmitSound("Flag.KillSelect");
    CancelChooseTalents();
  });
}

function CancelChooseTalents() {
  delete queue.talent;

  for (let i = 0; i < $("#TalentsSelectedMain").GetChildCount(); i++) {
    $("#TalentsSelectedMain")
      .GetChild(i)
      .SetPanelEvent("onactivate", function () {});
  }

  show_queue_panels();
}

function CalculateUpgradeValue(ent_index, value, count, upgrade_data) {
  upgrade_data.operator = upgrade_data.operator || OPERATOR.ADD;
  let result = 0;
  let final_multiplier = 1;

  if (upgrade_data.talents && ent_index) {
    Object.entries(upgrade_data.talents).forEach(([talent_name, operation]) => {
      let operator, value;
      if (typeof operation == "number") {
        operator = "+";
        value = operation;
      } else {
        operator = operation.charAt(0);
        value = Number(operation.slice(1));
      }
      const talent = Entities.GetAbilityByName(ent_index, talent_name);
      if (Abilities.GetLevel(talent) > 0) {
        if (operator == "+") result += value;
        else if (operator == "x") final_multiplier *= value;
      }
    });
  }

  let upgrade_value = value * final_multiplier;

  if (upgrade_data.operator == OPERATOR.ADD) {
    if (upgrade_data.increment) {
      if (upgrade_data.current_count == undefined) upgrade_data.current_count = 0;
      const total_count = upgrade_data.current_count + count;
      result += upgrade_value * total_count;

      result =
        CalculateIncrementValue(upgrade_value, upgrade_data, total_count) - CalculateIncrementValue(upgrade_value, upgrade_data, upgrade_data.current_count);
    } else result += upgrade_value * count;
  } else if (upgrade_data.operator == OPERATOR.MULTIPLY) {
    let target = upgrade_data.multiplicative_target !== undefined ? upgrade_data.multiplicative_target : 100;
    result += upgrade_data.multiplicative_base_value || 0;

    const abs_upgrade_value = Math.abs(upgrade_value / (result - target));
    result = (target - result) * (1 - Math.pow(1 - abs_upgrade_value, count));
  }

  return isNaN(result) ? 0 : Math.round(result * 100) / 100;
}

function GetMultiplyValueDiff(upgrade_definition, hero_idx, value, max, count_for_diff) {
  const multiply_value_calc = (count) => {
    return CalculateUpgradeValue(hero_idx, value, count, upgrade_definition);
  };
  return Math.round((multiply_value_calc(max) - multiply_value_calc(count_for_diff)) * 100) / 100;
}
