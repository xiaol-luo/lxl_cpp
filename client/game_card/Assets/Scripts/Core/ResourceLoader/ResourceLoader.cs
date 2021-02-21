
using System;
using System.Collections.Generic;
using UnityEngine.SceneManagement;

namespace Utopia
{
    public class ResourceLoader
    {
        static ResourceLoader _ins = null;
        public static ResourceLoader ins
        {
            get
            {
                if (null == _ins)
                    _ins = new ResourceLoader();
                return _ins;
            }
        }
        protected ResourceLoader() {}

#if USE_AB
        IResourceLoaderImpl m_resLoader = new ResourceLoaderImplAB();
#else
        IResourceLoaderImpl m_resLoader = new ResourceLoaderImplEditor();
#endif

        #region Resource

        Dictionary<string, ResourceState> m_resStates = new Dictionary<string, ResourceState>();
        ulong m_lastReqId = 0;
        ulong GenReqId()
        {
            ++m_lastReqId;
            if (m_lastReqId <= 0)
                m_lastReqId = 1;
            return m_lastReqId;
        }

        protected ResourceState GetResState(string path)
        {
            ResourceState ret = null;
            m_resStates.TryGetValue(path, out ret);
            return ret;
        }
        public ResourceState GetLoadedResState(string path)
        {
            ResourceState resState = this.GetResState(path);
            if (null == resState || !resState.isLoaded)
                return null;
            return resState;
        }
        public ResourceObserver LoadAsset(string path)
        {
            ResourceObserver retOb = null;
            ResourceState resState = this.GetResState(path);
            /*
             * resState.req.isLoaded will be loading or isLoaded.
             * if it fail, it will be remove by funciton ResLoadEndCall
             */
            if (null != resState && null != resState.req && resState.req.isLoaded) 
            {
                retOb = resState.AddObserver(null);
            }
            else
            {
                UnityEngine.Object ret = m_resLoader.Load(path);
                if (null != ret)
                {
                    if (null == resState)
                    {
                        resState = new ResourceState(this);
                        ulong reqId = this.GenReqId();
                        resState.req = ResourceRequest.CreateRequest(m_resLoader, path, ret, reqId);
                        m_resStates.Add(path, resState);
                        retOb = resState.AddObserver(null);
                    }
                    else
                    {
                        retOb = resState.AddObserver(null);
                        resState.req.SetRes(ret);
                    }
                }
            }
            return retOb;
        }
        public ResourceObserver AsyncLoadAsset(string path, System.Action<string, ResourceObserver> cb)
        {
            ResourceState resState = this.GetResState(path);
            if (null == resState)
            {
                resState = new ResourceState(this);
                ulong reqId = this.GenReqId();
                resState.req = ResourceRequest.CreateAsyncRequest(m_resLoader, path, this.ResLoadEndCall, reqId);
                m_resStates.Add(path, resState);
                resState.req.AsyncLoadRes();
            }
            else
            {
                // ģ���첽
                Core.ins.timer.Delay(() => { this.ResLoadEndCall(resState.req); }, 0); 
            }
            ResourceObserver ret = resState.AddObserver(cb);
            return ret;
        }
        public ResourceObserver CoLoadAsset(string path)
        {
            ResourceState resState = this.GetResState(path);
            if (null == resState)
            {
                resState = new ResourceState(this);
                ulong reqId = this.GenReqId();
                resState.req = ResourceRequest.CreateAsyncRequest(m_resLoader, path, this.ResLoadEndCall,reqId);
                m_resStates.Add(path, resState);
                resState.req.AsyncLoadRes();
            }
            ResourceObserver ret = resState.AddObserver(null);
            return ret;
        }

        public void RemoveResObserver(ResourceObserver ob)
        {
            if (null != ob && null != ob.resState)
            {
                ob.resState.RemoveObserver(ob.id);
            }
        }

        public void CheckUnloadRes(string path, ulong id)
        {
            ResourceState resState = this.GetResState(path);
            if (null != resState && 
                null != resState.req &&
                resState.req.id == id && 
                resState.req.isDone &&
                resState.observerCount <= 0
                && resState.refCount <= 0)
            {
                m_resStates.Remove(path);
                resState.req.Unload();
                resState.req = null;
            }
        }

        public void ResLoadEndCall(ResourceRequest req)
        {
            ResourceState resState = this.GetResState(req.path);
            if (null != resState && null != resState.req && req.id == resState.req.id)
            {
                foreach (ResourceObserver ob in resState.GetObservers())
                {
                    if (null != ob.cb)
                    {
                        ob.cb(req.path, ob);
                        ob.ResetCb();
                    }
                }
                if (!req.isLoaded)
                {
                    m_resStates.Remove(req.path);
                }
                else
                {
                    this.CheckUnloadRes(req.path, req.id);
                }
            }
            else
            {
                req.Unload();
            }
        }

