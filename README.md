# Filter Garden - Ezikon

This project is for generating Lua code that will be used by our GenGen2 to generate future filters.
### Usage
The project can be run from the command line using the Lua interpreter. It reads a JSON file, processes it, and outputs a formatted Lua script.
### Running the Script
You can run the script with default configuration paths (using the `config.lua` file) or provide custom paths via command-line arguments:
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
  ├── /src
  │   ├── main.lua             # Main script for executing the conversion
  │   ├── config.lua           # Configuration file for paths and settings
  │   ├── /modules             # Modules for specific functionalities
  │   │   ├── JsonParser.lua   # Module for JSON file reading and parsing
  │   │   ├── Formatter.lua    # Module for formatting Lua tables from JSON data
  ├── /lib
  │   ├── dkjson.lua           # JSON handling library
  ├── /data
  │   ├── Message-Spec-Example.json  # Sample JSON input file
  │   ├── protocol.json              # JSON protocol file (for structure reference)
  ├── /output
  │   ├── out.lua             # Output Lua script generated from JSON
  ├── /icds
  │   ├── dis.lua
  │   ├── protocol.lua
  │   ├── simple.lua
  │   ├── simplest.lua
  ├── /docs-implemtation      # Declaration of documentation files for project details
  ├── README.md               # Main project documentation and instructions
```
