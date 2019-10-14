
namespace Utopia
{
    public class AppStateMgr : StateMgr<EAppState, AppStateBase>
    {
        public App app { get; protected set; }
        public AppStateMgr(App _app)
        {
            app = _app;
            this.AddState(new AppStateInit(this));
            this.AddState(new AppStateMainLogic(this));
            this.AddState(new AppStateWaitTask(this));
            this.AddState(new AppStateQuit(this));
        }
    }
}

