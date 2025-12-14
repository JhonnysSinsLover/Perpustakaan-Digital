cmake_minimum_required(VERSION 3.16)

project(AppSigmaterial VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 COMPONENTS Quick QuickControls2 QuickDialogs2 Qml Sql REQUIRED)

qt_standard_project_setup(REQUIRES 6.8)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Add parent directory to include paths
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)

qt_add_executable(appAppSigmaterial
    main.cpp
    ../AppLogic.cpp
    ../Database.cpp
    ../CircularImage.cpp
    ../AppLogic.h
    ../Database.h
    ../CircularImage.h
    res.qrc
)

target_link_libraries(appAppSigmaterial
    PRIVATE Qt6::Quick
    PRIVATE Qt6::QuickControls2
    PRIVATE Qt6::QuickDialogs2
    PRIVATE Qt6::Sql
)

set_target_properties(appAppSigmaterial PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

include(GNUInstallDirs)
install(TARGETS appAppSigmaterial
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
