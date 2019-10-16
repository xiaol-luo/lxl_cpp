
namespace Utopia
{
    public class TestMsgNetAgentHandler : IMsgNetAgentHandler
    {
        public TestMsgNetAgentModule m_owner = null;

        protected override void OnRecvMsg(int protocolId, byte[] data, int dataBegin, int dataLen)
        {
            AppLog.Debug("TestMsgNetAgentHandler OnRecvMsg {0} {1} {2}", protocolId, dataBegin, dataLen);
        }

        public override void OnOpen(bool isSucc)
        {
            AppLog.Debug("TestMsgNetAgentHandler OnOpen {0}", isSucc);
        }

        public override void OnClose(int errno, string errMsg)
        {
            AppLog.Debug("TestMsgNetAgentHandler OnClose");
        }
    }
}

