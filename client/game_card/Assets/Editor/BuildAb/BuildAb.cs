
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public static class BuildAb
{
    public const string Abs_Out_Dir = "Abs";

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
        string outDir = Path.Combine(Application.streamingAssetsPath, Abs_Out_Dir);
        BuildAssetBundleOptions buildOpt = BuildAssetBundleOptions.None;
        BuildTarget buildTarget = BuildTarget.StandaloneWindows;
        List<AssetBundleBuild> buildList = new List<AssetBundleBuild>();

        string dataPathParentDir = Path.GetDirectoryName(Application.dataPath);

        {
            // images
            AssetBundleBuild abd = new AssetBundleBuild();
            abd.assetBundleName = "images";
            List<string> assetNames = new List<string>();

            {
                string assetDir = "Res/UI/Images";
                string absAssetDir = Path.Combine(Application.dataPath, assetDir);
                string fileFormat = "*.png";
                var resFiles = Directory.GetFiles(absAssetDir, fileFormat, SearchOption.AllDirectories);
                foreach (var elem in resFiles)
                {
                    string assetPath = ExtractRelativePath(elem, dataPathParentDir);
                    assetNames.Add(assetPath);
                }
            }

            abd.assetNames = assetNames.ToArray();
            if (abd.assetNames.Length > 0)
            {
                buildList.Add(abd);
            }
        }

        {
            // panels
            AssetBundleBuild abd = new AssetBundleBuild();
            abd.assetBundleName = "panels";
            List<string> assetNames = new List<string>();

            {
                string assetDir = "Res/UI/PanelMgr";
                string absAssetDir = Path.Combine(Application.dataPath, assetDir);
                string fileFormat = "*.prefab";
                var resFiles = Directory.GetFiles(absAssetDir, fileFormat, SearchOption.AllDirectories);
                foreach (var elem in resFiles)
                {
                    string assetPath = ExtractRelativePath(elem, dataPathParentDir);
                    assetNames.Add(assetPath);
                }
            }

            abd.assetNames = assetNames.ToArray();
            if (abd.assetNames.Length > 0)
            {
                buildList.Add(abd);
            }
        }

        {
            // scripts
            AssetBundleBuild abd = new AssetBundleBuild();
            abd.assetBundleName = "scripts";
            List<string> assetNames = new List<string>();

            {
                string assetDir = "Res/lua_script";
                string absAssetDir = Path.Combine(Application.dataPath, assetDir);
                string fileFormat = "*.bytes";
                var resFiles = Directory.GetFiles(absAssetDir, fileFormat, SearchOption.AllDirectories);
                foreach (var elem in resFiles)
                {
                    string assetPath = ExtractRelativePath(elem, dataPathParentDir);
                    assetNames.Add(assetPath);
                }
            }

            abd.assetNames = assetNames.ToArray();
            if (abd.assetNames.Length > 0)
            {
                buildList.Add(abd);
            }
        }

        Directory.CreateDirectory(outDir);
        AssetBundleManifest buildRet = BuildPipeline.BuildAssetBundles(outDir, buildList.ToArray(), buildOpt, buildTarget);
        {
            var allBundles = buildRet.GetAllAssetBundles();
            foreach (var elem in allBundles)
            {
                var abDp = buildRet.GetAllDependencies(elem);
                var abDdp = buildRet.GetAllDependencies(elem);
                var abHash = buildRet.GetAssetBundleHash(elem);
                var xx = abHash;
            }
        }
    }

    [UnityEditor.MenuItem("Tools/AssetBundle/ClearAll", false, 200)]
    public static void ClearAll()
    {

    }
}


