#include <stdio.h>

struct Elem
{
	int select_order = -1;
};

void cal_order(int n, int *out_array)
{
	if (nullptr == out_array || n <= 0)
		return;

	Elem *elems = new Elem[n];

	bool is_pick = true;
	int select_order = 0;

	int elem_idx = 0;
	while (select_order < n)
	{
		if (!is_pick)
		{
			is_pick = true;
		}
		else
		{
			Elem &elem = elems[elem_idx];
			if (elem.select_order < 0)
			{
				is_pick = false;
				elem.select_order = select_order;
				++select_order;
			}
		}
		elem_idx = (elem_idx + 1) % n;
	}

	for (int i = 0; i < n; ++i)
	{
		out_array[i] = elems[i].select_order;
	}
	delete[]elems; elems = nullptr;
}

int main(int argc, char **argv)
{
	const int n = 100;
	int out_array[n];
	cal_order(n, out_array);

	printf("n is %d, and orders is \n", n);

	for (int i = 0; i < n; ++i)
	{
		printf("%d \n", out_array[i]);
	}
}
