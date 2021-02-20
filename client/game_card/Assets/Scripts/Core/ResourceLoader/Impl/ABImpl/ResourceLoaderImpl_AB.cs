
using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace Utopia
{

    public class ResourceLoaderImplAB : IResourceLoaderImpl
    {
        Dictionary<string, AssetBundleMetaData> m_metaDataMap = null;

        Dictionary<string, AssetBundleMetaData> m_assetToBundleMap = new Dictionary<string, AssetBundleMetaData>();

        Dictionary<string, AssetBundleRunTimeData> m_bundleRtDataMap = new Dictionary<string, AssetBundleRunTimeData>();

        public ResourceLoaderImplAB()
        {
            m_metaDataMap = AssetBundleHelp.LoadMetaDatas();
            foreach (var kv in m_metaDataMap)
            {
                foreach (var asset in kv.Value.assetNames)
                {
                    m_assetToBundleMap[asset] = kv.Value;
                }
            }
        }

        public void AsyncLoad(string path, Action<string, UnityEngine.Object> cb)
        {
            bool isOk = false;
            if (m_assetToBundleMap.TryGetValue(path, out AssetBundleMetaData abMeta))
            {
                AssetBundleRunTimeData rtData = this.GetAssetBundleRtData(abMeta.bundleName, true);
                if (null != rtData)
                {
                    HandleAssetAddRef(rtData, path);

                    var op = rtData.assetBundle.LoadAssetAsync(path);
                    op.completed += (AsyncOperation _req) =>
                    {
                        AssetBundleRequest req = _req as AssetBundleRequest;
                        if (null != cb)
                        {
                            cb(path, req.asset);
                        }
                        if (null == req.asset)
                        {
                            this.Unload(path);
                        }
                    };
                    isOk = true;
                }
            }

            if (!isOk)
            {
                Core.ins.timer.Delay(() =>
                {
                    cb(path, null);
                }, 0);
            }
        }

        public void AsyncLoadScene(string path, Action<string, bool> cb)
        {

        }

        public UnityEngine.Object Load(string path)
        {
            UnityEngine.Object ret = null;
            AssetBundleMetaData abMeta = null;
            if (m_assetToBundleMap.TryGetValue(path, out abMeta))
            {
                AssetBundleRunTimeData rtData = this.GetAssetBundleRtData(abMeta.bundleName, true);
                if (null != rtData)
                {
                    HandleAssetAddRef(rtData, path);
                    ret = rtData.assetBundle.LoadAsset(path);
                }
            }
            return ret;
        }

        public bool LoadScene(string path)
        {
            throw new NotImplementedException();
        }

        public void Unload(string path)
        {
            if (m_assetToBundleMap.TryGetValue(path, out AssetBundleMetaData abMeta))
            {
                var rtData = this.GetAssetBundleRtData(abMeta.bundleName, false);
                if (null != rtData && rtData.refAssets.Contains(path))
                {
                    HandleAssetSubRef(rtData, path);
                }
            }
        }

        public void UnloadScene(string path)
        {
            throw new NotImplementedException();
        }

        protected AssetBundleRunTimeData GetAssetBundleRtData(string bundleName, bool createWhenMiss)
        {
            AssetBundleRunTimeData rtData = null;

            if (m_metaDataMap.TryGetValue(bundleName, out AssetBundleMetaData abMeta))
            {
                if (!m_bundleRtDataMap.TryGetValue(abMeta.bundleName, out rtData) && createWhenMiss)
                {
                    rtData = new AssetBundleRunTimeData();
                    rtData.metaData = abMeta;
                    var filePath = Path.Combine(Application.streamingAssetsPath, Path.Combine(Utopia.AssetBundleHelp.Abs_Out_Dir, abMeta.bundleName));
                    var fileContent = File.ReadAllBytes(filePath);
                    rtData.assetBundle = AssetBundle.LoadFromMemory(fileContent);
                    m_bundleRtDataMap[abMeta.bundleName] = rtData;
                    // 可能需要些错误提示
                    foreach (string dpAbName in abMeta.directDependencies)
                    {
                        this.GetAssetBundleRtData(dpAbName, true);
                    }
                }
            }
            return rtData;
        }


        protected ulong m_checkUnloadTid = 0;
        protected void CheckUnloadLater()
        {
#if !UNITY_EDITOR
            if (m_checkUnloadTid <= 0)
            {
                m_checkUnloadTid = Core.ins.timer.Delay(() => {
#endif

                    m_checkUnloadTid = 0;
                    List<string> unloadAbs = new List<string>();
                    foreach (var kv in m_bundleRtDataMap)
                    {
                        var rtData = kv.Value;
                        if (rtData.refAssets.Count <= 0 && rtData.refBundle.Count <= 0)
                        {
                            unloadAbs.Add(kv.Key);
                            // rtData.
                        }
                    }
                    foreach (var abName in unloadAbs)
                    {
                        if (m_bundleRtDataMap.TryGetValue(abName, out AssetBundleRunTimeData rtData))
                        {
                            rtData.assetBundle.Unload(true);
                        }
                        m_bundleRtDataMap.Remove(abName);

                    }

                    // Resources.UnloadUnusedAssets()
#if !UNITY_EDITOR
                }, 1.0f);
            }
#endif
        }

        protected void HandleAssetAddRef(AssetBundleRunTimeData rtData, string path)
        {
            int oldCount = rtData.refAssets.Count;
            rtData.refAssets.Add(path);
            if (oldCount <= 0)
            {
                foreach (string dp in  rtData.metaData.dependencies)
                {
                    var dpRtData = this.GetAssetBundleRtData(dp, false);
                    if (null != dpRtData)
                    {
                        dpRtData.refBundle.Add(rtData.metaData.bundleName);
                    }
                }
            }
        }

        protected void HandleAssetSubRef(AssetBundleRunTimeData rtData, string path)
        {
            rtData.refAssets.Remove(path);
            if (rtData.refAssets.Count <= 0)
            {
                foreach (string dp in rtData.metaData.dependencies)
                {
                    var dpRtData = this.GetAssetBundleRtData(dp, false);
                    if (null != dpRtData)
                    {
                        dpRtData.refBundle.Remove(rtData.metaData.bundleName);
                    }
                }
                this.CheckUnloadLater();
            }
        }
    }
}

