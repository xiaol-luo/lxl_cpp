using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net;
using UnityEngine;
using AppEventMgr = Utopia.EventMgr<string>;
using AppEventSubscriber = Utopia.EventSubscriber<string>;

namespace Utopia
{
    public partial class Core
    {
        public void ForeachModule(System.Action<CoreModule> _fn)
        {
            System.Action<CoreModule, object, object> fn = (CoreModule module, object p1, object p2) => { _fn(module); };
            foreach (CoreModule module in m_modules)
            {
                fn(module, null, null);
            }
        }
        public void ForeachModule(System.Action<CoreModule, object, object> fn, object inParam, ref object outParam)
        {
            foreach (CoreModule module in m_modules)
            {
                fn(module, inParam, outParam);
            }
        }
        bool ExecuteStageFnUtil(CoreModule.EStage preStage, CoreModule.EStage fromStage, CoreModule.EStage toStage)
        {
            this.currStage = fromStage;

            bool allModuleStageMatch = true;
            ForeachModule((CoreModule module) =>
            {
                if (CoreModule.EStage.Releasing != fromStage)
                    allModuleStageMatch &= (module.stage == preStage);
            });
            if (!allModuleStageMatch)
                return false;

            ForeachModule((CoreModule module) =>
            {
                module.stage = fromStage;
            });

            int failModuleId = CoreModule.EModule.Count;
            while (true)
            {
                bool allReady = true;
                foreach (CoreModule module in m_modules)
                {
                    if (toStage == module.stage)
                        continue;

                    CoreModule.ERet ret = CoreModule.ERet.Fail;
                    switch (fromStage)
                    {
                        case CoreModule.EStage.Awaking:
                            {
                                ret = module.Awake();
                            }
                            break;
                        case CoreModule.EStage.Releasing:
                            {
                                ret = module.Release();
                            }
                            break;
                    }
                    if (CoreModule.ERet.Fail == ret)
                    {
                        failModuleId = module.moduleId;
                        break;
                    }
                    if (toStage != module.stage)
                        allReady = false;
                }
                if (failModuleId != CoreModule.EModule.Count)
                {
                    AppLog.Info("AppModule {0} try from {1} to {2} ", fromStage, toStage, failModuleId);
                    break;
                }
                if (allReady)
                    break;
            }
            bool returnVal = CoreModule.EModule.Count == failModuleId;
            if (returnVal)
                this.currStage = toStage;
            return returnVal;
        }

        public void Awake()
        {
            bool ret = ExecuteStageFnUtil(CoreModule.EStage.Inited, CoreModule.EStage.Awaking, CoreModule.EStage.Awaked);
            if (ret)
            {
                ForeachModule((CoreModule module) =>
                {
                    module.stage = CoreModule.EStage.Updating;
                });
                currStage = CoreModule.EStage.Updating;
            }
            else
            {
                this.Release();
            }
                
        }
        public void Release()
        {
            if (CoreModule.EStage.Releasing != currStage && CoreModule.EStage.Released != currStage)
                ExecuteStageFnUtil(currStage, CoreModule.EStage.Releasing, CoreModule.EStage.Released);
        }

        public void Update()
        {
            foreach (CoreModule module in m_modules)
            {
                module.Update();
            }
        }

        public Coroutine StartCoroutine(IEnumerator ie)
        {
            return root.StartCoroutine(ie);
        }
        public void StopCoroutine(Coroutine co)
        {
            root.StopCoroutine(co);
        }
        public void StopAllCoroutines()
        {
            root.StopAllCoroutines();
        }
    }
}
