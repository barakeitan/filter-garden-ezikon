-- File: src/utils/Utils.lua

local Utils = {}

--- Converts a hexadecimal string to an integer in hexadecimal format
--- @param hexStr: A hexadecimal string (e.g., "1A2B")
--- @return A string representing the integer in hexadecimal format (e.g., "0x1A2B")
function Utils.hex_string_to_integer(hexStr)
    if type(hexStr) ~= "string" or not hexStr:match("^%x+$") then
        raise_error("Input must be a valid hexadecimal string.", "hexStringToInteger")
    end
    local intValue = tonumber(hexStr, 16)
    return string.format("0x%X", intValue)
end


--- @brief Raises a formatted error message specific to JSON field extraction.
--- Combines the provided message with additional context (if any) to generate a more detailed error message.
---
--- @param msg string The main error message.
--- @param context string (Optional) Additional context information to include in the error message.
--- @throws Error with the formatted message.
function Utils.json_field_extractor_raise_error(msg, context)
    local err_msg = "JsonFieldExtractor Error: " .. msg
    if context then
        err_msg = err_msg .. " | Context: " .. context
    end
    error(err_msg)
end

function Utils.valid_message_name(name)
    local output = name:gsub("%s+", "_")  -- Replace one or more whitespaces with an underscore
    output = output:gsub("[^a-zA-Z_]", "")  -- Remove any character that is not a letter or underscore

    return output
end

--- @brief Checks if a specified structure name exists within a structure definition table.
---
--- @param struct_def table A table containing the structure names.
--- @param struct_name string The name of the structure to check for.
---
--- @return boolean Returns `true` if the structure name exists in the definition, otherwise `false`.
function Utils.struct_exists(struct_def, struct_name)
    if type(struct_def) ~= "table" or not struct_def then return false end
    for _, v in ipairs(struct_def) do
        if v == struct_name then
            return true
        end
    end
    return false
end

return Utils