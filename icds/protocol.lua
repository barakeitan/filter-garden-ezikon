--header
header_record = {
  { name = "protocol_version", data_type = "uint8_t", valid_value = {min = 0, max = 5} },
  { name = "exercise_id", data_type = "uint8_t", valid_value = {min = 0} },
  { name = "pdu_type", data_type = "uint8_t", type_id = true, valid_value = {enum = {0, 1, 10, 11, 12, 129, 13, 130, 131, 132, 133, 134, 135, 14, 140, 141, 142, 143, 144, 15, 150, 151, 152, 153, 155, 156, 157, 16, 160, 161, 17, 170, 18, 19, 2, 20, 21, 22, 23, 24, 25, 26, 27, 3, 4, 5, 6, 7, 8, 9}} },
  { name = "protocol_family", data_type = "uint8_t", valid_value = {enum = {0, 1, 129, 130, 131, 132, 133, 2, 3, 4, 5, 6}} },
  { name = "timestamp", data_type = "uint32_t", valid_value = {min = 0} },
  { name = "pdu_length", data_type = "uint16_t", valid_value = {min = 0} },
  { name = "padding", data_type = "padding", bit_count = 8 }
}

--bitarrays
local entity_appearance_general = {
  { name = "entity_paint_scheme", bit_count = 1 },
  { name = "entity_mobility_kill", bit_count = 1 },
  { name = "entity_fire_power", bit_count = 1 },
  { name = "entity_damage", bit_count = 2 },
  { name = "entity_smoke", bit_count = 2 },
  { name = "entity_trailing_effect", bit_count = 2 },
  { name = "entity_hatch_state", bit_count = 3 },
  { name = "entity_lights", bit_count = 3 },
  { name = "entity_flaming_effect", bit_count = 1 }
}

local land_platforms = {
  { name = "launcher", bit_count = 1 },
  { name = "camouflage_type", bit_count = 2 },
  { name = "concealed", bit_count = 1 },
  { name = "unused", bit_count = 1 },
  { name = "frozen_status", bit_count = 1 },
  { name = "power_plant_status", bit_count = 1 },
  { name = "state", bit_count = 1 },
  { name = "tent", bit_count = 1 },
  { name = "ramp", bit_count = 1 },
  { name = "entity_specific", bit_count = 6 }
}

local air_platforms = {
  { name = "afterburner", bit_count = 1 },
  { name = "unused", bit_count = 4 },
  { name = "frozen_status", bit_count = 1 },
  { name = "power_plant_status", bit_count = 1 },
  { name = "state", bit_count = 1 },
  { name = "entity_specific", bit_count = 8 }
}

local generic_platforms = {
  { name = "unused", bit_count = 5 },
  { name = "frozen_status", bit_count = 1 },
  { name = "power_plant_status", bit_count = 1 },
  { name = "state", bit_count = 1 },
  { name = "entity_specific", bit_count = 8 }
}

local guided_munitions = {
  { name = "launch_flash", bit_count = 1 },
  { name = "unused_1", bit_count = 4 },
  { name = "frozen_status", bit_count = 1 },
  { name = "unused_2", bit_count = 1 },
  { name = "state", bit_count = 1 },
  { name = "entity_specific", bit_count = 8 }
}

local life_form = {
  { name = "lifeform_state", bit_count = 4 },
  { name = "unused_1", bit_count = 1 },
  { name = "frozen_status", bit_count = 1 },
  { name = "unused_2", bit_count = 1 },
  { name = "activity_state", bit_count = 1 },
  { name = "weapon_1", bit_count = 2 },
  { name = "weapon_2", bit_count = 2 },
  { name = "entity_specific", bit_count = 4 }
}

local environmental = {
  { name = "density", bit_count = 4 },
  { name = "unused", bit_count = 4 },
  { name = "environment_specific", bit_count = 8 }
}


--structs
local simulation_address = {
  { name = "site_id", data_type = "uint16_t", valid_value = {min = 0} },
  { name = "app_id", data_type = "uint16_t", valid_value = {min = 0} }
}

