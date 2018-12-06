#include "accessibility.h"

#include "options.h"
#include "string_formatter.h"

namespace accessibility
{
void espeak( const std::string &text )
{
#if( !defined MSYS2 && ( defined _WIN32 || defined WINDOWS ) )
    if( get_option<bool>( "USE_ESPEAKNG" ) ) {

        const std::string espeak_cmd = string_format( "%s -v%s \"%s\"",
                                       get_option<std::string>( "ESPEAKNG_PATH" ),
                                       get_option<std::string>( "ESPEAKNG_LANG" ),
                                       text );
        LPSTR cmd = TEXT( _strdup( espeak_cmd.c_str() ) );
        DWORD creationflags = CREATE_NO_WINDOW;
        STARTUPINFO info = { sizeof( info ) };
        PROCESS_INFORMATION processInfo;
        if( CreateProcess( NULL, cmd, NULL, NULL, TRUE, creationflags, NULL, NULL, &info, &processInfo ) ) {
            WaitForSingleObject( processInfo.hProcess, INFINITE );
            CloseHandle( processInfo.hProcess );
            CloseHandle( processInfo.hThread );
        }
    }
#else
    ( void )text;
#endif
}
}
