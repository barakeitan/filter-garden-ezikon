-- File: src/modules/JsonParser.lua
package.path = package.path .. ";./src/lib/?.lua"
local json = require("dkjson")

local JsonParser = {}

-- Function to read content from a file
function JsonParser.readFile(filePath)
    local file, err = io.open(filePath, "r")
    if not file then
        error("Error opening file: " .. (err or "unknown error"))
    end

    local content = file:read("*a") -- Read entire file content
    file:close()
    return content
end

-- Function to convert JSON file to a Lua table
function JsonParser.jsonFileToTable(filePath)
    local content = JsonParser.readFile(filePath)
    local luaTable, pos, err = json.decode(content, 1, nil)
    
    if err then
        error("Error parsing JSON: " .. err)
    end

    return luaTable
end

return JsonParser