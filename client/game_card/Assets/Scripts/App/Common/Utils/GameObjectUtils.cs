using System.Collections.Generic;
using UnityEngine;

public static class GameObjectUtils
{
    public static void MakeTravelAwake(GameObject go)
    {
        if (null == go)
            return;

        List<Transform> hidedNodes = new List<Transform>();
        Queue<Transform> waitVisitNodes = new Queue<Transform>();
        waitVisitNodes.Enqueue(go.transform);
        while(waitVisitNodes.Count > 0)
        {
            Transform ts = waitVisitNodes.Dequeue();
            if (!ts.gameObject.activeSelf)
            {
                hidedNodes.Add(ts);
                ts.gameObject.SetActive(true);
            }
            for (int i = 0; i < ts.childCount; ++ i)
            {
                Transform childTs = ts.GetChild(i);
                waitVisitNodes.Enqueue(childTs);
            }
        }
        foreach (Transform ts in hidedNodes)
        {
            ts.gameObject.SetActive(false);
        }
    }
}