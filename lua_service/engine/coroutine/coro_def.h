#pragma once

#include <functional>
#include <memory>
#include <vector>

class ICoroVar : public std::enable_shared_from_this<ICoroVar>
{
public:
	virtual ~ICoroVar()
	{
		this->Release();
	}
	virtual void Release() = 0;
};

class CommonCoroVar : public ICoroVar
{
public:
	using Release_Fn = std::function<void(void **)>;
	CommonCoroVar(void **data, Release_Fn release_fn) 
	{
		m_data = data;
		m_release_fn = release_fn;
	}

	virtual void Release() override
	{
		if (m_release_fn && m_data)
		{
			m_release_fn(m_data);
		}
	}

	template<typename T> 
	T GetData()
	{
		return static_cast<T>(m_data);
	}

protected:
	void **m_data = nullptr;
	Release_Fn m_release_fn = nullptr;
};

struct CoroOpRet
{
	CoroOpRet() {}
	CoroOpRet(int _error_num, std::shared_ptr<ICoroVar> _ret) 
	{
		error_num = _error_num;
		ret = _ret;
	}
	int error_num = 0;
	std::shared_ptr<ICoroVar> ret = nullptr;
};

using Coro_Create_Fn_Void_Void = std::function<void(void)>;
using Coro_Create_Fn_Var_Void = std::function<std::shared_ptr<ICoroVar>(void)>;
using Coro_Create_Fn_Var_Var = std::function<std::shared_ptr<ICoroVar>(std::shared_ptr<ICoroVar>)>;