using System;
using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Utopia
{
    public class ResourceScene : CustomYieldInstruction
    {
        ResourceLoader m_resLoader;
        public ResourceLoader resLoader { get { return m_resLoader; } }

        ResourceState m_resState;
        public ResourceState resState { get { return m_resState; } }
        UnityEngine.Coroutine m_resOperaCo;
        public bool isAddition;

        protected LoadSceneMode loadSceneMode 
        {
            get
            {
                return isAddition ? LoadSceneMode.Additive : LoadSceneMode.Single;
            }
        }

        public enum LoadResult
        {
            Succ,
            Fail,
            Cancel,
        };

        public enum State
        {
            Invalid,
            Inited,
            LoadingAsset,
            LoadingScene,
            Loaded,
            Fail,
            Released,
        }
        State m_state = State.Invalid;
        public State state { get { return m_state; } }

        public bool isDone
        {
            get
            {
                bool ret = true;
                switch (m_state)
                {
                    case State.Inited:
                    case State.LoadingAsset:
                    case State.LoadingScene:
                        ret = false;
                        break;
                }
                return ret;
            }
        }
        public bool isLoading
        {
            get
            {
                bool ret = false;
                switch (m_state)
                {
                    case State.LoadingAsset:
                    case State.LoadingScene:
                        ret = true;
                        break;
                }
                return ret;
            }
        }
        public bool isLoaded
        {
            get
            {
                bool ret = State.Loaded == m_state;
                return ret;
            }
        }

        public bool isLoadFail
        {
            get
            {
                bool ret = State.Fail == m_state;
                return ret;
            }
        }

        public bool isReleased
        {
            get
            {
                bool ret = State.Released == m_state;
                return ret;
            }
        }
        System.Action<string, ResourceScene.LoadResult> m_cb;
        public System.Action<string, ResourceScene.LoadResult> cb { get { return m_cb; } }
        public void SetCb(System.Action<string, ResourceScene.LoadResult> _cb) { m_cb = _cb; }

        public string sceneName
        {
            get
            {
                return resState.path;
            }
        }

        public override bool keepWaiting
        {
            get
            {
                return !isDone;
            }
        }

        public ResourceScene(ResourceState resState)
        {
            m_state = State.Inited;
            m_resState = resState;
            m_resLoader = resState.loader;
        }

        public void SetLoadAssetFail()
        {
            if (State.LoadingAsset == m_state)
            {
                m_state = State.Fail;
                resState.req.Unload();
                if (null != m_cb)
                {
                    m_cb(this.sceneName, LoadResult.Fail);
                    this.SetCb(null);
                }
            }
        }
        public void Release()
        {
            m_state = State.Released;

            if (null != m_cb)
            {
                m_cb(this.sceneName, LoadResult.Cancel);
                this.SetCb(null);
            }
            m_resState.req.UnloadScene();
            if (null != m_resOperaCo)
            {
                Core.ins.StopCoroutine(m_resOperaCo);
                m_resOperaCo = null;
            }

            SceneManager.UnloadSceneAsync(this.sceneName);
        }
        public bool AsyncReloadScene(System.Action<string, ResourceScene.LoadResult> newCb)
        {
            bool ret = false;
            if (this.isLoaded)
            {
                ret = true;
                m_state = State.LoadingScene;
                this.SetCb(newCb);
                SceneManager.UnloadSceneAsync(this.sceneName);
                AsyncOperation resOpera = UnityEngine.SceneManagement.SceneManager.LoadSceneAsync(this.sceneName, this.loadSceneMode);
                m_resOperaCo = Core.ins.StartCoroutine(CoLoadScene(resOpera));
            }
            return ret;
        }
        public bool AsyncLoadScene()
        {
            bool ret = false;
            if (State.LoadingAsset == m_state)
            {
                ret = true;
                m_state = State.LoadingScene;
                AsyncOperation resOpera = UnityEngine.SceneManagement.SceneManager.LoadSceneAsync(this.sceneName, this.loadSceneMode);
                m_resOperaCo = Core.ins.StartCoroutine(CoLoadScene(resOpera));
            }
            return ret;
        }
        IEnumerator CoLoadScene(AsyncOperation resOpera)
        {
            while (true)
            {
                if (null == resOpera || resOpera.isDone)
                    break;
                yield return new WaitForSeconds(0.001f);
            }
            if (null != resOpera && resOpera.isDone)
            {
                m_state = State.Loaded;
                if (null != m_cb)
                {
                    m_cb(this.sceneName, LoadResult.Succ);
                    this.SetCb(null);
                }
            }
            resOpera = null;
            m_resOperaCo = null;
        }

        public bool AsyncLoadAsset()
        {
            bool ret = false;
            if (State.Inited == m_state)
            {
                ret = true;
                m_state = State.LoadingAsset;
                resState.req.AsyncLoadScene();
            }
            return ret;
        }
    }
}