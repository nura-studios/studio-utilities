-- copy_remove_attempt_suffix.lua
-- Script to copy files with "_attempt_##" suffix and remove the suffix from the new filename
-- Also includes toggle to hide/show attempt files in playlist

local utils = require 'mp.utils'
local msg = require 'mp.msg'

-- Global state for playlist filtering
local attempt_files_hidden = false
local help_visible = false
local interaction_mode = nil  -- "image", "video", "audio"
local media_extensions = {
    image = {".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".tiff", ".tga"},
    video = {".mp4", ".avi", ".mkv", ".mov", ".wmv", ".flv", ".webm", ".m4v", ".mpg", ".mpeg"},
    audio = {".mp3", ".wav", ".flac", ".ogg", ".aac", ".m4a", ".wma"}
}

function detect_file_type(filename)
    if not filename then return nil end
    
    local ext = filename:match("%.([^%.]+)$")
    if not ext then return nil end
    
    ext = "." .. ext:lower()
    
    for media_type, extensions in pairs(media_extensions) do
        for _, extension in ipairs(extensions) do
            if ext == extension then
                return media_type
            end
        end
    end
    
    return nil
end

function set_interaction_mode()
    local current_path = mp.get_property("path")
    if not current_path then return end
    
    local filename = current_path:match("([^/\\]+)$")
    local file_type = detect_file_type(filename)
    
    if file_type and file_type ~= interaction_mode then
        interaction_mode = file_type
        msg.info("Interaction mode set to: " .. interaction_mode)
        mp.osd_message("Mode: " .. interaction_mode:upper(), 2)
        setup_mode_bindings()
    end
end

function get_filtered_playlist_indices(media_type)
    local playlist = mp.get_property_native("playlist")
    if not playlist then return {} end
    
    local indices = {}
    for i, entry in ipairs(playlist) do
        if entry.filename then
            local file_type = detect_file_type(entry.filename)
            if file_type == media_type then
                table.insert(indices, i - 1)  -- MPV uses 0-based indexing
            end
        end
    end
    
    return indices
end

function navigate_filtered_playlist(direction)
    if not interaction_mode then return end
    
    local indices = get_filtered_playlist_indices(interaction_mode)
    if #indices <= 1 then return end
    
    local current_pos = mp.get_property_number("playlist-pos") or 0
    local current_index = nil
    
    -- Find current position in filtered list
    for i, idx in ipairs(indices) do
        if idx == current_pos then
            current_index = i
            break
        end
    end
    
    if not current_index then return end
    
    local next_index
    if direction == "next" then
        next_index = current_index < #indices and current_index + 1 or 1  -- Loop to first
    else
        next_index = current_index > 1 and current_index - 1 or #indices  -- Loop to last
    end
    
    local target_pos = indices[next_index]
    mp.set_property("playlist-pos", target_pos)
    
    msg.info("Navigated to " .. interaction_mode .. " file at position: " .. target_pos)
end

function setup_mode_bindings()
    if not interaction_mode then return end
    
    -- Remove existing mouse wheel bindings
    mp.remove_key_binding("wheel_frame_back")
    mp.remove_key_binding("wheel_frame_forward") 
    mp.remove_key_binding("wheel_prev_media")
    mp.remove_key_binding("wheel_next_media")
    mp.remove_key_binding("spacebar_next_image")
    
    if interaction_mode == "video" then
        -- Video mode: mouse wheel = frame advance, up/down = filtered playlist
        mp.add_key_binding("WHEEL_UP", "wheel_frame_back", function() mp.command("frame-back-step") end)
        mp.add_key_binding("WHEEL_DOWN", "wheel_frame_forward", function() mp.command("frame-step") end)
        msg.info("Video mode: Mouse wheel = frame advance")
        
    elseif interaction_mode == "image" or interaction_mode == "audio" then
        -- Image/Audio mode: mouse wheel = navigate filtered playlist
        mp.add_key_binding("WHEEL_UP", "wheel_prev_media", function() navigate_filtered_playlist("prev") end)
        mp.add_key_binding("WHEEL_DOWN", "wheel_next_media", function() navigate_filtered_playlist("next") end)
        
        if interaction_mode == "image" then
            -- Spacebar also navigates for images
            mp.add_key_binding("SPACE", "spacebar_next_image", function() navigate_filtered_playlist("next") end)
            msg.info("Image mode: Mouse wheel + spacebar = navigate images")
        else
            msg.info("Audio mode: Mouse wheel = navigate audio files")
        end
    end
end

function copy_remove_attempt_suffix()
    msg.info("DEBUG: copy_remove_attempt_suffix function called")
    local current_path = mp.get_property("path")
    if not current_path then
        mp.osd_message("No file currently playing")
        return
    end
    
    msg.info("Current file: " .. current_path)
    
    -- Extract directory and filename
    local dir, filename = current_path:match("(.+)[/\\]([^/\\]+)$")
    if not dir or not filename then
        mp.osd_message("Cannot parse file path")
        return
    end
    
    msg.info("Directory: " .. dir)
    msg.info("Filename: " .. filename)
    
    -- Check if filename has "_attempt_##" pattern
    local name_without_ext, ext = filename:match("^(.+)%.([^%.]+)$")
    if not name_without_ext or not ext then
        mp.osd_message("Cannot parse filename and extension")
        return
    end
    
    -- Check for "_attempt_##" pattern (where ## is one or more digits)
    local base_name, attempt_num = name_without_ext:match("^(.+)_attempt_(%d+)$")
    if not base_name or not attempt_num then
        mp.osd_message("File does not have '_attempt_##' suffix pattern")
        return
    end
    
    -- Create new filename without attempt suffix
    local new_filename = base_name .. "." .. ext
    local new_path = dir .. "/" .. new_filename
    
    msg.info("Base name: " .. base_name)
    msg.info("Attempt number: " .. attempt_num)
    msg.info("New filename: " .. new_filename)
    msg.info("New path: " .. new_path)
    
    -- Use utils.subprocess to copy the file in background (will overwrite if exists)
    local copy_command = string.format('Copy-Item -Path "%s" -Destination "%s" -Force', current_path, new_path)
    msg.info("Executing PowerShell command: " .. copy_command)
    
    local result = utils.subprocess({
        args = {"powershell", "-WindowStyle", "Hidden", "-Command", copy_command},
        cancellable = false
    })
    
    if result.status == 0 then
        mp.osd_message(string.format("%s selected", new_filename))
        msg.info("File copied successfully")
    else
        mp.osd_message("Failed to copy file")
        msg.error("Copy operation failed with status: " .. tostring(result.status))
        if result.stderr and result.stderr ~= "" then
            msg.error("Error output: " .. result.stderr)
        end
    end
end

function has_attempt_suffix(filename)
    -- Extract filename without directory
    local name_only = filename:match("([^/\\]+)$") or filename
    
    -- Extract name without extension
    local name_without_ext = name_only:match("^(.+)%.[^%.]+$") or name_only
    
    -- Check for "_attempt_##" pattern
    return name_without_ext:match("_attempt_%d+$") ~= nil
end

function toggle_attempt_files_visibility()
    local playlist = mp.get_property_native("playlist")
    if not playlist then
        mp.osd_message("No playlist available", 2)
        return
    end
    
    attempt_files_hidden = not attempt_files_hidden
    
    if attempt_files_hidden then
        -- Hide attempt files by removing them from playlist
        local indices_to_remove = {}
        
        -- Collect indices of files to remove (in reverse order to avoid index shifting)
        for i = #playlist, 1, -1 do
            local entry = playlist[i]
            if entry.filename and has_attempt_suffix(entry.filename) then
                table.insert(indices_to_remove, i - 1) -- MPV uses 0-based indexing
            end
        end
        
        -- Remove the files from playlist
        for _, index in ipairs(indices_to_remove) do
            mp.commandv("playlist-remove", index)
        end
        
        local count = #indices_to_remove
        -- Show timed OSD message for variant mode ON
        mp.osd_message(string.format("\\ variant mode ON\nHidden %d attempt files", count), 3)
        msg.info(string.format("Hidden %d attempt files from playlist", count))
        
    else
        -- Show timed OSD message for variant mode OFF
        mp.osd_message("\\ variant mode OFF\nShowing all files (reload playlist to restore attempt files)", 3)
        msg.info("Toggle off - showing all files. Note: Removed attempt files need playlist reload to restore.")
    end
end

function move_to_trash()
    local current_path = mp.get_property("path")
    if not current_path then
        mp.osd_message("No file currently playing")
        return
    end
    
    msg.info("Moving to trash: " .. current_path)
    
    -- Get current playlist info before deletion
    local playlist_count = mp.get_property_number("playlist-count") or 0
    local current_pos = mp.get_property_number("playlist-pos") or 0
    
    -- Store the file to delete
    local file_to_delete = current_path
    
    -- First, navigate to next file if possible
    if playlist_count > 1 then
        if current_pos < playlist_count - 1 then
            -- Move to next file
            mp.command("playlist-next")
            msg.info("Moved to next file in playlist")
        else
            -- We're at the last file, go to previous
            mp.command("playlist-prev")
            msg.info("Moved to previous file (was at last file)")
        end
        
        -- Small delay to ensure file is loaded
        mp.add_timeout(0.1, function()
            -- Now delete the previous file in background
            local trash_command = string.format(
                'Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(\'%s\', \'OnlyErrorDialogs\', \'SendToRecycleBin\')', 
                file_to_delete:gsub("'", "''")  -- Escape single quotes for PowerShell
            )
            
            msg.info("Executing PowerShell command to move to trash: " .. file_to_delete)
            
            local result = utils.subprocess({
                args = {"powershell", "-WindowStyle", "Hidden", "-Command", trash_command},
                cancellable = false
            })
            
            if result.status == 0 then
                mp.osd_message("Previous file moved to recycle bin", 1)
                msg.info("File successfully moved to recycle bin: " .. file_to_delete)
            else
                mp.osd_message("Failed to move previous file to trash")
                msg.error("Trash operation failed with status: " .. tostring(result.status))
                if result.stderr and result.stderr ~= "" then
                    msg.error("Error output: " .. result.stderr)
                end
            end
        end)
    else
        -- Only one file in playlist, delete and show message
        local trash_command = string.format(
            'Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(\'%s\', \'OnlyErrorDialogs\', \'SendToRecycleBin\')', 
            current_path:gsub("'", "''")  -- Escape single quotes for PowerShell
        )
        
        msg.info("Executing PowerShell command to move to trash")
        
        local result = utils.subprocess({
            args = {"powershell", "-WindowStyle", "Hidden", "-Command", trash_command},
            cancellable = false
        })
        
        if result.status == 0 then
            mp.osd_message("File moved to recycle bin - No more files", 2)
            msg.info("File successfully moved to recycle bin")
        else
            mp.osd_message("Failed to move file to trash")
            msg.error("Trash operation failed with status: " .. tostring(result.status))
            if result.stderr and result.stderr ~= "" then
                msg.error("Error output: " .. result.stderr)
            end
        end
    end
end

function rename_current_file()
    local current_path = mp.get_property("path")
    if not current_path then
        mp.osd_message("No file currently playing")
        return
    end
    
    -- Extract directory and current filename
    local dir, current_filename = current_path:match("(.+)[/\\]([^/\\]+)$")
    if not dir or not current_filename then
        mp.osd_message("Cannot parse file path")
        return
    end
    
    msg.info("Current file: " .. current_filename)
    
    -- Get new filename from user input
    mp.input.get({
        prompt = "Rename to: ",
        default_text = current_filename,
        submit = function(new_filename)
            if not new_filename or new_filename == "" or new_filename == current_filename then
                mp.osd_message("Rename cancelled")
                return
            end
            
            -- Construct new path
            local new_path = dir .. "\\" .. new_filename
            
            msg.info("Renaming from: " .. current_path)
            msg.info("Renaming to: " .. new_path)
            
            -- Use PowerShell to rename the file
            local rename_command = string.format(
                'Rename-Item -Path "%s" -NewName "%s"', 
                current_path:gsub('"', '""'),  -- Escape double quotes for PowerShell
                new_filename:gsub('"', '""')   -- Escape double quotes for PowerShell
            )
            
            msg.info("Executing PowerShell command: " .. rename_command)
            
            local result = utils.subprocess({
                args = {"powershell", "-WindowStyle", "Hidden", "-Command", rename_command},
                cancellable = false
            })
            
            if result.status == 0 then
                mp.osd_message("File renamed successfully", 2)
                msg.info("File renamed successfully")
                -- Update the current file path in MPV
                mp.set_property("path", new_path)
            else
                mp.osd_message("Failed to rename file")
                msg.error("Rename operation failed with status: " .. tostring(result.status))
                if result.stderr and result.stderr ~= "" then
                    msg.error("Error output: " .. result.stderr)
                end
            end
        end
    })
end

function save_custom_snapshot()
    msg.info("DEBUG: save_custom_snapshot function called")
    local current_path = mp.get_property("path")
    if not current_path then
        mp.osd_message("No file currently playing")
        return
    end
    
    msg.info("Taking snapshot for: " .. current_path)
    
    -- Extract directory and filename
    local dir, filename = current_path:match("(.+)[/\\]([^/\\]+)$")
    if not dir or not filename then
        mp.osd_message("Cannot parse file path")
        return
    end
    
    -- Extract name without extension
    local name_without_ext, ext = filename:match("^(.+)%.([^%.]+)$")
    if not name_without_ext then
        name_without_ext = filename
        ext = ""
    end
    
    msg.info("Base filename: " .. name_without_ext)
    
    -- Remove any existing numbered suffix from the base name to get the true base
    local true_base_name = name_without_ext:match("^(.+)_(%d+)$") or name_without_ext
    
    msg.info("True base name: " .. true_base_name)
    
    -- Scan directory for existing snapshot files with this base name
    local scan_command = string.format('Get-ChildItem -Path "%s" -Filter "%s_*.png" | ForEach-Object { $_.Name }', dir, true_base_name)
    msg.info("Scanning for existing snapshots: " .. scan_command)
    
    local result = utils.subprocess({
        args = {"powershell", "-WindowStyle", "Hidden", "-Command", scan_command},
        cancellable = false
    })
    
    local highest_num = 0
    
    if result.status == 0 and result.stdout then
        -- Parse the output to find the highest numbered suffix
        for line in result.stdout:gmatch("[^\r\n]+") do
            local num = line:match(true_base_name .. "_(%d+)%.png$")
            if num then
                local num_val = tonumber(num)
                if num_val and num_val > highest_num then
                    highest_num = num_val
                end
                msg.info("Found existing snapshot: " .. line .. " (number: " .. (num or "none") .. ")")
            end
        end
    end
    
    -- Increment from the highest found number
    local next_num = highest_num + 1
    local snapshot_name = string.format("%s_%03d", true_base_name, next_num)
    
    msg.info("Highest existing number: " .. highest_num .. ", next number: " .. next_num)
    
    -- Create the snapshot filename with .png extension
    local snapshot_filename = snapshot_name .. ".png"
    local snapshot_path = dir .. "\\" .. snapshot_filename
    
    msg.info("Snapshot will be saved as: " .. snapshot_path)
    
    -- Use MPV's screenshot-to-file command
    local result = mp.commandv("screenshot-to-file", snapshot_path, "video")
    
    if result then
        mp.osd_message("Snapshot saved: " .. snapshot_filename, 2)
        msg.info("Snapshot saved successfully: " .. snapshot_path)
    else
        mp.osd_message("Failed to save snapshot")
        msg.error("Screenshot command failed")
    end
end

function show_custom_help()
    if help_visible then
        -- Hide help if already visible
        mp.osd_message("", 0)
        help_visible = false
        return
    end
    
    local help_text = [[Custom Hotkeys:

s              - Select: Copy file without '_attempt_##' suffix
ctrl+s         - Take numbered snapshot
ctrl+c         - Copy current frame to clipboard
\              - Toggle attempt files visibility (variant mode)
DEL            - Move current file to recycle bin
F2             - Rename current file
h              - Show/hide this help
Enter          - Toggle fullscreen
Middle click   - Toggle fullscreen
Left/Right     - Frame advance (default MPV behavior)
Up/Down        - Navigate filtered by media type
Alt+wheel      - Navigate filtered by media type

SMART MODES (auto-detected):
VIDEO: Mouse wheel = frame advance
IMAGE: Mouse wheel + spacebar = navigate images only
AUDIO: Mouse wheel = navigate audio files only

Press 'h' again to hide this help]]

    mp.osd_message(help_text, 10)  -- Show for 10 seconds instead of indefinitely
    help_visible = true
    
    msg.info("Custom help displayed")
    
    -- Auto-hide after 10 seconds
    mp.add_timeout(10, function()
        if help_visible then
            help_visible = false
            msg.info("Help auto-hidden after timeout")
        end
    end)
end

function hide_help()
    if help_visible then
        mp.osd_message("", 0)
        help_visible = false
        msg.info("Help hidden")
    end
end

-- Function to handle any key press and hide help
function on_key_press()
    if help_visible then
        hide_help()
    end
end

function playlist_prev_loop()
    local playlist_count = mp.get_property_number("playlist-count") or 0
    local current_pos = mp.get_property_number("playlist-pos") or 0
    
    if playlist_count <= 1 then
        return  -- No point in looping with 1 or no files
    end
    
    if current_pos <= 0 then
        -- At first item, loop to last
        mp.set_property("playlist-pos", playlist_count - 1)
        msg.info("Looped to end of playlist")
    else
        -- Normal previous
        mp.command("playlist-prev")
    end
end

function playlist_next_loop()
    local playlist_count = mp.get_property_number("playlist-count") or 0
    local current_pos = mp.get_property_number("playlist-pos") or 0
    
    if playlist_count <= 1 then
        return  -- No point in looping with 1 or no files
    end
    
    if current_pos >= playlist_count - 1 then
        -- At last item, loop to first
        mp.set_property("playlist-pos", 0)
        msg.info("Looped to start of playlist")
    else
        -- Normal next
        mp.command("playlist-next")
    end
end

-- Register the functions to be called by hotkeys
mp.add_key_binding("s", "copy_remove_attempt_suffix", copy_remove_attempt_suffix)
mp.add_key_binding("\\", "toggle_attempt_files", toggle_attempt_files_visibility)
mp.add_key_binding("DEL", "move_to_trash", move_to_trash)
mp.add_key_binding("F2", "rename_file", rename_current_file)
mp.add_key_binding("ctrl+s", "save_custom_snapshot", save_custom_snapshot)
mp.add_key_binding("ctrl+c", "copy_frame_clipboard", function() 
    mp.command("screenshot-to-clipboard") 
    mp.osd_message("Frame copied to clipboard", 1)
end)
mp.add_key_binding("h", "show_custom_help", show_custom_help)

-- Fullscreen toggle bindings
mp.add_key_binding("MBTN_MID", "toggle_fullscreen_mouse", function() mp.command("cycle fullscreen") end)
mp.add_key_binding("ENTER", "toggle_fullscreen_enter", function() mp.command("cycle fullscreen") end)

-- Override up/down keys to use filtered navigation
mp.add_key_binding("UP", "filtered_prev", function() navigate_filtered_playlist("prev") end)
mp.add_key_binding("DOWN", "filtered_next", function() navigate_filtered_playlist("next") end)

-- Alt + wheel: still does filtered playlist navigation
mp.add_key_binding("Alt+WHEEL_UP", "alt_wheel_prev", function() navigate_filtered_playlist("prev") end)
mp.add_key_binding("Alt+WHEEL_DOWN", "alt_wheel_next", function() navigate_filtered_playlist("next") end)

-- Set up interaction mode when file loads
mp.register_event("file-loaded", set_interaction_mode)

-- Initial setup
mp.add_timeout(0.1, set_interaction_mode) 