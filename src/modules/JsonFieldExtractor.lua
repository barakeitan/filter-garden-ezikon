--- @module JsonFieldExtractor
-- This module is responsible for extracting and processing fields from a JSON-based ICD (Interface Control Document).
-- It includes functions for parsing header fields, body fields, and other structure definitions from the JSON table.

-- File: src/modules/JsonFieldExtractor.lua

-- Extend the package path to include the module directory
package.path = package.path .. ";./src/modules/?.lua;./src/utils/?.lua"
local utils = require("utils")

local extract_json_field, extract_json_struct

local JsonFieldExtractor = {}

-- Internal table for storing parsed JSON information
local json_icd = {}

--- Parses message enumeration semantics.
--- @param constraints table A table containing the constraints options. private case messageTypeSemantics
--- @return table table of enumerated keys.
--- @raise Raises an error if the semantics table is invalid or missing required fields.
local function parse_message_enumeration(constraints)
    if type(constraints) ~= "table" or not constraints.options then
        utils.json_field_extractor_raise_error("Invalid semantics for message enumeration. Expected table with options.", "parse_message_enumeration")
    end
    local keys = {}
    json_icd.messages = json_icd.messages or {}
    for _, msg_child in pairs(constraints.options) do
        if not msg_child.key or not msg_child.label then
            utils.json_field_extractor_raise_error("Each message option must contain a key and label.", "parse_message_enumeration")
        end
        local key = tonumber(msg_child.key)
        if not key then
            utils.json_field_extractor_raise_error("Message key must be a valid number.", "parse_message_enumeration")
        end
        json_icd.messages[key] = {
            name = msg_child.label,
            fields = {}
        }
        table.insert(keys, key) -- TODO : consider making an enum section like structs as well
    end
    return keys
end

--- Parses numeric range constraints (e.g., min/max values).
--- @param constraints table A table containing field constraints.
--- @return table table with min and max values, or `nil` if not found.
--- @raise Raises an error if the constraints table is invalid or missing required information.
local function parse_valid_values(constraints)
    if type(constraints) ~= "table" then
        utils.json_field_extractor_raise_error("Invalid constraints type. Expected table.", "parse_min_max")
    end
    for _, constraint in ipairs(constraints) do
        if constraint.type == "NumericRangeConstraintSpec" then
            if not constraint.ranges or type(constraint.ranges) ~= "table" then
                utils.json_field_extractor_raise_error("Invalid range specification in constraints.", "parse_min_max")
            end
            -- TODO: loop through all of the ranges and add in the format {{min=,max=},{min=,max=}}
            local range = constraint.ranges[1]
            local min, max, valid_values
            if range.type == "Between" then
                if range.min == nil or range.max == nil then
                    utils.json_field_extractor_raise_error("Range must contain both min and max values.", "parse_min_max")
                end
                valid_values = { min = range.min, max = range.max }
            elseif range.type == "LowerThan" or range.type == "GreaterThan" then
                valid_values = range.type == "LowerThan" and {min = range.value} or {max = range.value}
            elseif range.type == "EqualTo" then
                valid_values = { Exact = range.value }
            end
            return valid_values
           -- return constraint.type ~= "HexNumericRangeConstraintSpec" and { min = range.min, max = range.max } or { min = utils.hex_string_to_integer(range.min), max = utils.hex_string_to_integer(range.max) }
        elseif constraint.type == "EnumSpec" then
            return { enum = parse_message_enumeration(constraint) }
        end
    end
    return nil
end

local function parse_field_size(data_extraction)
    local field_size = 0
    if data_extraction and data_extraction.endOffset.type == "FieldSizeOffsetConfig" then -- usually comes with a RelativeToFieldOffsetConfig in the start config
        field_size = data_extraction.endOffset and data_extraction.endOffset.size
    elseif data_extraction and data_extraction.startOffset.type == data_extraction.endOffset.type == "RelativeToMessageStartOffsetConfig" then
        field_size = data_extraction.endOffset.value - data_extraction.startOffset.value + 1
    elseif data_extraction and data_extraction.startOffset.type == data_extraction.endOffset.type == "RelativeToMessageEndOffsetConfig" then
        field_size = data_extraction.endOffset.value - data_extraction.startOffset.value + 1
    end
    return field_size
end

