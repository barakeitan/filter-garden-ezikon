-- File: src/modules/Formatter.lua

local Formatter = {}

-- Function to serialize a value into a string representation
function Formatter.serializeValue(v)
    if type(v) == "table" then
        local s = "{"
        for k, val in pairs(v) do
            s = s .. k .. " = " .. Formatter.serializeValue(val) .. ", "
        end
        if s:sub(-2) == ", " then
            s = s:sub(1, -3)  -- Remove trailing comma and space
        end
        return s .. "}"
    elseif type(v) == "string" then
        return '"' .. v .. '"'
    else
        return tostring(v)
    end
end

-- Function to print or write tables in a formatted manner
function Formatter.formatTables(tables)
    local result = ""
    for tableName, tableData in pairs(tables) do
        result = result .. "-- " .. tableName .. "\n"
        result = result .. tableName .. " = {\n"
        for _, record in ipairs(tableData) do
            local s = "  { "
            for k, v in pairs(record) do
                s = s .. k .. " = " .. Formatter.serializeValue(v) .. ", "
            end
            if s:sub(-2) == ", " then
                s = s:sub(1, -3)  -- Remove trailing comma and space
            end
            result = result .. s .. " },\n"
        end
        result = result .. "}\n\n"
    end
    return result
end

return Formatter