local MOBSTER_MODEL = "models/vip_mobster/player/mobster_new.mdl"

-- Function to update hands based on player model and skin
local function UpdateHandsSkin()
    -- Check if LocalPlayer is valid (might not be during initial loading)
    if not LocalPlayer or not IsValid(LocalPlayer()) then return end
    
    local ply = LocalPlayer()
    local model = ply:GetModel()
    
    -- Check if player is using the mobster model
    if string.lower(model) == string.lower(MOBSTER_MODEL) then
        local skin = ply:GetSkin()
        
        -- Set hands skin to match player skin (0 or 1)
        if skin == 0 or skin == 1 then
            -- Get the hands entity
            local hands = ply:GetHands()
            if IsValid(hands) then
                hands:SetSkin(skin)
            end
        end
    end
end

-- Only run on the client
if CLIENT then
    -- Hook into player spawn to update hands
    hook.Add("OnPlayerModelChanged", "backatitagainMobsterHandsSkinSync", UpdateHandsSkin)
    
    -- Hook into skin changes
    hook.Add("PlayerSetSkin", "backatitagainMobsterHandsSkinSync", function(ply)
        -- Only run for local player
        if ply == LocalPlayer() then
            UpdateHandsSkin()
        end
    end)
    
    -- Initial update when script loads and player is ready
    hook.Add("InitPostEntity", "backatitagainMobsterHandsSkinSync_Initial", function()
        timer.Simple(1, UpdateHandsSkin) -- Small delay to ensure player is fully loaded
    end)
    
    -- Update periodically in case other scripts change the skin
    timer.Create("backatitagainMobsterHandsSkinSync_Timer", 1, 0, UpdateHandsSkin)
end