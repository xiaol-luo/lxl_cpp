
namespace Utopia
{
    public enum EAppState
    {
        Invalid = 0,
        Init, // 各种初始化
        MainLogic, // 运行主逻辑
        Quit, // 退出
        WaitTask, // 等待任务

        Count,
    }

    public class AppStateBase : IState<EAppState>
    {
        public AppStateMgr stateMgr { get; protected set; }
        public AppStateBase() : base(null, 0) { }
        public AppStateBase(AppStateMgr _stateMgr, EAppState id) : base(_stateMgr, id)
        {
            stateMgr = _stateMgr;
        }
        public override void Enter(object param)
        {
        }

        public override void Exit()
        {
        }

        public override void Update()
        {
        }
    }
}

