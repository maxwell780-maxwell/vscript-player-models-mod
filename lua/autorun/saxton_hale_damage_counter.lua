if SERVER then
    util.AddNetworkString("SaxtonDamageUpdate")
    util.AddNetworkString("SaxtonDamageReset")
end

local SAXTON_MODELS = {
    ["models/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/santa_hale.mdl"] = true,
    ["models/saxton_hale_3.mdl"] = true,
    ["models/vsh/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/winter/saxton_hale.mdl"] = true,
    ["models/vsh/player/hell_hale.mdl"] = true,
    ["models/player/hell_hale.mdl"] = true,
    ["models/subzero_saxton_hale.mdl"] = true,
    ["models/vsh/player/mecha_hale.mdl"] = true
}

local damages = {}
local totalDamage = 0

if CLIENT then
    local damageIcon = Material("vgui/vssaxtonhale/dmg_icon")

    surface.CreateFont("SaxtonDamageFont", {
        font = "Arial",
        size = 42,
        weight = 800,
        antialias = true,
        shadow = true
    })

    net.Receive("SaxtonDamageUpdate", function()
        totalDamage = net.ReadFloat()
        damages[LocalPlayer():EntIndex()] = totalDamage
    end)

    net.Receive("SaxtonDamageReset", function()
        damages = {}
        totalDamage = 0
    end)

    hook.Add("HUDPaint", "SaxtonDamageDisplay", function()
        local saxtonPlayer = nil
        
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() and SAXTON_MODELS[ply:GetModel()] then
                saxtonPlayer = ply
                break
            end
        end
        
        if saxtonPlayer then
            local screenW, screenH = ScrW(), ScrH()
            local iconSize = 42
            local posY = screenH * 0.7
            
            surface.SetMaterial(damageIcon)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(screenW/2 - iconSize/2, posY, iconSize, iconSize)
            
            local damageText = tostring(math.floor(totalDamage))
            if #damageText > 3 then
                damageText = string.sub(damageText, 1, 3) .. "..."
            end
            
            surface.SetFont("SaxtonDamageFont")
            surface.SetTextColor(255, 255, 255, 255)
            surface.SetTextPos(screenW/2 + iconSize/2 + 5, posY)
            surface.DrawText(damageText)
        end
    end)
end

hook.Add("EntityTakeDamage", "SaxtonDamageTracker", function(target, dmginfo)
    if SERVER then
        if IsValid(target) and target:IsPlayer() and target:Alive() and SAXTON_MODELS[target:GetModel()] then
            local damage = dmginfo:GetDamage()
            totalDamage = totalDamage + damage
            
            for _, ply in ipairs(player.GetAll()) do
                net.Start("SaxtonDamageUpdate")
                net.WriteFloat(totalDamage)
                net.Send(ply)
            end
        end
    end
end)

hook.Add("PlayerSpawn", "SaxtonDamageReset", function(ply)
    if SERVER and SAXTON_MODELS[ply:GetModel()] then
        damages = {}
        totalDamage = 0
        net.Start("SaxtonDamageReset")
        net.Broadcast()
    end
end)

hook.Add("InitPostEntity", "SaxtonDamageReset", function()
    damages = {}
    totalDamage = 0
end)