local origin_id = {
  { name = "sim", data_type = "simulation_address_t"},
  { name = "entity_id", data_type = "uint16_t", valid_value = {min = 0} },
  { name = "ok", data_type = "uint8_t", valid_value = {const = 5} }
}

local receiving_id = {
  { name = "simulation_address", data_type = "simulation_address_t"},
  { name = "entity_id", data_type = "uint16_t", valid_value = {min = 0} }
}

local fixed_datum = {
  { name = "FD_ID", data_type = "uint32_t", valid_value = {min = 10000} },
  { name = "FD_value", data_type = "uint32_t" },
}

local variable_datum = {
  { name = "VD_ID", data_type = "uint32_t", valid_value = {min = 10000} },
  { name = "VD_length", data_type = "uint32_t", valid_value = {min = 0} },
  { name = "VD_value", data_type = "uint64_t" }
}

local entity_id = {
  { name = "simulation_address", data_type = "simulation_address_t" },
  { name = "entity_id", data_type = "uint16_t", valid_value = {min = 0} },
}

local event_id = {
  { name = "simulation_address", data_type = "simulation_address_t" },
  { name = "event_id", data_type = "uint16_t", valid_value = {min = 0} },
}

local linear_velocity_vector = {
  { name = "vector1", data_type = "float" },
  { name = "vector2", data_type = "float" },
  { name = "vector3", data_type = "float" }
}

local entity_coordinate = {
  { name = "x", data_type = "uint32_t" },
  { name = "y", data_type = "uint32_t" },
  { name = "z", data_type = "uint32_t" }
}

local world_coordinate = {
  { name = "x", data_type = "double" },
  { name = "y", data_type = "double" },
  { name = "z", data_type = "double" }
}

local entity_type = {
  { name = "kind", data_type = "uint8_t", valid_value = {min = 0, max = 9} },
  { name = "domain", data_type = "uint8_t" },
  { name = "country", data_type = "uint16_t", valid_value = {min = 0, max = 266} },
  { name = "category", data_type = "uint8_t" },
  { name = "subcategory", data_type = "uint8_t" },
  { name = "specific", data_type = "uint8_t" },
  { name = "extra", data_type = "uint8_t" }
}

local euler_angles  = {
  { name = "PSI", data_type = "float" },
  { name = "THETA", data_type = "float" },
  { name = "PHI", data_type = "float" }
}

local specific_appearance = {
  { name = "land_platforms", data_type = "land_platforms_bit_array" },
  { name = "air_platforms", data_type = "air_platforms_bit_array" },
  { name = "surface_platforms", data_type = "generic_platforms_bit_array" },
  { name = "subsurface_platforms", data_type = "generic_platforms_bit_array" },
  { name = "space_platforms", data_type = "generic_platforms_bit_array" },
  { name = "guided_munitions", data_type = "guided_munitions_bit_array" },
  { name = "life_form", data_type = "life_form_bit_array" },
  { name = "environmental", data_type = "environmental_bit_array" },
}

local entity_appearance = {
  { name = "general_appearance", data_type = "entity_appearance_general_bit_array" },
  { name = "specific_appearance", data_type = "specific_appearance_t" }
}

local entity_linear_acceleration = {
  { name = "vector1", data_type = "entity_coordinate_t"},
  { name = "vector2", data_type = "entity_coordinate_t"},
  { name = "vector3", data_type = "entity_coordinate_t"},
}

local dead_reckoning_parameters = {
  { name = "dead_reckoning_algorithm", data_type="uint8_t", valid_value = {min = 0, max = 9} },
  { name = "padd", data_type="padding", bit_count = 122 },
  { name = "entity_coordinate", data_type="uint8_t", valid_value = {min = 0, max = 9} }
}

local entity_marking = {
  
}

local entity_capabilities = {
  
}

local articulation_parameter = {
  
}


