-- File: src/modules/JsonFieldExtractor.lua

-- Create a table to hold the module functions
local JsonFieldExtractor = {}

-- Internal table for storing parsed JSON information
local json_icd = {}

-- Function to extract information about a field from the JSON structure
local function extract_json_field(field_table)
    local field = {}
    field.name = field_table.name

    -- Determine the type
    if field_table.fieldDecoding.numberType ~= "int" and field_table.fieldDecoding.numberType ~= nil then 
        field.data_type = field_table.fieldDecoding.numberType
    else 
        if field_table.fieldDecoding.signed == true then
            field.data_type = "int"
        else
            field.data_type = "uint"
        end
    end

    -- Add the sign and size to the int (each described by a different field in the json) 
    local field_size = field_table.dataExtraction.endOffset.size
    field.data_type = field.data_type .. (field_size * 8) .. "_t"

    -- Add the ranges, TODO: support multiple ranges like valid_value = {{min=5, max=8}, {min=20, max=23}}
    if field_table.constraints[001] ~= nil then
        field.valid_value = {min = field_table.constraints[001].ranges[001].min, max = field_table.constraints[001].ranges[001].max}
    end
    if field_table.semantics ~= nil then
        if field_table.semantics.type == "MessageTypeSemanticsSpec" then
            field.type_id = true
            json_icd.messages = {}
            local keys = {}
            for _, msg_child in pairs(field_table.semantics.options) do
                table.insert(json_icd.messages, msg_child.key,{name=msg_child.label, fields={}}) --perhaps enter the body loop here
                table.insert(keys, msg_child.key)
            end
            field.valid_value = {enum=keys}
        end
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
    if json_icd.messages ~= nil then
        for msg_code, msg_body in pairs(json_table.messageSpec.spec.children[2].caseOptions) do
            local message_key = tonumber(msg_code)
            if json_icd.messages[message_key] then
                for _, child_field in ipairs(msg_body.objectSpec.children) do
                    table.insert(json_icd.messages[message_key].fields, extract_json_field(child_field))
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

-- Function to retrieve the processed json_icd data
function JsonFieldExtractor.get_json_icd()
    return json_icd
end

return JsonFieldExtractor