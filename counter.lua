obs = obslua

-- Vinicius Lawliet
-- Version 2.0
-- RFMxIGlzIGJldHRlciB0aGFuIERTMg== (Base64)

-- Global variables
hotkey_id_inc = obs.OBS_INVALID_HOTKEY_ID
hotkey_id_dec = obs.OBS_INVALID_HOTKEY_ID
hotkey_id_res = obs.OBS_INVALID_HOTKEY_ID

counter = 0
start_value = 0
step = 1
allow_negative = false

format_string = "Counter: %d"
text_source_name = "Counter"

-- Crash-safe persistence file
state_file = "counter_state.txt"

-- Save counter immediately to file
function save_state()
    local file = io.open(state_file, "w")
    if file ~= nil then
        file:write(tostring(counter))
        file:close()
    end
end

-- Load counter from file if it exists
function load_state()
    local file = io.open(state_file, "r")
    if file ~= nil then
        local value = tonumber(file:read("*all"))
        file:close()

        if value ~= nil then
            counter = value
        end
    end
end

-- Load script
function script_load(settings)
    counter = obs.obs_data_get_int(settings, "counter")
    start_value = obs.obs_data_get_int(settings, "start_value")
    step = obs.obs_data_get_int(settings, "step")
    allow_negative = obs.obs_data_get_bool(settings, "allow_negative")

    text_source_name = obs.obs_data_get_string(settings, "text_source_name")
    format_string = obs.obs_data_get_string(settings, "format_string")

    if step < 1 then step = 1 end

    -- Recover last saved value (crash-safe)
    load_state()

    -- Register hotkeys
    hotkey_id_inc = obs.obs_hotkey_register_frontend("hotkey_inc", "Increment", increment_counter)
    hotkey_id_dec = obs.obs_hotkey_register_frontend("hotkey_dec", "Decrement", decrement_counter)
    hotkey_id_res = obs.obs_hotkey_register_frontend("hotkey_res", "Reset", reset_counter)
    
    -- Load saved hotkeys
    local hotkey_save_array_inc = obs.obs_data_get_array(settings, "hotkey_inc")
    local hotkey_save_array_dec = obs.obs_data_get_array(settings, "hotkey_dec")
    local hotkey_save_array_res = obs.obs_data_get_array(settings, "hotkey_res")

    obs.obs_hotkey_load(hotkey_id_inc, hotkey_save_array_inc)
    obs.obs_hotkey_load(hotkey_id_dec, hotkey_save_array_dec)
    obs.obs_hotkey_load(hotkey_id_res, hotkey_save_array_res)

    obs.obs_data_array_release(hotkey_save_array_inc)
    obs.obs_data_array_release(hotkey_save_array_dec)
    obs.obs_data_array_release(hotkey_save_array_res)

    update_text()
end

-- Save script state on OBS exit
function script_save(settings)
    obs.obs_data_set_int(settings, "counter", counter)
    obs.obs_data_set_int(settings, "start_value", start_value)
    obs.obs_data_set_int(settings, "step", step)
    obs.obs_data_set_bool(settings, "allow_negative", allow_negative)

    obs.obs_data_set_string(settings, "text_source_name", text_source_name)
    obs.obs_data_set_string(settings, "format_string", format_string)
    
    local hotkey_save_array_inc = obs.obs_hotkey_save(hotkey_id_inc)
    local hotkey_save_array_dec = obs.obs_hotkey_save(hotkey_id_dec)
    local hotkey_save_array_res = obs.obs_hotkey_save(hotkey_id_res)

    obs.obs_data_set_array(settings, "hotkey_inc", hotkey_save_array_inc)
    obs.obs_data_set_array(settings, "hotkey_dec", hotkey_save_array_dec)
    obs.obs_data_set_array(settings, "hotkey_res", hotkey_save_array_res)

    obs.obs_data_array_release(hotkey_save_array_inc)
    obs.obs_data_array_release(hotkey_save_array_dec)
    obs.obs_data_array_release(hotkey_save_array_res)

    save_state()
end

-- Increment counter
function increment_counter(pressed)
    if pressed then
        counter = counter + step
        update_text()
        save_state()
    end
end

-- Decrement counter
function decrement_counter(pressed)
    if pressed then
        counter = counter - step

        if not allow_negative and counter < 0 then
            counter = 0
        end

        update_text()
        save_state()
    end
end

-- Reset counter to start value
function reset_counter(pressed)
    if pressed then
        counter = start_value
        update_text()
        save_state()
    end
end

-- Update text source
function update_text()
    local source = obs.obs_get_source_by_name(text_source_name)
    if source ~= nil then
        local settings = obs.obs_source_get_settings(source)

        local success, new_text = pcall(string.format, format_string, counter)
        if not success then
            new_text = tostring(counter)
        end

        obs.obs_data_set_string(settings, "text", new_text)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)
    end
end

-- Script properties (UI)
function script_properties()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_text(props, "format_string", "Display Format", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "text_source_name", "Text Source Name (GDI+)", obs.OBS_TEXT_DEFAULT)

    obs.obs_properties_add_int(props, "start_value", "Start Value", -999999, 999999, 1)
    obs.obs_properties_add_int(props, "step", "Step", 1, 999999, 1)
    obs.obs_properties_add_bool(props, "allow_negative", "Allow Negative Values")

    return props
end

-- Called when user updates settings
function script_update(settings)
    format_string = obs.obs_data_get_string(settings, "format_string")
    text_source_name = obs.obs_data_get_string(settings, "text_source_name")

    start_value = obs.obs_data_get_int(settings, "start_value")
    step = obs.obs_data_get_int(settings, "step")
    allow_negative = obs.obs_data_get_bool(settings, "allow_negative")

    if step < 1 then step = 1 end

    update_text()
end

-- Script description
function script_description()
    return [[
Simple OBS counter with increment, decrement, and reset hotkeys.
The counter is saved instantly to a file to prevent data loss in case of crashes.

SETUP (Step-by-step):
1. OBS → add "Text (GDI+)" source
2. Rename to match "Text Source Name" (ex: Counter)
3. Tools → Scripts → load this script
4. Set format (ex: Deaths: %d)
5. Settings → Hotkeys → bind keys
]]
end