#include "skip_list.h"
#include <stdlib.h>
#include <string.h>

static bool skip_list_node_check_expand_forward_nodes(skip_list_node_t *node, uint16_t new_size)
{
	if (new_size <= node->forward_node_size)
		return false;

	uint16_t old_node_size = node->forward_node_size;
	skip_list_node_t **old_nodes = node->forward_nodes;
	node->forward_node_size = new_size;
	node->forward_nodes = (skip_list_node_t **)calloc(new_size, sizeof(skip_list_node_t *));
	if (old_nodes)
	{
		memcpy(node->forward_nodes, old_nodes, sizeof(skip_list_node_t *) * old_node_size);
		free(old_nodes); old_nodes = NULL;
	}
	return true;
}

static void skip_list_set_using_max_lvl(skip_list_t * list, uint16_t lvl)
{
	if (NULL == list)
		return;

	if (list->using_max_lvl < lvl)
	{
		if (skip_list_node_check_expand_forward_nodes(list->head, lvl + 1) || skip_list_node_check_expand_forward_nodes(list->tail, lvl + 1))
		{
			for (uint16_t i = list->using_max_lvl; i <= lvl; ++i)
			{
				list->head->forward_nodes[i] = list->tail;
			}
		}
		free(list->_help_trace_nodes);
		list->_help_trace_nodes = (skip_list_node_t **)calloc(lvl + 1, sizeof(skip_list_node_t *));
	}
	list->using_max_lvl = lvl;
}

skip_list_node_t * skip_list_node_alloc(void * key, void * data, uint16_t  forward_node_size, skip_list_free_node_key_pt free_key)
{
	skip_list_node_t *ret = (skip_list_node_t *)calloc(1, sizeof(skip_list_node_t));
	ret->key = key;
	ret->free_key = free_key;
	ret->data = data;
	skip_list_node_check_expand_forward_nodes(ret, forward_node_size);
	return ret;
}

void skip_list_node_free(skip_list_node_t * node)
{
	if (NULL == node)
		return;

	if (node->free_key && node->key)
	{
		node->free_key(node->key);
	}
	if (node->forward_nodes)
	{
		free(node->forward_nodes);
	}
	free(node);
}


skip_list_t * skip_list_alloc(uint16_t expect_n_nodes_make_one_index, skip_list_lt_cmp_node_key_pt lt_cmp_key, skip_list_free_node_key_pt free_key)
{
	skip_list_t *ret = (skip_list_t *)calloc(1, sizeof(skip_list_t));
	ret->expect_n_nodes_make_one_index = expect_n_nodes_make_one_index;
	ret->using_max_lvl = 0;
	ret->_help_trace_nodes = (skip_list_node_t **)calloc(ret->using_max_lvl + 1, sizeof(skip_list_node_t *));
	ret->lt_cmp_key = lt_cmp_key;
	ret->free_key = free_key;
	ret->head = skip_list_node_alloc(NULL, NULL, 32, ret->free_key);
	ret->tail = skip_list_node_alloc(NULL, NULL, 32, ret->free_key);
	ret->tail->back_node = ret->head;
	for (uint16_t i = 0; i < ret->head->forward_node_size; ++i)
	{
		ret->head->forward_nodes[i] = ret->tail;
	}
	return ret;
}

void skip_list_free(skip_list_t * list)
{
	if (NULL == list)
		return;

	skip_list_node_t *p = list->tail;
	while (p)
	{
		skip_list_node_t *free_node = p;
		p = free_node->back_node;
		skip_list_node_free(free_node);
	}
	free(list->_help_trace_nodes);
	free(list);
}

#define SKIP_LIST_FILL_SEARCH_RESULT(list, record_pre_nodes, key)								\
	do																							\
	{																							\
		skip_list_node_t *pre_node = list->head;												\
			for (int32_t curr_lvl = list->using_max_lvl; curr_lvl >= 0; --curr_lvl)			\
			{																					\
				skip_list_node_t *cmp_node = pre_node->forward_nodes[curr_lvl];					\
				while (cmp_node != list->tail && list->lt_cmp_key(cmp_node->key, key))			\
				{																				\
					pre_node = cmp_node;														\
					cmp_node = pre_node->forward_nodes[curr_lvl];								\
				}																				\
					record_pre_nodes[curr_lvl] = pre_node;										\
			}																					\
	} while (false);

