
using System;
using System.Collections.Generic;
using System.Net;

namespace Utopia
{
    public abstract class MsgNetAgentHandler : INetAgentHandler
    {
        abstract protected void OnRecvMsg(int protocolId, byte[] data, int dataBegin, int dataLen);

        const int CONTENT_LEN_DESCRIPT_SIZE = sizeof(uint);
        const int PROTOCOL_LEN_DESCRIPT_SIZE = sizeof(int);
        const int PROTOCOL_CONTENT_MAX_SIZE = 409600;
        const int PROTOCOL_MAX_SIZE = PROTOCOL_LEN_DESCRIPT_SIZE + PROTOCOL_CONTENT_MAX_SIZE;
        byte[] m_parseBuffer = new byte[PROTOCOL_MAX_SIZE + CONTENT_LEN_DESCRIPT_SIZE];
        int m_parseBufferOffset = 0;

        public override void OnRecvData(byte[] bytes, int dataBegin, int dataLen)
        {
            int bytesOffset = dataBegin;
            int bytesEnd = dataBegin + dataLen;
            while (bytesOffset < bytesEnd)
            {
                if (m_parseBufferOffset < CONTENT_LEN_DESCRIPT_SIZE)
                {
                    int copyLen = CONTENT_LEN_DESCRIPT_SIZE - m_parseBufferOffset;
                    if (copyLen > bytesEnd - bytesOffset)
                        copyLen = bytesEnd - bytesOffset;
                    Array.Copy(bytes, bytesOffset, m_parseBuffer, m_parseBufferOffset, copyLen);
                    bytesOffset += copyLen;
                    m_parseBufferOffset += copyLen;
                    if (bytesOffset >= bytesEnd)
                        break;
                }
                int ctxLen = IPAddress.NetworkToHostOrder(BitConverter.ToInt32(m_parseBuffer, 0));
                if (ctxLen > PROTOCOL_MAX_SIZE || ctxLen < PROTOCOL_LEN_DESCRIPT_SIZE)
                {
                    AppLog.Info("OnSocketRecvData ctxLen " + ctxLen.ToString());
                    m_netAgent.Close();
                    return;
                }

                {
                    int copyLen = CONTENT_LEN_DESCRIPT_SIZE + ctxLen - m_parseBufferOffset;
                    if (copyLen > bytes.Length - bytesOffset)
                        copyLen = bytes.Length - bytesOffset;
                    Array.Copy(bytes, bytesOffset, m_parseBuffer, m_parseBufferOffset, copyLen);
                    bytesOffset += copyLen;
                    m_parseBufferOffset += copyLen;
                    if (m_parseBufferOffset >= CONTENT_LEN_DESCRIPT_SIZE + ctxLen)
                    {
                        int protocolId = IPAddress.NetworkToHostOrder(BitConverter.ToInt32(m_parseBuffer, CONTENT_LEN_DESCRIPT_SIZE));
                        int protobufBegin = CONTENT_LEN_DESCRIPT_SIZE + PROTOCOL_LEN_DESCRIPT_SIZE;
                        int protobufLen = m_parseBufferOffset - protobufBegin;
                        m_parseBufferOffset = 0;
                        try
                        {
                            this.OnRecvMsg(protocolId, m_parseBuffer, protobufBegin, protobufLen);
                        }
                        catch (Exception e)
                        {
                            AppLog.Exception(e);
                        }
                    }
                }
            }
        }
    }
}

