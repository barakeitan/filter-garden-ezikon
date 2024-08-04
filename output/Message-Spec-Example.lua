-- messages
messages = {
  { name = "hello_msg", fields = {1 = {data_type = "int16_t", name = "bienvenue", valid_value = {1 = {min = 2, max = 18047}}}, 2 = {data_type = "float32_t", name = "welcome", valid_value = {1 = {min = 4, max = 9}}}, 3 = {name = "padding", data_type = "int64_t"}, 4 = {data_type = "int8_t", name = "ok", valid_value = {1 = {min = 0, max = 2147483647}}}} },
  { name = "bye_msg", fields = {1 = {name = "how_are_u", data_type = "uint8_t"}, 2 = {data_type = "int8_t", name = "goodbye", valid_value = {1 = {min = 2, max = 3}}}, 3 = {name = "padding", data_type = "uint64_t"}, 4 = {name = "have_a_nice_day", data_type = "uint8_t"}} },
}

-- header_record
header_record = {
  { data_type = "int8_t", name = "version", valid_value = {1 = {min = 0, max = 5}} },
  { type_id = true, data_type = "uint8_t", name = "msg_type", valid_value = {enum = {1 = 1, 2 = 2}} },
  { data_type = "int8_t", name = "family", valid_value = {1 = {min = 0, max = 6}} },
  { data_type = "int16_t", name = "len", valid_value = {1 = {min = 0, max = 2147483647}} },
  { name = "padding", data_type = "int8_t" },
}