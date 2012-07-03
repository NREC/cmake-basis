##############################################################################
# @file  FindJython.cmake
# @brief Find Jython interpreter.
#
# @par Output variables:
# <table border="0">
#   <tr>
#     @tp @b Jython_FOUND @endtp
#     <td>Whether the Jython executable was found.</td>
#   </tr>
#   <tr>
#     @tp @b Jython_EXECUTABLE @endtp
#     <td>Path to the Jython interpreter.</td>
#   </tr>
#   <tr>
#     @tp @b Jython_VERSION_STRING @endtp
#     <td>Jython version found, e.g. 2.5.2.</td>
#   </tr>
#   <tr>
#     @tp @b Jython_VERSION_MAJOR @endtp
#     <td>Jython major version found, e.g. 2.</td>
#   </tr>
#   <tr>
#     @tp @b Jython_VERSION_MINOR @endtp
#     <td>Jython minor version found, e.g. 5.</td>
#   </tr>
#   <tr>
#     @tp @b Jython_VERSION_PATCH @endtp
#     <td>Jython patch version found, e.g. 2.</td>
#   </tr>
# </table>
#
# @ingroup CMakeFindModules
##############################################################################

# find jython executable
find_program (Jython_EXECUTABLE NAMES jython)

# determine jython version string
if (Jython_EXECUTABLE)
  execute_process (COMMAND "${Jython_EXECUTABLE}" -c "import sys; sys.stdout.write(';'.join([str(x) for x in sys.version_info[:3]]))"
                   OUTPUT_VARIABLE _JYTHON_VERSION
                   RESULT_VARIABLE _JYTHON_VERSION_RESULT
                   ERROR_QUIET)
  if (_JYTHON_VERSION_RESULT EQUAL 0)
    string (REPLACE ";" "." JYTHON_VERSION_STRING "${_JYTHON_VERSION}")
    list (GET _VERSION 0 JYTHON_VERSION_MAJOR)
    list (GET _VERSION 1 JYTHON_VERSION_MINOR)
    list (GET _VERSION 2 JYTHON_VERSION_PATCH)
    if (JYTHON_VERSION_PATCH EQUAL 0)
      # it's called "Jython 2.5", not "2.5.0"
      string (REGEX REPLACE "\\.0$" "" JYTHON_VERSION_STRING "${JYTHON_VERSION_STRING}")
    endif()
  else ()
    # sys.version predates sys.version_info, so use that
    execute_process(COMMAND "${JYTHON_EXECUTABLE}" -c "import sys; sys.stdout.write(sys.version)"
                    OUTPUT_VARIABLE _JYTHON_VERSION
                    RESULT_VARIABLE _JYTHON_VERSION_RESULT
                    ERROR_QUIET)
    if (_JYTHON_VERSION_RESULT EQUAL 0)
      string (REGEX REPLACE " .*" "" JYTHON_VERSION_STRING "${_JYTHON_VERSION}")
      string (REGEX REPLACE "^([0-9]+)\\.[0-9]+.*" "\\1" JYTHON_VERSION_MAJOR "${JYTHON_VERSION_STRING}")
      string (REGEX REPLACE "^[0-9]+\\.([0-9])+.*" "\\1" JYTHON_VERSION_MINOR "${JYTHON_VERSION_STRING}")
      if (JYTHON_VERSION_STRING MATCHES "^[0-9]+\\.[0-9]+\\.[0-9]+.*")
          string (REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" JYTHON_VERSION_PATCH "${JYTHON_VERSION_STRING}")
      else ()
          set (JYTHON_VERSION_PATCH "0")
      endif()
    endif ()
  endif ()
  unset (_JYTHON_VERSION)
  unset (_JYTHON_VERSION_RESULT)
endif ()

# handle the QUIETLY and REQUIRED arguments and set Jython_FOUND to TRUE if
# all listed variables are TRUE
include (FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS (Jython REQUIRED_VARS JYTHON_EXECUTABLE VERSION_VAR JYTHON_VERSION_STRING)

if (DEFINED JYTHON_FOUND)
  set (Jython_FOUND "${JYTHON_FOUND}")
elseif (NOT DEFINED Jython_FOUND)
  set (Jython_FOUND FALSE)
endif ()

mark_as_advanced (JYTHON_EXECUTABLE)