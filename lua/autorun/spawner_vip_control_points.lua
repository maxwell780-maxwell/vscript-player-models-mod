-- Only run on server
if not SERVER then return end

local enabled = false
local mapName = "vip_firebrand_rc1"

-- Helper to remove all ent_control_point entities
local function removeControlPoints()
    for _, ent in ipairs(ents.FindByClass("ent_control_point")) do
        ent:Remove()
    end
end

-- Spawn helper
local function spawnControlPointAtIndex(index)
    local ent = ents.GetByIndex(index)
    if not IsValid(ent) then return end

    local cp = ents.Create("ent_control_point")
    if not IsValid(cp) then return end

    cp:SetPos(ent:GetPos())
    cp:SetAngles(ent:GetAngles())
    cp:Spawn()
end

-- Timer scheduling
local function startControlPointTimers()
    if game.GetMap() ~= mapName then return end

    -- Clear existing timers just in case
    timer.Remove("MobsterSpawn1")
    timer.Remove("MobsterSpawn2")
    timer.Remove("MobsterSpawn3")

    timer.Create("MobsterSpawn1", 40, 1, function()
        spawnControlPointAtIndex(87)
    end)

    timer.Create("MobsterSpawn2", 60, 1, function()
        spawnControlPointAtIndex(287)
    end)

    timer.Create("MobsterSpawn3", 80, 1, function()
        spawnControlPointAtIndex(39)
    end)
end

-- ConCommand handler
concommand.Add("mobster_vip_gamemode_enable", function(ply, cmd, args)
    if not args[1] then return end
    local val = tonumber(args[1])
    if val ~= 0 and val ~= 1 then return end

    enabled = (val == 1)

    if enabled then
        startControlPointTimers()
    else
        timer.Remove("MobsterSpawn1")
        timer.Remove("MobsterSpawn2")
        timer.Remove("MobsterSpawn3")
        removeControlPoints()
    end
end)

-- Optional: on map load, set default state
hook.Add("InitPostEntity", "MobsterGamemodeInit", function()
    if game.GetMap() ~= mapName then return end
    enabled = false
end)
