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
	CoroVarBase(void *ptr) 
	{
		m_ptr = ptr;
	}

	virtual ~CoroVarBase()
	{
		m_ptr = nullptr;
	}

	virtual void Release()
	{
		m_ptr = nullptr;
	}

	template<typename T> 
	T GetData()
	{
		return static_cast<T>(m_ptr);
	}

protected:
	void *m_ptr = nullptr;
};

template <typename T>
class CoroVar : public CoroVarBase
{
public:
	using Release_Fn = std::function<void(T)>;
	CoroVar(T data, Release_Fn fn) : CoroVarBase((void *)&data)
	{
		m_data = data;
		m_release_fn = fn;
	}

	virtual ~CoroVar()
	{
		this->DoRelease();
	}

	virtual void Release() override
	{
		this->DoRelease();
	}

	void DoRelease()
	{
		if (m_release_fn && m_ptr)
		{
			m_release_fn(m_data);
			m_release_fn = nullptr;
			m_ptr = nullptr;
		}
	}

protected:
	T m_data;
	Release_Fn m_release_fn = nullptr;
};

template <typename T>
class CoroVar<T *> : public CoroVarBase
{
public:
	using Release_Fn = std::function<void(T *)>;
	CoroVar(T *data, Release_Fn fn) : CoroVarBase((void *)data)
	{
		m_data = data;
		m_release_fn = fn;
	}

	virtual ~CoroVar()
	{
		this->DoRelease();
	}

	virtual void Release() override
	{
		this->DoRelease();
	}

	void DoRelease()
	{
		if (m_release_fn && m_ptr)
		{
			m_release_fn(m_data);
			m_release_fn = nullptr;
			m_ptr = nullptr;
		}
	}

protected:
	T *m_data;
	Release_Fn m_release_fn = nullptr;
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