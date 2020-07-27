﻿using System.Collections.Generic;
using UnityEngine;
using Utopia;

namespace Utopia.Resource
{
    class ResourceRefMonitorMono : MonoBehaviour
    {
        protected ResourceState resState;
        public int setOperaSeq { get; protected set; }

        private void Awake()
        {
            setOperaSeq = 0;
        }

        public int NextSetOperaSeq()
        {
            ++ setOperaSeq;
            return setOperaSeq;
        }

        private void OnDestroy()
        {
            SetResourceState(null);
        }

        public void SetResourceState(ResourceState newResState)
        {
            if (null != newResState)
            {
                newResState.AddRef();
            }
            if (null != resState)
            {
                resState.SubRef();
            }
            resState = newResState;
        }
    }
    class ResourceRefMonitorMono<T, R> : ResourceRefMonitorMono where T : Component where R : Object
    {
        protected static int Set<RT>(T component, string assetPath, 
            System.Action<int, ResourceRefMonitorMono, T, R> onEnd, 
            System.Func<UnityEngine.Object, R> convertResToRFun = null) where RT : ResourceRefMonitorMono<T, R>
        {
            var ai = component.GetComponent<RT>();
            if (ai == null)
            {
                ai = component.gameObject.AddComponent<RT>();
            }
            int setOperaSeq = ai.NextSetOperaSeq();
            if (string.IsNullOrEmpty(assetPath))
            {
                if (ai != null)
                {
                    ai.SetResourceState(null);
                }
                onEnd(setOperaSeq, ai, component, null);
            }
            else
            {
                {
                    ResourceLoader.ins.AsyncLoadAsset(assetPath, (string ap, ResourceObserver ob) =>
                    {
                        if (ai.setOperaSeq == setOperaSeq)
                        {
                            R res = null;
                            if (null != ob && ob.isLoaded && null != ob.res)
                            {
                                if (null != convertResToRFun)
                                {
                                    res = convertResToRFun(ob.res);
                                }
                                else
                                {
                                    res = ob.res as R;
                                }
                            }
                            if (null != ob && null != res)
                            {
                                ai.SetResourceState(ob.resState);
                                onEnd(setOperaSeq, ai, component, res);
                            }
                            else
                            {
                                ai.SetResourceState(null);
                                onEnd(setOperaSeq, ai, component, null);
                            }
                        }
                        ob.Release();
                    });
                }
            }
            return setOperaSeq;
        }
    }
}