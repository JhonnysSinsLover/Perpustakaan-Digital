cmake_minimum_required(VERSION 3.16)

project(AppSigmaterial VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 3rd party tools
find_package(Qt6 COMPONENTS Widgets Qml Quick Sql REQUIRED)

# Directory with the source code
add_subdirectory(resource)