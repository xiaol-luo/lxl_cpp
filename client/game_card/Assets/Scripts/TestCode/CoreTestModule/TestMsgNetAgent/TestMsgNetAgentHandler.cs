
namespace Utopia
{
    public class TestMsgNetAgentHandler : MsgNetAgentHandler
    {
        public TestMsgNetAgentModule m_owner = null;

        protected override void OnRecvMsg(int protocolId, byte[] data, int dataBegin, int dataLen)
        {
            AppLog.Debug("TestMsgNetAgentHandler OnRecvMsg");
        }

        public override void OnOpen(bool isSucc)
        {
            AppLog.Debug("TestMsgNetAgentHandler OnOpen {0}", isSucc);
        }

        public override void OnRecvData(byte[] data, int dataBegin, int dataLen)
        {
            AppLog.Debug("TestMsgNetAgentHandler OnRecvData");
        }

        public override void OnClose(int errno, string errMsg)
        {
            AppLog.Debug("TestMsgNetAgentHandler OnClose");
        }
    }
}

