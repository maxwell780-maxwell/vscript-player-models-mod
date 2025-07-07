if SERVER then
    util.AddNetworkString("MobsterSpawnParticle")

    CreateConVar("mobster_disguise_poof_spawn", "1", FCVAR_ARCHIVE, "Enable or disable the mobster disguise poof entity spawner")

    hook.Add("InitPostEntity", "SpawnMobsterParticleLoaderEntity", function()
        if GetConVar("mobster_disguise_poof_spawn"):GetBool() then
            local found = false
            for _, ent in ipairs(ents.FindByClass("func_mobster_entity_smoke_loader_ent")) do
                found = true
                break
            end

            if not found then
                local ent = ents.Create("func_mobster_entity_smoke_loader_ent")
                if not IsValid(ent) then return end
                ent:SetPos(Vector(999999, 999999, 999999))
                ent:Spawn()
                print("[Mobster] Spawned func_mobster_entity_smoke_loader_ent")
            end
        end
    end)

    hook.Add("PlayerSpawn", "MobsterCheckAndTriggerParticle", function(ply)
        timer.Create("MobsterModelCheck_" .. ply:EntIndex(), 0.1, 50, function()
            if not IsValid(ply) then return end
            local mdl = string.lower(ply:GetModel() or "")
            if mdl == "models/vip_mobster/player/mobster.mdl" then
                net.Start("MobsterSpawnParticle")
                net.Send(ply)
                timer.Remove("MobsterModelCheck_" .. ply:EntIndex())
            end
        end)
    end)
end

if CLIENT then
    net.Receive("MobsterSpawnParticle", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        timer.Simple(0.2, function()
            if not IsValid(ply) then return end
            ParticleEffect("mobster_appearation", ply:GetPos(), Angle(0, 0, 0), ply)
        end)
    end)
end
