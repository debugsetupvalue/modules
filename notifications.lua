local notify_module = {}
local notifiyevent = game.ReplicatedStorage.RemoteEvents.NotificationEvent
local notifunc
local queue = {}
local processing = false

function notify_module.getfunc()
    if notifunc then
        return notifunc
    end

    for i, v in pairs(getgc(true)) do
        if type(v) == "function" then
            local info = debug.getinfo(v)
            if info and info.source and info.source:find("NotificationScript") and info.name == "NormalNotify" then
                notifunc = v
                break
            end
        end
    end

    if not notifunc then
        warn("Notify function not found or was changed (fuck the devs)")
    end

    return notifunc
end

local function processQueue()
    while #queue > 0 do
        local data = table.remove(queue, 1)
        local f = notify_module.getfunc()
        if f then
            f(data.message, data.color or Color3.new(1, 1, 1), data.someFlag)
        else
            warn("Notify function unavailable")
        end
        task.wait(4)
    end
    processing = false
end

notifiyevent.OnClientEvent:Connect(function(message, color, someFlag)
    table.insert(queue, {message = message, color = color, someFlag = someFlag})
    if not processing then
        processing = true
        task.spawn(processQueue)
    end
end)

function notify_module.notify(message, color, someFlag)
    table.insert(queue, {message = message, color = color, someFlag = someFlag})
    if not processing then
        processing = true
        task.spawn(processQueue)
    end
end

return notify_module
