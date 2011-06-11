##############################################################################
# \file  BasisSubversionTools.cmake
# \brief CMake functions and macros related to Subversion.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

if (__BASIS_SUBVERSIONTOOLS_INCLUDED)
  return ()
else ()
  set (__BASIS_SUBVERSIONTOOLS_INCLUDED TRUE)
endif ()


# get directory of this file
#
# \note This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# required commands
# ============================================================================

find_program (BASIS_CMD_SVN NAMES svn DOC "Subversion command line client (svn).")
mark_as_advanced (BASIS_CMD_SVN)

# ============================================================================
# retrieve SVN information
# ============================================================================

# ****************************************************************************
# \brief Get current revision of file or directory.
#
# \param [in]  URL Absolute path of directory or file. May also be a URL to the
#                  directory or file in the repository. A leading "file://" is
#                  automatically removed such that the svn command treats it as a
#                  local path.
# \param [out] REV The revision number of URL. If URL is not under revision
#                  control or BASIS_CMD_SVN is invalid, "0" is returned.

function (basis_svn_get_revision URL REV)
  set (OUT "0")

  if (BASIS_CMD_SVN)
    # remove "file://" from URL
    string (REGEX REPLACE "file://" "" TMP "${URL}")

    # retrieve SVN info
    execute_process (
      COMMAND         "${BASIS_CMD_SVN}" info "${TMP}"
      OUTPUT_VARIABLE OUT
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # extract revision
    string (REGEX REPLACE "^(.*\n)?Revision: ([^\n]+).*" "\\2" OUT "${OUT}")

    if (OUT STREQUAL "")
      set (OUT "0")
    endif ()
  endif ()

  # return
  set ("${REV}" "${OUT}" PARENT_SCOPE)
endfunction ()

# ****************************************************************************
# \brief Get revision number when directory or file was last changed.
#
# \param [in]  URL Absolute path of directory or file. May also be a URL to the
#                  directory or file in the repository. A leading "file://" is
#                  automatically removed such that the svn command treats it as a
#                  local path.
# \param [out] REV Revision number when URL was last modified. If URL is not
#                  under Subversion control or BASIS_CMD_SVN is invalid,
#                  "0" is returned.

function (basis_svn_get_last_changed_revision URL REV)
  set (OUT "0")

  if (BASIS_CMD_SVN)
    # remove "file://" from URL
    string (REGEX REPLACE "file://" "" TMP "${URL}")

    # retrieve SVN info
    execute_process (
      COMMAND         "${BASIS_CMD_SVN}" info "${TMP}"
      OUTPUT_VARIABLE OUT
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # extract last changed revision
    string (REGEX REPLACE "^(.*\n)?Last Changed Rev: ([^\n]+).*" "\\2" OUT "${OUT}")

    if (OUT STREQUAL "")
      set (OUT "0")
    endif ()
  endif ()

  # return
  set ("${REV}" "${OUT}" PARENT_SCOPE)
endfunction ()

# ****************************************************************************
# \brief Get status of revision controlled file.
#
# \param [in]  URL    Absolute path of directory or file. May also be a URL to
#                     the directory or file in the repository.
#                     A leading "file://" will be removed such that the svn
#                     command treats it as a local path.
# \param [out] STATUS The status of URL as returned by 'svn status'.
#                     If the local directory or file is unmodified, an
#                     empty string is returned. An empty string is also
#                     returned when BASIS_CMD_SVN is invalid.

function (basis_svn_status URL STATUS)
  if (BASIS_CMD_SVN)
    # remove "file://" from URL
    string (REGEX REPLACE "file://" "" TMP "${URL}")

    # retrieve SVN status of URL
    execute_process (
      COMMAND         "${BASIS_CMD_SVN}" status "${TMP}"
      OUTPUT_VARIABLE OUT
      ERROR_QUIET
    )

    # return
    set ("${STATUS}" "${OUT}" PARENT_SCOPE)
  else ()
    set ("${STATUS}" "" PARENT_SCOPE)
  endif ()
endfunction ()

