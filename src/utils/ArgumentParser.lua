-- File: src/utils/ArgumentParser.lua

local ArgumentParser = {}

--- Function to parse command line arguments
function ArgumentParser.parse_arguments(...)
    local args = {...}
    if #args >= 2 then
        return args[1], args[2]
    else
        local config = require("config")
        return config.inputPath, config.outputPath
    end
end

return ArgumentParser
