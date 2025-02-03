cmake_minimum_required(VERSION 3.21)
project(HarfBuzzJS)

message("=== ${PROJECT_NAME} ===")

# C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Common compiler flags for both targets
set(COMMON_COMPILE_FLAGS
  -fno-exceptions
  -fno-rtti
  -fno-threadsafe-statics
  -fvisibility-inlines-hidden
  -flto
  $<$<CONFIG:Release>:-Oz>
  $<$<CONFIG:Debug>:-O0 -g>
)

# Common preprocessor definitions
set(COMMON_DEFINITIONS
  HB_TINY
  HB_USE_INTERNAL_QSORT
  HB_EXPERIMENTAL_API
)

# Common Emscripten link options
set(COMMON_LINK_FLAGS
  --no-entry
  -sMODULARIZE=1
  -sEXPORT_ES6=1
  -sEXPORT_NAME=createHarfBuzz
  $<$<CONFIG:Debug>:-sINITIAL_MEMORY=512KB>
  $<$<CONFIG:Release>:-sINITIAL_MEMORY=256KB>
  -sALLOW_MEMORY_GROWTH
  -sALLOW_TABLE_GROWTH
  $<$<CONFIG:Debug>:-gsource-map>
  $<$<CONFIG:Debug>:-sASSERTIONS=2>
  $<$<CONFIG:Release>:-O3>
)

# Output directory
set(OUTPUT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dist)

# Function to create a HarfBuzz target
function(add_harfbuzz_target TARGET_NAME SOURCE_FILE CONFIG_OVERRIDE SYMBOLS_FILE OUTPUT_NAME EXTRA_LINK_FLAGS)
  add_executable(${TARGET_NAME} ${SOURCE_FILE})
  
  # Add symbols file as a dependency
  set(SYMBOLS_PATH ${CMAKE_CURRENT_SOURCE_DIR}/${SYMBOLS_FILE})
  set_property(TARGET ${TARGET_NAME} PROPERTY LINK_DEPENDS ${SYMBOLS_PATH})
  
  # Include directories
  target_include_directories(${TARGET_NAME} PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
  )
  
  # Compiler flags
  target_compile_options(${TARGET_NAME} PRIVATE ${COMMON_COMPILE_FLAGS})
  
  # Preprocessor definitions
  target_compile_definitions(${TARGET_NAME} PRIVATE
    ${COMMON_DEFINITIONS}
    HB_CONFIG_OVERRIDE_H="${CONFIG_OVERRIDE}"
  )
  
  # Emscripten specific settings
  if(EMSCRIPTEN)
    # Link options
    target_link_options(${TARGET_NAME} PUBLIC
      ${COMMON_LINK_FLAGS}
      --emit-tsd ${OUTPUT_NAME}.d.ts
      -sEXPORTED_FUNCTIONS=@${SYMBOLS_PATH}
      ${EXTRA_LINK_FLAGS}
    )
    
    # Set output properties
    set_target_properties(${TARGET_NAME} PROPERTIES
      OUTPUT_NAME "${OUTPUT_NAME}"
      RUNTIME_OUTPUT_DIRECTORY ${OUTPUT_DIR}
      SUFFIX ".js"
    )
    
    # Post-build message
    add_custom_command(
      TARGET ${TARGET_NAME} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E echo "${TARGET_NAME} build complete: ${OUTPUT_DIR}/${OUTPUT_NAME}.js"
      COMMENT "Build complete"
    )
  endif()
endfunction()

# Main HarfBuzz target
add_harfbuzz_target(
  HarfBuzz
  harfbuzz/src/harfbuzz.cc
  "config-override.h"
  hb.symbols
  hb
  "-sEXPORTED_RUNTIME_METHODS=[\"addFunction\",\"removeFunction\",\"wasmMemory\",\"wasmExports\"];-sALLOW_TABLE_GROWTH=1;-lexports.js"
)

# HarfBuzz Subset target
add_harfbuzz_target(
  HarfBuzzSubset
  harfbuzz/src/harfbuzz-subset.cc
  "config-override-subset.h"
  hb-subset.symbols
  hb-subset
  ""  # No extra link flags for subset
)

if(NOT EMSCRIPTEN)
  message(FATAL_ERROR "This CMakeLists.txt is designed for Emscripten builds only. Please use CMake presets with Emscripten toolchain.")
endif()

# Create dist directory if it doesn't exist
file(MAKE_DIRECTORY ${OUTPUT_DIR})