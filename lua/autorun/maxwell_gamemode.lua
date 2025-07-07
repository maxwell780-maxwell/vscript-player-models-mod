-- Ensure this code only runs on the server
if not SERVER then return end

-- Create the ConVar with default value 0
local hardModeConVar = CreateConVar("maxwell_gammode_hard", "0", FCVAR_ARCHIVE, "Toggle hard mode (0 = off, 1 = on)")

-- Store the entities we create
local hardModeEntities = {}
local isDisabling = false

-- List of Saxton Hale player models to detect
local TARGET_MODELS = {
    ["models/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/santa_hale.mdl"] = true,
    ["models/saxton_hale_3.mdl"] = true,
    ["models/vsh/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/winter/saxton_hale.mdl"] = true,
    ["models/vsh/player/hell_hale.mdl"] = true,
    ["models/vsh/player/mecha_hale.mdl"] = true
}

-- Function to create explosion effect at position
local function CreateExplosionEffect(pos)
    -- Create a networked explosion effect that all clients can see
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetScale(1.5) -- Size of explosion
    util.Effect("Explosion", effectData, true, true) -- Standard GMod explosion effect
    
    -- Play explosion sound
    sound.Play("weapons/teleporter_explode.wav", pos, 75, 100, 1)
end

-- Function to remove the entities with effects
local function RemoveHardModeEntities()
    for _, ent in ipairs(hardModeEntities) do
        if IsValid(ent) then
            -- Create explosion effect at entity position
            CreateExplosionEffect(ent:GetPos())
            
            -- Remove the entity
            ent:Remove()
        end
    end
    
    hardModeEntities = {}
    hook.Remove("Think", "MaxwellHardModeMovement")
    isDisabling = false
end

-- Function to check if a player is on top of an entity
local function IsPlayerOnTop(ent, ply)
    if not IsValid(ent) or not IsValid(ply) then return false end
    
    local entPos = ent:GetPos()
    local plyPos = ply:GetPos()
    
    -- Check if player is above the entity (within a reasonable XY distance and slightly above in Z)
    local entBounds = ent:OBBMaxs()
    local plyBounds = ply:OBBMins()
    
    local xDist = math.abs(plyPos.x - entPos.x)
    local yDist = math.abs(plyPos.y - entPos.y)
    local zDist = plyPos.z - entPos.z
    
    return xDist < (entBounds.x + 20) and yDist < (entBounds.y + 20) and 
           zDist > 0 and zDist < 50
end

-- Function to check if a player is on a building (higher than normal ground level)
local function IsPlayerOnBuilding(ply)
    if not IsValid(ply) then return false end
    
    local plyPos = ply:GetPos()
    local traceDown = {}
    traceDown.start = plyPos
    traceDown.endpos = plyPos - Vector(0, 0, 300) -- Trace 300 units down
    traceDown.filter = ply
    
    local trace = util.TraceLine(traceDown)
    
    -- If the distance to the ground is significant, player is likely on a building
    return trace.HitPos:Distance(plyPos) > 100
end

-- Function to check if a player is far from other players
local function IsPlayerFarFromOthers(ply, minDistance)
    if not IsValid(ply) then return false end
    
    local plyPos = ply:GetPos()
    local farFromAll = true
    
    for _, otherPly in ipairs(player.GetAll()) do
        if otherPly ~= ply and otherPly:Alive() and not otherPly:IsSpec() then
            local distance = otherPly:GetPos():Distance(plyPos)
            if distance < minDistance then
                farFromAll = false
                break
            end
        end
    end
    
    return farFromAll
end

-- Function to check if there are enough players for a fair game
local function EnoughPlayersForGame()
    local count = 0
    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() and not ply:IsSpec() then
            count = count + 1
        end
    end
    
    return count >= 2 -- At least 2 players needed
end

-- Function to update the halo effect for Saxton Hale players
local function UpdateSaxtonHaleHalo()
    if not EnoughPlayersForGame() then return end
    
    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() and TARGET_MODELS[ply:GetModel()] then
            -- Check if Saxton is hiding on a building and far from other players
            if IsPlayerOnBuilding(ply) and IsPlayerFarFromOthers(ply, 1000) then
                -- Add halo effect to this player
                local haloPlayers = {ply}
                halo.Add(haloPlayers, Color(255, 215, 0), 2, 2, 5, true, true)
            end
        end
    end
end

