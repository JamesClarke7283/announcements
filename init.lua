-- Load settings
local announce_interval = tonumber(minetest.settings:get("announce_interval")) or 300
local announce_messages = minetest.settings:get("announce_messages") or ""
local messages = {}

-- Split the message string into a table
for message in announce_messages:gmatch("[^,]+") do
    table.insert(messages, message)
end

-- Function to send a random announcement with color
local function send_announcement()
    if #messages > 0 then
        local message = messages[math.random(#messages)]
        -- Format the message with color and style
        local formatted_message = minetest.colorize("#FFA500", "[INFO] ") .. minetest.colorize("#FFFF00", message)
        for _, player in ipairs(minetest.get_connected_players()) do
            minetest.chat_send_player(player:get_player_name(), formatted_message)
        end
    end
end


-- Register globalstep to handle interval
minetest.register_globalstep(function(dtime)
    static_timer = (static_timer or 0) + dtime
    if static_timer >= announce_interval then
        send_announcement()
        static_timer = 0
    end
end)
