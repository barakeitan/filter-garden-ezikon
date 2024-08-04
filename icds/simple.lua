--header
header_record = {
  { name = "version", data_type = "uint8_t", valid_value = {min = 0, max = 5} },
  { name = "type", data_type = "uint8_t", type_id = true, valid_value = {enum = {1, 2}} },
  { name = "family", data_type = "uint8_t", valid_value = {enum = {0, 1, 2, 3, 4, 5, 6}} },
  { name = "length", data_type = "uint16_t", valid_value = {min = 0} },
  { name = "padding", data_type = "pading", bit_count = 8 }
}

--bitarrays
local hi = {
  { name = "a", bit_count = 1 },
  { name = "b", bit_count = 11 },
  { name = "c", bit_count = 13 },
  { name = "d", bit_count = 3 },
  { name = "e", bit_count = 3 },
  { name = "f", bit_count = 2 }
}

local shalom = {
  { name = "g", bit_count = 9 },
  { name = "h", bit_count = 2 },
  { name = "i", bit_count = 1 },
  { name = "j", bit_count = 4 },
  { name = "k", bit_count = 16 }
}

--structs
local whats_up = {
  { name = "quiet", data_type = "uint8_t", valid_value = {min = 80} },
  { name = "load", data_type = "uint64_t", valid_value = {min = 0} },
  { name = "biting", data_type = "hi_bit_array" },
  { name = "haha", data_type = "int16_t", valid_value = {enum = {9, 3, 5, 178}} }
}

local salam = {
  { name = "surf", data_type = "shalom_bit_array" },
  { name = "good_padding", data_type="padding", bit_count = 30 },
  { name = "pen", data_type = "uint32_t", valid_value = {const = 4511} },
  { name = "ok", data_type = "double", valid_value = {max = 5} }
}

local hello_msg = {
  name = "hello_msg",
  fields = {
    { name = "bienvenue", data_type="uint16_t", valid_value = {min = 2, max = 18047} },
    { name = "welcome", data_type="float", valid_value = {min = 4, max = 9} },
    { name = "padd", data_type="padding", bit_count = 68 },
    { name = "ok", data_type="whats_up_t" }
  }
}

local bye_msg = {
  name = "bye_msg",
  fields = {
    { name = "how_are_u", data_type="salam_t" },
    { name = "goodbye", data_type="uint8_t", valid_value = {min = 2, max = 3} },
    { name = "padd", data_type="padding", bit_count = 68 },
    { name = "have_a_nice_day", data_type="uint8_t" }  }
}

--bitarrays table
bitarrays = {
  ["hi_bit_array"] = hi,
  ["shalom_bit_array"] = shalom
}

--structs table
structs = {
  ["whats_up_t"] = whats_up,
  ["salam_t"] = salam
}

--messages table
messages = {
  [1] = hello_msg,
  [2] = bye_msg
}
