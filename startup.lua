-- List of apps to minimize on startup
local appsToMinimize = {
    "BentoBox"
}

hs.timer.doAfter(3, function()
    -- minimize apps on the minimize list
    for _, appName in ipairs(appsToMinimize) do
        local app = hs.application.get(appName)
        if app then
            app:hide()
        end
    end

    -- automatically set the location of the device
    if hs.wifi.currentNetwork() == "wilcoG" then
        local command = '/usr/sbin/scselect home'
        local output, success = hs.execute(command)
    else
        local command = '/usr/sbin/scselect outside'
        local output, success = hs.execute(command)
    end
end)
