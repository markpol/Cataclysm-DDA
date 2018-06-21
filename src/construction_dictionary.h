#pragma once
#ifndef CONSTRUCTION_DICTIONARY_H
#define CONSTRUCTION_DICTIONARY_H

#include "construction.h"
#include "string_id.h"

#include <string>
#include <map>
#include <functional>
#include <set>
#include <vector>
#include <algorithm>

class JsonIn;
class JsonOut;
class JsonObject;
typedef std::string itype_id;
class construction;
using construction_id = string_id<construction>;

class construction_dictionary
{
        friend class Item_factory; // allow removal of blacklisted constructions
        friend construction_id;

    public:
        size_t size() const;
        std::map<construction_id, construction>::const_iterator begin() const;
        std::map<construction_id, construction>::const_iterator end() const;

        static void load_construction( JsonObject &jo, const std::string &src );

        static void finalize();
        static void reset();

    protected:
        /**
         * Remove all constructions matching the predicate
         * @warning must not be called after finalize()
         */
        static void delete_if( const std::function<bool( const construction & )> &pred );

        static construction &load( JsonObject &jo, const std::string &src,
                             std::map<construction_id, construction> &out );

    private:
        std::map<construction_id, construction> constructions;

        static void finalize_internal( std::map<construction_id, construction> &obj );
};

extern construction_dictionary construction_dict;

class construction_subset
{
    public:
        /**
         * Include a construction to the subset.
         * @param r construction to include
         * @param custom_difficulty If specified, it defines custom difficulty for the construction
         */
        void include( const construction *r, int custom_difficulty = -1 );
        void include( const construction_subset &subset );
        /**
         * Include a construction to the subset. Based on the condition.
         * @param subset Where to included the construction
         * @param pred Unary predicate that accepts a @ref construction.
         */
        template<class Predicate>
        void include_if( const construction_subset &subset, Predicate pred ) {
            for( const auto &elem : subset ) {
                if( pred( *elem ) ) {
                    include( elem );
                }
            }
        }

        /** Check if the subset contains a construction with the specified id. */
        bool contains( const construction *r ) const {
            return std::any_of( constructions.begin(), constructions.end(), [r]( const construction * elem ) {
                return elem->ident() == r->ident();
            } );
        }

        /**
         * Get custom difficulty for the construction.
         * @return Either custom difficulty if it was specified, or construction default difficulty.
         */
        int get_custom_difficulty( const construction *r ) const;

        /** Check if there is any constructions in given category (optionally restricted to subcategory) */
        bool empty_category(
            const std::string &cat,
            const std::string &subcat = std::string() ) const;

        /** Get all constructions in given category (optionally restricted to subcategory) */
        std::vector<const construction *> in_category(
            const std::string &cat,
            const std::string &subcat = std::string() ) const;

        /** Returns all constructions which could use component */
        const std::set<const construction *> &of_component( const itype_id &id ) const;

        enum class search_type {
            name,
            skill,
            component,
            tool,
            quality,
            quality_result
        };

        /** Find constructions matching query (left anchored partial matches are supported) */
        std::vector<const construction *> search( const std::string &txt,
                                            const search_type key = search_type::name ) const;

        size_t size() const {
            return constructions.size();
        }

        void clear() {
            component.clear();
            category.clear();
            constructions.clear();
        }

        std::set<const construction *>::const_iterator begin() const {
            return constructions.begin();
        }

        std::set<const construction *>::const_iterator end() const {
            return constructions.end();
        }

    private:
        std::set<const construction *> constructions;
        std::map<const construction *, int> difficulties;
        std::map<std::string, std::set<const construction *>> category;
        std::map<itype_id, std::set<const construction *>> component;
};

void serialize( const construction_subset &value, JsonOut &jsout );
void deserialize( construction_subset &value, JsonIn &jsin );

#endif
