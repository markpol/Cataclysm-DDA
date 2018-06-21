#pragma once
#ifndef CONSTRUCTION_H
#define CONSTRUCTION_H

#include "string_id.h"
#include "requirements.h"
#include "generic_factory.h"

#include <string>
#include <set>
#include <map>
#include <vector>
#include <functional>

namespace catacurses
{
class window;
} // namespace catacurses
class JsonObject;
class nc_color;
class Skill;
struct tripoint;

using skill_id = string_id<Skill>;

class construction;
using construction_id = string_id<construction>;

enum class construction_result : int
{
    terrain,
    furniture
};

namespace io
{

    static const std::map<std::string, construction_result> construction_result_map = {{
            { "terrain", construction_result::terrain },
            { "furniture", construction_result::furniture },
        }
    };

    template<>
    construction_result string_to_enum<construction_result>( const std::string &data )
    {
        return string_to_enum_look_up( construction_result_map, data );
    }

}

class construction
{
        friend class construction_dictionary;

    private:
        std::string result_ = "null";

    public:
        construction();

        operator bool() const {
            return result_ != "null";
        }

        const std::string &result() const {
            return result_;
        }

        construction_result result_type;
        std::string category;
        std::string subcategory;

        int time = 0; // in movement points (100 per turn)
        int difficulty = 0;

        /** Fetch combined requirement data (inline and via "using" syntax) */
        const requirement_data &requirements() const {
            return requirements_;
        }

        const construction_id &ident() const {
            return ident_;
        }

        bool is_blacklisted() const {
            return requirements_.is_blacklisted();
        }

        /// @returns The name (@ref item::nname) of the resulting item (@ref result).
        std::string result_name() const;

        std::map<itype_id, int> byproducts;

        skill_id skill_used;
        std::map<skill_id, int> required_skills;

        //Create a string list to describe the skill requirements for this construction
        // Format: skill_name(amount), skill_name(amount)
        std::string required_skills_string() const;

        void load( JsonObject &jo, const std::string &src );
        void finalize();

        /** Returns a non-empty string describing an inconsistency (if any) in the construction. */
        std::string get_consistency_error() const;

    private:
        construction_id ident_ = construction_id::NULL_ID();

        /** External requirements (via "using" syntax) where second field is multiplier */
        std::vector<std::pair<requirement_id, int>> reqs_external;

        /** Requires specified inline with the construction (and replaced upon inheritance) */
        std::vector<std::pair<requirement_id, int>> reqs_internal;

        /** Combined requirements cached when construction finalized */
        requirement_data requirements_;

 };

 void create_construction_result();

#endif
