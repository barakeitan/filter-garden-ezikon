-- File: src/main.lua

package.path = package.path .. ";./src/?.lua;./src/modules/?.lua"

local JsonParser = require("JsonParser")
local Formatter = require("Formatter")
local FileOperations = require("FileOperations")
local JsonFieldExtractor = require("JsonFieldExtractor")
local config = require("config")

-- Main function to create a filter from a JSON ICD
function Create_filter(inputPath, outputPath)
    local luaTable = JsonParser.jsonFileToTable(inputPath)
    JsonFieldExtractor.load_json_icd(luaTable)
    local json_icd = JsonFieldExtractor.get_json_icd(luaTable)

    -- Format tables and write to file
    local formattedTables = Formatter.formatTables(json_icd)
    FileOperations.writeFile(outputPath, formattedTables)

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