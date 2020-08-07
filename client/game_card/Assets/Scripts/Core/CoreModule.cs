
namespace Utopia
{
    public class CoreModule : Utopia.EventMgr
    {
        public enum EStage
        {
            Free,
            Inited,
            Awaking,
            Awaked,
            Updating,
            Releasing,
            Released,
        }
        protected int m_moduleId = EModule.Count;
        public int moduleId { get { return m_moduleId; } }
        public EStage stage { get; set; }
        public enum ERet
        {
            Success,
            Fail,
            Pending,
        }
        public struct EModule
        {
            public const int TimerModule = 0;
            public const int NetModule = 1;
            public const int TestModule = 2;
            public const int Count = 3;
        }

        public Core core { get; }

        public CoreModule(Core _core, int moduleId)
        {
            core = _core;
            m_moduleId = moduleId;
        }

        delegate ERet FnToCall();
        ERet CallUtil(EStage fromStage, EStage toStage, FnToCall fn)
        {
            if (toStage == stage)
                return ERet.Success;
            if (fromStage != stage)
                return ERet.Fail;
            ERet ret = fn();
            if (ERet.Success == ret)
                stage = toStage;
            return ret;
        }

        public void Init()
        {
            if (EStage.Free == stage)
            {
                this.OnInit();
                stage = EStage.Inited;
            }
        }
        public ERet Awake()
        {
            ERet ret = CallUtil(EStage.Awaking, EStage.Awaked, this.OnAwake);
            return ret;
        }
        public void Update()
        {
            if (EStage.Updating != stage)
                return;
            this.OnUpdate();
        }
        public ERet Release()
        {
            ERet ret = CallUtil(EStage.Releasing, EStage.Released, this.OnRelease);
            return ret;
        }

        protected virtual void OnInit() { }
        protected virtual ERet OnAwake() { return ERet.Success; }
        protected virtual void OnUpdate() { }
        protected virtual ERet OnRelease() { return ERet.Success; }
    }
}
