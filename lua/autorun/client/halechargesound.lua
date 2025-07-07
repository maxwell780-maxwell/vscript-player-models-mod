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

local DEFAULT_HALE = {
    ["models/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/santa_hale.mdl"] = true,
    ["models/saxton_hale_3.mdl"] = true,
    ["models/vsh/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/winter/saxton_hale.mdl"] = true,
    ["models/subzero_saxton_hale.mdl"] = true
}

local HELL_HALE = {
    ["models/vsh/player/hell_hale.mdl"] = true,
    ["models/player/hell_hale.mdl"] = true
}

local MECHA_HALE = {
    ["models/vsh/player/mecha_hale.mdl"] = true
}

local lastHoldType = nil
local flexTarget = 0
local flexIndex = nil
local lastModel = ""

local function FindScaredFlex(ply)
    if not IsValid(ply) then return nil end
    
    -- First try exact match
    for i = 0, ply:GetFlexNum() - 1 do
        local flexName = ply:GetFlexName(i)
        if flexName and string.lower(flexName) == "scared" then
            return i
        end
    end
    
    -- If exact match fails, try case variations
    for i = 0, ply:GetFlexNum() - 1 do
        local flexName = ply:GetFlexName(i)
        if flexName then
            local lowerName = string.lower(flexName)
            if lowerName == "scared" or flexName == "scared" or flexName == "Scared" or flexName == "SCARED" then
                return i
            end
        end
    end
    
    return nil
end

local function PlayHaleSound(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    local weapon = ply:GetActiveWeapon()
    if not IsValid(weapon) or weapon:GetClass() ~= "weapon_saxton_hale_swep" or not weapon.GetHoldType then
        flexTarget = 0
        lastHoldType = nil
        return
    end
    
    local holdType = weapon:GetHoldType()
    
    -- Set flex target based on current holdtype
    if holdType == "magic" then
        flexTarget = 0.8  -- Changed to 0.8
    else
        flexTarget = 0
    end
    
    -- Check if holdtype changed to magic (for sound playing)
    if holdType == "magic" and lastHoldType ~= "magic" then
        local model = string.lower(ply:GetModel() or "")
        if SAXTON_MODELS[model] then
            local soundList = {}
            if DEFAULT_HALE[model] then
                soundList = {
                    "mvm/saxton_hale_by_matthew_simmons/charge_a_01.mp3",
                    "mvm/saxton_hale_by_matthew_simmons/charge_a_02.mp3",
                    "mvm/saxton_hale_by_matthew_simmons/charge_b_01.mp3",
                    "mvm/saxton_hale_by_matthew_simmons/charge_b_02.mp3",
                    "mvm/saxton_hale_by_matthew_simmons/charge_b_03.mp3",
                    "mvm/saxton_hale_by_matthew_simmons/charge_c_01.mp3"
                }
            elseif HELL_HALE[model] then
                soundList = {
                    "mvm/hellfire_hale_matthew_simmons2/charge_a_01.mp3",
                    "mvm/hellfire_hale_matthew_simmons2/charge_a_02.mp3",
                    "mvm/hellfire_hale_matthew_simmons2/charge_b_01.mp3",
                    "mvm/hellfire_hale_matthew_simmons2/charge_b_02.mp3",
                    "mvm/hellfire_hale_matthew_simmons2/charge_b_03.mp3",
                    "mvm/hellfire_hale_matthew_simmons2/charge_c_01.mp3",
                    "mvm/hellfire_hale_new_lines2/charge_01.mp3",
                    "mvm/hellfire_hale_new_lines2/charge_02.mp3"
                }
            elseif MECHA_HALE[model] then
                soundList = {
                    "mvm/vsh_mecha/mecha_hale_edit/charge_a_01.mp3",
                    "mvm/vsh_mecha/mecha_hale_edit/charge_a_02.mp3",
                    "mvm/vsh_mecha/mecha_hale_edit/charge_b_01.mp3",
                    "mvm/vsh_mecha/mecha_hale_edit/charge_b_02.mp3",
                    "mvm/vsh_mecha/mecha_hale_edit/charge_b_03.mp3",
                    "mvm/vsh_mecha/mecha_hale_edit/charge_c_01.mp3",
                    "mvm/vsh_mecha/mecha_hale_new/charge_a_01.mp3",
                    "mvm/vsh_mecha/mecha_hale_new/charge_a_02.mp3",
                    "mvm/vsh_mecha/mecha_hale_new/charge_a_03.mp3"
                }
            end
            
            if #soundList > 0 then
                ply:EmitSound(soundList[math.random(#soundList)], 75, 100)
            end
        end
    end
    
    lastHoldType = holdType
end

hook.Add("Think", "SaxtonHaleHoldTypeSound", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    PlayHaleSound(ply)
    
    -- Check if model changed and reset flex index
    local currentModel = ply:GetModel() or ""
    if currentModel ~= lastModel then
        flexIndex = nil
        lastModel = currentModel
    end
    
    -- Handle 'scared' face flex - direct approach
    if ply.SetFlexWeight and ply.GetFlexNum then
        -- Find 'scared' flex index if not found or model changed
        if not flexIndex then
            flexIndex = FindScaredFlex(ply)
        end
        
        if flexIndex and flexIndex >= 0 and flexIndex < ply:GetFlexNum() then
            -- Direct set - no lerping, just set it to the target value
            ply:SetFlexWeight(flexIndex, flexTarget)
        end
    end
end)

-- Debug command to specifically check for 'scared' flex
concommand.Add("check_scared_flex", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then 
        print("Player not valid")
        return 
    end
    
    print("=== Checking for 'scared' flex on " .. ply:GetModel() .. " ===")
    print("Total flexes: " .. ply:GetFlexNum())
    
    local foundScared = false
    for i = 0, ply:GetFlexNum() - 1 do
        local name = ply:GetFlexName(i)
        if name then
            if string.lower(name) == "scared" then
                print("FOUND 'scared' flex at index " .. i .. ": " .. name)
                foundScared = true
            end
        end
    end
    
    if not foundScared then
        print("'scared' flex NOT FOUND on this model")
        print("All available flexes:")
        for i = 0, ply:GetFlexNum() - 1 do
            local name = ply:GetFlexName(i)
            if name then
                print("  " .. i .. ": " .. name)
            end
        end
    end
end)

-- Debug command to test the scared flex directly
concommand.Add("test_scared_flex", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then 
        print("Player not valid")
        return 
    end
    
    local scaredIndex = 46
    if scaredIndex < ply:GetFlexNum() then
        print("Testing scared flex at index 46...")
        print("Current weight: " .. (ply:GetFlexWeight(scaredIndex) or 0))
        ply:SetFlexWeight(scaredIndex, 0.8)
        print("Set weight to 0.8")
        
        timer.Simple(3, function()
            if IsValid(ply) then
                ply:SetFlexWeight(scaredIndex, 0)
                print("Reset weight to 0")
            end
        end)
    else
        print("Index 46 is out of range")
    end
end)
