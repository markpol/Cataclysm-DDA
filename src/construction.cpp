#include "construction.h"

#include "calendar.h"
#include "generic_factory.h"
#include "itype.h"
#include "item.h"
#include "string_formatter.h"
#include "output.h"
#include "skill.h"
#include "game_constants.h"
#include "game.h"
#include "player.h"
#include "skill.h"
#include "translations.h"
#include "messages.h"
#include "inventory.h"
#include "mapdata.h"
#include "map.h"
#include "map_iterator.h"
#include "debug.h"
#include "input.h"
#include "output.h"
#include "coordinate_conversions.h"
#include "json.h"
#include "rng.h"
#include "trap.h"
#include "overmapbuffer.h"
#include "options.h"
#include "npc.h"
#include "iuse.h"
#include "veh_type.h"
#include "vehicle.h"
#include "item_group.h"
#include "cata_utility.h"
#include "uistate.h"
#include "string_input_popup.h"
#include "vpart_position.h"

#include <algorithm>
#include <numeric>
#include <math.h>

construction::construction() : skill_used( skill_id::NULL_ID() ) {}

void construction::load( JsonObject &jo, const std::string &src )
{
    bool strict = src == "dda";

    result_ = jo.get_string( "result" );
    ident_ = construction_id( result_ );

    assign( jo, "time", time, strict, 0 );
    assign( jo, "difficulty", difficulty, strict, 0, MAX_SKILL );

    assign( jo, "skill_used", skill_used, strict );

    if( jo.has_member( "skills_required" ) ) {
        auto sk = jo.get_array( "skills_required" );
        required_skills.clear();

        if( sk.empty() ) {
            // clear all requirements

        } else if( sk.has_array( 0 ) ) {
            // multiple requirements
            while( sk.has_more() ) {
                auto arr = sk.next_array();
                required_skills[skill_id( arr.get_string( 0 ) )] = arr.get_int( 1 );
            }

        } else {
            // single requirement
            required_skills[skill_id( sk.get_string( 0 ) )] = sk.get_int( 1 );
        }
    }

    // constructions not specifying any external requirements inherit from their parent construction (if any)
    if( jo.has_string( "using" ) ) {
        reqs_external = { { requirement_id( jo.get_string( "using" ) ), 1 } };

    } else if( jo.has_array( "using" ) ) {
        auto arr = jo.get_array( "using" );
        reqs_external.clear();

        while( arr.has_more() ) {
            auto cur = arr.next_array();
            reqs_external.emplace_back( requirement_id( cur.get_string( 0 ) ), cur.get_int( 1 ) );
        }
    }

    const std::string type = jo.get_string( "type" );

    result_type = jo.get_enum_value<cosntruction_result>( "result_type" );

    assign( jo, "category", category, strict );
    assign( jo, "subcategory", subcategory, strict );

    // inline requirements are always replaced (cannot be inherited)
    const auto req_id = string_format( "inline_%s_%s", type.c_str(), ident_.c_str() );
    requirement_data::load_requirement( jo, req_id );
    reqs_internal = { { requirement_id( req_id ), 1 } };
}

void construction::finalize()
{
    // concatenate both external and inline requirements
    requirements_.add_requirements( reqs_external );
    requirements_.add_requirements( reqs_internal );

    reqs_external.clear();
    reqs_internal.clear();
}

std::string construction::get_consistency_error() const
{
    switch( result_type ) {
        case cosntruction_result::terrain:
            break;
        case cosntruction_result::furniture:
            break;
        default:
            return "defines invalid result type";
            break;
    }

    const auto is_invalid_skill = []( const std::pair<skill_id, int> &elem ) {
        return !elem.first.is_valid();
    };

    if( ( skill_used && !skill_used.is_valid() ) ||
        std::any_of( required_skills.begin(), required_skills.end(), is_invalid_skill ) ) {
        return "uses invalid skill";
    }

    return std::string();
}

std::string construction::required_skills_string() const
{
    if( required_skills.empty() ) {
        return _( "N/A" );
    }
    return enumerate_as_string( required_skills.begin(), required_skills.end(),
    []( const std::pair<skill_id, int> &skill ) {
        return string_format( "%s (%d)", skill.first.obj().name().c_str(), skill.second );
    } );
}

std::string construction::result_name() const
{
    return item::nname( result_ );
}

void create_construction_result()
{
    player &u = g->u;
    const construction &built = construction_dictionary[u.activity.index];

    const auto award_xp = [&]( player & c ) {
        for( const auto &pr : built.required_skills ) {
            c.practice( pr.first, ( int )( ( 10 + 15 * pr.second ) * ( 1 + built.time / 30000.0 ) ),
                        ( int )( pr.second * 1.25 ) );
        }
    };

    award_xp( g->u );

    // Friendly NPCs gain exp from assisting or watching...
    for( auto &elem : g->u.get_crafting_helpers() ) {
        if( character_has_skill_for( *elem, built ) ) {
            add_msg( m_info, _( "%s assists you with the work..." ), elem->name.c_str() );
        } else {
            //NPC near you isn't skilled enough to help
            add_msg( m_info, _( "%s watches you work..." ), elem->name.c_str() );
        }

        award_xp( *elem );
    }

    for( const auto &it : built.requirement->get_components() ) {
        u.consume_items( it );
    }
    for( const auto &it : built.requirement->get_tools() ) {
        u.consume_tools( it );
    }

    // Make the terrain change
    const tripoint terp = u.activity.placement;
    if( !built.post_terrain.empty() ) {
        if( built.post_is_furniture ) {
            g->m.furn_set( terp, furn_str_id( built.post_terrain ) );
        } else {
            g->m.ter_set( terp, ter_str_id( built.post_terrain ) );
        }
    }

    add_msg( m_info, _( "You finish your construction: %s." ), built.description.c_str() );

    // clear the activity
    u.activity.set_to_null();

    // This comes after clearing the activity, in case the function interrupts
    // activities
    built.post_special( terp );
}

bool character_has_skill_for( const Character &c, const construction &con )
{
    return std::all_of( con.required_skills.begin(), con.required_skills.end(),
    [&]( const std::pair<skill_id, int> &pr ) {
        return c.get_skill_level( pr.first ) >= pr.second;
    } );
}
