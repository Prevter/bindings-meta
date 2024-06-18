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

function(copy_bindings_data file_name target_file_name)
	set(CODEGEN_DATA_FILE ${CMAKE_BINARY_DIR}/bindings/bindings/Geode/${file_name})
	set(CODEGEN_DATA_EXPORT_FILE ${CMAKE_SOURCE_DIR}/output/${target_file_name})
	file(COPY ${CODEGEN_DATA_FILE} DESTINATION ${CMAKE_SOURCE_DIR}/output)
	file(RENAME ${CMAKE_SOURCE_DIR}/output/${file_name} ${CODEGEN_DATA_EXPORT_FILE})
endfunction()

# Export CodegenData.txt to CodegenData-<platform>-<gd_version>.txt
# Note: macOS 2.206+ exports CodegenDataIntel.txt and CodegenDataArm.txt, so we have to handle that as well
if (${GEODE_TARGET_PLATFORM} STREQUAL "MacOS" AND NOT ${GEODE_GD_VERSION} STREQUAL "2.200")
	copy_bindings_data("CodegenDataIntel.txt" "${GEODE_TARGET_PLATFORM}-${GEODE_GD_VERSION}-Intel.txt")
	copy_bindings_data("CodegenDataArm.txt" "${GEODE_TARGET_PLATFORM}-${GEODE_GD_VERSION}-Arm.txt")
else()
	copy_bindings_data("CodegenData.txt" "${GEODE_TARGET_PLATFORM}-${GEODE_GD_VERSION}.txt")
endif()