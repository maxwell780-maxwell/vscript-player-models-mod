local haleModels = {
    normal = {
        "models/player/saxton_hale.mdl",
        "models/subzero_saxton_hale.mdl",
        "models/vsh/player/saxton_hale.mdl",
        "models/vsh/player/santa_hale.mdl",
        "models/vsh/player/winter/saxton_hale.mdl"
    },
    hell = {
        "models/vsh/player/hell_hale.mdl",
        "models/player/hell_hale.mdl"
    },
    mecha = "models/vsh/player/mecha_hale.mdl"
}

local function isNormalSaxtonModel(model)
    if not model or model == "" then return false end
    model = string.lower(model)
    for _, haleModel in ipairs(haleModels.normal) do
        if model == string.lower(haleModel) then
            return true
        end
    end
    return false
end

local function isHellHaleModel(model)
    if not model or model == "" then return false end
    model = string.lower(model)
    for _, haleModel in ipairs(haleModels.hell) do
        if model == string.lower(haleModel) then
            return true
        end
    end
    return false
end

local function isMechaHaleModel(model)
    if not model or model == "" then return false end
    return string.lower(model) == string.lower(haleModels.mecha)
end

local function isSaxtonModel(model)
    if not model or model == "" then return false end
    return isNormalSaxtonModel(model) or isHellHaleModel(model) or isMechaHaleModel(model)
end

hook.Add("OnPlayerHitGround", "SaxtonHaleVelocityCheck", function(ply, inWater, onFloater, speed)
    if not IsValid(ply) or inWater or not ply:Alive() then return end

    local model = ply:GetModel()
    if not model or model == "" then return end

    model = string.lower(model)
    if not isSaxtonModel(model) then return end

    if speed >= 1000 then
        local explosionRadius = speed * 0.1
        local effect = "vsh_mighty_slam"
        local sound = math.random(1, 2) == 1 and "ambient/explosions/explode_4.wav" or "ambient/explosions/explode_1.wav"

        if isHellHaleModel(model) then
            effect = "vsh_mighty_slam_sparks"
        elseif isMechaHaleModel(model) then
            effect = "vsh_mighty_slam_sparks"
        end

        ply:EmitSound(sound)
        ParticleEffect(effect, ply:GetPos(), Angle(0, 0, 0))

        if isHellHaleModel(model) then
            for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), explosionRadius)) do
                if (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) and not isSaxtonModel(ent:GetModel()) then
                    ent:Ignite(5)
                end
            end
        end

        for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), explosionRadius)) do
            if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) and not isSaxtonModel(ent:GetModel()) then
                local dist = ply:GetPos():Distance(ent:GetPos())
                local damage = math.max(0, 150 - (dist / 10))
                if SERVER then
                    ent:TakeDamage(damage, ply, ply)
                end
            end
        end
    end
end)