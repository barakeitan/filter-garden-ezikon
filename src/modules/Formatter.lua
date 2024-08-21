-- File: src/modules/Formatter.lua

package.path = package.path .. ";./src/modules/?.lua;./src/utils/?.lua"

local Formatter = {}
local Constants = require("Constants")

local table_to_string
--- Generates the Lua code for the header section of the output based on the provided JSON ICD.
--- @param json_icd table The JSON structure containing the header information.
--- @return string The Lua code string for the header section.
local function generate_header_code(json_icd)
    -- TODO: Change header based on 'json_icd' parameter
    return Constants.HEADER_SECTION_START ..
        "local header_record = {\n" ..
        table_to_string(json_icd.header_record, 1) ..
        "\n}\n" .. Constants.HEADER_SECTION_END
end

--- Generates the Lua code for the messages section based on the provided JSON ICD.
--- @param json_icd table The JSON structure containing the message definitions.
--- @return string The Lua code string for the messages section.
local function generate_messages_code(json_icd)
    local output = Constants.MESSAGES_SECTION_START
    for _, message in pairs(json_icd.messages) do
        output = output .. "\n\n--------------- " .. string.upper(message.name) .. " ---------------\n\n"
        output = output .. "local " .. message.name .. " = {\n"
        output = output .. "  name = \"" .. message.name .. "\",\n"
        output = output .. "  fields = {\n" ..
            table_to_string(message.fields, 2) ..
            "\n  }\n}\n" .. Constants.MESSAGES_SECTION_END
    end
    return output .. "\n"
end

--- Generates the Lua code for structure definitions based on the provided JSON ICD.
--- @param json_icd table The JSON structure containing the structure definitions.
--- @return string The Lua code string for the structure definitions.
local function generate_structs(json_icd)
    local output = Constants.STRUCTS_SECTION_START
    for struct_name, fields in pairs(json_icd.structs) do
        output = output .. "-- " .. string.upper(struct_name) .. "\nlocal " .. struct_name .. " = {\n" ..
            table_to_string(fields, 1) ..
            "\n}\n"
    end
    return output .. Constants.STRUCTS_SECTION_END
end

--- Generates the Lua code for the structure table mapping in the ICD.
--- @param json_icd table The JSON structure containing structure type definitions.
--- @return string The Lua code string for the structure table mapping.
local function generate_structs_table_code(json_icd)
    local output = Constants.STRUCT_TABLE_SECTION_START .. "local structs = {\n"
    for _, struct_name in ipairs(json_icd.structs_def) do
        output = output .. "  [\"" .. struct_name .. "_t\"] = " .. struct_name .. ",\n"
    end
    return output:sub(1, -3) .. "\n}\n" .. Constants.STRUCT_TABLE_SECTION_END
end

--- Generates the Lua code for the messages table mapping in the ICD.
--- @param json_icd table The JSON structure containing message definitions.
--- @return string The Lua code string for the messages table mapping.
local function generate_messages_table_code(json_icd)
    local output = Constants.MESSAGE_TABLE_SECTION_START .. "local messages = {\n"
    for key, message in pairs(json_icd.messages) do
        output = output .. "  [" .. key .. "] = " .. message.name .. ",\n"
    end
    return output:sub(1, -3) .. "\n}\n" .. Constants.MESSAGE_TABLE_SECTION_END
end

--- Generates the complete Lua code output for the given JSON ICD.
--- @param json_icd table The JSON structure containing the full ICD information.
--- @return string The generated Lua code output.
function Formatter.generate_lua_output(json_icd)
    local output = Constants.GENERATED_STARTER_COMMENT ..
        "-- ======" .. json_icd.protocol_name .. " Filter" .. "====== --" .. "\n\n" ..
        generate_header_code(json_icd) ..
        generate_messages_code(json_icd) ..
        generate_structs(json_icd) ..
        generate_structs_table_code(json_icd) ..
        generate_messages_table_code(json_icd) ..
        "\ngenerate_filter_code(header_record, messages)"
    return output
end

--- Converts a Lua table to a formatted string suitable for Lua code generation.
--- @param tbl table The Lua table to be converted.
--- @param indent number The indentation level for formatting.
--- @return string result The formatted Lua code string.
function table_to_string(tbl, indent)
    indent = indent or 0
    local padding = string.rep("  ", indent)
    local result = {}

    for _, v in ipairs(tbl) do
        local entry = padding .. "{ name = \"" .. v.name .. "\", data_type = \"" .. v.data_type .. "\""
        
        if v.bit_count then
            entry = entry .. ", bit_count = " .. v.bit_count
        end

        if v.valid_value then
            entry = entry .. ", valid_value = { " .. Formatter.valid_value_to_string(v.valid_value) .. " }"
        end

        if v.type_id then
            entry = entry .. ", type_id = " .. tostring(v.type_id)
        end

        table.insert(result, entry .. " }")
    end

    return table.concat(result, ",\n")
end

--- Converts a valid_value table to a formatted string for Lua code generation.
--- @param valid_value table The table containing the valid value details.
--- @return string The formatted Lua code string for valid values.
function Formatter.valid_value_to_string(valid_value)
    if valid_value.enum then
        return "enum = { " .. table.concat(valid_value.enum, ", ") .. " }"
    elseif valid_value.exact then
        return "exact = { " .. table.concat(valid_value.exact, ", ") .. " }"
    elseif valid_value.min or valid_value.max then
        local min = valid_value.min and "min = " .. valid_value.min or ""
        local max = valid_value.max and "max = " .. valid_value.max or ""
        return min .. (min ~= "" and ", " or "") .. max
    end
    return ""
end

return Formatter