--- Determines the data type of a field based on decoding information.
--- @param field_table table A table containing the field's details.
--- @return string string representing the data type (e.g., "int32_t", "float").
--- @raise Raises an error if the field table or decoding information is invalid.
local function parse_data_type(field_table)
    if type(field_table) ~= "table" then
        utils.json_field_extractor_raise_error("Invalid field_table provided.", "parse_data_type")
    end
    
    -- Check if the table is a struct and return the struct name
    if field_table.type == "ObjectFieldSpec" then return field_table.name end

    local decoding = field_table.fieldDecoding
    

    local field_size = parse_field_size(field_table.dataExtraction)
    if not field_size then
        utils.json_field_extractor_raise_error("Field size information is missing or invalid.", "parse_data_type")
    end

    -- float or double is not represented, need to diffrenciate by size
    if decoding.numberType and decoding.numberType == "decimal" then
        return field_size == 4 and "float" or "double"
    end
    local is_signed = decoding.signed
    local base_type = is_signed and "int" or "uint"

    if decoding.type == "RawFieldDecodingSpec" or decoding.type == "HexRawFieldDecodingSpec" then
        base_type = "uint" -- We treat raw fields as unsigned integer, raw field must have size
    end

    local data_type = base_type .. (field_size * 8) .. "_t"
    -- TODO: check this
    if not (data_type:match("_t$") or data_type == "float" or data_type == "double" or data_type == "int") then
        utils.json_field_extractor_raise_error("Unsupported or invalid data type: " .. data_type, "parse_data_type")
    end

    return data_type
end

--- Extracts the structure definition from the JSON table.
--- @param object_table table A table containing the object specification.
--- @return string name of the extracted structure.
--- @raise Raises an error if the structure definition is invalid or incomplete.
function extract_json_struct(object_table)
    local struct_name = utils.valid_message_name(object_table.name)
    if not utils.struct_exists(json_icd.structs_def, struct_name) then
        table.insert(json_icd.structs_def, struct_name)
        json_icd.structs[struct_name] = {}
        for _, child_field in ipairs(object_table.children) do
            table.insert(json_icd.structs[struct_name], extract_json_field(child_field))
        end
    end
    return struct_name
end

local function extract_array_field(field_table)
    local field = {}

    -- This means that it is an array of struct, hence the treatment should be different
    if field_table.type == "ArrayFieldSpec" then
        field.data_type = extract_json_struct(field_table.fieldItem)
        if field_table.arraySize.type == "StaticArraySize" then
            field.static_array_size = field_table.arraySize.arraySize
        elseif field_table.arraySize.type == "DynamicArraySize" then 
            field.optional = {type= "optional_type.ARRAY", depend=string.sub(field_table.arraySize.arraySizeFieldPath, 3)} -- remove the ./
        end
    else
        local decoding = field_table.fieldDecoding
        if decoding.numberType and decoding.numberType ~= "int" then
            return decoding.numberType
        end
        local is_signed = decoding.signed
        local base_type = is_signed and "int" or "uint"
        local field_size = field_table.dataExtraction.endOffset.itemSize

        if decoding.type == "RawFieldDecodingSpec" then
            base_type = "uint" -- We treat raw fields as unsigned integer, raw field must have size
        end
        field.valid_value = parse_valid_values(field_table.constraints)
        field.data_type = base_type .. (field_size * 8) .. "_t"
        if field_table.dataExtraction.endOffset.type == "StaticArrayOffsetConfig" then
            field.static_array_size = field_table.dataExtraction.endOffset.arraySize
        elseif field_table.dataExtraction.endOffset.type == "DynamicArrayOffsetConfig" then
            field.optional = {type= "optional_type.ARRAY", depend=string.sub(field_table.dataExtraction.endOffset.arraySizeFieldPath, 3)}
        end
    end
    return field
end

local function extract_bitfield_field(field_table)

end

local function extract_string_field(field_table)
    local field = {}
    field.data_type = "string"
    if field_table.dataExtraction.endOffset.delimiter ~= nil then
        field.delimiter = '"'..field_table.dataExtraction.endOffset.delimiter..'"'
    end
    if field_table.fieldDecoding.escape ~= nil then
        if field_table.fieldDecoding.escape == '\\' then
            field.escape = '"'.."\\\\"..'"'
        else
            field.escape = '"'..field_table.fieldDecoding.escape..'"'
        end
    end
    if field_table.fieldDecoding.charset ~= nil then
        field.charset = '"'..field_table.fieldDecoding.charset..'"'
    end
    return field
end

