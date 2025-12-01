if SERVER then
    util.AddNetworkString("Mobster_Assign")

    local MOBSTER_MODELS = {
        "models/vip_mobster/player/old/mobster.mdl",
        "models/vip_mobster/player/mobster_new.mdl"
    }

    local MOBSTER_HANDS = "models/vip_mobster/weapons/c_mobster_arms.mdl"
    local PICKUP_CLASS = "ent_mobster_pickup"
    local PICKUP_RADIUS = 100

    local activeMobster = nil

    local function IsMobsterModel(mdl)
        for _, v in ipairs(MOBSTER_MODELS) do
            if mdl == v then return true end
        end
        return false
    end

    local function SetPickupAvailability(state)
        RunConsoleCommand("mobster_pickup_availability", state)
    end

    local function ForceAvailabilityCheck()
        if IsValid(activeMobster) then
            SetPickupAvailability("0")
        else
            SetPickupAvailability("1")
        end
    end

    local function SetMobsterHands(ply)
        if not IsValid(ply) then return end

        timer.Simple(0, function()
            if not IsValid(ply) then return end

            local hands = ply:GetHands()
            if IsValid(hands) then
                hands:SetModel(MOBSTER_HANDS)
            end
        end)
    end

    local function MakePlayerMobster(ply)
        if IsValid(activeMobster) then return end
        if not IsValid(ply) then return end

        activeMobster = ply

        local oldPos = ply:GetPos()
        local chosenModel = table.Random(MOBSTER_MODELS)

        ply._MobsterRespawnPos = oldPos
        ply._MobsterModel = chosenModel

        SetPickupAvailability("0")

        ply:KillSilent()

        timer.Simple(0.1, function()
            if IsValid(ply) then ply:Spawn() end
        end)
    end

    hook.Add("PlayerSpawn", "Mobster_PostSpawn", function(ply)
        if ply == activeMobster and ply._MobsterModel then
            timer.Simple(0, function()
                if not IsValid(ply) then return end

                ply:SetModel(ply._MobsterModel)
				ply:SetSkin(1)
				
                if ply._MobsterRespawnPos then
                    ply:SetPos(ply._MobsterRespawnPos)
                end

                SetMobsterHands(ply)
            end)
        end

        ForceAvailabilityCheck()
    end)

    hook.Add("PlayerDeath", "Mobster_DeathReset", function(ply)
        if ply == activeMobster then
            activeMobster = nil
        end

        timer.Simple(0, ForceAvailabilityCheck)
    end)

    hook.Add("Think", "Mobster_PickupRadiusChecker", function()
        if IsValid(activeMobster) then return end

        for _, pickup in ipairs(ents.FindByClass(PICKUP_CLASS)) do
            local ppos = pickup:GetPos()

            for _, ply in ipairs(player.GetAll()) do
                if not IsValid(ply) then continue end
                if IsMobsterModel(ply:GetModel()) then continue end

                if ply:GetPos():Distance(ppos) <= PICKUP_RADIUS then
                    MakePlayerMobster(ply)
                    return
                end
            end
        end
    end)

    hook.Add("PlayerInitialSpawn", "Mobster_BlockPickup", function()
        timer.Simple(1, ForceAvailabilityCheck)
    end)

    -- ✅ SAFETY WATCHDOG
    timer.Create("MobsterAvailabilityWatchdog", 1, 0, function()
        ForceAvailabilityCheck()
    end)
end


if CLIENT then
    cvars.AddChangeCallback("mobster_pickup_availability", function(_, _, new)
        new = tonumber(new)
        -- HUD / effects optional
    end)
end
