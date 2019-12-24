using UnityEngine;
using System.Collections;

namespace Utopia.Resource
{
    class AnimatorRATRefMonitorMono : ResourceRefMonitorMono<Animator, RuntimeAnimatorController>
    {
        public static int Set(Animator animator, string assetPath)
        {
            return Set(animator, assetPath, (seq, refMono, a, s) => {
                if (seq == refMono.setOperaSeq)
                {
                    a.runtimeAnimatorController = s;
                }
            });
        }

        public static int Set(Animator animator, string assetPath, System.Action<int, ResourceRefMonitorMono, Animator, RuntimeAnimatorController> onEnd)
        {
            return Set<AnimatorRATRefMonitorMono>(animator, assetPath, onEnd);
        }

        public static IEnumerator CoSet(Animator animator, string assetPath)
        {
            bool isDone = false;
            Set<AnimatorRATRefMonitorMono>(animator, assetPath, (seq, refMono, a, r)=> 
            {
                isDone = true;
                if (seq == refMono.setOperaSeq)
                {
                    a.runtimeAnimatorController = r;
                }
            });
            yield return new WaitUntil(() => { return isDone; });
        }
    }
}