bool skip_list_insert(skip_list_t * list, void * key, void * data) 
{
	if (NULL == list || NULL == key)
		return false;

	int node_max_level = -1;
	int rand_val = 0;
	do
	{
		++node_max_level;
		rand_val = rand() % list->expect_n_nodes_make_one_index;
	} while (0 == rand_val);

	skip_list_node_t *node = skip_list_node_alloc(key, data, node_max_level + 1, list->free_key);
	
	if (node_max_level > list->using_max_lvl)
	{
		skip_list_set_using_max_lvl(list, node_max_level);
	}

	skip_list_node_t **record_pre_nodes = list->_help_trace_nodes;
	SKIP_LIST_FILL_SEARCH_RESULT(list, record_pre_nodes, key);

	skip_list_node_t *pre_node = record_pre_nodes[0];
	skip_list_node_t *next_node = pre_node->forward_nodes[0];
	next_node->back_node = node;
	node->back_node = pre_node;

	for (int32_t curr_lvl = 0; curr_lvl <= node_max_level; ++curr_lvl)
	{
		node->forward_nodes[curr_lvl] = record_pre_nodes[curr_lvl]->forward_nodes[curr_lvl];
		record_pre_nodes[curr_lvl]->forward_nodes[curr_lvl] = node;
	}

	return true;
}

void * skip_list_remove(skip_list_t * list, void * key)
{
	skip_list_node_t **record_pre_nodes = list->_help_trace_nodes;
	SKIP_LIST_FILL_SEARCH_RESULT(list, record_pre_nodes, key);

	void *out_data = NULL;
	skip_list_node_t *curr_node = record_pre_nodes[0]->forward_nodes[0];
	if (curr_node != list->tail && !list->lt_cmp_key(curr_node->key, key) && !list->lt_cmp_key(key, curr_node->key))
	{
		out_data = curr_node->data;

		skip_list_node_t *pre_node = curr_node->back_node;
		skip_list_node_t *next_node = curr_node->forward_nodes[0];
		next_node->back_node = pre_node;
		for (int32_t curr_lvl = curr_node->forward_node_size - 1; curr_lvl >= 0 ; --curr_lvl)
		{
			record_pre_nodes[curr_lvl]->forward_nodes[curr_lvl] = curr_node->forward_nodes[curr_lvl];
		}
		if (list->using_max_lvl == curr_node->forward_node_size - 1)
		{
			uint32_t new_using_max_level = list->using_max_lvl;
			for (int32_t curr_lvl = curr_node->forward_node_size - 1; curr_lvl >= 0; --curr_lvl)
			{
				if (list->head == record_pre_nodes[curr_lvl] && list->tail == record_pre_nodes[curr_lvl]->forward_nodes[curr_lvl])
				{
					new_using_max_level = curr_lvl;
					continue;
				}
				break;
			}
			if (new_using_max_level != list->using_max_lvl)
			{
				skip_list_set_using_max_lvl(list, new_using_max_level);
			}
		}
	}
	return out_data;
}

bool skip_list_find(skip_list_t * list, void * key, void **out_data)
{
	int32_t using_max_lvl = list->using_max_lvl;
	skip_list_node_t *pre_node = list->head;
	skip_list_node_t **record_pre_nodes = list->_help_trace_nodes;
	SKIP_LIST_FILL_SEARCH_RESULT(list, record_pre_nodes, key);

	bool is_exist = false;
	skip_list_node_t *curr_node = record_pre_nodes[0]->forward_nodes[0];
	if (curr_node != list->tail && !list->lt_cmp_key(curr_node->key, key) && !list->lt_cmp_key(key, curr_node->key))
	{
		is_exist = true;
		if (out_data)
		{
			*out_data = curr_node->data;
		}
	}
	return is_exist;
}

