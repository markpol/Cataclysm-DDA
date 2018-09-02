function echo( s )

  s = tostring( s )
  print( s )
  if( game.add_msg ) then
    game.add_msg( s )
  end
 
end

function echo_tripoint( p, function_name )

  local x = tostring( math.floor( p.x ) )
  local y = tostring( math.floor( p.y ) )
  local z = tostring( math.floor( p.z ) )

  local formatted_string = function_name.." = "..x..","..y..","..z
  echo( formatted_string )

end

echo( "-= Start info =-" )

local p1 = player:pos()
local p2 = player:global_omt_location()
local p3 = player:global_sm_location()
local p4 = player:global_square_location()
local p5 = map:get_abs_sub()
local p6 = map:getabs(p1)

echo_tripoint( p1, "                   player:pos" )
echo_tripoint( p2, "   player:global_omt_location" )
echo_tripoint( p3, "    player:global_sm_location" )
echo_tripoint( p4, "player:global_square_location" )
echo_tripoint( p5, "              map:get_abs_sub" )
echo_tripoint( p6, "                 map:getabs()" )

echo( "-= End info =-" )
