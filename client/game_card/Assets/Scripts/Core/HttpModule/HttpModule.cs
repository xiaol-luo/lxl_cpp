using System;
using System.Collections.Generic;
using System.ComponentModel;
using UnityEngine.Networking;

namespace Utopia
{
    using TimerId = System.UInt64;

    public class HttpModule : CoreModule
    {
        protected class HttpReqestData
        {
            public long operaId;
            public UnityWebRequestAsyncOperation asyncOpera;
            public UnityWebRequest webReq;
            public Action<string/*error*/, byte[]/*bodyContent*/, Dictionary<string, string>/*heads*/> rspCbFn;
        }
            
        protected Dictionary<long, HttpReqestData> m_httpReqDataMap = new Dictionary<long, HttpReqestData>();
        protected long m_lastSeq = 0;

        public HttpModule(Core _app) : base(_app, EModule.HttpModule)
        {
            
        }
        protected override void OnInit()
        {
            base.OnInit();
        }

        protected override ERet OnRelease()
        {
            foreach (long operaId in new List<long>(m_httpReqDataMap.Keys))
            {
                this.Cancel(operaId);
            }
            return base.OnRelease();
        }

        public void Cancel(long operaId)
        {
            HttpReqestData reqData = null;
            if (m_httpReqDataMap.TryGetValue(operaId, out reqData))
            {
                m_httpReqDataMap.Remove(operaId);
                reqData.webReq.Abort();
                reqData.webReq.Dispose();
                reqData.webReq = null;
                reqData.asyncOpera = null;
                reqData.rspCbFn = null;
            }
        }

        public long Get(string url, Action<string/*error*/, byte[]/*bodyContent*/, Dictionary<string, string>/*heads*/> rspCbFn, Dictionary<string, string> heads = null, int timeoutSec = 30)
        {
            UnityWebRequest webReq = new UnityWebRequest(url, UnityWebRequest.kHttpVerbGET);
            webReq.downloadHandler = new DownloadHandlerBuffer();
            webReq.timeout = timeoutSec;
            if (null != heads)
            {
                foreach (var kv in heads)
                {
                    webReq.SetRequestHeader(kv.Key, kv.Value);
                }
            }

            UnityWebRequestAsyncOperation asyncOpera = webReq.SendWebRequest();
            long operaId = this.NextSeq();
            HttpReqestData httpReqData = new HttpReqestData();
            httpReqData.operaId = operaId;
            httpReqData.rspCbFn = rspCbFn;
            httpReqData.asyncOpera = asyncOpera;
            httpReqData.webReq = webReq;
            m_httpReqDataMap[operaId] = httpReqData;
            asyncOpera.completed += (UnityEngine.AsyncOperation rspAsyncOpera) =>
            {
                this.OnHttpRsp(operaId, rspAsyncOpera);
            };
            return operaId;
        }

        protected void OnHttpRsp(long operaId, UnityEngine.AsyncOperation rspAsyncOpera)
        {
            HttpReqestData reqData = null;
            if (!m_httpReqDataMap.TryGetValue(operaId, out reqData))
                return;
            m_httpReqDataMap.Remove(operaId);

            UnityWebRequestAsyncOperation asyn_opera = rspAsyncOpera as UnityWebRequestAsyncOperation;
            if (null != reqData.rspCbFn)
            {
                string errorStr = null;
                Dictionary<string, string> rspHeads = null;
                byte[] rspContent = null;
                if (asyn_opera.webRequest.isNetworkError || asyn_opera.webRequest.isHttpError)
                {
                    errorStr = asyn_opera.webRequest.error;
                }
                else
                {
                    rspHeads = asyn_opera.webRequest.GetResponseHeaders();
                    rspContent = reqData.webReq.downloadHandler.data;
                }
                reqData.rspCbFn(errorStr, rspContent, rspHeads);
            }

            reqData.webReq.Dispose();
            reqData.webReq = null;
            reqData.asyncOpera = null;
            reqData.rspCbFn = null;
        }

        protected long NextSeq()
        {
            m_lastSeq += 1;
            return m_lastSeq;
        }
    }
}

