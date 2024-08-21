# Filter Garden - Azikon

This project is for generating Lua code that will be used by our GenGen2 to generate future filters.
### Usage
The project can be run from the command line using the Lua interpreter. It reads a JSON file, processes it, and outputs a formatted Lua script.
### Running the Script
You can run the script with default configuration paths (using the `src/config.lua` file) or provide custom paths via command-line arguments:
```bash
lua src/main.lua
```
Or with custom paths:
```bash
lua src/main.lua "./data/custom.json" "./output/custom.lua"
```

### Project Structure Overview
```
/root-directory
  ├── /.vscode
  │   ├── launch.json          # Configuration file for running project via VSCode
  ├── /src
  │   ├── main.lua             # Main script for executing the conversion
  │   ├── config.lua           # Configuration file for paths and settings
  │   ├── /modules             # Modules for specific functionalities
  │   │   ├── JsonFieldExtractor.lua   # Module for extarcting JSON file
  │   │   ├── Formatter.lua            # Module for formatting Lua tables from JSON data
  |   ├── /lib
  │   |   ├── dkjson.lua               # JSON handling library
  |   ├── /utils
  │   |   ├── ArgumentParser.lua           # Parse arguments or using `/src/config.lua`
  │   |   ├── Constants.lua                # Storing constants
  │   |   ├── FileOperations.lua           # Utils for files (e.g, writing a file)
  │   |   ├── JsonParser.lua               # Module for JSON file reading and parsing
  │   |   ├── Utils.lua                    # Module for general util functionalities
  ├── /data
  │   ├── Message-Spec-Example.json  # Sample JSON input file
  │   ├── protocol.json              # JSON protocol file
  │   ├── structs.json               # JSON structs exmaple file (for structure reference)
  │   ├── MESSAGE.json               # JSON `MESSAGE` exmaple file
  ├── /output
  │   ├── out.lua                   # Output Lua script generated from JSON (PLACEHOLDER)
  │   ├── Message-Spec-Example.lua  # Output Lua script generated from `Message-Spec-Example.json`
  │   ├── structs.lua  # Output Lua script generated from `structs.json`
  ├── /icds
  │   ├── dis.lua
  │   ├── protocol.lua
  │   ├── manualProtocol.lua    # A manually built protocol for an output example
  │   ├── simple.lua
  │   ├── simplest.lua          # Manually written output Lua script example generated from `Simplest.json`
  ├── /docs-implemtation      # Declaration of documentation files for project details
  ├── README.md               # Main project documentation and instructions
```

### Contributing Guidelines
To keep our code clean and consistent, here are some simple guidelines for naming functions:
1. Use `snake_case`: Stick to all lowercase with underscores, like `load_file` or `parse_data`. It’s easy to read and follows Lua’s usual style.

2. Be descriptive: Use names that clearly say what the function does, like `generate_report` instead of just `generate`. Clarity is key!

3. Keep it modular: Each file should focus on one thing (e.g., parsing, formatting). This makes it easier to find and update code when needed.

4. Keep it friendly: Better to be a bit verbose and clear than too brief and confusing.

