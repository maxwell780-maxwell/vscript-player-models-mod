local function AddToggleConVarButton(panel, label, convarName, iconPath)
    local btn = panel:Button(label)
    btn.DoClick = function()
        if not ConVarExists(convarName) then
            chat.AddText(Color(255, 50, 50), "[Maxwell] Error: ConVar '" .. convarName .. "' doesn't exist or isn't client-accessible.")
            return
        end

        local cvar = GetConVar(convarName)
        local current = cvar:GetBool()
        RunConsoleCommand(convarName, current and "0" or "1")
    end

    local icon = vgui.Create("DImage", panel)
    icon:SetSize(48, 260)
    icon:SetImage(iconPath)
    panel:AddItem(icon)
end

local function AddOneShotCommandButton(panel, label, commandName, iconPath)
    local btn = panel:Button(label)
    btn.DoClick = function()
        RunConsoleCommand(commandName)
    end

    local icon = vgui.Create("DImage", panel)
    icon:SetSize(48, 260)
    icon:SetImage(iconPath)
    panel:AddItem(icon)
end

-- Hook Maxwell tabs into Utilities category
hook.Add("PopulateToolMenu", "AddMaxwellsUtilityPanels", function()
    -- Commands tab
    spawnmenu.AddToolMenuOption("Utilities", "Maxwell's Commands", "MaxwellTools", "Commands", "", "", function(panel)
        panel:ClearControls()
        panel:Help("better commands to suit your needs")

        AddToggleConVarButton(panel, "Should Saxton Hale Gammode Have a Custom Hard Mode?", "maxwell_gammode_hard", "vgui/icons/saxton_gammode_hard_teaser_icon")
        AddToggleConVarButton(panel, "Should Jump Pad Use Old Particle Effects?", "maxwell_jump_pad_should_use_old_particle_effects", "vgui/icons/jump_pad_old_teaser_icon")
        AddToggleConVarButton(panel, "Should tanks spawn when your on vip_firebrand_rc1?", "maxwell_should_tanks_spawn_in_vip_gamemode", "vgui/icons/tank_spawner_teaser_icon")
        AddToggleConVarButton(panel, "Should the Mobster have smoke effects when spawning?", "mobster_disguise_poof_spawn", "vgui/icons/mobster_spawn_smoke_teaser_icon")
        AddOneShotCommandButton(panel, "Should control points be enabled for mobster gammode?", "mobster_vip_gamemode_enable", "vgui/icons/mobster_control_points_teaser")
        AddOneShotCommandButton(panel, "Gesture Binding Help?", "maxwell_playgestures_help", "vgui/icons/gester_help_teaser_icon")
    end)

    -- The Gargoyle tab
    spawnmenu.AddToolMenuOption("Utilities", "Maxwell's Commands", "MaxwellGargoyle", "The Gargoyle", "", "", function(panel)
        panel:ClearControls()
        panel:Help("Stuff having to deal with the gargoyle")

        AddToggleConVarButton(panel, "Should gargoyle spawn when your hell hale?", "tf_gargoyle_spawning", "vgui/icons/gargoyle entity icon")
    end)
end)