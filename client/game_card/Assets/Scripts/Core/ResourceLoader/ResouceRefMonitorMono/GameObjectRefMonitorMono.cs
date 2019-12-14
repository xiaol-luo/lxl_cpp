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
            resState.SubRef();
        }
    }
}