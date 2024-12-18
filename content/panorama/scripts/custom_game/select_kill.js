GameEvents.Subscribe("select_kill_on_start_game", Init)

function Init()
{
    $("#SelectKillMain").style.opacity = "1"
    $("#SelectKillButton").SetPanelEvent("onactivate", function() 
    { 
        $("#SelectKillButton").SetPanelEvent("onactivate", function() {}); 
        GameEvents.SendCustomGameEventToServer( "select_kills_event", {} );
        $("#SelectKillMain").style.opacity = "0"
        Game.EmitSound("Flag.KillSelect")
    });
    $("#DeclineKillButton").SetPanelEvent("onactivate", function() 
    { 
        $("#SelectKillMain").style.opacity = "0"
        Game.EmitSound("Flag.KillDeciline")
    });
}   