-- Function to move the entities in the pattern
local function MoveHardModeEntities()
    if #hardModeEntities < 3 then return end
    
    local ent1 = hardModeEntities[1] -- This will move left and right
    local ent2 = hardModeEntities[2] -- This will move up and down
    local ent3 = hardModeEntities[3] -- This will stay stationary
    
    if not IsValid(ent1) or not IsValid(ent2) or not IsValid(ent3) then
        RemoveHardModeEntities()
        return
    end
    
    local time = CurTime()
    
    -- Entity 1: Move left and right (using sine wave) - SLOWER
    local pos1 = ent1:GetPos()
    local newX = math.sin(time * 0.5) * 200 -- Reduced speed by multiplying time by 0.5
    local oldX = pos1.x
    ent1:SetPos(Vector(newX, pos1.y, pos1.z))
    
    -- Entity 2: Move up and down (using cosine wave) - SLOWER
    local pos2 = ent2:GetPos()
    local newZ = 100 + math.cos(time * 0.7) * 130 -- Reduced speed by multiplying time by 0.5
    local oldZ = pos2.z
    local isMovingUp = (newZ > oldZ)
    ent2:SetPos(Vector(pos2.x, pos2.y, newZ))
    
    -- Entity 3: Stays stationary, no movement code needed
    
    -- Check if any players are on top of the up/down entity and it's moving up
    if isMovingUp then
        for _, ply in ipairs(player.GetAll()) do
            if IsPlayerOnTop(ent2, ply) then
                -- Apply upward force to the player
                local upForce = 5 -- Adjust as needed
                ply:SetVelocity(Vector(0, 0, upForce * 100))
            end
        end
    end
end

-- Function to create the entities
local function CreateHardModeEntities()
    -- Remove any existing entities first
    RemoveHardModeEntities()
    
    -- Create first entity (left-right mover)
    local ent1 = ents.Create("vsh_australia_jump_pad")
    if IsValid(ent1) then
        ent1:SetPos(Vector(0, -250, 50)) -- Position it at x=0, y=-250, z=50
        ent1:Spawn()
        ent1:Activate()
        table.insert(hardModeEntities, ent1)
    end
    
    -- Create second entity (up-down mover)
    local ent2 = ents.Create("vsh_australia_jump_pad")
    if IsValid(ent2) then
        ent2:SetPos(Vector(0, 250, 100)) -- Position it at x=0, y=250, z=100
        ent2:Spawn()
        ent2:Activate()
        table.insert(hardModeEntities, ent2)
    end
    
    -- Create third entity (stationary, positioned high above)
    local ent3 = ents.Create("vsh_australia_jump_pad")
    if IsValid(ent3) then
        ent3:SetPos(Vector(0, 0, 500)) -- Position it at x=0, y=0, z=500 (high above)
        ent3:Spawn()
        ent3:Activate()
        table.insert(hardModeEntities, ent3)
    end
    
    -- Start the movement hook if we have entities
    if #hardModeEntities > 0 then
        hook.Add("Think", "MaxwellHardModeMovement", MoveHardModeEntities)
        
        -- Play sound to indicate hard mode is enabled
        for _, ply in ipairs(player.GetAll()) do
            ply:EmitSound("weapons/samurai/tf_marked_for_death_indicator.wav", 75, 100, 1)
        end
    end
end

-- Function to play the sequence of sounds when disabling hard mode
local function PlayDisablingSounds()
    isDisabling = true
    
    -- Play first sound
    for _, ply in ipairs(player.GetAll()) do
        ply:EmitSound("items/samurai/tf_conch.wav", 75, 100, 1)
    end
    
    -- Schedule second sound after first one ends (approximately 2 seconds)
    timer.Simple(2, function()
        if not isDisabling then return end
        
        for _, ply in ipairs(player.GetAll()) do
            ply:EmitSound("items/samurai/tf_samurai_noisemaker_seta_03.wav", 75, 100, 1)
        end
        
        -- Schedule third sound after second one ends (approximately 2 seconds)
        timer.Simple(2, function()
            if not isDisabling then return end
            
            for _, ply in ipairs(player.GetAll()) do
                ply:EmitSound("items/samurai/tf_samurai_noisemaker_setb_02.wav", 75, 100, 1)
            end
            
            -- Finally remove entities after the last sound (approximately 2 seconds)
            timer.Simple(2, function()
                if not isDisabling then return end
                RemoveHardModeEntities()
            end)
        end)
    end)
end

-- ConVar change callback
cvars.AddChangeCallback("maxwell_gammode_hard", function(convar_name, value_old, value_new)
    if tonumber(value_new) == 1 then
        -- Hard mode enabled
        CreateHardModeEntities()
    else
        -- Hard mode disabled - play sounds sequence then remove entities
        PlayDisablingSounds()
    end
end, "MaxwellHardModeCallback")

-- Initialize based on current ConVar value (for server restart)
hook.Add("InitPostEntity", "MaxwellHardModeInit", function()
    if GetConVar("maxwell_gammode_hard"):GetInt() == 1 then
        CreateHardModeEntities()
    end
    
    -- Set up the halo effect hook
    hook.Add("PreDrawHalos", "SaxtonHaleHaloEffect", UpdateSaxtonHaleHalo)
end)
