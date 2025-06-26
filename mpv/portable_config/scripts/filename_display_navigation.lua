-- filename_display_navigation.lua
-- Script to show filename when navigating with up/down keys and hide after 1 second

local msg = require 'mp.msg'

-- Timer to delay filename retrieval after navigation
local filename_timer = nil

function show_filename_with_delay()
    -- Cancel any existing timer
    if filename_timer then
        filename_timer:stop()
        filename_timer = nil
    end
    
    -- Create a timer to get filename after a small delay
    filename_timer = mp.add_timeout(0.1, function()
        local filename = mp.get_property("filename")
        if filename then
            -- Show the filename on OSD for 1 second
            mp.osd_message(filename, 1)
            msg.info("Showing filename: " .. filename)
        end
        filename_timer = nil
    end)
end

function navigate_up()
    -- Execute the original playlist-prev command
    mp.command("playlist-prev")
    
    -- Show filename after navigation with delay
    show_filename_with_delay()
end

function navigate_down()
    -- Execute the original playlist-next command
    mp.command("playlist-next")
    
    -- Show filename after navigation with delay
    show_filename_with_delay()
end

-- Register the navigation functions
mp.add_key_binding("UP", "navigate-up", navigate_up)
mp.add_key_binding("DOWN", "navigate-down", navigate_down) 