using UnityEngine;
using UnityEngine.UI;
using System.Collections;

namespace Utopia.Resource
{
    class AudioClipRefMonitorMono : ResourceRefMonitorMono<AudioSource, AudioClip>
    {
        public static int Set(AudioSource image, string assetPath, System.Action<int, ResourceRefMonitorMono, AudioSource, AudioClip> onEnd)
        {
            return Set<AudioClipRefMonitorMono>(image, assetPath, onEnd);
        }

        public static int Set(AudioSource image, string assetPath)
        {
            int setOperaSeq = Set(image, assetPath, (seq, refMono, i, s) =>
            {
                if (seq == refMono.setOperaSeq)
                {
                    i.clip = s;
                }
            });
            return setOperaSeq;
        }

        public static IEnumerator CoSet(AudioSource image, string assetPath)
        {
            bool isDone = false;
            Set<AudioClipRefMonitorMono>(image, assetPath, (seq, refMono, i, s) =>
            {
                isDone = true;
                if (seq == refMono.setOperaSeq)
                {
                    i.clip = s;
                }
            });
            yield return new WaitUntil(() => { return isDone; });
        }
    }
}