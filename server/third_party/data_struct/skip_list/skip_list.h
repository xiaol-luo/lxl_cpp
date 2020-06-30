#ifndef __SKIP_LIST_H__
#define __SKIP_LIST_H__

#include <stdint.h>

#ifdef _cplusplus
extern "C" {
#endif

typedef void(*skip_list_free_node_key_pt)(void *key);
typedef bool(*skip_list_cmp_node_key_pt)(void *a, void *b);

typedef struct skip_list_node_s skip_list_node_t;
struct skip_list_node_s
{
	void *key;
	skip_list_free_node_key_pt free_key;
	void *data;
	skip_list_node_t *back_node;
	uint16_t forward_node_size;
	skip_list_node_t **forward_nodes;
};

typedef struct skip_list_s skip_list_t;
struct skip_list_s
{
	uint16_t expect_lvl;
	uint16_t using_max_lvl;
	skip_list_node_t **_help_trace_less_nodes;
	skip_list_node_t *head;
	skip_list_node_t *tail;
	skip_list_free_node_key_pt free_key;
	skip_list_cmp_node_key_pt cmp_key; // cmp_key(a, b), return true a在前， 否则b在前
};

skip_list_node_t * skip_list_node_alloc(void * key, void * data, uint16_t forward_node_size, skip_list_free_node_key_pt free_key);
void skip_list_node_free(skip_list_node_t *node);

skip_list_t * skip_list_alloc(uint16_t expect_lvl, skip_list_cmp_node_key_pt cmp_key, skip_list_free_node_key_pt free_key);
void skip_list_free(skip_list_t *list);
skip_list_node_t * skip_list_insert(skip_list_t *list, void *key, void *data);
void skip_list_remove(skip_list_t *list, skip_list_node_t *node);
skip_list_node_t * skip_list_find(skip_list_t *list, void *key);
void skip_list_find_key(void *key);


#ifdef _cplusplus
}
#endif


#endif // !__SKIP_LIST_H__
