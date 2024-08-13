-- messages
messages = {
  { name = "hello_msg", fields = {1 = {name = "bienvenue", data_type = "int16_t", valid_value = {min = 2, max = 18047}}, 2 = {name = "welcome", data_type = "float32_t", valid_value = {min = 4, max = 9}}, 3 = {name = "padding", data_type = "int64_t"}, 4 = {name = "ok", data_type = "int8_t", valid_value = {min = 0, max = 2147483647}}} },
  { name = "bye_msg", fields = {1 = {name = "how_are_u", data_type = "uint8_t"}, 2 = {name = "goodbye", data_type = "int8_t", valid_value = {min = 2, max = 3}}, 3 = {name = "padding", data_type = "uint64_t"}, 4 = {name = "have_a_nice_day", data_type = "uint8_t"}} },
}

-- header_record
header_record = {
  { name = "version", data_type = "int8_t", valid_value = {min = 0, max = 5} },
  { name = "msg_type", data_type = "uint8_t", valid_value = {enum = {1 = "1", 2 = "2"}}, type_id = true },
  { name = "family", data_type = "int8_t", valid_value = {min = 0, max = 6} },
  { name = "len", data_type = "int16_t", valid_value = {min = 0, max = 2147483647} },
  { name = "padding", data_type = "int8_t" },
}

