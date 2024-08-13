-- File: src/modules/JsonFieldExtractor.lua

package.path = package.path .. ";./src/modules/?.lua"
local Formatter = require("Formatter")

-- Create a table to hold the module functions
local JsonFieldExtractor = {}

-- Internal table for storing parsed JSON information
local json_icd = {}

-- Function to parse constraints
local function parse_constraints(constraints)
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

    -- Add the constraints (ranges)
    field.valid_value = parse_constraints(field_table.constraints)

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
    return "--header\nlocal header_record = " .. JsonFieldExtractor.table_to_string(json_icd.header_record) .. "\n\n"
end

-- Function to generate Lua code for individual message definitions
local function generate_messages_code()
    local output = ""
    for key, message in pairs(json_icd.messages) do
        output = output .. "local " .. message.name .. " = {\n  name = \"" .. message.name .. "\",\n  fields = {\n"
        for index, field in ipairs(message.fields) do
            output = output .. "    { name = \"" .. field.name .. "\", data_type = \"" .. field.data_type .. "\""
            if field.valid_value then
                output = output .. ", valid_value = " .. JsonFieldExtractor.table_to_string(field.valid_value)
            end
            output = output .. " },\n"
        end
        output = output .. "  }\n}\n\n"
    end
    return output
end

-- Function to generate Lua code for the messages table
local function generate_messages_table_code()
    local output = "--messages table\nlocal messages = {\n"
    for key, message in pairs(json_icd.messages) do
        output = output .. "  [" .. key .. "] = " .. message.name .. ",\n"
    end
    output = output .. "}\n"
    return output
end

-- Main function to generate the complete Lua output
function JsonFieldExtractor.generate_lua_output()
    local output = generate_header_code()
    output = output .. generate_messages_code()
    output = output .. generate_messages_table_code()
    output = output .. "\ngenerate_filter_code(header_record, messages)"
    return output
end

-- Function to generate and return the processed json_icd data and Lua output
function JsonFieldExtractor.get_json_icd(json_table)
    JsonFieldExtractor.load_json_icd(json_table)
    local lua_output = JsonFieldExtractor.generate_lua_output()
    print(lua_output)
    return json_icd, lua_output
end

-- Helper function to convert a Lua table to a string
function JsonFieldExtractor.table_to_string(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        if type(k) == "string" then
            k = "\"" .. k .. "\""
        end
        if type(v) == "table" then
            v = JsonFieldExtractor.table_to_string(v)
        else
            if type(v) == "string" then
                v = "\"" .. v .. "\""
            end
        end
        if type(v) == "boolean" then
            if v then
                v = "true"
            else
                v = "false"
            end
        end
        result = result .. "[" .. k .. "]=" .. v .. ","
    end
    return result .. "}"
end

return JsonFieldExtractor