#include "double_link_list.h"
#include <stdlib.h>
#include <string.h>

double_link_list_t * double_link_list_alloc(double_link_list_eq_cmp_data_pt eq_cmp_data_fn)
{

	double_link_list_t *list = (double_link_list_t *)calloc(1, sizeof(double_link_list_t));
	list->eq_cmp_data_fn = eq_cmp_data_fn;
	list->head = nullptr;
	list->tail = nullptr;
	return list;
}

void double_link_list_free(double_link_list_t * list, double_link_list_free_data_pt free_data_fn)
{
	if (NULL == list)
		return;

	double_link_list_clear(list, free_data_fn);
	free(list);
}

void double_link_list_clear(double_link_list_t * list, double_link_list_free_data_pt free_data_fn)
{
	if (NULL == list)
		return;

	double_link_list_node_t *node = list->head;
	list->head = NULL;
	list->tail = NULL;

	double_link_list_node_t *next_node = NULL;
	while (NULL != node)
	{
		next_node = node->next;
		if (NULL != free_data_fn)
		{
			free_data_fn(node->data);
		}
		double_link_node_free(node);
		node = next_node;
	}
}

double_link_list_node_t * double_link_list_find(double_link_list_t * list, void * data)
{
	if (NULL == list || NULL == list->head)
		return NULL;

	double_link_list_node_t *node = list->head;
	do 
	{
		if (list->eq_cmp_data_fn(data, node->data))
		{
			break;
		}
		node = node->next;
	} while (NULL != node);
	return node;
}

double_link_list_node_t * double_link_list_insert(double_link_list_t * list, void * data)
{
	if (NULL == list)
		return NULL;

	double_link_list_node_t *node = nullptr;
	if (NULL == list->head)
	{
		node = double_link_node_alloc(data);
		node->list = list;
		list->head = node;
		list->tail = node;
	}
	else
	{
		node = double_link_list_insert_before(list->head, data);
	}
	return node;
}

double_link_list_node_t * double_link_list_append(double_link_list_t * list, void * data)
{
	if (NULL == list)
		return NULL;

	double_link_list_node_t *node = nullptr;
	if (NULL == list->head)
	{
		node = double_link_node_alloc(data);
		node->list = list;
		list->head = node;
		list->tail = node;
	}
	else
	{
		node = double_link_list_insert_after(list->tail, data);
	}
	return node;
}

double_link_list_node_t * double_link_list_insert_before(double_link_list_node_t * node, void * data)
{
	if (NULL == node || NULL == node->list)
		return NULL;

	double_link_list_node_t *new_node = double_link_node_alloc(data);
	new_node->list = node->list;
	new_node->next = node;
	new_node->prev = node->prev;
	node->prev = new_node;

	if (NULL != new_node->prev)
	{
		new_node->prev->next = new_node;
	}
	else
	{
		new_node->list->head = new_node;
	}

	return new_node;
}

double_link_list_node_t * double_link_list_insert_after(double_link_list_node_t * node, void * data)
{
	if (NULL == node || NULL == node->list)
		return NULL;

	double_link_list_node_t *new_node = double_link_node_alloc(data);
	new_node->list = node->list;
	new_node->prev = node;
	new_node->next = node->next;
	node->next = new_node;

	if (NULL != new_node->next)
	{
		new_node->next->prev = new_node;
	}
	else
	{
		new_node->list->tail = new_node;
	}

	return new_node;
}

bool double_link_list_remove_node(double_link_list_node_t * node)
{
	if (NULL == node || NULL == node->list)
		return false;

	if (node->list->head == node)
	{
		node->list->head = node->next;
	}
	if (node->list->tail == node)
	{
		node->list->tail = node->prev;
	}

	if (NULL != node->prev)
	{
		node->prev->next = node->next;
	}
	if (NULL != node->next)
	{
		node->next->prev = node->prev;
	}
	double_link_node_free(node);
	return true;
}

bool double_link_list_remove_data(double_link_list_t * list, void * data)
{
	double_link_list_node_t *node = double_link_list_find(list, data);
	return double_link_list_remove_node(node);
}

bool double_link_list_is_empty(double_link_list_t * list)
{
	return NULL == list || NULL == list->head;
}

double_link_list_node_t * double_link_node_alloc(void * data)
{
	double_link_list_node_t *node = (double_link_list_node_t *)calloc(1, sizeof(double_link_list_node_t));
	node->data = data;
	return node;
}

void double_link_node_free(double_link_list_node_t * node)
{
	if (NULL == node)
		return;

	node->prev = NULL;
	node->next = NULL;
	node->list = NULL;
	free(node);
}
