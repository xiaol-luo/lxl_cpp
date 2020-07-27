using System;
using UnityEngine;

public abstract class IStateMgr<EId>
{
    protected abstract IState<EId> GetStateHelp(EId stateId);
    public void ChangeState(EId stateId, object param = null)
    {
        IState<EId> nextState = this.GetStateHelp(stateId);
        if (null == nextState)
        {
            Debug.LogErrorFormat(string.Format("stateId {0} is null", stateId));
            return;
        }

        if (null != m_activeState)
        {
            m_activeState.Exit();
        }
        m_lastState = m_activeState;
        m_activeState = nextState;
        m_activeState.Enter(param);
    }

    public void UpdateState()
    {
        if (null != m_activeState)
            m_activeState.Update();
    }

    public void FixedUpdate()
    {
        if (null != m_activeState)
        {
            m_activeState.FixedUpdate();
        }
    }

    public static EId InvalidID = (EId)Enum.ToObject(typeof(EId), 0);

    public EId activeId
    {
        get
        {
            if (null != m_activeState)
                return m_activeState.Id;
            return InvalidID;
        }
    }
    public EId lastId
    {
        get
        {
            if (null != m_lastState)
                return m_lastState.Id;
            return InvalidID;
        }
    }

    protected IState<EId> m_activeState = null;
    protected IState<EId> m_lastState = null;
}