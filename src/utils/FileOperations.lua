-- File: src/modules/FileOperations.lua

local FileOperations = {}

--- @brief Writes content to a specified file.
--- If the file does not exist, it will be created. If the file already exists, its content will be overwritten.
---
--- @param filePath string The path to the file where content should be written.
--- @param content string The content to be written to the file.
---
--- @throws Error If the file cannot be opened for writing.
function FileOperations.write_file(filePath, content)
    local file, err = io.open(filePath, "w")
    if not file then
        error("Error writing to file: " .. (err or "unknown error"))
    end

    file:write(content)
    file:close()
end

return FileOperations