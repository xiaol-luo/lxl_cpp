
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
                    rtData.refAssets.Add(path);
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
                    rtData.refAssets.Add(path);
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
                    rtData.refAssets.Remove(path);
                    if (rtData.refAssets.Count <= 0)
                    {
                        this.CheckUnloadLater();
                    }
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
                }
            }
            return rtData;
        }


        protected ulong m_checkUnloadTid = 0;
        protected void CheckUnloadLater()
        {
            if (m_checkUnloadTid <= 0)
            {
                m_checkUnloadTid = Core.ins.timer.Delay(() => {
                    m_checkUnloadTid = 0;
                    List<string> unloadAbs = new List<string>();
                    foreach (var kv in m_bundleRtDataMap)
                    {
                        var rtData = kv.Value;
                        if (rtData.refAssets.Count <= 0)
                        {
                            unloadAbs.Add(kv.Key);
                            // rtData.
                        }
                    }
                    foreach (var abName in unloadAbs)
                    {

                    }
                }, 1.0f);
            }
        }
    }
}

