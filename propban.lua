local SAM_PropBans = {}

-- get prop ban function
function SAM_GetPropBan(steamid)
    return SAM_PropBans[steamid] and SAM_PropBans[steamid] or false
end

-- prop ban function
function SAM_PropBan(steamid, banTime)
    banTime = banTime or 0
    banTime = banTime > 0 and CurTime() + banTime or math.huge

    SAM_PropBans[steamid] = banTime
end

-- prop unban function
function SAM_UnpropBan(steamid)
    SAM_PropBans[steamid] = nil
end

hook.Add("PlayerSpawnObject", "PropBanCheck", function(ply, model)
    local steamid = ply:SteamID()

    if SAM_PropBans[steamid] and SAM_PropBans[steamid] > CurTime() then
        ply:ChatPrint("You are currently banned from spawning props.")
        return false
    end
end)

hook.Add("CanTool", "PropbanToolCheck", function(ply, tr, toolname, tool, button)
    local steamid = ply:SteamID()

    if SAM_PropBans[steamid] and SAM_PropBans[steamid] > CurTime() then
        ply:ChatPrint("You are currently banned from spawning props.")
        return false
    end
end)

-- -- Clear the table if the player becomes invalid
-- hook.Add("PlayerDisconnected", "ClearPropBanCache", function(ply)
--     local steamid = ply:SteamID()
--     SAM_PropBans[steamid] = nil
-- end)


-- !propban command
sam.command.new("propban")
    :SetCategory("Utility")
    :SetPermission("propban", "admin")
    :AddArg("player")
    :AddArg("length", { hint = "length, 0 for permanent", optional = false, min = 0, default = 0 })
    :AddArg("text", { hint = "reason", optional = true, default = sam.language.get("default_reason") })
    :GetRestArgs()
    :Help("Ban a player from spawning props.")
    :OnExecute(function(ply, targets, length, reason)
        for i = 1, #targets do
            local target = targets[i]
            local steamid = target:SteamID()
            SAM_PropBan(steamid, length * 60)
        end

        if sam.is_command_silent then return end
        sam.player.send_message(nil, "{A} banned {T} from spawning props for {V}. Reason: {V_2}", {
            A = ply, T = targets, V = length <= 0 and "ever" or sam.format_length(length), V_2 = reason
        })
    end)
:End()


-- !unpropban command
sam.command.new("unpropban")
    :SetCategory("Utility")
    :SetPermission("unpropban", "admin")
    :AddArg("player", { optional = true })
    :Help("Unban a player from spawning props.")
    :OnExecute(function(ply, targets)
        for i = 1, #targets do
            local target = targets[i]
            local steamid = target:SteamID()
            SAM_UnpropBan(steamid)
        end

        if sam.is_command_silent then return end
        sam.player.send_message(nil, "{A} allowed {T} to spawn props again.", {
            A = ply, T = targets
        })
    end)
:End()
