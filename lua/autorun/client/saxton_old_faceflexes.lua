local HALE_MODEL = "models/saxton_hale_3.mdl"
local TRANSITION_SPEED = 3.0
local CHANCE_TO_CHANGE = 0.001
local RETURN_DELAY = 2
local TRANSITION_TIME = 1

-- Set default flex values
local MAD_VALUE = 1        -- His default angry expression
local SILENCE_VALUE = 1    -- His alternate expression
local LID_VALUE = -0.5      -- Partially closed eyelids
local happyBig_VALUE = 0      -- Partially closed eyelids

local TIME_VARIATIONS = {
    { delay = 10, chance = 0.7 },
    { delay = 60, chance = 0.25 },
    { delay = 600, chance = 0.05 }
}

hook.Add("Think", "saxtonHaleFaceExpressions", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    if ply:GetModel() == HALE_MODEL then
        ply:SetFlexScale(1)
        
        local madID = ply:GetFlexIDByName("mad") or 0
        local silenceID = ply:GetFlexIDByName("silence") or 1
        local leftLidID = ply:GetFlexIDByName("left_CloseLid") or 2
        local rightLidID = ply:GetFlexIDByName("right_CloseLid") or 3
        local happyBigID = ply:GetFlexIDByName("happyBig") or 4
        
        -- Always set eyelids to the default value
        ply:SetFlexWeight(leftLidID, LID_VALUE)
        ply:SetFlexWeight(rightLidID, LID_VALUE)
        ply:SetFlexWeight(happyBigID, happyBig_VALUE)
        
        if not ply.changingExpression and math.random() < CHANCE_TO_CHANGE then
            ply.changingExpression = true
            ply.changeStartTime = CurTime()
            ply.returningToNormal = false
            
            local rand = math.random()
            local cumulative = 0
            for _, variation in ipairs(TIME_VARIATIONS) do
                cumulative = cumulative + variation.chance
                if rand <= cumulative then
                    ply.selectedDelay = variation.delay
                    break
                end
            end
        end
        
        if ply.changingExpression then
            local timeSinceChange = CurTime() - ply.changeStartTime
            
            if timeSinceChange < ply.selectedDelay then
                local progress = timeSinceChange / ply.selectedDelay
                local madWeight = Lerp(progress, MAD_VALUE, 0)
                local silenceWeight = Lerp(progress, 0, SILENCE_VALUE)
                
                ply:SetFlexWeight(madID, madWeight)
                ply:SetFlexWeight(silenceID, silenceWeight)
            elseif not ply.returningToNormal then
                ply.returningToNormal = true
                ply.returnStartTime = CurTime()
            end
            
            if ply.returningToNormal then
                local returnProgress = (CurTime() - ply.returnStartTime) / TRANSITION_TIME
                
                if returnProgress >= 1 then
                    ply.changingExpression = false
                else
                    local madWeight = Lerp(returnProgress, 0, MAD_VALUE)
                    local silenceWeight = Lerp(returnProgress, SILENCE_VALUE, 0)
                    
                    ply:SetFlexWeight(madID, madWeight)
                    ply:SetFlexWeight(silenceID, silenceWeight)
                end
            end
        else
            ply:SetFlexWeight(madID, MAD_VALUE)
            ply:SetFlexWeight(silenceID, 0)
        end
    end
end)