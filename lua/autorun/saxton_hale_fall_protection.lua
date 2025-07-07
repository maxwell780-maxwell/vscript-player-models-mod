local PROTECTED_MODELS = {
    ["models/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/santa_hale.mdl"] = true,
    ["models/bots/headless_hatman.mdl"] = true,
    ["models/vsh/player/saxton_hale.mdl"] = true,
    ["models/player/hell_hale.mdl"] = true,
    ["models/saxton_hale_3.mdl"] = true,
    ["models/vsh/player/hell_hale.mdl"] = true,
    ["models/vsh/player/mecha_hale.mdl"] = true,
    ["models/subzero_saxton_hale.mdl"] = true,
    ["models/player/redmond_mann.mdl"] = true,
    ["models/player/blutarch_mann.mdl"] = true,
    ["models/vsh/player/winter/saxton_hale.mdl"] = true
}

hook.Add("EntityTakeDamage", "SaxtonFallDamageProtection", function(target, dmginfo) --YAY no more saxton breaking his ankels and legs
    if target:IsPlayer() and PROTECTED_MODELS[target:GetModel()] and dmginfo:IsFallDamage() then
        return true -- Blocks the fall damage completely so yaaaaay :)
    end
end)
