"use strict";

var dotaHud = FindDotaHudElement("HUDElements");

class HighFive {
    constructor() {
        this.RemoveOnRestart();
        this.playerId = Players.GetLocalPlayer();
        this.button = this.CreateButton();
        this.background = this.button ? this.button.FindChildTraverse("CooldownBackground") : null;
        this.label = this.button ? this.button.FindChildTraverse("CooldownLabel") : null;
        this.HighFiveKeyButtonLabel = this.button ? this.button.FindChildTraverse("HighFiveKeyButtonLabel") : null;
        this.heroIndex = Game.GetPlayerInfo(this.playerId).player_selected_hero_entity_index;
        this.keybind_button = null;
        // this.Tick();
		GameEvents.Subscribe("dota_player_update_selected_unit", (() => this.OnUpdateUnit()))
		GameEvents.Subscribe("dota_player_update_query_unit", (() => this.OnUpdateUnit()))
    }
    RemoveOnRestart() {
        dotaHud.FindChildrenWithClassTraverse("__HF_HighFive_Remove__").forEach(panel => panel.DeleteAsync(0));
    }
    CreateButton() {
        var container = dotaHud.FindChildrenWithClassTraverse("TertiaryAbilityContainer")[0];
        if (!container) {
            $.Msg("HighFive: TertiaryAbilityContainer not found");
            return null;
        }
        var high_five = $.CreatePanel("Button", $.GetContextPanel(), "HighFive", { class: "__HF_HighFive_Remove__" });
        high_five.BLoadLayoutSnippet("HighFiveSnippet");
        high_five.SetPanelEvent("onactivate", () => this.HighFive());
        high_five.SetPanelEvent("onmouseover", () => {
            var entindex = Players.GetLocalPlayerPortraitUnit();
            $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", high_five, "high_five", entindex);
        });
        high_five.SetPanelEvent("onmouseout", () => $.DispatchEvent("DOTAHideAbilityTooltip", high_five));
        high_five.SetParent(container);
        return high_five;
    }
    HighFive()
    {
        var selected_index = Players.GetLocalPlayerPortraitUnit();
        GameEvents.SendCustomGameEventToServer( "high_five", {PlayerID : this.playerId, selected_index : selected_index} );
    }
    HighFiveBind()
    {
        var selected_index = Players.GetLocalPlayerPortraitUnit();
        GameEvents.SendCustomGameEventToServer( "high_five", {PlayerID : this.playerId, selected_index : selected_index} );
    }
	OnUpdateUnit() {
		$.Schedule(0.1, () => {
			var selected_index = Players.GetLocalPlayerPortraitUnit();
			if (this.button) {
                this.button.SetHasClass("Hidden", !Entities.IsRealHero(selected_index));
            }
			this.heroIndex = Game.GetPlayerInfo(this.playerId).player_selected_hero_entity_index;
			// $.Schedule(Game.GetGameFrameTime(), () => this.Tick());
		})
	}
    // Tick() {
    //     var selected_index = Players.GetLocalPlayerPortraitUnit();
    //     this.button.SetHasClass("Hidden", !Entities.IsRealHero(selected_index));
    //     this.heroIndex = Game.GetPlayerInfo(this.playerId).player_selected_hero_entity_index;
    //     $.Schedule(Game.GetGameFrameTime(), () => this.Tick());
    // }
}
var highfive = new HighFive();

class SummonMount {
    constructor() {
        this.RemoveOnRestart();
        this.playerId = Players.GetLocalPlayer();
        this.button = this.CreateButton();
        this.background = this.button ? this.button.FindChildTraverse("CooldownBackground") : null;
        this.label = this.button ? this.button.FindChildTraverse("CooldownLabel") : null;
        this.MountKeyButtonLabel = this.button ? this.button.FindChildTraverse("MountKeyButtonLabel") : null;
        this.heroIndex = Game.GetPlayerInfo(this.playerId).player_selected_hero_entity_index;
        this.keybind_button = null;
        GameEvents.Subscribe("dota_player_update_selected_unit", (() => this.OnUpdateUnit()))
        GameEvents.Subscribe("dota_player_update_query_unit", (() => this.OnUpdateUnit()))
        $.Msg("SummonMount: Constructor");
    }
    RemoveOnRestart() {
        dotaHud.FindChildrenWithClassTraverse("__HF_Mount_Remove__").forEach(panel => panel.DeleteAsync(0));
    }
    CreateButton() {
        var container = dotaHud.FindChildrenWithClassTraverse("TertiaryAbilityContainer")[0];
        if (!container) {
            $.Msg("SummonMount: TertiaryAbilityContainer not found");
            return null;
        }
        var summon_mount = $.CreatePanel("Button", $.GetContextPanel(), "SummonMount", { class: "__HF_Mount_Remove__" });
        summon_mount.BLoadLayoutSnippet("SummonMountSnippet");
        summon_mount.SetPanelEvent("onactivate", () => this.SummonMount());
        summon_mount.SetPanelEvent("onmouseover", () => {
            var entindex = Players.GetLocalPlayerPortraitUnit();
            $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", summon_mount, "summon_mount", entindex);
        });
        summon_mount.SetPanelEvent("onmouseout", () => $.DispatchEvent("DOTAHideAbilityTooltip", summon_mount));
        summon_mount.SetParent(container);
        return summon_mount;
    } 
    SummonMount()
    {
        var selected_index = Players.GetLocalPlayerPortraitUnit();
        GameEvents.SendCustomGameEventToServer( "summon_mount", {PlayerID : this.playerId, selected_index : selected_index} );
    }
    SummonMountBind()
    {
        var selected_index = Players.GetLocalPlayerPortraitUnit();
        GameEvents.SendCustomGameEventToServer( "summon_mount", {PlayerID : this.playerId, selected_index : selected_index} );
    }
    OnUpdateUnit() {
        $.Schedule(0.1, () => {
            var selected_index = Players.GetLocalPlayerPortraitUnit();
            if (this.button) {
                this.button.SetHasClass("Hidden", !Entities.IsRealHero(selected_index)); 
            }
            this.heroIndex = Game.GetPlayerInfo(this.playerId).player_selected_hero_entity_index;
        })
    }
}
var summonmount = new SummonMount();

function GetDotaHud()
{
    let hPanel = $.GetContextPanel();

    while ( hPanel && hPanel.id !== 'Hud')
    {
        hPanel = hPanel.GetParent();
    }

    if (!hPanel)
    {
        throw new Error('Could not find Hud root from panel with id: ' + $.GetContextPanel().id);
    }

    return hPanel;
}
function FindDotaHudElement(sId)
{
    return GetDotaHud().FindChildTraverse(sId);
}
