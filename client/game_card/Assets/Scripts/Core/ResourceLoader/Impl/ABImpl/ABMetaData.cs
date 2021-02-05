using Newtonsoft.Json;
using System.Collections.Generic;
using System.IO;
using UnityEngine;


namespace Utopia
{
    public static class AssetBundleHelp
    {
        public const string Abs_Out_Dir = "Abs";
        public const string Asset_Bundle_Meta_Data_Name = "ab_meta_data.json";


        public static Dictionary<string, AssetBundleMetaData> LoadMetaDatas()
        {
            Dictionary<string, AssetBundleMetaData> ret = null;

            string metaFilePath = Path.Combine(Application.streamingAssetsPath, Path.Combine(Abs_Out_Dir, Asset_Bundle_Meta_Data_Name));
            if (File.Exists(metaFilePath))
            {
                string allTxt = File.ReadAllText(metaFilePath);
                ret = JsonConvert.DeserializeObject<Dictionary<string, AssetBundleMetaData>>(allTxt);
            }
            return ret;
        }
    }

    public class AssetBundleMetaData
    {
        public string bundleName;
        public string hash;
        public List<string> assetNames = new List<string>();
        public List<string> dependencies = new List<string>();
    }

    public class AssetBundleRunTimeData
    {
        public AssetBundleMetaData metaData;
        public AssetBundle assetBundle;
        public HashSet<string> refAssets = new HashSet<string>();
        
    }
}


