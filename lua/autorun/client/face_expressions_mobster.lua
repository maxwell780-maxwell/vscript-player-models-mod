local HEAVY_MODEL = "models/vip_mobster/player/mobster.mdl"
local TRANSITION_SPEED = 0.5
local CHANCE_TO_CHANGE = 0.001 -- 0.1% chance per think

-- Time variations for the original expression
local TIME_VARIATIONS = {
    { delay = 10, chance = 0.7 },    -- 10 seconds, 70% chance
    { delay = 60, chance = 0.25 },   -- 1 minute, 25% chance
    { delay = 600, chance = 0.05 }   -- 10 minutes, 5% chance
}

local TRANSITION_TIME = 1

hook.Add("Think", "MobsterFaceExpressionstime", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    if ply:GetModel() == HEAVY_MODEL then
        ply:SetFlexScale(1)
        
        local idleFaceID = ply:GetFlexIDByName("idleface") or 0
        local leftLidID = ply:GetFlexIDByName("left_CloseLid") or 1
        local rightLidID = ply:GetFlexIDByName("right_lid_closer") or 2
        local multiLidID = ply:GetFlexIDByName("multi_CloseLid") or 3
        
        -- Random chance to change expression
        if not ply.changingExpression and math.random() < CHANCE_TO_CHANGE then
            ply.changingExpression = true
            ply.changeStartTime = CurTime()
            ply.returningToNormal = false
            
            -- Select random duration based on chances
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
        
        -- Handle expression changes
        if ply.changingExpression then
            local timeSinceChange = CurTime() - ply.changeStartTime
            
            if timeSinceChange < ply.selectedDelay then
                -- Smoothly transition to neutral
                local progress = timeSinceChange / ply.selectedDelay
                local targetWeight = Lerp(progress, 1, 0)
                local lidTargetWeight = Lerp(progress, 0.5, 0.5)
                local multiTargetWeight = Lerp(progress, 0.5, 0.5)
                
                ply:SetFlexWeight(idleFaceID, targetWeight)
                ply:SetFlexWeight(leftLidID, lidTargetWeight)
                ply:SetFlexWeight(rightLidID, lidTargetWeight)
                ply:SetFlexWeight(multiLidID, multiTargetWeight)
            elseif not ply.returningToNormal then
                ply.returningToNormal = true
                ply.returnStartTime = CurTime()
            end
            
            if ply.returningToNormal then
                local returnProgress = (CurTime() - ply.returnStartTime) / TRANSITION_TIME
                
                if returnProgress >= 1 then
                    ply.changingExpression = false
                else
                    local targetWeight = Lerp(returnProgress, 0, 1)
                    local lidTargetWeight = Lerp(returnProgress, 0.5, 0.5)
                    local multiTargetWeight = Lerp(returnProgress, 0.5, 0.5) -- thanks to sourcegraph for the typo fix

                    
                    ply:SetFlexWeight(idleFaceID, targetWeight)
                    ply:SetFlexWeight(leftLidID, lidTargetWeight)
                    ply:SetFlexWeight(rightLidID, lidTargetWeight)
                    ply:SetFlexWeight(multiLidID, multiTargetWeight)
                end
            end
        else
            ply:SetFlexWeight(idleFaceID, 1)
            ply:SetFlexWeight(leftLidID, 0.5)
            ply:SetFlexWeight(rightLidID, 0.5)
            ply:SetFlexWeight(multiLidID, 0.5)
        end
    end
end)