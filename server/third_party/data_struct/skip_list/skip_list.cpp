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
				list->tail->forward_nodes[i] = list->head;
			}
		}
		free(list->_help_trace_less_nodes);
		list->_help_trace_less_nodes = (skip_list_node_t **)calloc(lvl + 1, sizeof(skip_list_node_t *));
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


skip_list_t * skip_list_alloc(uint16_t expect_lvl, skip_list_cmp_node_key_pt cmp_key, skip_list_free_node_key_pt free_key)
{
	skip_list_t *ret = (skip_list_t *)calloc(1, sizeof(skip_list_t));
	ret->expect_lvl = expect_lvl;
	ret->using_max_lvl = 0;
	ret->_help_trace_less_nodes = (skip_list_node_t **)calloc(ret->using_max_lvl + 1, sizeof(skip_list_node_t *));
	ret->cmp_key = cmp_key;
	ret->free_key = free_key;
	ret->head = skip_list_node_alloc(NULL, NULL, ret->expect_lvl * 2, ret->free_key);
	ret->tail = skip_list_node_alloc(NULL, NULL, ret->expect_lvl * 2, ret->free_key);
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
	free(list->_help_trace_less_nodes);
	free(list);
}

skip_list_node_t * skip_list_insert(skip_list_t * list, void * key, void * data) 
{
	int node_max_level = 0;
	int rand_val = rand() % list->expect_lvl;
	while (0 != rand_val)
	{
		++node_max_level;
		rand_val = rand() % list->expect_lvl;
	}
	skip_list_node_t *node = skip_list_node_alloc(key, data, node_max_level + 1, list->free_key);
	
	if (node_max_level > list->using_max_lvl)
	{
		skip_list_set_using_max_lvl(list, node_max_level);
	}
	int32_t using_max_lvl = list->using_max_lvl;
	skip_list_node_t **record_less_nodes = list->_help_trace_less_nodes;

	skip_list_node_t *curr_node = list->head;

	for (int32_t curr_lvl = using_max_lvl; curr_lvl >= 0; --curr_lvl)
	{
		skip_list_node_t *cmp_node = curr_node->forward_nodes[curr_lvl];
		while (cmp_node != list->tail && list->cmp_key(cmp_node->key, key))
		{
			curr_node = cmp_node;
			cmp_node = curr_node->forward_nodes[curr_lvl];
		}
		record_less_nodes[curr_lvl] = curr_node;
	}
	
	skip_list_node_t *pre_node = record_less_nodes[0];
	skip_list_node_t *next_node = pre_node->forward_nodes[0];
	next_node->back_node = node;
	node->back_node = pre_node;

	for (int32_t curr_lvl = 0; curr_lvl <= node_max_level; ++curr_lvl)
	{
		node->forward_nodes[curr_lvl] = record_less_nodes[curr_lvl]->forward_nodes[curr_lvl];
		record_less_nodes[curr_lvl]->forward_nodes[curr_lvl] = node;
	}

	return node;
}

void skip_list_remove(skip_list_t * list, skip_list_node_t * node)
{

}

skip_list_node_t * skip_list_find(skip_list_t * list, void * key)
{
	return nullptr;
}

void skip_list_find_key(void * key)
{
}
