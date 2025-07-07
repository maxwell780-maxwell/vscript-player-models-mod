if not SERVER then return end

local allowedMap = "vip_firebrand_rc1"
local tankClasses = {
    "tank_red_demoman",
    "tank_red_soldier",
    "tank_red_heavy",
    "tank_red_engineer"
}

local spawnedTanks = {
    tank1 = nil,
    tank2 = nil
}

-- ConVar to control tank spawning
CreateConVar("maxwell_should_tanks_spawn_in_vip_gamemode", "0", FCVAR_ARCHIVE, "Enable tank spawning in vip_firebrand_rc1")

local function IsSpawningEnabled()
    return GetConVar("maxwell_should_tanks_spawn_in_vip_gamemode"):GetBool()
end

local function IsAutoTank(ent)
    return IsValid(ent) and ent.tank_auto_spawned
end

local function CountAutoTanks()
    local count = 0
    for _, ent in ipairs(ents.GetAll()) do
        if IsAutoTank(ent) then
            count = count + 1
        end
    end
    return count
end

local function GetRandomTankClass()
    return tankClasses[math.random(#tankClasses)]
end

local function SpawnTank(slot, index)
    local baseEnt = ents.GetByIndex(index)
    if not IsValid(baseEnt) then return end

    local pos = baseEnt:GetPos()
    local ang = baseEnt:GetAngles()
    local class = GetRandomTankClass()

    local tank = ents.Create(class)
    if not IsValid(tank) then return end

    tank:SetPos(pos)
    tank:SetAngles(ang)
    tank:Spawn()
    tank.tank_auto_spawned = true
    spawnedTanks[slot] = tank

    timer.Simple(0, function()
        if not IsValid(tank) then return end
        tank:CallOnRemove("respawn_tank_" .. slot, function(ent)
            if ent.tank_auto_spawned then
                spawnedTanks[slot] = nil
                local delay = math.random(20, 30)
                timer.Simple(delay, function()
                    if IsSpawningEnabled() and CountAutoTanks() < 2 then
                        if slot == "tank1" then
                            SpawnTank("tank1", 605)
                        elseif slot == "tank2" then
                            SpawnTank("tank2", 694)
                        end
                    end
                end)
            end
        end)
    end)
end

hook.Add("Initialize", "InitTankSpawner", function()
    if game.GetMap() ~= allowedMap then return end

    timer.Create("CheckAndSpawnTanks", 1, 0, function()
        if not IsSpawningEnabled() then return end
        if CountAutoTanks() >= 2 then return end

        if not IsValid(spawnedTanks.tank1) then
            timer.Simple(10, function()
                if IsSpawningEnabled() and not IsValid(spawnedTanks.tank1) and CountAutoTanks() < 2 then
                    SpawnTank("tank1", 605)
                end
            end)
        end

        if not IsValid(spawnedTanks.tank2) then
            timer.Simple(10, function()
                if IsSpawningEnabled() and not IsValid(spawnedTanks.tank2) and CountAutoTanks() < 2 then
                    SpawnTank("tank2", 694)
                end
            end)
        end
    end)
end)