--- Extracts and organizes information from a field table.
--- @param field_table table A table containing the field's details.
--- @return table table representing the extracted field.
--- @raise Raises an error if the field table is invalid or missing required information.
function extract_json_field(field_table)
    if type(field_table) ~= "table" or not field_table.name then
        utils.json_field_extractor_raise_error("Invalid field_table provided. Expected a table with a name field.", "extract_json_field")
    end
    
    local field = {
        name = field_table.name,
    }
    -- Check if this is a struct 
    if field_table.type == "ObjectFieldSpec" then
        extract_json_struct(field_table.objectSpec)
        field.data_type = field_table.objectSpec.name .. "_t"
    -- Check if this is an array of primitives
    elseif field_table.dataExtraction.endOffset.type == "DynamicArrayOffsetConfig" or field_table.dataExtraction.endOffset.type == "staticArrayOffsetConfig" then 
        field = utils.mergeTables(field, extract_array_field(field_table))

    -- check if this is an array of structs
    elseif field_table.type == "ArrayFieldSpec" then
        field = utils.mergeTables(field, extract_array_field(field_table))

    -- check if this is a bitfield
    elseif field_table.type == "BitObjectFieldSpec" then
        field = utils.mergeTables(field, extract_bitfield_field(field_table))

    -- Check that the field is a string
    elseif field_table.fieldDecoding.type == "StringFieldDecodingSpec" or field_table.fieldDecoding.type == "HexStringFieldDecodingSpec" then
       field = utils.mergeTables(field, extract_string_field(field_table))
    else
        if field_table.semantics then
            if field_table.semantics.type == "MessageTypeSemanticsSpec" then
                field.type_id = true
                field.valid_value = { enum = parse_message_enumeration(field_table.semantics) }
            elseif field_table.semantics.type == 'none' or field_table.semantics.type == 'MessageLengthSemanticsSpec' then
                -- TODO: Implement this edge-case 
            elseif field_table.semantics.type == 'gap' then
                --[[
                    Check two things: 
                    Whether the gap field hasn't a size param - GAP.NOTICE
                    And if the gap field has size param and not valid_value - GAP.BYPASS
                ]]
                
                field.gap_bypass = "NOTICE: " .. field_table.semantics.description
                if next(field_table.constraints) == nil or next(field_table.dataExtraction) == nil then
                    field.gap_notice = true
                end
            else
                --utils.json_field_extractor_raise_error("Unsupported semantics type: " .. field_table.semantics.type, "extract_json_field")
                print("unknown semantic type")
            end
            if not field.gap_notice then
                field.data_type = parse_data_type(field_table)
                field.valid_value = parse_valid_values(field_table.constraints)
            end
        end
    end
    return field
end

--- Extracts the header fields from the JSON table.
--- @param json_table table A Lua table representing the JSON structure.
--- @return table list of parsed header fields.
--- @raise Raises an error if the JSON table structure is invalid or incomplete.
local function extract_json_header(json_table)
    if type(json_table) ~= "table" or not json_table.messageSpec or not json_table.messageSpec.spec then
        utils.json_field_extractor_raise_error("Invalid JSON table structure for extracting header.", "extract_json_header")
    end
    local header_fields = {}
    local children = json_table.messageSpec.spec.children[1].objectSpec.children
    if not children or type(children) ~= "table" then
        utils.json_field_extractor_raise_error("Header fields are missing or improperly structured.", "extract_json_header")
    end
    for _, child in ipairs(children) do
        table.insert(header_fields, extract_json_field(child))
    end
    return header_fields
end

--- Extracts the body fields from the JSON table.
-- Returns a table with the extracted message fields and names based on message codes.
--- @param json_table table A Lua table representing the JSON structure.
--- @return table table in the same format as json_icd.messages with names and extracted fields.
--- @raise Raises an error if the JSON table structure is invalid or incomplete.
local function extract_json_body(json_table)
    if type(json_table) ~= "table" or not json_table.messageSpec or not json_table.messageSpec.spec then
        utils.json_field_extractor_raise_error("Invalid JSON table structure for extracting body.", "extract_json_body")
    end

    local body_cases = json_table.messageSpec.spec.children[2] and json_table.messageSpec.spec.children[2].caseOptions
    if not body_cases or type(body_cases) ~= "table" then
        utils.json_field_extractor_raise_error("Body cases are missing or improperly structured.", "extract_json_body")
    end

    local extracted_messages = {}

    for msg_code, msg_body in pairs(body_cases) do
        local message_key = tonumber(msg_code)
        local message_name = utils.valid_message_name(json_icd.messages[message_key].name)
        local message = {
            name = message_name,
            fields = {}
        }

        local fields = msg_body.objectSpec and msg_body.objectSpec.children
        if not fields or type(fields) ~= "table" then
            utils.json_field_extractor_raise_error("Fields for message code " .. msg_code .. " are missing or improperly structured.", "extract_json_body")
        end

        for _, child_field in ipairs(fields) do
            table.insert(message.fields, extract_json_field(child_field))
        end

        if message_key ~= nil then
            extracted_messages[message_key] = message
        end
    end

    return extracted_messages
end

--- Loads and processes the entire JSON table, extracting header and body fields.
--- @param json_table table table representing the JSON structure.
local function load_json_icd(json_table)
    json_icd.protocol_name = json_table.name
    json_icd.structs_def = {}
    json_icd.structs = {}
    json_icd.header_record = extract_json_header(json_table)
    json_icd.messages = extract_json_body(json_table)
end

--- Main entry point for getting the processed JSON ICD information.
--- @param json_table table A Lua table representing the JSON structure.
--- @return table json_icd table containing all extracted information.
--- @raise Raises an error if the input is not a valid table.
function JsonFieldExtractor.get_json_icd(json_table)
    if type(json_table) ~= "table" then
        utils.json_field_extractor_raise_error("Invalid input. Expected a table for JSON ICD processing.", "get_json_icd")
    end
    load_json_icd(json_table)
    return json_icd
end

return JsonFieldExtractor