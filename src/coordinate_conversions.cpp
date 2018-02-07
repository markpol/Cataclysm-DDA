#include "coordinate_conversions.h"

static int divide( int v, int m )
{
    if( v >= 0 ) {
        return v / m;
    }
    return ( v - m + 1 ) / m;
}

static int divide( int v, int m, int &r )
{
    const int result = divide( v, m );
    r = v - result * m;
    return result;
}

point omt_to_om_copy( int x, int y )
{
    return point( divide( x, OMAPX ), divide( y, OMAPY ) );
}

tripoint omt_to_om_copy( const tripoint &p )
{
    return tripoint( divide( p.x, OMAPX ), divide( p.y, OMAPY ), p.z );
}

void omt_to_om( int &x, int &y )
{
    x = divide( x, OMAPX );
    y = divide( y, OMAPY );
}

point omt_to_om_remain( int &x, int &y )
{
    return point( divide( x, OMAPX, x ), divide( y, OMAPY, y ) );
}


point sm_to_omt_copy( int x, int y )
{
    return point( divide( x, SM_IN_OMT ), divide( y, SM_IN_OMT ) );
}

tripoint sm_to_omt_copy( const tripoint &p )
{
    return tripoint( divide( p.x, SM_IN_OMT ), divide( p.y, SM_IN_OMT ), p.z );
}

void sm_to_omt( int &x, int &y )
{
    x = divide( x, SM_IN_OMT );
    y = divide( y, SM_IN_OMT );
}

point sm_to_omt_remain( int &x, int &y )
{
    return point( divide( x, SM_IN_OMT, x ), divide( y, SM_IN_OMT, y ) );
}


point sm_to_om_copy( int x, int y )
{
    return point( divide( x, SM_IN_OMT * OMAPX ), divide( y, SM_IN_OMT * OMAPY ) );
}

tripoint sm_to_om_copy( const tripoint &p )
{
    return tripoint( divide( p.x, SM_IN_OMT * OMAPX ), divide( p.y, SM_IN_OMT * OMAPY ), p.z );
}

void sm_to_om( int &x, int &y )
{
    x = divide( x, SM_IN_OMT * OMAPX );
    y = divide( y, SM_IN_OMT * OMAPY );
}

point sm_to_om_remain( int &x, int &y )
{
    return point( divide( x, SM_IN_OMT * OMAPX, x ), divide( y, SM_IN_OMT * OMAPY, y ) );
}


point omt_to_sm_copy( int x, int y )
{
    return point( x * SM_IN_OMT, y * SM_IN_OMT );
}

tripoint omt_to_sm_copy( const tripoint &p )
{
    return tripoint( p.x * SM_IN_OMT, p.y * SM_IN_OMT, p.z );
}

void omt_to_sm( int &x, int &y )
{
    x *= SM_IN_OMT;
    y *= SM_IN_OMT;
}


point om_to_sm_copy( int x, int y )
{
    return point( x * SM_IN_OMT * OMAPX, y * SM_IN_OMT * OMAPX );
}

tripoint om_to_sm_copy( const tripoint &p )
{
    return tripoint( p.x * SM_IN_OMT * OMAPX, p.y * SM_IN_OMT * OMAPX, p.z );
}

void om_to_sm( int &x, int &y )
{
    x *= SM_IN_OMT * OMAPX;
    y *= SM_IN_OMT * OMAPY;
}


point ms_to_sm_copy( int x, int y )
{
    return point( divide( x, SEEX ), divide( y, SEEY ) );
}

tripoint ms_to_sm_copy( const tripoint &p )
{
    return tripoint( divide( p.x, SEEX ), divide( p.y, SEEY ), p.z );
}

void ms_to_sm( int &x, int &y )
{
    x = divide( x, SEEX );
    y = divide( y, SEEY );
}

point ms_to_sm_remain( int &x, int &y )
{
    return point( divide( x, SEEX, x ), divide( y, SEEY, y ) );
}


point sm_to_ms_copy( int x, int y )
{
    return point( x * SEEX, y * SEEY );
}

tripoint sm_to_ms_copy( const tripoint &p )
{
    return tripoint( p.x * SEEX, p.y * SEEY, p.z );
}

void sm_to_ms( int &x, int &y )
{
    x *= SEEX;
    y *= SEEY;
}


point ms_to_omt_copy( int x, int y )
{
    return point( divide( x, SEEX * SM_IN_OMT ), divide( y, SEEY * SM_IN_OMT ) );
}

tripoint ms_to_omt_copy( const tripoint &p )
{
    return tripoint( divide( p.x, SEEX * SM_IN_OMT ), divide( p.y, SEEY * SM_IN_OMT ), p.z );
}

void ms_to_omt( int &x, int &y )
{
    x = divide( x, SEEX * SM_IN_OMT );
    y = divide( y, SEEY * SM_IN_OMT );
}

point ms_to_omt_remain( int &x, int &y )
{
    return point( divide( x, SEEX * SM_IN_OMT, x ), divide( y, SEEY * SM_IN_OMT, y ) );
}


tripoint omt_to_seg_copy( const tripoint &p )
{
    return tripoint( divide( p.x, OMT_IN_SEG ), divide( p.y, OMT_IN_SEG ), p.z );
}
