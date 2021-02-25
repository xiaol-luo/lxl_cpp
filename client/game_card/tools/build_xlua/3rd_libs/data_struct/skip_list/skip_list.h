#ifndef __SKIP_LIST_H__
#define __SKIP_LIST_H__

#include <stdint.h>

#ifdef _cplusplus
extern "C" {
#endif

typedef void(*skip_list_free_node_key_pt)(void *key);
typedef bool(*skip_list_lt_cmp_node_key_pt)(void *a, void *b);

typedef struct skip_list_node_s skip_list_node_t;
struct skip_list_node_s
{
	void *key;
	skip_list_free_node_key_pt free_key;
	void *data;
	skip_list_node_t *back_node;
	uint16_t forward_node_size;
	skip_list_node_t **forward_nodes;
	uint32_t *forward_node_nums;
};

typedef struct skip_list_s skip_list_t;
struct skip_list_s
{
	uint32_t node_count;
	uint16_t expect_n_nodes_make_one_index; // ����ÿn���ڵ㣬��һ������
	uint16_t using_max_lvl;
	skip_list_node_t **_help_trace_nodes;
	uint32_t *_help_trace_node_ranks;
	skip_list_node_t *head;
	skip_list_node_t *tail;
	skip_list_free_node_key_pt free_key;
	skip_list_lt_cmp_node_key_pt lt_cmp_key; // lt_cmp_key(a, b) ==> a < b ? true : false��Լ��С�ķ�ǰ�ߣ����Է���true�� a��b��ǰ��
};

skip_list_node_t * skip_list_node_alloc(void * key, void * data, uint16_t forward_node_size, skip_list_free_node_key_pt free_key);
void skip_list_node_free(skip_list_node_t *node);

skip_list_t * skip_list_alloc(uint16_t expect_lvl, skip_list_lt_cmp_node_key_pt lt_cmp_key, skip_list_free_node_key_pt free_key);
void skip_list_free(skip_list_t *list);
bool skip_list_insert(skip_list_t *list, void *key, void *data);
void * skip_list_remove(skip_list_t *list, void *key);
bool skip_list_find(skip_list_t * list, void * key, void **out_data, uint32_t *rank);
uint32_t skip_list_rank(skip_list_t * list, void *key);

#ifdef _cplusplus
}
#endif


#endif // !__SKIP_LIST_H__
