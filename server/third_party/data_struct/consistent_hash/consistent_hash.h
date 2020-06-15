
#pragma once

#include <string>
#include <unordered_map>
#include <map>

class ConsistentHash
{
public:
	ConsistentHash();
	~ConsistentHash();
	
	bool SetRealNode(std::string name, uint32_t virtual_nodes);
	std::pair<bool, std::string> Find(const void *p, uint32_t len);
	static uint32_t cal_hash(const void *p, uint32_t len);

private:
	struct VirtualNode
	{
		uint32_t id;
		uint32_t hash_val;
	};
	struct RealNode
	{
		RealNode(std::string _name) : name(_name) {}

		std::string name;
		std::vector<VirtualNode> virtual_node_vec;
	};
	std::map<uint32_t, RealNode *> m_ring_nodes;
	std::unordered_map<std::string, RealNode> m_real_nodes;

	std::string m_empty_str;
};