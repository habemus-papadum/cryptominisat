# Original work Copyright (c) 2017, Mate Soos
# Modified work Copyright (c) 2017, Pierre Vignet
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

execute_process(COMMAND python-config --cflags OUTPUT_VARIABLE PY_C_CONFIG)
execute_process(COMMAND python-config --ldflags OUTPUT_VARIABLE PY_LD_CONFIG)

set(SETUP_PY    "${CMAKE_CURRENT_BINARY_DIR}/setup.py")
set(OUTPUT      "${CMAKE_CURRENT_BINARY_DIR}/build")

# Copy environment for distutils
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/README.rst" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/")
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/")
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/tests" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/")
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/MANIFEST.in" "${CMAKE_CURRENT_BINARY_DIR}/MANIFEST.in")


configure_file("${CMAKE_CURRENT_SOURCE_DIR}/setup.py.in" ${SETUP_PY})

add_custom_target(mypylib
    COMMAND ${PYTHON_EXECUTABLE} ${SETUP_PY} build
)

add_dependencies(mypylib
    libcryptominisat5
)

add_custom_command(OUTPUT ${OUTPUT}/timestamp
                   COMMAND ${PYTHON_EXECUTABLE}
                   ARGS setup.py build_ext --inplace --rpath ../lib
                   DEPENDS libcryptominisat5)

add_custom_target(python_interface
                  ALL DEPENDS ${OUTPUT}/timestamp)

# Make a distribution source package
# not really working -- only adds the .py files, and the test
add_custom_target(python_interface_dist_package
                  COMMAND ${PYTHON_EXECUTABLE} ${SETUP_PY} sdist
                  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

install(CODE "execute_process(
    COMMAND ${PYTHON_EXECUTABLE} ${SETUP_PY} install --record files.txt
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})"
)

if (ENABLE_TESTING AND NOT APPLE)
    add_test(NAME python_interface_test
             COMMAND ${PYTHON_EXECUTABLE} ${SETUP_PY} test
             WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
endif()
