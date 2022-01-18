@echo off
rem
rem CMake wrapper for current project, to ease the process of generating
rem project files or Makefiles
rem
rem Usage: run_cmake.bat <build_dir> <debug_runtime_output_dir> <runtime_output_dir> <source_dir> <cmake_generator>
rem
setlocal

set PWD=%cd%.

set CMAKE_BUILD_DIR=%~1
if "%CMAKE_BUILD_DIR%"=="" set CMAKE_BUILD_DIR=%PWD%

set CMAKE_DEBUG_OUTPUT=%~2
if "%CMAKE_DEBUG_OUTPUT%"=="" set CMAKE_DEBUG_OUTPUT=%PWD%\TestBed\FUEditor\bins

set CMAKE_RUNTIME_OUTPUT=%~3
if "%CMAKE_RUNTIME_OUTPUT%"=="" set CMAKE_RUNTIME_OUTPUT=%PWD%\TestBed\FUEditor\bins

set SOURCE_DIR=%~4
if "%SOURCE_DIR%"=="" set SOURCE_DIR=%PWD%

set CMAKE_GENERATOR=%~5
if "%CMAKE_GENERATOR%"=="" set CMAKE_GENERATOR=Visual Studio 14 2015 Win64

set CMAKE_BUILD_TYPE=Debug

set MinGW_GCC=%~6
if "%MinGW_GCC%"=="" set MinGW_GCC=C:/MinGW/bin/gcc.exe

set MinGW_G++=%~7
if "%MinGW_G++%"=="" set MinGW_G++=C:/MinGW/bin/g++.exe

SET(CMAKE_SYSTEM_NAME Generic)

if not exist "%CMAKE_BUILD_DIR%" mkdir "%CMAKE_BUILD_DIR%"
pushd "%CMAKE_BUILD_DIR%" && ^
cmake -G "%CMAKE_GENERATOR%" -G "Unix Makefiles" ^
    -Wno-dev ^
    -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" ^
    -DCMAKE_SYSTEM_NAME=Generic ^
    -DCMAKE_C_COMPILER="%MinGW_GCC%" ^
    -DCMAKE_CXX_COMPILER="%MinGW_G++%" ^
    "%SOURCE_DIR%" && ^
popd

endlocal
