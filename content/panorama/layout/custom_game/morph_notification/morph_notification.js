GameEvents.Subscribe( 'start_morphling_notification', start_morphling_notification);
function start_morphling_notification()
{
    $("#MorphNotificationSpawn").style.visibility = "visible"
    $("#MorphNotificationSpawn").SetHasClass("MorphNotificationSpawnOpacity", true);
    $.Schedule( 4, () => 
    { 
        $("#MorphNotificationSpawn").style.visibility = "collapse"
        $("#MorphNotificationSpawn").SetHasClass("MorphNotificationSpawnOpacity", false);
    })
}

GameEvents.Subscribe( 'start_morphling_timer', start_morphling_timer);
function start_morphling_timer(data)
{
    $("#MorphTimerPanel").style.opacity = "1"
    tick_morphling_timer(data)
}

GameEvents.Subscribe( 'tick_morphling_timer', tick_morphling_timer);
function tick_morphling_timer(data)
{
    let time = Math.floor(data.time)
    var min = Math.trunc((time)/60) 
    var sec_n =  (time) - 60*Math.trunc((time)/60) 
    var hour = String( Math.trunc((min)/60) )
    var min = String(min - 60*( Math.trunc(min/60) ))
    var sec = String(sec_n)
    if (sec_n < 10) 
    {
        sec = '0' + sec
    }
    $("#MorphTimer").text = min + ':' + sec
}

GameEvents.Subscribe( 'end_morphling_timer', end_morphling_timer);
function end_morphling_timer()
{
    $("#MorphTimerPanel").style.opacity = "0"
}

GameEvents.Subscribe( 'kill_morphling_notification', kill_morphling_notification);
function kill_morphling_notification(data)
{
    let teamDetails = Game.GetTeamDetails( data.team )
    $("#MorphNotificationKilled").text = $.Localize( teamDetails.team_name ) + " " + $.Localize( "#morphling_killed" )
    $("#MorphNotificationKilled").style.visibility = "visible"
    $("#MorphNotificationKilled").SetHasClass("MorphNotificationSpawnOpacity", true);
    $.Schedule( 4, () => 
    { 
        $("#MorphNotificationKilled").style.visibility = "collapse"
        $("#MorphNotificationKilled").SetHasClass("MorphNotificationSpawnOpacity", false);
    })
}

GameEvents.Subscribe( 'out_morphling_notification', out_morphling_notification);
function out_morphling_notification(data)
{
    $("#MorphNotificationOut").style.visibility = "visible"
    $("#MorphNotificationOut").SetHasClass("MorphNotificationSpawnOpacity", true);
    $.Schedule( 5, () => 
    { 
        $("#MorphNotificationOut").style.visibility = "collapse"
        $("#MorphNotificationOut").SetHasClass("MorphNotificationSpawnOpacity", false);
    })
}