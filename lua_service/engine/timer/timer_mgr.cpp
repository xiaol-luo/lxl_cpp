#include "timer_mgr.h"
#include <queue>
#include <string.h>

TimerMgr::TimerMgr(uint64_t now_ms) : m_now_ms(now_ms)
{
	m_rbtree_sentinel_node = new srv_rbtree_node_t;
	memset(m_rbtree_sentinel_node, 0, sizeof(srv_rbtree_node_t));
	m_rbtree_timer_items = new srv_rbtree_t;
	memset(m_rbtree_timer_items, 0, sizeof(srv_rbtree_t));
	srv_rbtree_init(m_rbtree_timer_items, m_rbtree_sentinel_node, srv_rbtree_insert_value);
}

TimerMgr::~TimerMgr()
{
	if (nullptr != m_rbtree_sentinel_node && nullptr != m_rbtree_timer_items)
	{
		std::queue<srv_rbtree_node_t *> node_queue;
		if (m_rbtree_timer_items->root != m_rbtree_timer_items->sentinel)
			node_queue.push(m_rbtree_timer_items->root);
		while (!node_queue.empty())
		{
			srv_rbtree_node_t *node = node_queue.front();
			node_queue.pop();
			if (node->left != m_rbtree_timer_items->sentinel)
				node_queue.push(node->left);
			if (node->right != m_rbtree_timer_items->sentinel)
				node_queue.push(node->right);
			if (nullptr != node->data)
				delete (TimerItem *)node->data;
			delete node;
		}
		delete m_rbtree_sentinel_node; m_rbtree_sentinel_node = nullptr;
		delete m_rbtree_timer_items; m_rbtree_timer_items = nullptr;
	}
}

TimerID TimerMgr::Add(TimerCallback cb_fn, int64_t start_ts_ms, int64_t execute_span_ms, int64_t execute_times)
{
	if (nullptr == cb_fn || execute_span_ms < 0)
		return INVALID_TIMER_ID;
	if (execute_times == EXECUTE_UNLIMIT_TIMES && execute_span_ms <= 0)
		return INVALID_TIMER_ID;
	if (execute_times != EXECUTE_UNLIMIT_TIMES && execute_times < 0)
		return INVALID_TIMER_ID;

	TimerItem *timer_item = new TimerItem();
	timer_item->id = this->GenTimerId();
	timer_item->span_ms = execute_span_ms;
	timer_item->execute_times = execute_times;
	timer_item->is_firm = execute_times == EXECUTE_UNLIMIT_TIMES;
	timer_item->cb_fn = cb_fn;
	timer_item->execute_ms = (start_ts_ms >= m_now_ms) ? start_ts_ms : m_now_ms;
	srv_rbtree_node_t *node = (srv_rbtree_node_t *)malloc(sizeof(srv_rbtree_node_t));
	memset(node, 0, sizeof(srv_rbtree_node_t));
	node->key = timer_item->execute_ms;
	node->data = timer_item;
	m_id_to_timer_node[timer_item->id] = node;
	if (timer_item->execute_ms <= m_now_ms)
		m_nodes_execute_now.push_back(node);
	else
		srv_rbtree_insert(m_rbtree_timer_items, node);
	return timer_item->id;
}

TimerID TimerMgr::AddNext(TimerCallback cb_fn, int64_t start_ts_ms)
{
	return this->Add(cb_fn, start_ts_ms, 0, 1);
}

TimerID TimerMgr::AddFirm(TimerCallback cb_fn, int64_t execute_span_ms, int64_t execute_times)
{

	return this->Add(cb_fn, m_now_ms + execute_span_ms, execute_span_ms, execute_times);
}

void TimerMgr::Remove(TimerID timer_id)
{
	m_to_remove_nodes.insert(timer_id);
}

void TimerMgr::UpdateTime(int64_t now_ms)
{
	m_now_ms = now_ms;
	this->ChekRemoveNodes();
	if (!m_nodes_execute_now.empty())
	{
		for (srv_rbtree_node_t *node : m_nodes_execute_now)
		{
			this->TryExecuteNode(node);
		}
		m_nodes_execute_now.clear();
	}
	int loop = 0;
	while (loop++ < 10000000 && m_rbtree_timer_items->root != m_rbtree_timer_items->sentinel)
	{
		srv_rbtree_node_t *node = srv_rbtree_min(m_rbtree_timer_items->root, m_rbtree_timer_items->sentinel);
		if (m_rbtree_timer_items->sentinel == node)
			break;
		if (node->key > m_now_ms)
			break;
		srv_rbtree_delete(m_rbtree_timer_items, node);
		this->TryExecuteNode(node);
	}
	this->ChekRemoveNodes();
}

TimerID TimerMgr::GenTimerId()
{
	do
	{
		++m_last_timer_id;
		m_last_timer_id <= 0 ? (m_last_timer_id = 1) : 0;

	} while (m_id_to_timer_node.count(m_last_timer_id) > 0);

	return m_last_timer_id;
}

void TimerMgr::ChekRemoveNodes()
{
	if (m_to_remove_nodes.empty())
		return;

	for (long long timer_id : m_to_remove_nodes)
	{
		auto it = m_id_to_timer_node.find(timer_id);
		if (m_id_to_timer_node.end() == it)
			continue;;
		srv_rbtree_node_t *node = it->second;
		if (node->parent)
			srv_rbtree_delete(m_rbtree_timer_items, node);
		delete (TimerItem *)node->data;
		free(node);
		m_id_to_timer_node.erase(it);
	}
	m_to_remove_nodes.clear();
}

void TimerMgr::TryExecuteNode(srv_rbtree_node_t *node)
{
	// 每个进入到这里的node，只被m_id_to_timer_node有效引用
	TimerItem *timer_item = (TimerItem *)node->data;
	if (nullptr == timer_item)
	{
		TimerID timer_id = INVALID_TIMER_ID;
		for (auto kvPair : m_id_to_timer_node)
		{
			if (kvPair.second == node)
			{
				timer_id = kvPair.first;
				break;
			}
		}
		if (INVALID_TIMER_ID != timer_id)
		{
			m_to_remove_nodes.insert(timer_id);
		}
		else
		{
			delete node;
		}
		return;
	}
	if (m_to_remove_nodes.count(timer_item->id) > 0)
		return;

	timer_item->cb_fn();
	if (!timer_item->is_firm)
	{
		--timer_item->execute_times;
	}
	if (timer_item->is_firm || timer_item->execute_times > 0)
	{
		timer_item->execute_ms = m_now_ms + timer_item->span_ms;
		node->key = timer_item->execute_ms;
		srv_rbtree_insert(m_rbtree_timer_items, node);
	}
	else
	{
		TimerID timer_id = timer_item->id;
		timer_item = nullptr;
		node = nullptr;
		this->Remove(timer_id);
	}
}