#include "skip_list.h"
#include <stdlib.h>

skip_list_node_t * skip_list_node_alloc(void * key, void * data, uint32_t  lvl_node_size, skip_list_free_node_key_pt free_key)
{
	skip_list_node_t *ret = (skip_list_node_t *)calloc(1, sizeof(skip_list_node_t));
	ret->key = key;
	ret->free_key = free_key;
	ret->data = data;
	ret->lvl_node_size = lvl_node_size;
	if (ret->lvl_node_size > 0)
	{
		ret->lvl_nodes = (skip_list_node_t **)calloc(ret->lvl_node_size, sizeof(skip_list_node_t *));
	}
	return ret;
}

void skip_list_node_free(skip_list_node_t * node)
{
	if (NULL == node)
		return;

	if (node->free_key)
	{
		node->free_key(node->key);
	}
	if (node->lvl_nodes)
	{
		free(node->lvl_nodes);
	}
	free(node);
}

skip_list_t * skip_list_alloc(uint32_t expect_lvl, skip_list_cmp_node_key_pt cmp_key, skip_list_free_node_key_pt free_key)
{
	skip_list_t *ret = (skip_list_t *)calloc(1, sizeof(skip_list_t));
	ret->expect_lvl = expect_lvl;
	ret->cmp_key = cmp_key;
	ret->free_key = free_key;
	ret->head = skip_list_node_alloc(NULL, NULL, ret->expect_lvl * 2, NULL);
	ret->tail = skip_list_node_alloc(NULL, NULL, ret->expect_lvl * 2, NULL);
	return ret;
}

void skip_list_free(skip_list_t * list)
{
	if (NULL == list)
		return;

	skip_list_node_t *p = list->tail;
	while (p)
	{
		p = p->back_node;
		skip_list_node_free(p);
	}
	skip_list_node_free(list->tail);
	skip_list_node_free(list->head);
	free(list);
}

skip_list_node_t * skip_list_insert(skip_list_t * list, void * key, void * data)
{
	return nullptr;
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
