
using Newtonsoft.Json;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using Utopia;
using System.Xml;

public static class BuildAb
{
    public static string ExtractRelativePath(string absPath, string absPrefixPath)
    {
        string tmpAbsPath = absPath.Replace("\\", "/");
        string tmpAbsPrefixPath = absPrefixPath.Replace("\\", "/");
        string ret = tmpAbsPath;
        if (tmpAbsPath.StartsWith(tmpAbsPrefixPath))
        {
            ret = tmpAbsPath.Substring(tmpAbsPrefixPath.Length + 1);
            ret.TrimStart('/');
        }
        return ret;
    }

    [UnityEditor.MenuItem("Tools/AssetBundle/Copy Lua Script", false, 200)]
    public static void CopyLuaScript()
    {
        {
            string assetDir = "Res/lua_script";
            string absAssetDir = Path.Combine(Application.dataPath, assetDir);

            {
                string scriptSubDir = "LuaScriptServer";
                string fromDir = Path.Combine(Application.dataPath, string.Format("../{0}", scriptSubDir));
                fromDir = Path.GetFullPath(fromDir);
                string toDir = Path.Combine(absAssetDir, scriptSubDir);
                var scriptFiles = Directory.GetFiles(fromDir, "*.lua", SearchOption.AllDirectories);
                foreach (var elem in scriptFiles)
                {
                    string relativePath = ExtractRelativePath(elem, fromDir);
                    string toPath = Path.Combine(toDir, string.Format("{0}.bytes", relativePath));
                    if (File.Exists(toPath))
                        File.Delete(toPath);
                    Directory.CreateDirectory(Path.GetDirectoryName(toPath));
                    File.Copy(elem, toPath);
                }
            }

            {
                string scriptSubDir = "LuaScript";
                string fromDir = Path.Combine(Application.dataPath, string.Format("../{0}", scriptSubDir));
                fromDir = Path.GetFullPath(fromDir);
                string toDir = Path.Combine(absAssetDir, scriptSubDir);
                var scriptFiles = Directory.GetFiles(fromDir, "*.lua", SearchOption.AllDirectories);
                foreach (var elem in scriptFiles)
                {
                    string relativePath = ExtractRelativePath(elem, fromDir);
                    string toPath = Path.Combine(toDir, string.Format("{0}.bytes", relativePath));
                    if (File.Exists(toPath))
                        File.Delete(toPath);
                    Directory.CreateDirectory(Path.GetDirectoryName(toPath));
                    File.Copy(elem, toPath);
                }
            }
        }
    }

    [UnityEditor.MenuItem("Tools/AssetBundle/Build Win", false, 200)]
    public static void BuildWin()
    {
        string outDir = Path.Combine(Application.streamingAssetsPath, AssetBundleHelp.Abs_Out_Dir);
        BuildAssetBundleOptions buildOpt = BuildAssetBundleOptions.None;
        BuildTarget buildTarget = BuildTarget.StandaloneWindows;
        List<AssetBundleBuild> buildList = new List<AssetBundleBuild>();

        string dataPathParentDir = Path.GetDirectoryName(Application.dataPath);

        BuildAssetBundleSetting babs = BuildAssetBundleSetting.ParseFile(BuildAssetBundleSetting.GetDefaultSettingFilePath());
        foreach (var setting in babs.bundleSettingMap.Values)
        {
            HashSet<string> assetNames = new HashSet<string>();

            {
                string absAssetDir = Path.Combine(Application.dataPath, setting.src);
                foreach (string fileFormat in setting.subfixs)
                {
                    var resFiles = Directory.GetFiles(absAssetDir, fileFormat, SearchOption.AllDirectories);
                    foreach (var elem in resFiles)
                    {
                        string assetPath = ExtractRelativePath(elem, dataPathParentDir);
                        bool needPck = true;
                        if (setting.excludes.TryGetValue(assetPath, out BuildAssetBundleSetting.PathSetting ps))
                        {
                            if (BuildAssetBundleSetting.IsPlatformMatch(ps.platforms))
                            {
                                needPck = false;
                            }
                        }
                        if (needPck)
                        {
                            assetNames.Add(assetPath);
                        }
                    }
                }
            }
            {
                foreach (var ps in setting.includes.Values)
                {
                    if (BuildAssetBundleSetting.IsPlatformMatch(ps.platforms))
                    {
                        assetNames.Add(ps.val);
                    }
                }
            }

            AssetBundleBuild abd = new AssetBundleBuild();
            abd.assetBundleName = setting.name;
            abd.assetNames = new List<string>(assetNames).ToArray();
            if (abd.assetNames.Length > 0)
            {
                buildList.Add(abd);
            }
        }

        Directory.CreateDirectory(outDir);
        AssetBundleManifest buildRet = BuildPipeline.BuildAssetBundles(outDir, buildList.ToArray(), buildOpt, buildTarget);
        {
            Dictionary<string, AssetBundleMetaData> metaDatas = new Dictionary<string, AssetBundleMetaData>();

            var allBundles = buildRet.GetAllAssetBundles();
            foreach (var elem in allBundles)
            {
                var abDp = buildRet.GetAllDependencies(elem);
                var abDdp = buildRet.GetDirectDependencies(elem);
                var abHash = buildRet.GetAssetBundleHash(elem);
                var xx = abHash;

                var metaData = new AssetBundleMetaData();
                metaData.bundleName = elem;
                metaData.hash = abHash.ToString();
                metaData.directDependencies = new List<string>(abDp);
                foreach (var buildInfo in buildList)
                {
                    if (buildInfo.assetBundleName == elem)
                    {
                        metaData.assetNames = new List<string>(buildInfo.assetNames);
                        break;
                    }
                }
                metaDatas.Add(metaData.bundleName, metaData);
            }

            foreach (var kv in metaDatas)
            {
                HashSet<string> dependencies = new HashSet<string>();
                Stack<string> waitCheckDp = new Stack<string>(kv.Value.directDependencies);

                while (waitCheckDp.Count > 0)
                {
                    string dp = waitCheckDp.Pop();
                    if (!dependencies.Contains(dp))
                    {
                        dependencies.Add(dp);
                        if (metaDatas.TryGetValue(dp, out AssetBundleMetaData dbMetaData))
                        {
                            foreach (var relateDp in dbMetaData.directDependencies)
                            {
                                if (!dependencies.Contains(relateDp))
                                {
                                    waitCheckDp.Push(relateDp);
                                }
                            }
                        }
                    }
                }
                dependencies.Remove(kv.Key);
                kv.Value.dependencies = new List<string>(dependencies);
            }


            // var jsonStr = JsonConvert.SerializeObject(new AssetBundleMetaDataMap() { datas = metaDatas }, Formatting.Indented);
            var jsonStr = JsonConvert.SerializeObject(metaDatas, Newtonsoft.Json.Formatting.Indented);
            // jsonStr = jsonStr + jsonStr;
            File.WriteAllText(Path.Combine(outDir, AssetBundleHelp.Asset_Bundle_Meta_Data_Name), jsonStr);
        }
    }

