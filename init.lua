-- Load announcement settings
local announce_interval = tonumber(minetest.settings:get("announce_interval")) or 300
local announce_messages = minetest.settings:get("announce_messages") or "Message1,Message2,Message3"
local messages = {}

-- Split the message string into a table
for message in string.gmatch(announce_messages, "[^,]+") do
    message = message:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
    table.insert(messages, message)
end

-- Function to send a random announcement
local function send_announcement()
    if #messages > 0 then
        local message = messages[math.random(#messages)]
        local formatted_message = minetest.colorize("#FFA500", "[INFO] ") .. minetest.colorize("#FFFF00", message)

        for _, player in ipairs(minetest.get_connected_players()) do
            local player_name = player:get_player_name()
            local player_pref = minetest.deserialize(storage:get_string(player_name)) or {receive_announcements = true}
            if player_pref.receive_announcements then
                minetest.chat_send_player(player_name, formatted_message)
            end
        end
    end
end

-- Register globalstep for sending announcements
local static_timer = 0
minetest.register_globalstep(function(dtime)
    static_timer = static_timer + dtime
    if static_timer >= announce_interval then
        send_announcement()
        static_timer = 0
    end
end)

-- Toggle announcements command
minetest.register_chatcommand("announcements_toggle", {
    description = "Toggle receiving announcements",
    func = function(name)
        local player_pref = minetest.deserialize(storage:get_string(name)) or {receive_announcements = true}
        player_pref.receive_announcements = not player_pref.receive_announcements
        storage:set_string(name, minetest.serialize(player_pref))
        local status = player_pref.receive_announcements and "enabled" or "disabled"
        return true, "Announcements have been " .. status
    end,
})

-- Mod storage for player preferences
storage = minetest.get_mod_storage()
