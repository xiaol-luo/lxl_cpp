
#pragma once

#include <map>

#include "double_link_list/double_link_list.h"

template<typename K>
class LockStepSet
{
public:
	using size_type = typename std::map<K, double_link_list_node_t *>::size_type;
	// using value_type = typename K;

	struct WrapData
	{
		K val;
		double_link_list_node_t *dl_node;
	};

	class iterator
	{
		friend LockStepSet;
	public:
		iterator(double_link_list_node_t *ptr) : m_ptr(ptr) {}

		bool operator==(const iterator &it) const {
			return it.m_ptr == this->m_ptr;
		}

		bool operator!=(const iterator &it)  const {
			return it.m_ptr != this->m_ptr;
		}

		iterator & operator++() {
			m_ptr = m_ptr->next;
			return *this;
		}

		iterator & operator++(int) {
			double_link_list_node_t *tmp = m_ptr;
			m_ptr = m_ptr->next;
			return iterator(tmp);
		}

		K operator*() const {
			WrapData *wrap_data = (WrapData *)m_ptr->data;
			return (K)wrap_data->val;
		}

		K * operator->() {
			WrapData *wrap_data = (WrapData *)m_ptr->data;
			return (K *)(&wrap_data->val);
		}

	private:
		double_link_list_node_t *m_ptr = nullptr;
	};

	static bool eq_cmp_node_data(void *_p1, void *_p2)
	{
		WrapData * p1 = (WrapData *)_p1;
		WrapData * p2 = (WrapData *)_p2;
		return !(p1->val < p2->val) && !(p2->val < p1->val);
	}

	static void free_node_data(void *p)
	{
		WrapData *wrap_data = (WrapData *)p;
		delete wrap_data;
	}
public:
	LockStepSet() {
		m_list = double_link_list_alloc(eq_cmp_node_data);
	}
	~LockStepSet() {
		m_map.clear();
		double_link_list_free(m_list, free_node_data);
		m_list = nullptr;
	}

	bool empty() { return m_map.empty(); }
	bool size() { return m_map.size(); }

	iterator begin() const {
		return iterator(m_list->head);
	}

	iterator end() const {
		return iterator(nullptr);
	}

	void clear()
	{
		m_map.clear();
		double_link_list_clear(m_list, free_node_data);
	}

	iterator find(const K &val)
	{
		auto it = m_map.find(val);
		if (m_map.end() == it)
		{
			return iterator(nullptr);
		}
		WrapData *wrap_data = it->second;
		return iterator(wrap_data->dl_node);
	}

	
	bool exist(const K &val)
	{
		return m_map.end() != m_map.find(val);
	}
	
	std::pair<iterator, bool> insert(const K &val)
	{
		bool ret = false;
		double_link_list_node_t *node = nullptr;
		if (m_map.end() == m_map.find(val))
		{
			WrapData *wrap_data = new WrapData();
			wrap_data->val = val;
			node = double_link_list_append(m_list, (void*)(wrap_data));
			wrap_data->dl_node = node;
			m_map.insert(std::make_pair(val, wrap_data));
			ret = true;
		}
		return std::pair<iterator, bool>(iterator(node), ret);
	}

	size_t erase(const K &val)
	{
		auto it = m_map.find(val);
		if (m_map.end() == it)
			return 0;
		
		WrapData *wrap_data = it->second;
		m_map.erase(val);
		double_link_list_remove_node(wrap_data->dl_node);
		free_node_data((void*)wrap_data);
		return 1;
	}

	iterator erase(const iterator &it)
	{
		double_link_list_node_t *next_node = nullptr;
		if (nullptr != it.m_ptr)
		{
			next_node = it.m_ptr->next;
		}

		erase(*it);
		return iterator(next_node);
	}

private:

	std::map<K, WrapData *> m_map;
	double_link_list_t *m_list = nullptr;
};

