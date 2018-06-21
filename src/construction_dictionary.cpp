#include "construction_dictionary.h"

#include "itype.h"
#include "generic_factory.h"
#include "item_factory.h"
#include "item.h"
#include "init.h"
#include "cata_utility.h"
#include "crafting.h"
#include "skill.h"

#include <algorithm>
#include <numeric>

construction_dictionary construction_dict;

namespace
{

void delete_if( std::map<construction_id, construction> &data,
                const std::function<bool( const construction & )> &pred )
{
    for( auto it = data.begin(); it != data.end(); ) {
        if( pred( it->second ) ) {
            it = data.erase( it );
        } else {
            ++it;
        }
    }
}

}

static construction null_construction;
static std::set<const construction *> null_match;

static DynamicDataLoader::deferred_json deferred;

template<>
const construction &string_id<construction>::obj() const
{
    const auto iter = construction_dict.constructions.find( *this );
    if( iter != construction_dict.constructions.end() ) {
        return iter->second;
    }
    if( *this != NULL_ID() ) {
        debugmsg( "invalid construction id \"%s\"", c_str() );
    }
    return null_construction;
}

template<>
bool string_id<construction>::is_valid() const
{
    return construction_dict.constructions.find( *this ) != construction_dict.constructions.end();
}

// searches for left-anchored partial match in the relevant construction requirements set
template <class group>
bool search_reqs( group gp, const std::string &txt )
{
    return std::any_of( gp.begin(), gp.end(), [&]( const typename group::value_type & opts ) {
        return std::any_of( opts.begin(),
        opts.end(), [&]( const typename group::value_type::value_type & e ) {
            return lcmatch( e.to_string(), txt );
        } );
    } );
}
// template specialization to make component searches easier
template<>
bool search_reqs( std::vector<std::vector<item_comp> >  gp,
                  const std::string &txt )
{
    return std::any_of( gp.begin(), gp.end(), [&]( const std::vector<item_comp> &opts ) {
        return std::any_of( opts.begin(), opts.end(), [&]( const item_comp & ic ) {
            return lcmatch( item::nname( ic.type ), txt );
        } );
    } );
}

std::vector<const construction *> construction_subset::search( const std::string &txt,
        const search_type key ) const
{
    std::vector<const construction *> res;

    std::copy_if( constructions.begin(), constructions.end(), std::back_inserter( res ), [&]( const construction * r ) {
        switch( key ) {
            case search_type::name:
                return lcmatch( r->result_name(), txt );

            case search_type::skill:
                return lcmatch( r->required_skills_string(), txt ) || lcmatch( r->skill_used->name(), txt );

            case search_type::component:
                return search_reqs( r->requirements().get_components(), txt );

            case search_type::tool:
                return search_reqs( r->requirements().get_tools(), txt );

            case search_type::quality:
                return search_reqs( r->requirements().get_qualities(), txt );

            case search_type::quality_result: {
                const auto &quals = item::find_type( r->result() )->qualities;
                return std::any_of( quals.begin(), quals.end(), [&]( const std::pair<quality_id, int> &e ) {
                    return lcmatch( e.first->name, txt );
                } );
            }

            default:
                return false;
        }
    } );

    return res;
}

bool construction_subset::empty_category( const std::string &cat,
                                    const std::string &subcat ) const
{
    auto iter = category.find( cat );
    if( iter != category.end() ) {
        if( subcat.empty() ) {
            return false;
        } else {
            for( auto &e : iter->second ) {
                if( e->subcategory == subcat ) {
                    return false;
                }
            }
        }
    }
    return true;
}

std::vector<const construction *> construction_subset::in_category( const std::string &cat,
        const std::string &subcat ) const
{
    std::vector<const construction *> res;
    auto iter = category.find( cat );
    if( iter != category.end() ) {
        if( subcat.empty() ) {
            res.insert( res.begin(), iter->second.begin(), iter->second.end() );
        } else {
            std::copy_if( iter->second.begin(), iter->second.end(),
            std::back_inserter( res ), [&subcat]( const construction * e ) {
                return e->subcategory == subcat;
            } );
        }
    }
    return res;
}

