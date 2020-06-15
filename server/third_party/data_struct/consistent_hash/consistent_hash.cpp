#include "consistent_hash.h"


unsigned int MurMurHash(const void *key, int len) {
	const unsigned int m = 0x5bd1e995;
	const int r = 24;
	const int seed = 97;
	unsigned int h = seed ^ len;
	// Mix 4 bytes at a time into the hash
	const unsigned char *data = (const unsigned char *)key;
	while (len >= 4) {
		unsigned int k = *(unsigned int *)data;
		k *= m;
		k ^= k >> r;
		k *= m;
		h *= m;
		h ^= k;
		data += 4;
		len -= 4;
	}
	// Handle the last few bytes of the input array
	switch (len) {
	case 3:
		h ^= data[2] << 16;
	case 2:
		h ^= data[1] << 8;
	case 1:
		h ^= data[0];
		h *= m;
	};
	// Do a few final mixes of the hash to ensure the last few
	// bytes are well-incorporated.
	h ^= h >> 13;
	h *= m;
	h ^= h >> 15;
	return h;
}

ConsistentHash::ConsistentHash()
{
}

ConsistentHash::~ConsistentHash()
{
}

bool ConsistentHash::SetRealNode(std::string name, uint32_t virtual_nodes)
{
	auto it = m_real_nodes.find(name);
	if (m_real_nodes.end() == it)
	{
		if (0 == virtual_nodes) 
		{
			return true;
		}
		auto ret = m_real_nodes.insert(std::make_pair(name, RealNode(name)));
		if (!ret.second)
		{
			return false;
		}
		it = ret.first;
	}
	RealNode &real_node = it->second;
	if (real_node.virtual_node_vec.size() > virtual_nodes)
	{
		while (real_node.virtual_node_vec.size() > virtual_nodes)
		{
			const VirtualNode &v_node = real_node.virtual_node_vec.back();
			m_ring_nodes.erase(v_node.hash_val);
			real_node.virtual_node_vec.pop_back();
		}
	}
	else if (real_node.virtual_node_vec.size() < virtual_nodes)
	{
		uint32_t last_id = 0;
		if (!real_node.virtual_node_vec.empty())
		{
			const VirtualNode &v_node = real_node.virtual_node_vec.back();
			last_id = v_node.id;
		}
		while (real_node.virtual_node_vec.size() < virtual_nodes)
		{
			VirtualNode v_node;
			v_node.id = ++last_id;
			std::string hash_input = real_node.name + std::to_string(v_node.id);
			v_node.hash_val = ConsistentHash::cal_hash(hash_input.data(), hash_input.size());
			if (m_ring_nodes.end() == m_ring_nodes.find(v_node.hash_val))
			{
				m_ring_nodes.insert(std::make_pair(v_node.hash_val, &real_node));
				real_node.virtual_node_vec.push_back(v_node);
			}
		}
	}
	return true;
}

std::pair<bool, std::string> ConsistentHash::Find(const void * p, uint32_t len)
{
	if (p && len > 0 && !m_ring_nodes.empty())
	{
		uint32_t hash_val = ConsistentHash::cal_hash(p, len);
		auto it = m_ring_nodes.lower_bound(hash_val);
		if (m_ring_nodes.end() == it)
		{
			it = m_ring_nodes.begin();
		}
		std::pair<bool, std::string> ret = std::make_pair(true, it->second->name);
		return ret;
	}
	else
	{
		std::pair<bool, std::string> ret = std::make_pair(false, m_empty_str);
		return ret;
	}
}

uint32_t ConsistentHash::cal_hash(const void * p, uint32_t len)
{
	uint32_t ret = 0;
	if (p && len > 0)
	{
		ret = (uint32_t)MurMurHash(p, len);
	}
	return ret;
}
