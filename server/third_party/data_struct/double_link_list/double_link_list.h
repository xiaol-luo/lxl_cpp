#ifndef __DOUBLE_LINK_LIST__
#define __DOUBLE_LINK_LIST__

#include <stdint.h>

#ifdef _cplusplus
extern "C" {
#endif

	typedef bool(*double_link_list_eq_cmp_data_pt)(void *a, void *b);
	typedef void(*double_link_list_free_data_pt)(void *data);

	typedef struct double_link_list_node_s double_link_list_node_t;
	typedef struct double_link_list_s double_link_list_t;

	struct double_link_list_node_s
	{
		double_link_list_node_t *prev;
		double_link_list_node_t *next;
		double_link_list_t *list;
		void *data;
		double_link_list_free_data_pt free_data_fn;
	};

	struct double_link_list_s
	{
		double_link_list_node_t *head;
		double_link_list_node_t *tail;
		double_link_list_eq_cmp_data_pt eq_cmp_data_fn;
	};

	double_link_list_t * double_link_list_alloc(double_link_list_eq_cmp_data_pt eq_cmp_data_fn);
	void double_link_list_free(double_link_list_t *list, double_link_list_free_data_pt free_data_fn);
	void double_link_list_clear(double_link_list_t *list, double_link_list_free_data_pt free_data_fn);
	double_link_list_node_t * double_link_list_find(double_link_list_t *list, void *data);
	double_link_list_node_t * double_link_list_insert(double_link_list_t *list, void *data);
	double_link_list_node_t * double_link_list_append(double_link_list_t *list, void *data);
	double_link_list_node_t * double_link_list_insert_before(double_link_list_node_t *node, void *data);
	double_link_list_node_t * double_link_list_insert_after(double_link_list_node_t *node, void *data);
	bool double_link_list_remove_node(double_link_list_node_t *node);
	bool double_link_list_remove_data(double_link_list_t *list, void *data);
	bool double_link_list_is_empty(double_link_list_t *list);

	double_link_list_node_t * double_link_node_alloc(void *data);
	void double_link_node_free(double_link_list_node_t *node);

#ifdef _cplusplus
}
#endif

#endif // !__DOUBLE_LINK_LIST__
