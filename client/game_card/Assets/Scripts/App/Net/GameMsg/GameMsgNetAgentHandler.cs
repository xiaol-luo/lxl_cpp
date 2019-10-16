
namespace Utopia
{
    public class GameMsgNetAgentHandler : IMsgNetAgentHandler
    {
        GameNet m_gameNet = null;
        public GameMsgNetAgentHandler(GameNet game_net)
        {
            m_gameNet = game_net;
        }
        public override void OnClose(int errno, string errMsg)
        {
            m_gameNet.OnClose(errno, errMsg);
        }

        public override void OnOpen(bool isSucc)
        {
            m_gameNet.OnOpen(isSucc);
        }

        protected override void OnRecvMsg(int protocolId, byte[] data, int dataBegin, int dataLen)
        {
            m_gameNet.OnRecvMsg(protocolId, data, dataBegin, dataLen);
        }
    }
}