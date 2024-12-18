local particles = 
{
    "particles/overhead_particle/leader_overhead.vpcf",
    "particles/econ/items/tinker/boots_of_travel/teleport_start_bots_ground_flash.vpcf",
    "particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015_ground_flash.vpcf",
    "particles/units/heroes/hero_invoker/invoker_alacrity.vpcf",
    "particles/units/heroes/hero_invoker/invoker_emp.vpcf",
    "particles/units/heroes/hero_invoker/invoker_ghost_walk.vpcf",
    "particles/units/heroes/hero_invoker/invoker_ghost_walk_debuff.vpcf",
    "particles/units/heroes/hero_invoker/invoker_sun_strike_team.vpcf",
    "particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf",
    "particles/units/heroes/hero_invoker/invoker_cold_snap.vpcf",
    "particles/units/heroes/hero_invoker/invoker_cold_snap_status.vpcf",
    "particles/units/heroes/hero_invoker/invoker_cold_snap.vpcf",
    "particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf",
    "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
    "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf",
    "particles/units/heroes/hero_invoker/invoker_tornado.vpcf",
    "particles/units/heroes/hero_invoker/invoker_tornado_child.vpcf",
    "particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf",
    "particles/units/heroes/hero_invoker/invoker_deafening_blast_knockback_debuff.vpcf",
    "particles/units/heroes/hero_invoker/invoker_deafening_blast_disarm_debuff.vpcf",
    "particles/status_fx/status_effect_iceblast.vpcf",
    "particles/units/heroes/hero_invoker/invoker_ice_wall.vpcf",
    "particles/units/heroes/hero_invoker/invoker_ice_wall_debuff.vpcf",
    "particles/status_fx/status_effect_frost.vpcf",
    "particles/units/heroes/hero_tinker/tinker_rearm.vpcf",
    "particles/econ/items/necrolyte/necro_ti9_immortal/necro_ti9_immortal_ambient",
    "particles/head_flag.vpcf",
    "particles/units/heroes/hero_arc_warden/arc_warden_tempest_cast.vpcf",
    "particles/ui/ui_game_start_hero_spawn.vpcf",
    "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf",
    "particles/djalal/custom_timer.vpcf",
    "particles/morph_head_skull.vpcf",
    "particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf",
    "particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf",
    "particles/units/heroes/hero_morphling/morphling_waveform.vpcf",
    "particles/units/heroes/hero_crystalmaiden/maiden_frostbite.vpcf",
    "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf",
    "particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf",
    "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf",
    "particles/units/heroes/hero_muerta/muerta_parting_shot_projectile.vpcf",
    "particles/items2_fx/refresher.vpcf",
    "particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf",
    "particles/units/heroes/hero_techies/techies_blast_off.vpcf",
    "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf",
    "particles/acrona/ghost_sword/ghost_sword_projectile_juggernaut.vpcf",
    "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf",
    "particles/units/heroes/hero_antimage/antimage_spellshield.vpcf",
    "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf",
    "particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance.vpcf",
    "particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf",
    "particles/acrona/ghost_sword/ghost_sword_ghosts.vpcf",
    "models/flag/particle/banner_fire_main.vpcf",
    "models/flag/particle/banner2_fire_main.vpcf",
    "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf",
    "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf",
    "particles/status_fx/status_effect_snapfire_slow.vpcf",
    "particles/status_fx/status_effect_troll_warlord_battletrance.vpcf",
    "particles/hw_fx/golem_terror_status_effect.vpcf",
    "particles/hw_fx/golem_terror_debuff.vpcf",
    "particles/hw_fx/golem_terror.vpcf",
    "particles/hw_fx/golem_terror_telegraph_guardian.vpcf",
    "particles/hw_fx/golem_terror_debuff.vpcf",
    "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf",
    "particles/generic_timer.vpcf",
    "particles/head_flag.vpcf",
    "particles/econ/items/lina/lina_head_headflame/lina_headflame.vpcf",
    "particles/econ/items/lina/lina_head_headflame/lina_flame_hand_dual_headflame.vpcf",
    "particles/djalal/custom_timer.vpcf",
}

local sounds = 
{
    "soundevents/game_sounds_heroes/game_sounds_legion_commander.vsndevts",
    "soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts",
    "soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts",
    "soundevents/game_sounds_heroes/game_sounds_wisp.vsndevts",
    "soundevents/game_sounds_custom_announcer.vsndevts",
    "soundevents/voscripts/game_sounds_vo_warlock_golem.vsndevts",
}

local function PrecacheEverythingFromTable( context, kvtable)
    for key, value in pairs(kvtable) do
        if type(value) == "table" then
            if not string.find(key, "npc_precache_") then
               PrecacheEverythingFromTable( context, value )
            end
        else
            if string.find(value, "vpcf") then
                PrecacheResource( "particle", value, context)
            end
            if string.find(value, "vmdl") then
                PrecacheResource( "model", value, context)
            end
            if string.find(value, "vsndevts") then            
                PrecacheResource( "soundfile", value, context)
            end
        end
    end
end

function PrecacheEverythingFromKV( context )
    local kv_files = 
    {
        "scripts/npc/npc_units_custom.txt",
        "scripts/npc/npc_items_custom.txt",
    }
    for _, kv in pairs(kv_files) do
        local kvs = LoadKeyValues(kv)
        if kvs then
            PrecacheEverythingFromTable( context, kvs)
        end
    end
end

return function(context)
    PrecacheEverythingFromKV(context)
    for _, p in pairs(particles) do
        PrecacheResource("particle", p, context)
    end
    for _, p in pairs(sounds) do
        PrecacheResource("soundfile", p, context)
    end
    PrecacheResource( "particle_folder", "particles/neutral_fx/", context )
    PrecacheResource( "particle_folder", "particles/items_fx/", context )
    PrecacheResource( "particle_folder", "particles/items5_fx/", context )
    PrecacheResource( "particle_folder", "particles/items4_fx/", context )
    PrecacheResource( "particle_folder", "particles/items3_fx/", context )
    PrecacheResource( "particle_folder", "particles/items2_fx/", context )
    local heroes = LoadKeyValues("scripts/npc/dota_heroes.txt")
    for k,v in pairs(heroes) do
        PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_" .. k:gsub("npc_dota_hero_","") ..".vsndevts", context )  
        PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_" .. k:gsub("npc_dota_hero_","") ..".vsndevts", context ) 
    end
end



