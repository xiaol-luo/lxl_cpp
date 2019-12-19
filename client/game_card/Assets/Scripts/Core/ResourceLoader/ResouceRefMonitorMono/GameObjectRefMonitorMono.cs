using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Utopia.Resource
{
    class GameObjectRefMonitorMono : MonoBehaviour
    {
        ResourceState resState;

        public static void Add(GameObject go, ResourceState resState)
        {
            resState.AddRef();
            GameObjectRefMonitorMono cmp = go.GetComponent<GameObjectRefMonitorMono>();
            if (null == cmp)
            {
                cmp = go.AddComponent<GameObjectRefMonitorMono>();
            }
            if (null != cmp.resState)
            {
                cmp.resState.SubRef();
            }
            cmp.resState = resState;
        }
        private void OnDestroy()
        {
            if (null != gameObject)
            {
                AppLog.Info("OnDestroy {0}", this.gameObject.name);
            }
            if (null != resState)
            {
                resState.SubRef();
            }
        }

        ~GameObjectRefMonitorMono()
        {
            // UnityEngine.GameObject.Find()
            AppLog.Info("~GameObjectRefMonitorMono {0}", this.gameObject.name);
        }
    }
}