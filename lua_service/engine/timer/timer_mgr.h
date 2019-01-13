#pragma once

#include "timer_def.h"
#include "rb_tree/srv_rbtree.h"
#include <vector>
#include <set>
#include <unordered_map>

class TimerMgr
{
public:
	TimerMgr(uint64_t now_ms);
	~TimerMgr();

	TimerID Add(TimerCallback cb_fn, int64_t start_ts_ms, int64_t execute_span_ms, int64_t execute_times);
	TimerID AddNext(TimerCallback cb_fn, int64_t start_ts_ms);
	TimerID AddFirm(TimerCallback cb_fn, int64_t execute_span_ms, int64_t execute_times);
	void Remove(TimerID timer_id);
	void UpdateTime(int64_t now_ms);

private:
	struct TimerItem
	{
		long long id = INVALID_TIMER_ID;
		bool is_firm = false;
		long long execute_ms = 0;
		long long span_ms = 0;
		long long execute_times = 0;
		TimerCallback cb_fn = nullptr;
	};

	uint64_t m_now_ms;

	srv_rbtree_node_t *m_rbtree_sentinel_node = nullptr;
	srv_rbtree_t *m_rbtree_timer_items = nullptr;

	std::vector<srv_rbtree_node_t *> m_nodes_execute_now;
	void TryExecuteNode(srv_rbtree_node_t *node);

	std::unordered_map<TimerID, srv_rbtree_node_t *> m_id_to_timer_node;
	TimerID m_last_timer_id = 0;
	TimerID GenTimerId();

	std::set<TimerID> m_to_remove_nodes;
	void ChekRemoveNodes();
};