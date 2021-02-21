using System;
using System.Collections;
using System.Collections.Generic;

namespace Utopia
{
    public class ResourceRequest : UnityEngine.CustomYieldInstruction
    {
        public static ResourceRequest CreateAsyncRequest(IResourceLoaderImpl _loaderImpl, string path, System.Action<ResourceRequest> cb, ulong id)
        {
            ResourceRequest ret = new ResourceRequest();
            ret.loaderImpl = _loaderImpl;
            ret.id = id;
            ret.loadEndCb = cb;
            ret.path = path;
            ret.m_state = RequestState.Inited;
            return ret;
        }

        public static ResourceRequest CreateRequest(IResourceLoaderImpl _loaderImpl, string path, UnityEngine.Object res, ulong id)
        {
            ResourceRequest ret = new ResourceRequest();
            ret.loaderImpl = _loaderImpl;
            ret.id = id;
            ret.path = path;
            ret.res = res;
            ret.m_state = RequestState.Loaded;
            return ret;
        }

        enum RequestState
        {
            Invalid,
            Inited,
            Loading,
            Loaded,
            Fail,
            Unloaded,
        }

        public IResourceLoaderImpl loaderImpl;
        public ulong id;
        public UnityEngine.Object res { get; protected set; }
        public string path { get; protected set; }

        System.Action<ResourceRequest> loadEndCb = null;

        RequestState m_state = RequestState.Invalid;
        public bool isDone {
            get
            {
                bool ret = true;
                switch (m_state)
                {
                    case RequestState.Inited:
                    case RequestState.Loading:
                        ret = false;
                        break;
                }
                return ret;
            }
        }

        public bool isLoaded
        {
            get
            {
                bool ret = RequestState.Loaded == m_state;
                return ret;
            }
        }

        public bool isLoadFail
        {
            get
            {
                bool ret = RequestState.Fail == m_state;
                return ret;
            }
        }

        public bool isUnloaded
        {
            get
            {
                bool ret = RequestState.Unloaded == m_state;
                return ret;
            }
        }

        public override bool keepWaiting
        {
            get
            {
                return !isDone;
            }
        }

        public void AsyncLoadRes()
        {
            loaderImpl.AsyncLoad(path, (string reqPath, UnityEngine.Object res) => {
                AsyncLoadResEndCall(res);
            });
        }
        void AsyncLoadResEndCall(UnityEngine.Object res)
        {
            this.SetRes(res);
        }
        public void Unload()
        {
            if (isDone && !isUnloaded)
            {
                m_state = RequestState.Unloaded;
                res = null;
                loaderImpl.Unload(path);
            }
        }
        public void SetRes(UnityEngine.Object _res)
        {
            if (null != res)
            {
                // ¼õÉÙ¼ÆÊý
                loaderImpl.Unload(path);
            }
            res = _res;
            if (null != res)
                m_state = RequestState.Loaded;
            else
                m_state = RequestState.Fail;
            if (null != loadEndCb)
            {
                loadEndCb(this);
            }
        }

        public void AsyncLoadScene()
        {
            loaderImpl.AsyncLoadScene(path, (string reqPath, bool isSucc) =>
            {
                AsyncLoadSceneEndCall(isSucc);
            });
        }

        protected void AsyncLoadSceneEndCall(bool isSucc)
        {
            if (isSucc)
                m_state = RequestState.Loaded;
            else
                m_state = RequestState.Fail;
            if (null != loadEndCb)
            {
                loadEndCb(this);
            }
        }

        public void UnloadScene()
        {
            if (isDone && !isUnloaded)
            {
                m_state = RequestState.Unloaded;
                res = null;
                loaderImpl.UnloadScene(path);
            }
        }
    }
}

