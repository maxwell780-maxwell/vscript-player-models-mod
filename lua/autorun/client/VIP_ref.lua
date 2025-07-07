local VIP_MODEL = "models/vip/player/julius/julius.mdl"
local TRANSITION_SPEED = 3.0
local CHANCE_TO_CHANGE = 0.001
local RETURN_DELAY = 2
local TRANSITION_TIME = 1

-- Set default flex values
local SKEPTICAL_VALUE = 1  -- His default nervous expression
local SQUINT_VALUE = 1     -- His alternate expression

local TIME_VARIATIONS = {
    { delay = 10, chance = 0.7 },
    { delay = 60, chance = 0.25 },
    { delay = 600, chance = 0.05 }
}

hook.Add("Think", "vipFaceExpressions", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    if ply:GetModel() == VIP_MODEL then
        ply:SetFlexScale(1)
        
        local skepticalID = ply:GetFlexIDByName("Skeptical") or 0
        local squintID = ply:GetFlexIDByName("Squint") or 1
        
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
                local skepticalWeight = Lerp(progress, SKEPTICAL_VALUE, 0)
                local squintWeight = Lerp(progress, 0, SQUINT_VALUE)
                
                ply:SetFlexWeight(skepticalID, skepticalWeight)
                ply:SetFlexWeight(squintID, squintWeight)
            elseif not ply.returningToNormal then
                ply.returningToNormal = true
                ply.returnStartTime = CurTime()
            end
            
            if ply.returningToNormal then
                local returnProgress = (CurTime() - ply.returnStartTime) / TRANSITION_TIME
                
                if returnProgress >= 1 then
                    ply.changingExpression = false
                else
                    local skepticalWeight = Lerp(returnProgress, 0, SKEPTICAL_VALUE)
                    local squintWeight = Lerp(returnProgress, SQUINT_VALUE, 0)
                    
                    ply:SetFlexWeight(skepticalID, skepticalWeight)
                    ply:SetFlexWeight(squintID, squintWeight)
                end
            end
        else
            ply:SetFlexWeight(skepticalID, SKEPTICAL_VALUE)
            ply:SetFlexWeight(squintID, 0)
        end
    end
end)