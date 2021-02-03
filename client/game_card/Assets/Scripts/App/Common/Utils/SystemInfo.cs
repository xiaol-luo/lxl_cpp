
using UnityEngine;

namespace Utopia
{
    public static class SystemInfo
    {
        public readonly static string Platform_Name_Stand_Unknown = "unknown";
        public readonly static string Platform_Name_Stand_Alone = "stand_alone";
        public readonly static string Platform_Name_Stand_Iphone = "iphone";
        public readonly static string Platform_Name_Stand_Android = "android";

        public static bool IsEditor
        {
            get
            {
                bool ret = false;
#if UNITY_EDITOR
                ret = true;
#endif
                return ret;
            }
        }

        public static string PlatformName
        {
            get
            {
                string ret = Platform_Name_Stand_Unknown;
#if UNITY_STANDALONE
                ret = Platform_Name_Stand_Alone;
#endif
#if UNITY_IPHONE
            ret = Platform_Name_Stand_Iphone;
#endif
#if UNITY_ANDROID
            ret = Platform_Name_Stand_Android;
#endif
                return ret;
            }
        }

        public static bool IsUseAB()
        {
#if USE_AB
            return true;
#else
            return false;
#endif
        }
    }
}

