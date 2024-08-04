-- File: src/main.lua

package.path = package.path .. ";./src/?.lua;./src/modules/?.lua"

local JsonParser = require("JsonParser")
local Formatter = require("Formatter")
local config = require("config")

local json_icd = {}

-- Function to extract information about a field from the JSON structure
local function extract_json_field(field_table)
    local field = {}
    field.name = field_table.name

    -- Determine the field data type
    if field_table.fieldDecoding.numberType ~= "int" and field_table.fieldDecoding.numberType ~= nil then 
        field.data_type = field_table.fieldDecoding.numberType
    else 
        if field_table.fieldDecoding.signed == true then
            field.data_type = "int"
        else
            field.data_type = "uint"
        end
    end

    -- Add the size to the integer type (each field described separately in JSON)
    local field_size = field_table.dataExtraction.endOffset.size
    field.data_type = field.data_type .. (field_size * 8) .. "_t"

    -- Add constraints for valid values
    if field_table.constraints[1] ~= nil then
        field.valid_value = {
            min = field_table.constraints[1].ranges[1].min,
            max = field_table.constraints[1].ranges[1].max
        }
    end

    -- Check for specific semantics like message type
    if field_table.semantics ~= nil then
        if field_table.semantics.type == "MessageTypeSemanticsSpec" then
            field.type_id = true
            json_icd.messages = {}
            local keys = {}
            for _, msg_child in pairs(field_table.semantics.options) do
                table.insert(json_icd.messages, msg_child.key, {name = msg_child.label, fields = {}})
                table.insert(keys, msg_child.key)
            end
            field.valid_value = {enum = keys}
        end
    end

    return field
end

-- Function to extract header fields from the JSON structure
local function extract_json_header(json_table)
    local header = {}
    for _, child in ipairs(json_table.messageSpec.spec.children[1].objectSpec.children) do
        table.insert(header, extract_json_field(child))
    end
    return header
end

-- Function to extract body fields from the JSON structure
local function extract_json_body(json_table)
    if json_icd.messages ~= nil then
        for msg_code, msg_body in pairs(json_table.messageSpec.spec.children[2].caseOptions) do
            for _, child_field in ipairs(msg_body.objectSpec.children) do
                if tonumber(msg_code) then
                    table.insert(json_icd.messages[tonumber(msg_code)].fields, extract_json_field(child_field))
                end
            end
        end
    end
end

-- Function to load JSON structure into a custom Lua table format
local function load_json_icd(json_table)
    json_icd.header_record = extract_json_header(json_table)
    extract_json_body(json_table)
end

-- Function to write content to a file
local function writeFile(filePath, content)
    local file, err = io.open(filePath, "w")
    if not file then
        error("Error writing to file: " .. (err or "unknown error"))
    end

    file:write(content)
    file:close()
end

-- Main function to create a filter from a JSON ICD
function Create_filter(inputPath, outputPath)
    local luaTable = JsonParser.jsonFileToTable(inputPath)
    load_json_icd(luaTable)

    -- Format tables and write to file
    local formattedTables = Formatter.formatTables(json_icd)
    writeFile(outputPath, formattedTables)

    print("Conversion complete. Output written to " .. outputPath)
end

-- Function to parse command line arguments
local function parseArguments(...)
    local args = {...}
    if #args >= 2 then
        return args[1], args[2]
    else
        return config.inputPath, config.outputPath
    end
end

-- Main execution
local inputFilePath, outputFilePath = parseArguments()

Create_filter(inputFilePath, outputFilePath)