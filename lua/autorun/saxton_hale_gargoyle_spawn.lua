if SERVER then
    local gargoyleClass = "gargoyle"
    local despawnDelay = 100
    local playerDeathDespawnDelay = 30
    
    local activeGargoyle = nil

    -- Create a ConVar for controlling gargoyle spawning
    CreateConVar("tf_gargoyle_spawning", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Enable or disable gargoyle spawning (1 = enabled, 0 = disabled)")

    local gargoyleSpawnSounds = {
        "mvm/hellfire_hale_new_lines2/gargoyle_01.mp3",
        "mvm/hellfire_hale_new_lines2/gargoyle_02.mp3"
    }

    local gargoyleGoneSounds = {
        "mvm/hellfire_hale_new_lines2/gargoyle_gone_01.mp3",
        "mvm/hellfire_hale_new_lines2/gargoyle_gone_02.mp3",
        "mvm/hellfire_hale_new_lines2/gargoyle_gone_03.mp3"
    }

    local playerModelsToCheck = {
        ["models/vsh/player/hell_hale.mdl"] = true,
        ["models/player/hell_hale.mdl"] = true
    }

    local function getValidPlayer()
        for _, ply in ipairs(player.GetAll()) do
            if playerModelsToCheck[ply:GetModel()] and ply:Alive() then
                return ply
            end
        end
        return nil
    end

    local function isValidSpawnPos(pos)
        local trace = util.TraceHull({
            start = pos + Vector(0, 0, 50),
            endpos = pos - Vector(0, 0, 500),
            mins = Vector(-16, -16, 0),
            maxs = Vector(16, 16, 72),
            mask = MASK_SOLID_BRUSHONLY
        })
        return trace.Hit and not trace.StartSolid
    end

    local function resetSpawnTimer()
        timer.Remove("GargoyleLoop")
        local spawnDelay = math.random(0, 1) == 0 and 100 or 200

        timer.Create("GargoyleLoop", spawnDelay, 1, function()
            if not IsValid(activeGargoyle) and GetConVar("tf_gargoyle_spawning"):GetBool() then
                spawnGargoyle()
            end
        end)
    end

    function spawnGargoyle()
        if IsValid(activeGargoyle) or not GetConVar("tf_gargoyle_spawning"):GetBool() then return end
        
        timer.Simple(math.random(100, 200), function()
            local ply = getValidPlayer()
            if not ply then return end

            local validPositions = {}
            local navAreas = navmesh.GetAllNavAreas()

            for _, area in ipairs(navAreas) do
                local pos = area:GetCenter()
                if isValidSpawnPos(pos) and pos:Distance(ply:GetPos()) > 1000 then
                    table.insert(validPositions, pos)
                end
            end

            if #validPositions == 0 then return end

            local spawnPosition = validPositions[math.random(#validPositions)]
            local gargoyle = ents.Create(gargoyleClass)
            gargoyle:SetPos(spawnPosition)
            gargoyle:Spawn()

            activeGargoyle = gargoyle

            ply:EmitSound(gargoyleSpawnSounds[math.random(#gargoyleSpawnSounds)])
            ply:ChatPrint("A Soul Gargoyle has mysteriously appeared for you. Go and find it!")

            timer.Simple(despawnDelay, function()
                if IsValid(gargoyle) then
                    gargoyle:Remove()
                    ply:EmitSound(gargoyleGoneSounds[math.random(#gargoyleGoneSounds)])
                end
            end)

            hook.Add("EntityRemoved", "GargoyleRemoved", function(ent)
                if ent == gargoyle then
                    activeGargoyle = nil
                    resetSpawnTimer()
                    ply:EmitSound(gargoyleGoneSounds[math.random(#gargoyleGoneSounds)])
                end
            end)

            hook.Add("PlayerDeath", "GargoyleDespawnOnDeath", function(victim)
                if victim == ply then
                    timer.Simple(playerDeathDespawnDelay, function()
                        if IsValid(gargoyle) then
                            gargoyle:Remove()
                        end
                    end)
                end
            end)
        end)
    end

    hook.Add("InitPostEntity", "GargoyleSpawnOnStart", function()
        resetSpawnTimer()
    end)

end