    [UnityEditor.MenuItem("Tools/AssetBundle/ClearAll", false, 200)]
    public static void ClearAll()
    {
    }

    public class BuildAssetBundleSetting
    {
        public static string GetDefaultSettingFilePath()
        {
            return Path.Combine(Application.dataPath, "Editor/BuildAb/ab_setting.xml");
        }

        public static BuildAssetBundleSetting ParseFile(string filePath)
        {
            string content = File.ReadAllText(filePath);
            return Parse(content);
        }

        public static BuildAssetBundleSetting Parse(string content)
        {
            BuildAssetBundleSetting ret = new BuildAssetBundleSetting();
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(content);
            XmlNodeList xmlBundles = doc.DocumentElement.SelectNodes("/xml/bundles/bundle");
            foreach (XmlNode xmlBundle in xmlBundles)
            {
                BundleSetting bs = new BundleSetting();
                bs.name = xmlBundle.Attributes.GetNamedItem("name").Value;
                bs.src = xmlBundle.Attributes.GetNamedItem("src").Value;
                bs.subfixs = ParseSubfixStr(xmlBundle.Attributes.GetNamedItem("subfix").Value);
                bs.platforms = ParsePlatformStr(xmlBundle.Attributes.GetNamedItem("platform").Value);
                {
                    var nodes = xmlBundle.SelectNodes("includes/elem");
                    foreach (XmlNode elem in nodes)
                    {
                        PathSetting ps = new PathSetting();
                        ps.val = Path.Combine(bs.src, elem.InnerText).Replace("\\", "/");
                        ps.platforms = ParsePlatformStr(elem.Attributes.GetNamedItem("platform").Value);
                        bs.includes.Add(ps.val, ps);
                    }
                }
                {
                    var nodes = xmlBundle.SelectNodes("excludes/elem");
                    foreach (XmlNode elem in nodes)
                    {
                        PathSetting ps = new PathSetting();
                        ps.val = Path.Combine(bs.src, elem.InnerText).Replace("\\", "/");
                        ps.platforms = ParsePlatformStr(elem.Attributes.GetNamedItem("platform").Value);
                        bs.excludes.Add(ps.val, ps);
                    }
                }


                Debug.Assert(!ret.bundleSettingMap.ContainsKey(bs.name));
                ret.bundleSettingMap.Add(bs.name, bs);
            }
            return ret;
        }

        public static HashSet<string> ParsePlatformStr(string str)
        {
            var ret = new HashSet<string>();
            foreach (string val in str.Split('|'))
            {
                switch (val)
                {
                    case "*":
                        ret.Add(Utopia.SystemInfo.Platform_Name_Stand_Alone);
                        ret.Add(Utopia.SystemInfo.Platform_Name_Stand_Iphone);
                        ret.Add(Utopia.SystemInfo.Platform_Name_Stand_Android);
                        break;
                    case "android":
                        ret.Add(Utopia.SystemInfo.Platform_Name_Stand_Android);
                        break;
                    case "ios":
                        ret.Add(Utopia.SystemInfo.Platform_Name_Stand_Iphone);
                        break;
                    case "win":
                        ret.Add(Utopia.SystemInfo.Platform_Name_Stand_Alone);
                        break;
                }
            }
            return ret;
        }

        public static bool IsPlatformMatch(HashSet<string> allowPlatforms)
        {
            return allowPlatforms.Contains(Utopia.SystemInfo.PlatformName); 
        }

        public static HashSet<string> ParseSubfixStr(string str)
        {
            var ret = new HashSet<string>(str.Split('|'));
            return ret;
        }

        public class PathSetting
        {
            public string val = "";
            public HashSet<string> platforms = new HashSet<string>();
        }

        public class BundleSetting
        {
            public string name;
            public string src;
            public HashSet<string> subfixs = new HashSet<string>();
            public HashSet<string> platforms = new HashSet<string>();
            public Dictionary<string, PathSetting> includes = new Dictionary<string, PathSetting>();
            public Dictionary<string, PathSetting> excludes = new Dictionary<string, PathSetting>();
        }

        public Dictionary<string, BundleSetting> bundleSettingMap = new Dictionary<string, BundleSetting>();
    }
}


