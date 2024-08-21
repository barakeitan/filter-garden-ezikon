-- File: src/utils/ArgumentParser.lua

local ArgumentParser = {}

-- Function to print the help message
local function printHelp()
    print([[
Usage: ./exe <inputPath> <outputPath>

Arguments:
  inputPath   The path to the input file.
  outputPath  The path to save the output file.

Options:
  --help      Show this help message.
]])
end

--- Function to parse command line arguments
function ArgumentParser.parse_arguments(...)
    local args = {...}
    if #args >= 2 then
        if arg[1] == "--help" or arg[2] == "--help" then
            printHelp()
            os.exit(0)
        end
        return args[1], args[2]
    else
        local config = require("config")
        return config.inputPath, config.outputPath
    end
end

return ArgumentParser
