-- File: src/modules/JsonParser.lua
package.path = package.path .. ";./src/lib/?.lua"
local json = require("dkjson")

local JsonParser = {}

--- Reads the content of a file and returns it as a string.
---
--- This function opens a file in read mode, reads the entire content, 
--- and returns it as a string. If there is an error opening the file, 
--- it raises an error with a descriptive message.
---
--- @param filePath string The path to the file that should be read.
--- @return string content of the file as a string.
--- @throws Error if the file cannot be opened.
local function read_file(filePath)
    local file, err = io.open(filePath, "r")
    if not file then
        error("Error opening file: " .. (err or "unknown error"))
    end

    local content = file:read("*a") -- Read entire file content
    file:close()
    return content
end

--- Reads a JSON file and converts it into a Lua table.
---
--- This function first reads the content of the specified file using 
--- `read_file()`. It then attempts to parse the content as JSON 
--- and returns the resulting Lua table. If there is an error during 
--- parsing, it raises an error with a descriptive message.
---
--- @param filePath string The path to the JSON file.
--- @return table The parsed content of the JSON file as a Lua table.
--- @throws Error if the JSON parsing fails or the file cannot be read.
function JsonParser.json_file_to_table(filePath)
    local content = read_file(filePath)
    local luaTable, pos, err = json.decode(content, 1, nil)
    if err then
        error("Error parsing JSON: " .. err)
    end

    return luaTable
end

return JsonParser