
set(target hierarchy3)


file(GLOB "${target}_SRC" "${CMAKE_CURRENT_SOURCE_DIR}/*.c" "${CMAKE_CURRENT_SOURCE_DIR}/*.asm")
if(CMAKE_DEBUG)
    message(STATUS "${target}_SRC: ${${target}_SRC}")
endif()



set(SOURCE
  ${SOURCE}
  ${${target}_SRC}
  PARENT_SCOPE
)

