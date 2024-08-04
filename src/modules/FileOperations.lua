-- File: src/modules/FileOperations.lua

local FileOperations = {}

-- Function to write content to a file
function FileOperations.writeFile(filePath, content)
    local file, err = io.open(filePath, "w")
    if not file then
        error("Error writing to file: " .. (err or "unknown error"))
    end

    file:write(content)
    file:close()
end

return FileOperations