
set(target hierarchy2)


file(GLOB "${target}_SRC" "${CMAKE_CURRENT_SOURCE_DIR}/*.c" "${CMAKE_CURRENT_SOURCE_DIR}/*.asm")
if(CMAKE_DEBUG)
    message(STATUS "${target}_SRC: ${${target}_SRC}")
endif()


add_subdirectory(hierarchy3)

set(SOURCE
  ${SOURCE}
  ${${target}_SRC}
  PARENT_SCOPE
)