--messages
local acknowledge_msg = {
  name = "acknowledge_msg",
  fields = { 
    { name = "origin_id", data_type="origin_id_t" },
    { name = "receiving_id", data_type="receiving_id_t" },
    { name = "acknowledge", data_type="uint16_t", valid_value = {min = 1, max = 4} },
    { name = "response", data_type="uint16_t", valid_value = {min = 0, max = 2} },
    { name = "request_id", data_type="uint32_t", valid_value = {min = 0} }
  }
}

local action_request_msg = {
  name = "action_request_msg",
  fields = { 
    { name = "origin_id", data_type="origin_id_t" },
    { name = "receiving_id", data_type="receiving_id_t" },
    { name = "request_id", data_type="uint32_t", valid_value = {min = 0} },
    { name = "action_id", data_type="uint32_t", valid_value = {min = 0, max = 36} },
    { name = "FD_num", data_type="uint32_t", valid_value = {min = 0} },
    { name = "VD_num", data_type="uint32_t", valid_value = {min = 0} },
    { name = "FD", data_type="fixed_datum_t" },
    { name = "VD", data_type="variable_datum_t" }
  }
}

local action_response_msg = {
  name = "action_response_msg",
  fields = { 
    { name = "origin_id", data_type="origin_id_t" },
    { name = "receiving_id", data_type="receiving_id_t" },
    { name = "request_id", data_type="uint32_t", valid_value = {min = 0} },
    { name = "request_status", data_type="uint32_t", valid_value = {min = 0, max = 5} },
    { name = "FD_num", data_type="uint32_t", valid_value = {min = 0} },
    { name = "VD_num", data_type="uint32_t", valid_value = {min = 0} },
    { name = "FD", data_type="fixed_datum_t" },
    { name = "VD", data_type="variable_datum_t" }
  }
}

local collision_msg = {
  name = "collision_msg",
  fields = { 
    { name = "issuing_id", data_type="entity_id_t" },
    { name = "colliding_id", data_type="entity_id_t" },
    { name = "event_id", data_type="event_id_t" },
    { name = "colliding_type", data_type="uint8_t", valid_value = {min = 0, max = 2} },
    { name = "padding", data_type="uint8_t" },
    { name = "linear_velocity_vector", data_type="linear_velocity_vector_t" },
    { name = "mass", data_type="uint32_t" },
    { name = "entity_coordinate", data_type="entity_coordinate_t" }
  }
}

local comment_msg = {
  name = "comment_msg",
  fields = { 
    { name = "origin_id", data_type="origin_id_t" },
    { name = "receiving_id", data_type="receiving_id_t" },
    { name = "FD_num", data_type="uint32_t", valid_value = {min = 0} },
    { name = "VD_num", data_type="uint32_t", valid_value = {min = 0} },
    { name = "VD", data_type="variable_datum_t" }
  }
}

local create_entity_msg = {
  name = "create_entity_msg",
  fields = { 
    { name = "origin_id", data_type="origin_id_t" },
    { name = "receiving_id", data_type="receiving_id_t" },
    { name = "request_id", data_type="uint32_t", valid_value = {min = 0} }
  }
}

local data_msg = {
  name = "data_msg",
  fields = { 
    { name = "origin_id", data_type="origin_id_t" },
    { name = "receiving_id", data_type="receiving_id_t" },
    { name = "request_id", data_type="uint32_t", valid_value = {min = 0} },
    { name = "padding", data_type = "uint32_t" },
    { name = "FD_num", data_type="uint32_t", valid_value = {min = 0} },
    { name = "VD_num", data_type="uint32_t", valid_value = {min = 0} },
    { name = "FD", data_type="fixed_datum_t" },
    { name = "VD", data_type="variable_datum_t" }
  }
}
local data_query_msg = {
  name = "data_query_msg",
  fields = { 
    { name = "origin_id", data_type="origin_id_t" },
    { name = "receiving_id", data_type="receiving_id_t" },
    { name = "request_id", data_type="uint32_t", valid_value = {min = 0} },
    { name = "time_interval", data_type = "uint32_t" },
    { name = "FD_num", data_type="uint32_t", valid_value = {min = 0} },
    { name = "VD_num", data_type="uint32_t", valid_value = {min = 0} },
    { name = "FD", data_type="fixed_datum_t" },
    { name = "VD", data_type="variable_datum_t" }
  }
}

