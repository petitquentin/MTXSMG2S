cmake_minimum_required(VERSION 3.8)

#project setting
project(SMG2S LANGUAGES C CXX VERSION 1.2.0)

include(GNUInstallDirs)

# MPI compiler
find_package(MPI REQUIRED)

include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++14" COMPILER_SUPPORTS_CXX14)
if(COMPILER_SUPPORTS_CXX14)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
else()
     message([FATAL_ERROR] "The compiler ${CMAKE_CXX_COMPILER} has no C++14 support. Please use a different C++ compiler.")
endif()

add_library(smg2s INTERFACE)

target_include_directories(smg2s INTERFACE 
                                "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include/>"
                                $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    )
            
target_link_libraries(smg2s INTERFACE MPI::MPI_CXX)

# Generate SMG2S executable
add_executable(smg2s.exe smg2s.cpp)
target_link_libraries(smg2s.exe PRIVATE smg2s )
add_executable(generate_matrix.exe generate_matrix.cpp)
target_link_libraries(generate_matrix.exe PRIVATE smg2s )

install( TARGETS smg2s
  EXPORT smg2s-headers
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  FILES_MATCHING
    PATTERN "*.hpp"
)

install(EXPORT smg2s-headers
  NAMESPACE SMG2S::
  FILE smg2s-header.cmake
  EXPORT_LINK_INTERFACE_LIBRARIES
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
  )

INSTALL(TARGETS smg2s.exe DESTINATION ${CMAKE_INSTALL_BINDIR})
INSTALL(TARGETS generate_matrix.exe DESTINATION ${CMAKE_INSTALL_BINDIR})


#file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/generate_matrix.sh DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

file(GLOB C_WRAPPERS "src/C/*.cc")
add_library(smg2s2c ${C_WRAPPERS})
target_include_directories(smg2s2c INTERFACE 
                            "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include/>"
                            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    )

target_link_libraries(smg2s2c PUBLIC smg2s)


install( TARGETS smg2s2c
    EXPORT smg2s-c
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING
    PATTERN "*.h"
)

install(EXPORT smg2s-c
    NAMESPACE SMG2S::
    FILE smg2s-c.cmake
    EXPORT_LINK_INTERFACE_LIBRARIES
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

include(CMakePackageConfigHelpers)
configure_package_config_file(
    "cmake/Config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/smg2s-config.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

install( FILES
  "${CMAKE_CURRENT_BINARY_DIR}/smg2s-config.cmake"
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
  )

file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/generate_matrix.sh DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/generate_matrix_loc.sh DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

###tests
add_subdirectory(tests)

###examples
add_subdirectory(examples)

# SMG2S test
enable_testing()
add_test(Test_Size_10000_w_proc1 ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} 1 ${CMAKE_CURRENT_BINARY_DIR}/smg2s.exe -D 10000)
add_test(Test_Size_20000_w_proc2 ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} 2 ${CMAKE_CURRENT_BINARY_DIR}/smg2s.exe -D 20000)

add_test(Test_Size_10000_s_proc1 ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} 1 ${CMAKE_CURRENT_BINARY_DIR}/smg2s.exe -D 10000)
add_test(Test_Size_10000_s_proc2 ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} 2 ${CMAKE_CURRENT_BINARY_DIR}/smg2s.exe -D 10000)

add_test(Test_Size_10000_w_proc1_nonsymm ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} 1 ${CMAKE_CURRENT_BINARY_DIR}/smg2s.exe -D 10000 -M non-symm)
add_test(Test_Size_20000_w_proc2_nonsymm ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} 2 ${CMAKE_CURRENT_BINARY_DIR}/smg2s.exe -D 20000 -M non-symm)

add_test(Test_Size_10000_s_proc1_nonsymm ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} 1 ${CMAKE_CURRENT_BINARY_DIR}/smg2s.exe -D 10000 -M non-symm)
add_test(Test_Size_10000_s_proc2_nonsymm ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} 2 ${CMAKE_CURRENT_BINARY_DIR}/smg2s.exe -D 10000 -M non-symm)
