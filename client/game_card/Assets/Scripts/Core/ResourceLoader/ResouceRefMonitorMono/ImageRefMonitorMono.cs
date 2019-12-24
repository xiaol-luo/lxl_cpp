
using System.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace Utopia.Resource
{
    class ImageRefMonitorMono : ResourceRefMonitorMono<Image, Sprite>
    {
        public static Sprite ConvertResToSprite(UnityEngine.Object res)
        {
            Sprite ret = null;
            if (null != res)
            {
                if (res is Sprite)
                {
                    ret = res as Sprite;
                }
                if (res is Texture2D)
                {
                    Texture2D t = res as Texture2D;
                    ret = Sprite.Create(t, new Rect(0, 0, t.width, t.height), Vector2.zero);
                }
            }
            return ret;
        }

        public static int Set(Image image, string assetPath, System.Action<int, ResourceRefMonitorMono, Image, Sprite> onEnd)
        {
            return Set<ImageRefMonitorMono>(image, assetPath, onEnd, ConvertResToSprite);
        }
        public static int Set(Image image, string assetPath, bool isSetSize = false)
        {
            int setOperaSeq = Set<ImageRefMonitorMono>(image, assetPath, (seq, refMono, i, s) => 
            {
                if (seq == refMono.setOperaSeq)
                {
                    i.sprite = s;
                    if (isSetSize)
                    {
                        i.SetNativeSize();
                    }
                }
            }, ConvertResToSprite);
            return setOperaSeq;
        }
        public static IEnumerator CoSet(Image image, string assetPath, bool isSetSize = false)
        {
            bool isDone = false;
            Set<ImageRefMonitorMono>(image, assetPath, (seq, refMono, i, s) =>
            {
                isDone = true;
                if (seq == refMono.setOperaSeq)
                {
                    i.sprite = s;
                    if (isSetSize)
                        i.SetNativeSize();
                }
            }, ConvertResToSprite);
            yield return new WaitUntil(() => { return isDone; });
        }
    }
}