#pragma once

#include <functional>
#include <memory>
#include <vector>

enum ECoroStatus
{
	ECoroStatus_Dead = 0,
	ECoroStatus_Suspended,
	ECoroStatus_Running,
};

enum ECoroError
{
	ECoroError_None = 0,
	ECoroError_Not_Resumable = 1,
	ECoroError_Not_Yieldable = 2,
	ECoroError_Not_Find = 3,
	ECoroError_Not_Running_Coro = 4,
	ECoroError_Other_Coro_Running = 5,
};

class CoroVarBase : public std::enable_shared_from_this<CoroVarBase>
{
public:
	using Release_Fn = std::function<void(void **)>;
	CoroVarBase(void **data, Release_Fn release_fn) 
	{
		m_data = data;
		m_release_fn = release_fn;
	}

	virtual ~CoroVarBase()
	{
		this->DoRelease();
	}

	virtual void Release()
	{
		this->DoRelease();
	}

	void DoRelease()
	{
		if (m_release_fn && m_data)
		{
			m_release_fn(m_data);
			m_data = nullptr;
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

template <typename T>
class CoroVar : public CoroVarBase
{
public:
	using Release_Fn = std::function<void(T)>;
	CoroVar(T data, Release_Fn fn)
	{

	}
};

struct CoroOpRet
{
	CoroOpRet() {}
	CoroOpRet(ECoroError _error_num, std::shared_ptr<CoroVarBase> _ret)
	{
		error_num = _error_num;
		ret = _ret;
	}
	ECoroError error_num = ECoroError_None;
	std::shared_ptr<CoroVarBase> ret = nullptr;
};

using Coro_Create_Fn_Void_Void = std::function<void(void)>;
using Coro_Create_Fn_Var_Void = std::function<std::shared_ptr<CoroVarBase>(void)>;
using Coro_Create_Fn_Var_Var = std::function<std::shared_ptr<CoroVarBase>(std::shared_ptr<CoroVarBase>)>;