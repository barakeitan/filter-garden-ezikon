-- File: src/main.lua

package.path = package.path .. ";./src/?.lua;./src/modules/?.lua;./src/utils/?.lua"

local JsonParser = require("JsonParser")
local Formatter = require("Formatter")
local FileOperations = require("FileOperations")
local JsonFieldExtractor = require("JsonFieldExtractor")
local ArgumentParser = require("ArgumentParser")

--- Main function to create a filter from a JSON json_icd
--- @param inputPath string The input path given.
--- @param outputPath string The output path given.
--- @return written File with Lua Code.
local function create_filter(inputPath, outputPath)
    local luaTable = JsonParser.json_file_to_table(inputPath)
    local json_icd = JsonFieldExtractor.get_json_icd(luaTable)
    local lua_output = Formatter.generate_lua_output(json_icd)
    FileOperations.write_file(outputPath, lua_output)

    print("Conversion complete. Output written to " .. outputPath)
end

local inputFilePath, outputFilePath = ArgumentParser.parse_arguments()

create_filter(inputFilePath, outputFilePath)