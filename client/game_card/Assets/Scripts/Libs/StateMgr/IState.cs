
using System;
using UnityEngine;

public abstract class IState<EId>
{
    public IState(IStateMgr<EId> stateMgr, EId id)
    {
        m_stateMgr = stateMgr;
        Id = id;
    }

    public abstract void Enter(object param);
    public abstract void Exit();
    public abstract void Update();
    public abstract void FixedUpdate();

    protected IStateMgr<EId> m_stateMgr;
    public EId Id { get; protected set; }
}
