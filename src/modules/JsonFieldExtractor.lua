-- File: src/modules/JsonFieldExtractor.lua

package.path = package.path .. ";./src/modules/?.lua"
local Formatter = require("Formatter")

-- Create a table to hold the module functions
local JsonFieldExtractor = {}

-- Internal table for storing parsed JSON information
local json_icd = {}

-- Function to parse constraints
local function parse_min_max(constraints)
    if not constraints or #constraints == 0 then
        return nil
    end

    local constraint_str = nil
    for _, constraint in ipairs(constraints) do
        if constraint.type == "NumericRangeConstraintSpec" then
            local min = constraint.ranges[1].min
            local max = constraint.ranges[1].max
            constraint_str = {min = min, max = max}
        end
    end
    return constraint_str
end

-- Function to extract information about a field from the JSON structure
local function extract_json_field(field_table)
    local field = {}
    field.name = field_table.name

    -- Determine the data type
    if field_table.fieldDecoding.numberType and field_table.fieldDecoding.numberType ~= "int" then 
        field.data_type = field_table.fieldDecoding.numberType
    else 
        if field_table.fieldDecoding.signed then
            field.data_type = "int"
        else
            field.data_type = "uint"
        end
    end

    -- Add the sign and size to the int
    local field_size = field_table.dataExtraction.endOffset.size
    field.data_type = field.data_type .. (field_size * 8) .. "_t"

    -- Parse data-type
    --field.data_type = parse_data_type(field_table)

    -- Add the constraints (ranges)
    field.valid_value = parse_min_max(field_table.constraints)
    -- Handle type_id and enumeration for message types
    if field_table.semantics and field_table.semantics.type == "MessageTypeSemanticsSpec" then
        field.type_id = true
        local keys = {}
        json_icd.messages = json_icd.messages or {}
        
        for _, msg_child in pairs(field_table.semantics.options) do
            json_icd.messages[tonumber(msg_child.key)] = {
                name = msg_child.label,
                fields = {}
            }
            table.insert(keys, msg_child.key)
        end
        
        field.valid_value = {enum = keys}
    end

    return field
end

-- Function to extract header fields from the JSON structure
function JsonFieldExtractor.extract_json_header(json_table)
    local header = {}
    for _, child in ipairs(json_table.messageSpec.spec.children[1].objectSpec.children) do
        table.insert(header, extract_json_field(child))
    end
    return header
end

-- Function to extract body fields from the JSON structure
function JsonFieldExtractor.extract_json_body(json_table)
    if json_icd.messages then
        for msg_code, msg_body in pairs(json_table.messageSpec.spec.children[2].caseOptions) do
            local message_key = tonumber(msg_code)
            local message = json_icd.messages[message_key]
            if message then
                for _, child_field in ipairs(msg_body.objectSpec.children) do
                    table.insert(message.fields, extract_json_field(child_field))
                end
            end
        end
    end
end

-- Function to load JSON structure into a custom Lua table format
function JsonFieldExtractor.load_json_icd(json_table)
    json_icd.header_record = JsonFieldExtractor.extract_json_header(json_table)
    JsonFieldExtractor.extract_json_body(json_table)
end

-- Function to generate Lua code for header record
local function generate_header_code()
    return "-- Header Message\nlocal header_record = {\n" .. JsonFieldExtractor.table_to_string(json_icd.header_record, 0) .. "\n}\n\n"
end

-- Function to generate Lua code for individual message definitions
local function generate_messages_code()
    local output = ""
    for key, message in pairs(json_icd.messages) do
        output = output .. "-- " .. string.upper(message.name) .. "\n" .. "local " .. message.name .. " = {\n  name = \"" .. message.name .. "\",\n  fields = {\n"
        output = output .. JsonFieldExtractor.table_to_string(message.fields, 1) .. "\n"
        output = output .. "  }\n}\n\n"
    end
    return output
end

-- Function to generate Lua code for the messages table
local function generate_messages_table_code()
    local output = "\n-- Messages Definition Table\nlocal messages = {\n"
    for key, message in pairs(json_icd.messages) do
        output = output .. "  [" .. key .. "] = " .. message.name .. ",\n"
    end
    output = output .. "}\n"
    return output
end

-- Function that implememt the structs table definition and the structures itself
-- Unimplemented
local function generate_structs_table()
    local output = "\nֿֿֿֿֿ-- Structs Definition Table\nlocal structs = {\n"
    json_icd.structs = json_icd.structs or {}
    for key, message in pairs(json_icd.structs) do
        
    end
    output = output .. "}\n"
    return output
end

-- Main function to generate the complete Lua output
function JsonFieldExtractor.generate_lua_output()
    local output = '--[[\n\tThis Lua Code is generated by the Filter-Garden Project "Azikon"\n]]\n\n'
    output = output .. generate_header_code()
    output = output .. generate_messages_code()
    output = output .. generate_structs_table()
    output = output .. generate_messages_table_code()
    output = output .. "\ngenerate_filter_code(header_record, messages, structs)"
    return output
end

-- Function to generate and return the processed json_icd data and Lua output
function JsonFieldExtractor.get_json_icd(json_table)
    JsonFieldExtractor.load_json_icd(json_table)
    local lua_output = JsonFieldExtractor.generate_lua_output()
    -- return json_icd
    return lua_output
end

-- Helper function to convert a Lua table to a string with proper formatting and field order
function JsonFieldExtractor.table_to_string(tbl, indent)
    indent = indent or 0
    local result = "" -- Start with an empty string
    local padding = string.rep("  ", indent + 1)

    for _, v in ipairs(tbl) do
        result = result .. padding .. "{ "
        
        -- Define the order of the keys
        local ordered_keys = { "name", "data_type", "valid_value" }
        
        -- Process the ordered keys first
        for _, key in ipairs(ordered_keys) do
            local value = v[key]
            if value then
                if key == "valid_value" and type(value) == "table" then
                    result = result .. key .. " = { "
                    if value.enum then
                        result = result .. "enum = { " .. table.concat(value.enum, ", ") .. " }"
                    elseif value[1] and value[1].exact then
                        -- Handling multiple exact values
                        for _, exact_entry in ipairs(value) do
                            result = result .. "{ exact = " .. exact_entry.exact .. " }, "
                        end
                    else
                        local min = value.min or ""
                        local max = value.max or ""
                        result = result .. "min = " .. min .. ", max = " .. max
                    end
                    result = result .. " }, "
                elseif type(value) == "table" then
                    result = result .. key .. " = " .. JsonFieldExtractor.table_to_string({value}, indent + 1) .. ", "
                else
                    if type(value) == "string" then
                        value = "\"" .. value .. "\""
                    end
                    result = result .. key .. " = " .. tostring(value) .. ", "
                end
            end
        end
        
        -- Process any remaining keys that are not in the ordered list
        for key, value in pairs(v) do
            if not (key == "name" or key == "data_type" or key == "valid_value") then
                if type(value) == "table" then
                    result = result .. key .. " = " .. JsonFieldExtractor.table_to_string({value}, indent + 1) .. ", "
                else
                    if type(value) == "string" then
                        value = "\"" .. value .. "\""
                    end
                    result = result .. key .. " = " .. tostring(value) .. ", "
                end
            end
        end

        result = result:sub(1, -3) -- Remove the trailing comma and space
        result = result .. " },\n"
    end

    result = result .. string.rep("  ", indent)

    -- Remove the last newline character
    if result:sub(-2) == ",\n" then
        result = result:sub(1, -3) -- Removes ",\n" at the end
    end

    return result
end
    
    
return JsonFieldExtractor