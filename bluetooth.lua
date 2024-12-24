require "string"

local BLUETOOTH_MAC_ADDRESS = "00-22-d9-00-1a-3e"
local connected_tv_identifiers = {"LG TV", "LG TV SSCR2"} -- Used to identify the TV when it's connected to this computer

function lgtv_is_connected()
    for i, v in ipairs(connected_tv_identifiers) do
        if hs.screen.find(v) ~= nil then
            return true
        end
    end
    return false
end

function bluetooth(power)
    local command
    if power == "off" then
        -- print("Disconnecting Bluetooth device " .. BLUETOOTH_MAC_ADDRESS)
        command = "/opt/homebrew/bin/blueutil --disconnect " .. BLUETOOTH_MAC_ADDRESS .. " >/dev/null 2>&1 &"
    elseif power == "on" then
        -- print("Connecting Bluetooth device " .. BLUETOOTH_MAC_ADDRESS)
        command = "/opt/homebrew/bin/blueutil --connect " .. BLUETOOTH_MAC_ADDRESS .. " >/dev/null 2>&1 &"
    else
        print("Invalid power state. Expected 'on' or 'off'.")
        return
    end
    return hs.execute(command)
end

function f(event)
    if event == hs.caffeinate.watcher.screensDidSleep then
        bluetooth("off")
    elseif (event == hs.caffeinate.watcher.screensDidWake or
            event == hs.caffeinate.watcher.systemDidWake or 
            event == hs.caffeinate.watcher.screensDidUnlock) and lgtv_is_connected() then
        bluetooth("on")
        local audioOutput = hs.audiodevice.findOutputByName("Audioengine HD3")
        if audioOutput then
            audioOutput:setDefaultOutputDevice()
        end
    end
end

watcher = hs.caffeinate.watcher.new(f)
watcher:start()