
cmake_minimum_required(VERSION 2.8.12)

project(TestTone)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
# define a default build type
if (NOT CMAKE_BUILD_TYPE)
  message(STATUS "No build type selected, default to Release")
  set(CMAKE_BUILD_TYPE "Release")
endif()

add_executable(TestTonePA19 TestTonePA19.c)
target_link_libraries(TestTonePA19 -L/usr/lib/x86_64-linux-gnu portaudio m rt asound pthread )

add_executable(TestDevicesPA19 TestDevicesPA19.c)
target_link_libraries(TestDevicesPA19 -L/usr/lib/x86_64-linux-gnu portaudio rt asound pthread )
