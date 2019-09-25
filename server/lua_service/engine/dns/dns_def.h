#pragma once

#ifdef WIN32
#include <winsock2.h>
#include <WS2tcpip.h>

#else
#include <netdb.h>
#include <arpa/inet.h>
#endif

