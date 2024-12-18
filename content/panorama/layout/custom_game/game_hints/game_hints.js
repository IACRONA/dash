var NOTIFICATION_TIMER = 10

GameEvents.Subscribe("warsong_game_hint_create", warsong_game_hint_create);

function warsong_game_hint_create(data)
{
    CreateHint(data.text)
}

function CreateHint(text)
{ 
    let HintPanel = $.CreatePanel("Panel", $("#HintsContainer"), "")
    HintPanel.AddClass("HintPanel")
    HintPanel.AddClass("VisibleHint")

    let HintLabel = $.CreatePanel("Label", HintPanel, text)
    HintLabel.AddClass("HintLabel")
    HintLabel.html = true
    HintLabel.text = $.Localize("#"+text)
    HintPanel.DeleteAsync(NOTIFICATION_TIMER+1)

    let schedule_id = $.Schedule(NOTIFICATION_TIMER, function () 
    {
        if (HintPanel)
        {
            HintPanel.RemoveClass("VisibleHint")
        }
    });

    let Close = $.CreatePanel("Panel", HintPanel, "")
    Close.AddClass("Close")

    Close.SetPanelEvent("onactivate", function()
    {
        $.CancelScheduled(schedule_id)
        HintPanel.DeleteAsync(0)
    })

    Game.EmitSound("ui.npe_objective_given")
}