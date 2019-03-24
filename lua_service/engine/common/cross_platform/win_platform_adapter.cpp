#ifdef _WIN32

#include "cross_platform_adapter.h"
#include <stdio.h>
#include <winsock2.h>
#include <iphlpapi.h>
#include <ws2tcpip.h>
#include <wchar.h>
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "iphlpapi.lib")

static void print_adapter(PIP_ADAPTER_ADDRESSES aa)
{
	char buf[BUFSIZ];
	memset(buf, 0, BUFSIZ);
	WideCharToMultiByte(CP_ACP, 0, aa->FriendlyName, wcslen(aa->FriendlyName), buf, BUFSIZ, NULL, NULL);
	WideCharToMultiByte(CP_ACP, 0, aa->Description, wcslen(aa->Description), buf, BUFSIZ, NULL, NULL);
	printf("iftype:%lld, adapter_name:%s\n", (int64_t)aa->IfType, buf);
	
}

static void print_addr(PIP_ADAPTER_UNICAST_ADDRESS ua)
{
	char buf[BUFSIZ];
	int family = ua->Address.lpSockaddr->sa_family;
	printf("\t%s ", family == AF_INET ? "IPv4" : "IPv6");
	memset(buf, 0, BUFSIZ);
	getnameinfo(ua->Address.lpSockaddr, ua->Address.iSockaddrLength, buf, sizeof(buf), NULL, 0, NI_NUMERICHOST);
	printf("%s\n", buf);
}

 DWORD ExtractNetIpsHelp(std::vector<std::string> &out_ret)
{
	ULONG flags = GAA_FLAG_SKIP_MULTICAST | GAA_FLAG_SKIP_ANYCAST | GAA_FLAG_SKIP_DNS_SERVER;
	DWORD size = 0;
	DWORD rv = GetAdaptersAddresses(AF_INET, flags, NULL, NULL, &size);
	if (ERROR_BUFFER_OVERFLOW != rv)
		return rv;
	
	PIP_ADAPTER_ADDRESSES adapter_addresses = (PIP_ADAPTER_ADDRESSES)malloc(size);
	rv = GetAdaptersAddresses(AF_INET, flags, NULL, adapter_addresses, &size);
	if (rv != ERROR_SUCCESS) {
		free(adapter_addresses);
		return rv;
	}

	for (PIP_ADAPTER_ADDRESSES aa = adapter_addresses; aa != NULL; aa = aa->Next)
	{
		bool not_ignore = (IF_TYPE_ETHERNET_CSMACD == aa->IfType) || (IF_TYPE_IEEE80211 == aa->IfType);
		if (!not_ignore)
			continue;
		static WCHAR CONST_STR_BLUETOOTH[64] = L"Bluetooth"; // 过滤蓝牙
		static WCHAR CONST_STR_ADAPTER[64] = L"Adapter"; // 过滤适配器
		if (wcsstr(aa->Description, CONST_STR_BLUETOOTH) // 这个处理不是特别好，有更好的过滤规则可以改这里
			|| wcsstr(aa->Description, CONST_STR_ADAPTER))
		{
			continue;
		}
		// print_adapter(aa);
		for (PIP_ADAPTER_UNICAST_ADDRESS ua = aa->FirstUnicastAddress; ua != NULL; ua = ua->Next) 
		{
			char buf[BUFSIZ];
			memset(buf, 0, BUFSIZ);
			getnameinfo(ua->Address.lpSockaddr, ua->Address.iSockaddrLength, buf, sizeof(buf), NULL, 0, NI_NUMERICHOST);
			out_ret.push_back(buf);
			// print_addr(ua);
		}
	}
	free(adapter_addresses);
	return 0;
}

 std::vector<std::string> ExtractNetIps()
 {
	 std::vector<std::string> out_ret;
	 ExtractNetIpsHelp(out_ret);
	 return out_ret;
 }

#endif