        #endregion

        #region Scene

        Dictionary<string, ResourceScene> m_resScenes = new Dictionary<string, ResourceScene>();

        ResourceScene GetResScene(string path)
        {
            ResourceScene ret;
            m_resScenes.TryGetValue(path, out ret);
            return ret;
        }
        public void AsyncLoadScene(string path, bool isAddition, System.Action<string, ResourceScene.LoadResult> cb)
        {
            if (!isAddition)
            {
                Dictionary<string, ResourceScene> tmpScens = new Dictionary<string, ResourceScene>(m_resScenes);
                foreach (string item in tmpScens.Keys)
                {
                    if (item == path)
                        continue;
                    this.UnloadScene(item);
                }
            }

            ResourceScene resScene = this.GetResScene(path);
            if (null != resScene) 
            {
                // ������Fail��Released���������Ϊ�����߼������ϰ���Щ�����resScene�Ƴ�m_resScenes
                // ������Inited���������Ϊ���е�resSceneһ�������Ͼ�TryLoadAssset��
                if (resScene.isLoading)
                {
                    // resScene.isAddition = isAddition; // �����Ƿ�����ģ���ʱ������
                    if (null != resScene.cb)
                    {
                        resScene.cb(resScene.sceneName, ResourceScene.LoadResult.Cancel);
                        resScene.SetCb(cb);
                    }
                }
                else if (resScene.isLoaded)
                {
                    resScene.AsyncReloadScene(cb);
                }
            }
            else
            {
                ResourceState resState = new ResourceState(this);
                ulong reqId = this.GenReqId();
                resState.req = ResourceRequest.CreateAsyncRequest(m_resLoader, path, this.ResLoadSceneEndCall, reqId);
                resScene = new ResourceScene(resState);
                resScene.isAddition = isAddition;
                resScene.SetCb(cb);
                m_resScenes.Add(resScene.sceneName, resScene);
                resScene.AsyncLoadAsset();
            }
        }
        public ResourceScene CoLoadScene(string path, bool isAddition)
        {
            if (!isAddition)
            {
                Dictionary<string, ResourceScene> tmpScens = new Dictionary<string, ResourceScene>(m_resScenes);
                foreach (string item in tmpScens.Keys)
                {
                    if (item == path)
                        continue;
                    this.UnloadScene(item);
                }
            }

            ResourceState resState = new ResourceState(this);
            ulong reqId = this.GenReqId();
            resState.req = ResourceRequest.CreateAsyncRequest(m_resLoader, path, this.ResLoadSceneEndCall, reqId);
            ResourceScene resScene = new ResourceScene(resState);
            resScene.AsyncLoadAsset();

            m_resScenes.Add(resScene.sceneName, resScene);
            return resScene;
        }
        public bool LoadScene(string path, bool isAddition)
        {
            ResourceScene resScene = this.GetResScene(path);
            if (null != resScene)
            {
                return resScene.isLoaded;
            }
            else
            {
                if (m_resLoader.LoadScene(path))
                {
                    ResourceState resState = new ResourceState(this);
                    ulong reqId = this.GenReqId();
                    resState.req = ResourceRequest.CreateRequest(m_resLoader, path, null, reqId);
                    resScene = new ResourceScene(resState);
                    resScene.isAddition = isAddition;
                    m_resScenes.Add(resScene.sceneName, resScene);
                    UnityEngine.SceneManagement.SceneManager.LoadScene(path, isAddition ? LoadSceneMode.Additive : LoadSceneMode.Single);
                    return true;
                }
            }
            return false;
        }

        public void UnloadScene(string path)
        {
            ResourceScene resScene = this.GetResScene(path);
            if (null != resScene)
            {
                m_resScenes.Remove(path);
                resScene.Release();
            }
        }
        public void ResLoadSceneEndCall(ResourceRequest req)
        {
            ResourceScene resScene = this.GetResScene(req.path);
            if (null != resScene && null != resScene.resState && 
                null != resScene.resState.req && 
                req.id == resScene.resState.req.id)
            {
                if (!req.isLoaded)
                {
                    resScene.SetLoadAssetFail();
                    m_resScenes.Remove(req.path);
                }
                else
                {
                    resScene.AsyncLoadScene();
                }
            }
            else
            {
                req.UnloadScene();
            }
        }
        #endregion
    }
}