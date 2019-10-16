using System;

namespace Utopia
{
    public class GameNet
    {
        GameMsgNetAgentHandler m_msgHandler = null;
        ulong m_netAgentId = 0;
        MsgNetAgent m_netAgent = null;
        Action<bool> m_openCb = null;
        Action<int, string> m_closeCb = null;
        Action<int, byte[], int, int> m_onRecvMsgCb = null;

        public GameNet(Action<bool> openCb, Action<int, string> closeCb, Action<int, byte[], int, int> onRecvMsgCb)
        {
            m_openCb = openCb;
            m_closeCb = closeCb;
            m_onRecvMsgCb = onRecvMsgCb;

            m_netAgent = new MsgNetAgent();
            m_msgHandler = new GameMsgNetAgentHandler(this);
            m_netAgent.SetHandler(m_msgHandler);
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
            if (null != m_onRecvMsgCb)
            {
                m_onRecvMsgCb(protocolId, data, dataBegin, dataLen);
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
    }
}