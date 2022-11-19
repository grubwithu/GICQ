cmake_minimum_required(VERSION 3.22)
project(GICQ_Server)

set(CMAKE_CXX_STANDARD 14)

add_executable(GICQ_Server main.cpp Base/sqlite3.c Base/sqlite3.h Base/Server.cpp Base/Server.h Base/Message.h Base/UserInfo.h)
