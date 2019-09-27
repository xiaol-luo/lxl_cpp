
using UnityEngine;

namespace Utopia
{
    public class CoreMain : MonoBehaviour
    {
        void Start()
        {
            AppLog.Init(new ConsoleLogImpl(), null);
            DontDestroyOnLoad(gameObject);
            Core.MakeInstance(this);
            Core.ins.Awake();
        }

        void FixedUpdate()
        {
            Core.ins.Update();
        }

        void OnApplicationQuit()
        {
            Core.ins.Release();
            AppLog.Release();
        }
    }
}
