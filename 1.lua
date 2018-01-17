function print_info (p, f)

local x = tostring(math.floor(p.x))
local y = tostring(math.floor(p.y))
local z = tostring(math.floor(p.z))

print (f.." = "..x..","..y..","..z)

end

print ("-= Start info =-")

local p1 = player:pos()
local p2 = player:global_omt_location()
local p3 = player:global_sm_location()
local p4 = player:global_square_location()
local p5 = map:get_abs_sub()
local p6 = map:getabs(p1)

print_info(p1, "                   player:pos")
print_info(p2, "   player:global_omt_location")
print_info(p3, "    player:global_sm_location")
print_info(p4, "player:global_square_location")
print_info(p5, "              map:get_abs_sub")
print_info(p6, "                 map:getabs()")

print ("-= End info =-")
