find_package(Boost QUIET)
IF(Boost_FOUND)
	OPTION(USE_BOOST "Build Boost-dependent functions." TRUE)
ELSE()
	OPTION(USE_BOOST "Build Boost-dependent functions." FALSE)
ENDIF()

IF(USE_BOOST)
	SET(Boost_USE_STATIC_LIBS OFF) 
	SET(Boost_USE_MULTITHREADED ON)  
	SET(Boost_USE_STATIC_RUNTIME OFF) 
	
	SET(BOOST_Components_List "")
	LIST(APPEND BOOST_Components_List "system")
	LIST(APPEND BOOST_Components_List "filesystem")
	LIST(APPEND BOOST_Components_List "program_options")
	LIST(APPEND BOOST_Components_List "date_time")
	
	IF ( Boost_VERSION VERSION_LESS 106200 )
		FIND_PACKAGE(Boost COMPONENTS ${BOOST_Components_List} REQUIRED)
	ELSE()
		MESSAGE(FATAL_ERROR "Boost version ${Boost_VERSION} is not yet supported by CMake. Try installing version 106200 (1.62.0).")
	ENDIF()
	
	IF(Boost_FOUND)
		MESSAGE(STATUS "Boost found!")
		
		MESSAGE(STATUS "CMAKE_GENERATOR  = ${CMAKE_GENERATOR}")
		SET(Boost_LIBRARY_DIR "${Boost_INCLUDE_DIR}/${msvc_LIB}" CACHE PATH "" FORCE)
		
		IF ( Boost_VERSION VERSION_LESS 106200 )
			FIND_PACKAGE(Boost COMPONENTS ${BOOST_Components_List} REQUIRED)
		ELSE()
			FIND_PACKAGE(Boost REQUIRED)
		ENDIF()
		
		MESSAGE(STATUS "Boost_INCLUDE_DIR = ${Boost_INCLUDE_DIR}")
		MESSAGE(STATUS "Boost_LIBRARY_DIR = ${Boost_LIBRARY_DIR}")
		
		INCLUDE_DIRECTORIES(${Boost_INCLUDE_DIR})
		link_directories(${Boost_LIBRARY_DIR})
		ADD_DEFINITIONS( -D_USE_BOOST_ )
		
		IF(IS_WINDOWS)
			SET(BOOST_SUFFIX_1 "${_boost_COMPILER}${_boost_MULTITHREADED}-")
			SET(BOOST_SUFFIX_2 "${Boost_LIB_VERSION}")
		ELSE()
			SET(BOOST_SUFFIX_1 "")
			SET(BOOST_SUFFIX_2 "")
		ENDIF()
		
	ELSE()
		MESSAGE(FATAL_ERROR "Boost not found! It is possible boost is installed, but not for this architecture (e.g. 64-bit libraries may be installed, but not 32-bit, or the version installed may be for the wrong version of Visual Studio.")
	ENDIF()
ELSE()
	IF (NOT BUILD_FOR_ROS)
		MESSAGE(WARNING "If not building for ROS, it is best if the Boost libraries are included for timekeeping and other purposes. Please ensure either the <BUILD_FOR_ROS> or <USE_BOOST> flag is set true if this is possible on your system.")
	ENDIF()
ENDIF()

IF(USE_PCL)
	IF(NOT USE_BOOST)
		MESSAGE(WARNING "Though the user has specified not to include Boost, it may still be included because PCL incorporates Boost anyway.")
	ENDIF()
ENDIF()

IF( USE_BOOST )
	IF( Boost_FOUND)
		SET(boost_FOUND TRUE)
		IF ( Boost_VERSION VERSION_LESS 106200 )
			IF( IS_64_BIT )
				IF(IS_WINDOWS)
					STRING( FIND ${Boost_SYSTEM_LIBRARY_DEBUG} "lib64" APOSITION )
					IF ("${APOSITION}" STREQUAL "-1")
						MESSAGE(FATAL_ERROR "This is a 64-bit build, and it looks like CMake actually found the 32-bit Boost libraries to link to!")
					ENDIF()
				ELSE()
					STRING( FIND ${Boost_SYSTEM_LIBRARY_DEBUG} "x86_64" APOSITION )
					IF ("${APOSITION}" STREQUAL "-1")
						MESSAGE(FATAL_ERROR "This is a 64-bit build, and it looks like CMake actually found the 32-bit Boost libraries to link to!")
					ENDIF()
				ENDIF()
			ELSE()
				STRING( FIND ${Boost_SYSTEM_LIBRARY_DEBUG} "lib64" APOSITION ) 
				IF (NOT "${APOSITION}" STREQUAL "-1")
					MESSAGE(FATAL_ERROR "This is a 32-bit build, and it looks like CMake actually found the 64-bit Boost libraries to link to!")
				ENDIF()
			ENDIF()
		ENDIF()
		LIST(APPEND ADDITIONAL_LIBRARIES ${Boost_LIBRARIES})
	ELSE()
		SET(boost_FOUND FALSE)
	ENDIF()
ENDIF()
