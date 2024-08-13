--header
local header_record = {
  { name = "version", data_type = "uint8_t", valid_value = {min = 0, max = 5} },
  { name = "type", data_type = "uint8_t", type_id = true, valid_value = {enum = {1, 2}} },
  { name = "family", data_type = "uint8_t", valid_value = {enum = {0, 1, 2, 3, 4, 5, 6}} },
  { name = "length", data_type = "uint16_t", valid_value = {min = 0} },
  { name = "padding", data_type = "padding", bit_count = 8 }
}

local hello_msg = {
  name = "hello_msg",
  fields = {
    { name = "bienvenue", data_type="uint16_t", valid_value = {min = 2, max = 18047} },
    { name = "welcome", data_type="float", valid_value = {min = 4, max = 9} },
    { name = "padd", data_type="padding", bit_count = 68 },
    { name = "ok", data_type="uint8_t" }
  }
}

local bye_msg = {
  name = "bye_msg",
  fields = {
    { name = "how_are_u", data_type="uint8_t" },
    { name = "goodbye", data_type="uint8_t", valid_value = {min = 2, max = 3} },
    { name = "padd", data_type="padding", bit_count = 68 },
    { name = "have_a_nice_day", data_type="uint8_t" }  }
}

--messages table
local messages = {
  [1] = hello_msg,
  [2] = bye_msg
}

generate_filter_code(header_record, messages)