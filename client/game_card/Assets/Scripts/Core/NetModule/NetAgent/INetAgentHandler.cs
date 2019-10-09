
namespace Utopia
{
    public abstract class INetAgentHandler
    {
        protected NetAgentBase m_netAgent = null;

        public void SetNetAgent(NetAgentBase netAgent)
        {
            UnityEngine.Debug.Assert(null == m_netAgent);
            m_netAgent = netAgent;
        }

        abstract public void OnOpen(bool isSucc);
        abstract public void OnRecvData(byte[] data, int dataBegin, int dataLen);
        abstract public void OnClose(int errno, string errMsg);
    }
}


