local function CheckMechaHaleModel()
    local modelPath = "models/vsh/player/mecha_hale.mdl"
    local currentMap = game.GetMap()
    
    if CLIENT then
        if file.Exists(modelPath, "GAME") then
            chat.AddText(Color(0, 255, 0), "MECHA HALE MODEL FOUND")
            
            if currentMap == "vsh_facility_rc2" then
                chat.AddText(Color(0, 255, 255), "Playing on VSH Facility - Mecha Hale Model Ready!")
            end
        else
            LocalPlayer():EmitSound("ui/hint.wav")
            chat.AddText(Color(255, 0, 0), "WARNING MECHA HALE MODEL DOES NOT EXIST REPLACING VALID MODEL !tf_MECHA_saxton WITH BOT HEAVY MODEL")
            list.Set("PlayerOptionsModel", "!tf_MECHA_saxton", nil)
        end
    end
end

-- Continuous model checker
local function EnforceFallbackModel()
    local modelPath = "models/vsh/player/mecha_hale.mdl"
    local fallbackModel = "models/bots/heavy/bot_heavy.mdl"
    
    if SERVER then
        timer.Create("MechaHaleModelChecker", 0.1, 0, function()
            for _, ply in ipairs(player.GetAll()) do
                if not file.Exists(modelPath, "GAME") and ply:GetModel():lower() == modelPath:lower() then
                    ply:SetModel(fallbackModel)
                    net.Start("MechaHaleModelSwitch")
                    net.Send(ply)
                end
            end
        end)
    end
end

if SERVER then
    util.AddNetworkString("MechaHaleModelSwitch")
    hook.Add("InitPostEntity", "MechaHaleModelEnforcer", EnforceFallbackModel)
end

if CLIENT then
    hook.Add("InitPostEntity", "MechaHaleModelChecker", CheckMechaHaleModel)
    
    net.Receive("MechaHaleModelSwitch", function()
        chat.AddText(Color(255, 165, 0), "Mecha Hale model does not exist here have a heavy bot as a player model replacement place holder ;)")
    end)
end