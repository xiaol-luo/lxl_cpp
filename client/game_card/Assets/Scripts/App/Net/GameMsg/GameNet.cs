using System;
using XLua;

namespace Utopia
{
    public class GameNet
    {
        GameMsgNetAgentHandler m_msgHandler = null;
        ulong m_netAgentId = 0;
        MsgNetAgent m_netAgent = null;
        Action<bool> m_openCb = null;
        Action<int, string> m_closeCb = null;
        Action<int, byte[], int, int> m_recvMsgCb = null;
        AppEventSubscriber m_netModuleSubcriber = null;

        public GameNet()
        {
            m_netAgent = new MsgNetAgent();
            m_msgHandler = new GameMsgNetAgentHandler(this);
            m_netAgent.SetHandler(m_msgHandler);
            m_netModuleSubcriber = App.ins.net.CreateEventSubcriber();
            m_netModuleSubcriber.Subscribe<NetAgentBase>(NetModuleEventDef.Remove_NetAgent, this.OnRemoveNetAgent);
        }

        public void SetCallbacks(Action<bool> openCb, Action<int, string> closeCb, Action<int, byte[], int, int> onRecvMsgCb)
        {
            m_openCb = openCb;
            m_closeCb = closeCb;
            m_recvMsgCb = onRecvMsgCb;
        }

        public void OnClose(int errno, string errMsg)
        {
            if (null != m_closeCb)
            {
                m_closeCb(errno, errMsg);
            }
        }

        public void OnOpen(bool isSucc)
        {
            if (null != m_openCb)
            {
                m_openCb(isSucc);
            }
        }

        public void OnRecvMsg(int protocolId, byte[] data, int dataBegin, int dataLen)
        {
            if (null != m_recvMsgCb)
            {
                m_recvMsgCb(protocolId, data, dataBegin, dataLen);
            }
        }

        public ulong Connect(string _host, int _port)
        {
            m_netAgent.Close();
            if (m_netAgentId > 0)
            {
                App.ins.net.RemoveNetAgent(m_netAgentId);
                m_netAgentId = 0;
            }
            m_netAgent.Connect(_host, _port);
            m_netAgentId = App.ins.net.AddNetAgent(m_netAgent);
            return m_netAgentId;
        }

        public ulong ReConnect()
        {
            return this.Connect(m_netAgent.host, m_netAgent.port);
        }

        public void Close()
        {
            m_netAgent.Close();
        }

        public NetAgentState GetState()
        {
            return m_netAgent.GetState();
        }

        public int GetErrorNum()
        {
            return m_netAgent.GetErrorNum();
        }

        public string GetErrorMsg()
        {
            return m_netAgent.GetErrorMsg();
        }

        public bool Send(int protocolId)
        {
            return m_netAgent.Send(protocolId);
        }

        public bool Send(int protocolId, byte[] data, int offset = 0, int len = -1)
        {
            return m_netAgent.Send(protocolId, data, offset, len);
        }

        public void OnRemoveNetAgent(string evString, NetAgentBase netAgent)
        {
            AppLog.Debug("OnRemoveNetAgent {0}", netAgent.id);
        }
    }
}