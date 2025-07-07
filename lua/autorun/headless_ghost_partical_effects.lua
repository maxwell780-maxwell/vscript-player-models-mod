if SERVER then
    util.AddNetworkString("PlayHalloweenSummon")
    util.AddNetworkString("SpawnGhostPumpkin")
    util.AddNetworkString("RemoveGhostPumpkin")

    local function AttachGhostEffect(ply)
        if not IsValid(ply) then return end
        if ply:GetModel() == "models/bots/headless_hatman.mdl" then
            net.Start("SpawnGhostPumpkin")
            net.WriteEntity(ply)
            net.Broadcast()
        end
    end

    hook.Add("PlayerSpawn", "CheckHatmanModel", function(ply)
        timer.Simple(0.1, function() -- Delay to ensure model is set
            if IsValid(ply) and ply:GetModel() == "models/bots/headless_hatman.mdl" then
                net.Start("PlayHalloweenSummon")
                net.WriteEntity(ply)
                net.Broadcast()

                -- Wait for summon effect duration (~3s) before attaching ghost_pumpkin
                timer.Simple(3, function()
                    AttachGhostEffect(ply)
                end)
            end
        end)
    end)

    hook.Add("PlayerDeath", "RemoveGhostEffect", function(ply)
        net.Start("RemoveGhostPumpkin")
        net.WriteEntity(ply)
        net.Broadcast()
    end)
end

if CLIENT then
    net.Receive("PlayHalloweenSummon", function()
        local ply = net.ReadEntity()
        if not IsValid(ply) then return end

        local summonEffect = CreateParticleSystem(ply, "halloween_boss_summon", PATTACH_ABSORIGIN_FOLLOW, 0)
        if summonEffect then
            timer.Simple(3, function() -- Wait for effect to finish
                if IsValid(ply) then
                    net.Start("SpawnGhostPumpkin")
                    net.WriteEntity(ply)
                    net.SendToServer()
                end
            end)
        end
    end)

    net.Receive("SpawnGhostPumpkin", function()
        local ply = net.ReadEntity()
        if not IsValid(ply) then return end

        local effect = CreateParticleSystem(ply, "ghost_pumpkin", PATTACH_ABSORIGIN_FOLLOW, 0)
        if effect then
            ply.GhostPumpkinEffect = effect
        end
    end)

    net.Receive("RemoveGhostPumpkin", function()
        local ply = net.ReadEntity()
        if IsValid(ply) and ply.GhostPumpkinEffect then
            ply.GhostPumpkinEffect:StopEmission()
            ply.GhostPumpkinEffect = nil
        end
    end)
end