local designator_msg = {
  name = "designator_msg",
  fields = { 
    { name = "designating_id", data_type="entity_id_t" },
    { name = "code_name", data_type="uint16_t", valid_value = {min = 0, max = 1} },
    { name = "designated_id", data_type="entity_id_t" },
    { name = "designator_code", data_type = "uint16_t", valid_value = {min = 0, max = 1} },
    { name = "designator_power", data_type="uint32_t" },
    { name = "designator_wavelength", data_type="uint32_t" },
    { name = "designator_spot_r", data_type="entity_coordinate_t" },
    { name = "designator_spot_entity_coordinate", data_type="world_coordinate_t" },
    { name = "dead_reckoning_algorithm", data_type="uint8_t", valid_value = {min = 0, max = 9} },
    { name = "padding", data_type="uint32_t" },
    { name = "entity_linear_acceleration", data_type="linear_velocity_vector_t" },
  }
}

local entity_state_msg = {
  name = "entity_state_msg",
  fields = {
    { name = "entity_id", data_type="entity_id_t" },
    { name = "force_id", data_type="uint8_t", valid_value = {min = 0, max = 3} },
    { name = "number_of_articulation_parameters", data_type="uint8_t", valid_value = {min = 0} },
    { name = "entity_type", data_type="entity_type_t" },
    { name = "alternative_entity_type", data_type="entity_type_t" },
    { name = "entity_linear_velocity_vector", data_type = "linear_velocity_vector_t" },
    { name = "entity_location", data_type="world_coordinate_t" },
    { name = "entity_orientation", data_type="euler_angles_t" },
    { name = "entity_appearance", data_type="entity_appearance_t" },
    { name = "dead_reckoning_parameters", data_type="dead_reckoning_parameters_t" },
    { name = "entity_marking", data_type="entity_appearance_t" },
    { name = "entity_capabilities", data_type="entity_appearance_t" },
    { name = "articulation_parameter", data_type="entity_appearance_t" }
  }
}

--structs table
structs = {
  ["simulation_address_t"] = simulation_address,
  ["origin_id_t"] = origin_id,
  ["receiving_id_t"] = receiving_id,
  ["fixed_datum_t"] = fixed_datum,
  ["variable_datum_t"] = variable_datum,
  ["entity_id_t"] = entity_id,
  ["event_id_t"] = event_id,
  ["linear_velocity_vector_t"] = linear_velocity_vector,
  ["entity_coordinate_t"] = entity_coordinate,
  ["world_coordinate_t"] = world_coordinate,
  ["entity_type_t"] = entity_type,
  ["euler_angles_t"] = euler_angles,
  ["specific_appearance_t"] = specific_appearance,
  ["entity_appearance_t"] = entity_appearance,
  ["dead_reckoning_parameters_t"] = dead_reckoning_parameters,
  ["entity_marking_t"] = entity_marking,
  ["entity_capabilities_t"] = entity_capabilities,
  ["articulation_parameter_t"] = articulation_parameter,
  ["entity_linear_acceleration_t"] = entity_linear_acceleration
}

--bitarrays table
bitarrays = {
  ["entity_appearance_general_bit_array"] = entity_appearance_general,
  ["land_platforms_bit_array"] = land_platforms,
  ["air_platforms_bit_array"] = air_platforms,
  ["generic_platforms_bit_array"] = generic_platforms,
  ["guided_munitions_bit_array"] = guided_munitions,
  ["life_form_bit_array"] = life_form,
  ["environmental_bit_array"] = environmental
}

--messages table
messages = {
  [15] = acknowledge_msg,
  [16] = action_request_msg,
  [17] = action_response_msg,
  [4] = collision_msg,
  [22] = comment_msg,
  [11] = create_entity_msg,
  [20] = data_msg,
  [18] = data_query_msg,
  [24] = designator_msg,
  [1] = entity_state_msg
}