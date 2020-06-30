#ifndef __SKIP_LIST_H__
#define __SKIP_LIST_H__

#include <stdint.h>

#ifdef _cplusplus
extern "C" {
#endif

typedef void(*skip_list_free_node_key_pt)(void *key);
typedef void(*skip_list_cmp_node_key_pt)(void *key);

typedef struct skip_list_node_s skip_list_node_t;
struct skip_list_node_s
{
	void *key;
	skip_list_free_node_key_pt free_key;
	void *data;
	skip_list_node_t *back_node;
	uint32_t lvl_node_size;
	skip_list_node_t **lvl_nodes;
};

typedef struct skip_list_s skip_list_t;
struct skip_list_s
{
	uint32_t expect_lvl;
	uint32_t using_max_lvl;
	skip_list_node_t *head;
	skip_list_node_t *tail;
	skip_list_free_node_key_pt free_key;
	skip_list_cmp_node_key_pt cmp_key;
};

skip_list_node_t * skip_list_node_alloc(void * key, void * data, uint32_t lvl_node_size, skip_list_free_node_key_pt free_key);
void skip_list_node_free(skip_list_node_t *node);

skip_list_t * skip_list_alloc(uint32_t expect_lvl, skip_list_cmp_node_key_pt cmp_key, skip_list_free_node_key_pt free_key);
void skip_list_free(skip_list_t *list);
skip_list_node_t * skip_list_insert(skip_list_t *list, void *key, void *data);
void skip_list_remove(skip_list_t *list, skip_list_node_t *node);
skip_list_node_t * skip_list_find(skip_list_t *list, void *key);
void skip_list_find_key(void *key);


#ifdef _cplusplus
}
#endif


#endif // !__SKIP_LIST_H__
