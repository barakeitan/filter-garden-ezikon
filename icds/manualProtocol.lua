local header_record = {
    -- couldn't care less
}

local string_message = {
    {name="flight_number", data_type = "flight_number_t"}
}

local flight_number = {
    {name="letters", data_type="flight_number_letters_t"},
    {name="digits", data_type="flight_number_digits_t"}
}
--[[
    In the fieldDecoding section of the json, 
    if the type is a "StringFieldDecodingSpec"
    one might find that the json doesn't contain a signed fieldDecoding
    in which case you should consider treating it as unsigned

    In addition, the string blabla above will be considered a uint with its size
    to calculate the end offset of a RelativeToMessageStartOffsetConfig
    one must check that the start offset is the same and subtract the start value from the end value 
]]
local flight_number_letters = {
    {name="version-letters", data_type="int8_t", valid_value={ min = 0, max = 5 }}
}

local flight_number_digits = {
    {name="version-digits", data_type="int8_t", valid_value={ min = 0, max = 5 }}
}

local structs = {
    ["flight_number_t"] = flight_number,
    ["flight_number_letters_t"] = flight_number_letters,
    ["flight_number_digits_t"] = flight_number_digits
}



local messages = {
    [21] = string_message
}

-- field1.name = "hulubulu"

-- if type = ofs do the written below
--     filed1.data_type=ejs(fieldTable.objectSpec)
--         ejs()
--             if(structs[objectSpec.name] == nil
--                 struct.fields ={extract all children} and add it to the struct table def
--             return objectSpec.name .. "_t"
-- else
--     continue extracting field