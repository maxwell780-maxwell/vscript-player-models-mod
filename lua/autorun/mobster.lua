player_manager.AddValidModel( "!tf_mobster",			"models/vip_mobster/player/mobster.mdl" )
player_manager.AddValidHands( "!tf_mobster",			"models/vip_mobster/weapons/c_mobster_arms.mdl",			0, "0000000" )

list.Set( "PlayerOptionsAnimations", "!tf_mobster", { "taunt01", "layer_taunt_yetipunch", "taunt_highfivestart", "taunt_dosido_intro", "taunt_dosido_dance", "taunt02", "layer_taunt_rps_scissors_lose", "layer_taunt_rps_rock_lose", "layer_taunt_rps_paper_lose", "layer_taunt_rps_paper_win", "layer_taunt_rps_rock_win", "layer_taunt_rps_scissors_win", "taunt_russian", "layer_taunt_laugh", "taunt05", "taunt06", "scout_taunt_replay", "taunt_aerobic_a", "taunt_aerobic_b", "layer_taunt_flip_success_receiver", "stand_melee", "taunt_conga", "stand_loser", "taunt_highfivesuccessfull", "stand_item1" } )

local ActivityTranslateFixTF2 = {}

hook.Add("TranslateActivity", "mobstersCustomAnimations", function(pl, act)
    if not IsValid(pl) then return end

    local weapon = pl:GetActiveWeapon()
    if not IsValid(weapon) then return end

    local holdtype = weapon:GetHoldType()

    -- Saxton Hale and vip models
    if pl:GetModel() == "models/vip_mobster/player/mobster.mdl" then

        -- Handle the holdtype and specific animation behavior
        if holdtype == "normal" or holdtype == "passive" then
            -- Play loser animations for "normal" or "passive" holdtypes
            ActivityTranslateFixTF2[ACT_MP_STAND_IDLE] = pl:GetSequenceActivity(pl:LookupSequence("stand_LOSER"))
            ActivityTranslateFixTF2[ACT_MP_RUN] = pl:GetSequenceActivity(pl:LookupSequence("run_LOSER"))
            ActivityTranslateFixTF2[ACT_MP_WALK] = pl:GetSequenceActivity(pl:LookupSequence("run_LOSER"))
            ActivityTranslateFixTF2[ACT_MP_SWIM] = pl:GetSequenceActivity(pl:LookupSequence("swim_loser"))
            ActivityTranslateFixTF2[ACT_MP_AIRWALK] = pl:GetSequenceActivity(pl:LookupSequence("airwalk_LOSER"))
            ActivityTranslateFixTF2[ACT_MP_CROUCH_IDLE] = pl:GetSequenceActivity(pl:LookupSequence("crouch_LOSER"))
            ActivityTranslateFixTF2[ACT_MP_CROUCHWALK] = pl:GetSequenceActivity(pl:LookupSequence("crouch_walk_melee"))
			ActivityTranslateFixTF2[ACT_LAND] = pl:GetSequenceActivity(pl:LookupSequence("jumpland_loser"))
        elseif
            holdtype == "melee" or holdtype == "melee2" then
            -- For these melee-related holdtypes, keep the original melee animations
            ActivityTranslateFixTF2[ACT_MP_STAND_IDLE] = pl:GetSequenceActivity(pl:LookupSequence("stand_melee"))
            ActivityTranslateFixTF2[ACT_MP_RUN] = ACT_MP_RUN_MELEE
            ActivityTranslateFixTF2[ACT_MP_WALK] = ACT_MP_RUN_MELEE
            ActivityTranslateFixTF2[ACT_MP_AIRWALK] = pl:GetSequenceActivity(pl:LookupSequence("airwalk_melee"))
            ActivityTranslateFixTF2[ACT_MP_CROUCH_IDLE] = ACT_MP_CROUCH_MELEE
            ActivityTranslateFixTF2[ACT_MP_CROUCHWALK] = ACT_MP_CROUCHWALK_MELEE
			ActivityTranslateFixTF2[ACT_MP_ATTACK_STAND_PRIMARYFIRE] 						= pl:GetSequenceActivity(pl:LookupSequence("attack_stand_melee"))
			ActivityTranslateFixTF2[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] 						= pl:GetSequenceActivity(pl:LookupSequence("attack_stand_melee"))
			ActivityTranslateFixTF2[ACT_MP_RELOAD_STAND] = ACT_MP_RELOAD_STAND_MELEE
			ActivityTranslateFixTF2[ACT_MP_RELOAD_CROUCH] = ACT_MP_RELOAD_CROUCH_MELEE
			ActivityTranslateFixTF2[ACT_MP_JUMP] = ACT_MP_JUMP_START_MELEE
			ActivityTranslateFixTF2[ACT_MP_SWIM] = ACT_MP_SWIM_MELEE
			ActivityTranslateFixTF2[ACT_MP_JUMP_START] = ACT_MP_JUMP_START_MELEE
			ActivityTranslateFixTF2[ACT_MP_JUMP_FLOAT] = ACT_MP_JUMP_FLOAT_MELEE
			ActivityTranslateFixTF2[ACT_LAND] = ACT_MP_JUMP_LAND_MELEE

			elseif holdtype == "slam" then
			ActivityTranslateFixTF2[ACT_MP_ATTACK_STAND_PRIMARYFIRE] 						= pl:GetSequenceActivity(pl:LookupSequence("attackstand_item1"))
			ActivityTranslateFixTF2[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] 						= pl:GetSequenceActivity(pl:LookupSequence("attackcrouch_item1"))
			ActivityTranslateFixTF2[ACT_MP_RELOAD_STAND] 						= pl:GetSequenceActivity(pl:LookupSequence("reloadstand_ITEM2"))
			ActivityTranslateFixTF2[ACT_MP_STAND_IDLE] = pl:GetSequenceActivity(pl:LookupSequence("stand_item1"))
			ActivityTranslateFixTF2[ACT_MP_RUN] = pl:GetSequenceActivity(pl:LookupSequence("run_item1"))
			ActivityTranslateFixTF2[ACT_MP_WALK] = pl:GetSequenceActivity(pl:LookupSequence("run_item1"))
			ActivityTranslateFixTF2[ACT_MP_JUMP] = pl:GetSequenceActivity(pl:LookupSequence("a_jumpstart_item1"))
			ActivityTranslateFixTF2[ACT_MP_JUMP_FLOAT] = pl:GetSequenceActivity(pl:LookupSequence("a_jumpfloat_item1"))
			ActivityTranslateFixTF2[ACT_MP_SWIM] = pl:GetSequenceActivity(pl:LookupSequence("swim_item1"))
			ActivityTranslateFixTF2[ACT_MP_CROUCHWALK] = pl:GetSequenceActivity(pl:LookupSequence("crouch_walk_item1"))
			ActivityTranslateFixTF2[ACT_MP_CROUCH_IDLE] = pl:GetSequenceActivity(pl:LookupSequence("crouch_item1"))
            ActivityTranslateFixTF2[ACT_MP_AIRWALK] = pl:GetSequenceActivity(pl:LookupSequence("airwalk_item1"))
			ActivityTranslateFixTF2[ACT_LAND] = pl:GetSequenceActivity(pl:LookupSequence("jumpland_item1"))
			elseif holdtype == "ar2" then
			ActivityTranslateFixTF2[ACT_MP_ATTACK_STAND_PRIMARYFIRE] 						= pl:GetSequenceActivity(pl:LookupSequence("attackstand_primary"))
			ActivityTranslateFixTF2[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] 						= pl:GetSequenceActivity(pl:LookupSequence("attackcrouch_primary"))
			ActivityTranslateFixTF2[ACT_MP_RELOAD_STAND] 						= pl:GetSequenceActivity(pl:LookupSequence("reloadstand_primary"))
			ActivityTranslateFixTF2[ACT_MP_RELOAD_CROUCH] 						= pl:GetSequenceActivity(pl:LookupSequence("reloadcrouch_primary"))
			ActivityTranslateFixTF2[ACT_MP_STAND_IDLE] = pl:GetSequenceActivity(pl:LookupSequence("stand_primary"))
			ActivityTranslateFixTF2[ACT_MP_RUN] = pl:GetSequenceActivity(pl:LookupSequence("run_primary"))
			ActivityTranslateFixTF2[ACT_MP_WALK] = pl:GetSequenceActivity(pl:LookupSequence("run_primary"))
			ActivityTranslateFixTF2[ACT_MP_JUMP] = pl:GetSequenceActivity(pl:LookupSequence("a_jumpstart_primary"))
			ActivityTranslateFixTF2[ACT_MP_JUMP_FLOAT] = pl:GetSequenceActivity(pl:LookupSequence("a_jumpfloat_primary"))
			ActivityTranslateFixTF2[ACT_MP_SWIM] = pl:GetSequenceActivity(pl:LookupSequence("swim_primary"))
			ActivityTranslateFixTF2[ACT_MP_CROUCHWALK] = pl:GetSequenceActivity(pl:LookupSequence("crouch_walk_primary"))
			ActivityTranslateFixTF2[ACT_MP_CROUCH_IDLE] = pl:GetSequenceActivity(pl:LookupSequence("crouch_primary"))
            ActivityTranslateFixTF2[ACT_MP_AIRWALK] = pl:GetSequenceActivity(pl:LookupSequence("airwalk_primary"))
			ActivityTranslateFixTF2[ACT_LAND] = pl:GetSequenceActivity(pl:LookupSequence("jumpland_primary"))
		end

       return ActivityTranslateFixTF2[act] or act
    end
end)

