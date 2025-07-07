local haleModels = {
    "models/player/saxton_hale.mdl",
    "models/vsh/player/santa_hale.mdl",
    "models/saxton_hale_3.mdl",
    "models/vsh/player/saxton_hale.mdl",
    "models/player/hell_hale.mdl",
    "models/vsh/player/mecha_hale.mdl",
    "models/vsh/player/hell_hale.mdl",
    "models/subzero_saxton_hale.mdl",
    "models/player/redmond_mann.mdl",
    "models/player/blutarch_mann.mdl",
    "models/vsh/player/winter/saxton_hale.mdl"
}

local function isSaxtonHale(ply)
    local model = string.lower(ply:GetModel())
    for _, haleModel in ipairs(haleModels) do
        if model == haleModel then
            return true
        end
    end
    return false
end

local function calculateSaxtonHealth(playerCount)
    if playerCount <= 1 then
        return 1000
    elseif playerCount >= 2 and playerCount <= 6 then
        return math.floor(45 * playerCount^2 + 2800 * (0.3 + playerCount / 10))
    elseif playerCount >= 7 and playerCount <= 23 then
        return math.floor(45 * playerCount^2 + 2800)
    else
        return math.floor(2000 * (playerCount - 23) + 26600)
    end
end

hook.Add("PlayerSpawn", "SetSaxtonHaleHealth", function(ply) --health code thanks to code copilot
    timer.Simple(1, function()
        if not IsValid(ply) or not isSaxtonHale(ply) then return end
        
        local playerCount = #player.GetAll()
        local health = calculateSaxtonHealth(playerCount)
        
        ply:SetHealth(health)
        ply:SetMaxHealth(health)
    end)
end)
