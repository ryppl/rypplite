##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

set(Boost_FOUND TRUE)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

set(Boost_INCLUDE_DIRS "${CMAKE_BINARY_DIR}/include")
set(Boost_LIBRARY_DIRS "${CMAKE_BINARY_DIR}/lib")

set(RYPPL_DEPENDENCY_DIR "${CMAKE_BINARY_DIR}/dependencies")
set(Boost_RESOURCE_PATH "${RYPPL_DEPENDENCY_DIR}/cmake/resources")
set(Boost_USE_FILE "${RYPPL_DEPENDENCY_DIR}/cmake/modules/UseBoost.cmake")
set(Boost_DEV_FILE "${RYPPL_DEPENDENCY_DIR}/cmake/modules/UseBoostDev.cmake")

function(ryppl_fetch_dependency name)
  set(url "git://github.com/boost-lib/${name}.git")
  if(NOT EXISTS "${RYPPL_DEPENDENCY_DIR}/${name}")
    find_package(Git REQUIRED)
    file(MAKE_DIRECTORY "${RYPPL_DEPENDENCY_DIR}")
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" clone ${url} ${name}
      WORKING_DIRECTORY "${RYPPL_DEPENDENCY_DIR}"
      RESULT_VARIABLE error_code
      )
    if(error_code)
      message(FATAL_ERROR "Failed to fetch from repository: '${url}'")
    endif(error_code)
  endif(NOT EXISTS "${RYPPL_DEPENDENCY_DIR}/${name}")
endfunction(ryppl_fetch_dependency)

if(NOT DEFINED RYPPL_DEPENDENCY_LEVEL)
  set(RYPPL_DEPENDENCY_LEVEL 0 CACHE INTERNAL "" FORCE)
endif(NOT DEFINED RYPPL_DEPENDENCY_LEVEL)

math(EXPR level "${RYPPL_DEPENDENCY_LEVEL} + 1")
set(RYPPL_DEPENDENCY_LEVEL ${level} CACHE INTERNAL "" FORCE)

foreach(component cmake ${Boost_FIND_COMPONENTS})
  ryppl_fetch_dependency(${component})

  list(FIND RYPPL_COMPONENTS ${component} index)
  if(index EQUAL -1)
    list(APPEND RYPPL_COMPONENTS ${component})
    add_subdirectory(
      "${RYPPL_DEPENDENCY_DIR}/${component}"
      "${RYPPL_DEPENDENCY_DIR}-build/${component}"
      EXCLUDE_FROM_ALL
      )
    if(RYPPL_DEPENDENCY_LEVEL GREATER 1)
      set(RYPPL_COMPONENTS ${RYPPL_COMPONENTS} PARENT_SCOPE)
    endif(RYPPL_DEPENDENCY_LEVEL GREATER 1)
  endif(index EQUAL -1)
endforeach(component)

math(EXPR level "${RYPPL_DEPENDENCY_LEVEL} - 1")
set(RYPPL_DEPENDENCY_LEVEL ${level} CACHE INTERNAL "" FORCE)

