
using System;
using System.Collections.Generic;
using UnityEngine.SceneManagement;

namespace Utopia
{
    public class ResourceLoaderProxy
    {
        public static ResourceLoaderProxy Create()
        {
            return new ResourceLoaderProxy(ResourceLoader.ins);
        }

        ResourceLoader m_loader;
        public ResourceLoaderProxy(ResourceLoader _loader)
        {
            m_loader = _loader;
        }

        Dictionary<string, ResourceObserver> m_resObservers = new Dictionary<string, ResourceObserver>();

        protected ResourceObserver GetResObserver(string path)
        {
            ResourceObserver ret = null;
            m_resObservers.TryGetValue(path, out ret);
            if (null != ret && !ret.isValid)
            {
                m_resObservers.Remove(path);
                ret = null;
            }
            return ret;
        }
        public ResourceObserver GetLoadedResObserver(string path)
        {
            ResourceObserver resState = this.GetResObserver(path);
            if (null == resState || !resState.isLoaded)
                return null;
            return resState;
        }
        public ResourceObserver LoadAsset(string path)
        {
            ResourceObserver ret = this.GetLoadedResObserver(path);
            if (null == ret)
            {
                ret = m_loader.LoadAsset(path);
                if (null != ret && ret.isValid && null == GetResObserver(path))
                {
                    m_resObservers.Add(ret.path, ret);
                }
                else
                {
                    if(null != ret)
                    {
                        ret.Release();
                    }
                    ret = this.GetLoadedResObserver(path);
                }
            }
            return ret;
        }
        public ResourceObserver AsyncLoadAsset(string path, System.Action<string, ResourceObserver> cb)
        {
            ResourceObserver ret = this.GetLoadedResObserver(path);
            if (null == ret)
            {
                ret = m_loader.AsyncLoadAsset(path, (string resPath, ResourceObserver resOb) => {
                    if (null == this.GetResObserver(path) && null != ret && ret.isValid)
                    {
                        m_resObservers.Add(ret.path, ret);
                    }
                    else
                    {
                        if (null != ret)
                        {
                            ret.Release();
                        }
                    }
                    if (null != cb)
                    {
                        cb(resPath, resOb);
                    }
                });
            }
            else
            {
                if (null != cb)
                {
                    Core.ins.timer.Delay(() => {
                        cb(path, ret);
                    }, 0);
                }
            }
            return ret;
        }
        public ResourceObserver CoLoadAsset(string path)
        {
            ResourceObserver ret = this.GetResObserver(path);
            if (null == ret)
            {
                ret = m_loader.CoLoadAsset(path);
                m_resObservers.Add(ret.path, ret);

            }
            return ret;
        }
        public void UnloadAsset(string path)
        {
            var ob = this.GetResObserver(path);
            if (null != ob && ob.isValid)
            {
                m_resObservers.Remove(path);
                ob.Release();
            }
        }

        public void Release()
        {
            foreach (ResourceObserver ob in m_resObservers.Values)
            {
                ob.Release();
            }
            m_resObservers.Clear();
        }

        public void AsyncLoadScene(string path, bool isAddition, System.Action<string, ResourceScene.LoadResult> cb)
        {
            m_loader.AsyncLoadScene(path, isAddition, cb);
        }

        public bool LoadScene(string path, bool isAddition)
        {
            bool ret = m_loader.LoadScene(path, isAddition);
            return ret;
        }
        public ResourceScene CoLoadScene(string path, bool isAddition)
        {
            ResourceScene ret = m_loader.CoLoadScene(path, isAddition);
            return ret;
        }
        public void UnloadScene(string path)
        {
            m_loader.UnloadScene(path);
        }
    }
}