const std::set<const construction *> &construction_subset::of_component( const itype_id &id ) const
{
    auto iter = component.find( id );
    return iter != component.end() ? iter->second : null_match;
}

void construction_dictionary::load_construction( JsonObject &jo, const std::string &src )
{
    load( jo, src, construction_dict.constructions );
}

construction &construction_dictionary::load( JsonObject &jo, const std::string &src,
                                 std::map<construction_id, construction> &dest )
{
    construction r;

    // defer entries dependent upon as-yet unparsed definitions
    if( jo.has_string( "copy-from" ) ) {
        auto base = construction_id( jo.get_string( "copy-from" ) );
        if( !dest.count( base ) ) {
            deferred.emplace_back( jo.str(), src );
            return null_construction;
        }
        r = dest[ base ];
    }

    r.load( jo, src );

    dest[ r.ident() ] = std::move( r );

    return dest[ r.ident() ];
}

size_t construction_dictionary::size() const
{
    return constructions.size();
}

std::map<construction_id, construction>::const_iterator construction_dictionary::begin() const
{
    return constructions.begin();
}

std::map<construction_id, construction>::const_iterator construction_dictionary::end() const
{
    return constructions.end();
}

void construction_dictionary::finalize_internal( std::map<construction_id, construction> &obj )
{
    for( auto &elem : obj ) {
        elem.second.finalize();
    }
    // remove any blacklisted or invalid constructions...
    delete_if( []( const construction & elem ) {
        if( elem.is_blacklisted() ) {
            return true;
        }

        const std::string error = elem.get_consistency_error();

        if( !error.empty() ) {
            debugmsg( "construction %s %s.", elem.ident().c_str(), error.c_str() );
        }

        return !error.empty();
    } );
}

void construction_dictionary::finalize()
{
    DynamicDataLoader::get_instance().load_deferred( deferred );

    finalize_internal( construction_dict.constructions );

}

void construction_dictionary::reset()
{
    construction_dict.constructions.clear();
}

void construction_dictionary::delete_if( const std::function<bool( const construction & )> &pred )
{
    ::delete_if( construction_dict.constructions, pred );
}

void construction_subset::include( const construction *r, int custom_difficulty )
{
    if( custom_difficulty < 0 ) {
        custom_difficulty = r->difficulty;
    }
    // We always prefer lower difficulty for the subset, but we save it only if it's not default
    if( constructions.count( r ) > 0 ) {
        const auto iter = difficulties.find( r );
        // See if we need to lower the difficulty of the existing construction
        if( iter != difficulties.end() && custom_difficulty < iter->second ) {
            if( custom_difficulty != r->difficulty ) {
                iter->second = custom_difficulty; // Added again with lower difficulty
            } else {
                difficulties.erase( iter ); // No need to keep the default difficulty. Free some memory
            }
        } else if( custom_difficulty < r->difficulty ) {
            difficulties[r] = custom_difficulty; // Added again with lower difficulty
        }
    } else {
        // add construction to category and component caches
        for( const auto &opts : r->requirements().get_components() ) {
            for( const item_comp &comp : opts ) {
                component[comp.type].insert( r );
            }
        }
        category[r->category].insert( r );
        // Set the difficulty is it's not the default
        if( custom_difficulty != r->difficulty ) {
            difficulties[r] = custom_difficulty;
        }
        // insert the construction
        constructions.insert( r );
    }
}

void construction_subset::include( const construction_subset &subset )
{
    for( const auto &elem : subset ) {
        include( elem, subset.get_custom_difficulty( elem ) );
    }
}

int construction_subset::get_custom_difficulty( const construction *r ) const
{
    const auto iter = difficulties.find( r );
    if( iter != difficulties.end() ) {
        return iter->second;
    }
    return r->difficulty;
}
