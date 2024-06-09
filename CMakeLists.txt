cmake_minimum_required(VERSION 3.25 FATAL_ERROR)

project(BindingsDataExport LANGUAGES CXX)

include(cmake/CPM.cmake)

# Figure out the target platform
if (NOT DEFINED GEODE_TARGET_PLATFORM)
	if(APPLE)
		if(IOS)
			set(GEODE_TARGET_PLATFORM "iOS")
		else()
			set(GEODE_TARGET_PLATFORM "MacOS")
		endif()
	elseif(WIN32)
		set(GEODE_TARGET_PLATFORM "Win32")
	elseif(ANDROID)
		if (ANDROID_ABI STREQUAL "arm64-v8a")
			set(GEODE_TARGET_PLATFORM "Android64")
		elseif(ANDROID_ABI STREQUAL "armeabi-v7a")
			set(GEODE_TARGET_PLATFORM "Android32")
		endif()
	else()
		message(FATAL_ERROR "Unable to detect platform, please set GEODE_TARGET_PLATFORM in the root CMake file.")
	endif()
endif()

# Figure out the GD version
if (NOT DEFINED GEODE_GD_VERSION)
	if (${GEODE_TARGET_PLATFORM} STREQUAL "Win32")
		set(GEODE_GD_VERSION 2.206)
	elseif (${GEODE_TARGET_PLATFORM} STREQUAL "Android32" OR ${GEODE_TARGET_PLATFORM} STREQUAL "Android64")
		set(GEODE_GD_VERSION 2.206)
	else()
		set(GEODE_GD_VERSION 2.206)
	endif()
endif()

message(STATUS "Generating bindings for ${GEODE_TARGET_PLATFORM} with GD version ${GEODE_GD_VERSION}")

# Include the bindings
set(GEODE_LOADER_PATH "")
CPMAddPackage(NAME "bindings"
    GITHUB_REPOSITORY "geode-sdk/bindings"
    GIT_TAG "main"
    DOWNLOAD_ONLY YES
    NO_CACHE YES
)
set(GEODE_BINDINGS_REPO_PATH ${bindings_SOURCE_DIR})
add_subdirectory(${GEODE_BINDINGS_REPO_PATH} ${CMAKE_BINARY_DIR}/bindings)

# Export CodegenData.txt to CodegenData-<platform>-<gd_version>.txt
set(CODEGEN_DATA_FILE ${CMAKE_BINARY_DIR}/bindings/bindings/Geode/CodegenData.txt)
set(CODEGEN_DATA_EXPORT_FILE ${CMAKE_SOURCE_DIR}/output/${GEODE_TARGET_PLATFORM}-${GEODE_GD_VERSION}.txt)
file(COPY ${CODEGEN_DATA_FILE} DESTINATION ${CMAKE_SOURCE_DIR}/output)
file(RENAME ${CMAKE_SOURCE_DIR}/output/CodegenData.txt ${CODEGEN_DATA_EXPORT_FILE})