hook.Add("UpdateAnimation", "mobsterAnimations", function(pl, velocity, maxseqgroundspeed) --pitch and yaw rotation 
    if pl:GetModel() == "models/vip_mobster/player/mobster.mdl" then

        local pitch = math.Clamp(math.NormalizeAngle(-pl:EyeAngles().p), -45, 90)
        local pitch2 = math.Clamp(math.NormalizeAngle(-pl:EyeAngles().p), -1, 1)
        pl:SetPoseParameter("body_pitch", pitch)
        pl:SetPoseParameter("head_pitch", pitch2)
        
        if not pl.PlayerBodyYaw or not pl.TargetBodyYaw then
            pl.TargetBodyYaw = pl:EyeAngles().y
            pl.PlayerBodyYaw = pl.TargetBodyYaw
        end
        
        local diff = pl.PlayerBodyYaw - pl:EyeAngles().y
        local yaw = pl.PlayerBodyYaw - pl:EyeAngles().y
        
        if velocity:Length2D() > 0.5 or diff > 45 or diff < -45 then
            pl.TargetBodyYaw = pl:EyeAngles().y
        end
            
        local d = pl.TargetBodyYaw - pl.PlayerBodyYaw
        if d > 180 then
            pl.PlayerBodyYaw = math.NormalizeAngle(Lerp(0.2, pl.PlayerBodyYaw+360, pl.TargetBodyYaw))
        elseif d < -180 then
            pl.PlayerBodyYaw = math.NormalizeAngle(Lerp(0.2, pl.PlayerBodyYaw-360, pl.TargetBodyYaw))
        else
            pl.PlayerBodyYaw = Lerp(0.2, pl.PlayerBodyYaw, pl.TargetBodyYaw)
        end
        
        pl:SetPoseParameter("body_yaw", yaw)
        if CLIENT then
            pl:SetRenderAngles(Angle(0, pl.PlayerBodyYaw, 0))
        end
    else
        return GAMEMODE:UpdateAnimation(pl, velocity, maxseqgroundspeed)
    end
end)
