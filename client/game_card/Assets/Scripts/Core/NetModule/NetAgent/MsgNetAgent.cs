using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using UnityEngine;

namespace Utopia
{
    public class MsgNetAgent : NetAgentBase
    {
        override protected IClientSocket NewSocket()
        {
            return new ClientSocketCSharp();
        }

        const int CONTENT_LEN_DESCRIPT_SIZE = sizeof(uint);
        const int PROTOCOL_LEN_DESCRIPT_SIZE = sizeof(int);
        const int PROTOCOL_CONTENT_MAX_SIZE = 409600;
        const int PROTOCOL_MAX_SIZE = PROTOCOL_LEN_DESCRIPT_SIZE + PROTOCOL_CONTENT_MAX_SIZE;
        byte[] m_parseBuffer = new byte[PROTOCOL_MAX_SIZE + CONTENT_LEN_DESCRIPT_SIZE];
        int m_parseBufferOffset = 0;
        protected override void OnSocketRecvData(List<byte[]> bytesList)
        {
            foreach (byte[] bytes in bytesList)
            {
                int bytesOffset = 0;
                while (bytesOffset < bytes.Length)
                {
                    if (m_parseBufferOffset < CONTENT_LEN_DESCRIPT_SIZE)
                    {
                        int copyLen = CONTENT_LEN_DESCRIPT_SIZE - m_parseBufferOffset;
                        if (copyLen > bytes.Length - bytesOffset)
                            copyLen = bytes.Length - bytesOffset;
                        Array.Copy(bytes, bytesOffset, m_parseBuffer, m_parseBufferOffset, copyLen);
                        bytesOffset += copyLen;
                        m_parseBufferOffset += copyLen;
                        if (bytesOffset >= bytes.Length)
                            break;
                    }
                    int ctxLen = IPAddress.NetworkToHostOrder(BitConverter.ToInt32(m_parseBuffer, 0));
                    if (ctxLen > PROTOCOL_MAX_SIZE || ctxLen < PROTOCOL_LEN_DESCRIPT_SIZE)
                    {
                        AppLog.Info("OnSocketRecvData ctxLen " + ctxLen.ToString());
                        this.Close();
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
                            int parseBufferOffset = m_parseBufferOffset;
                            m_parseBufferOffset = 0;

                            int protocolId = IPAddress.NetworkToHostOrder(BitConverter.ToInt32(m_parseBuffer, CONTENT_LEN_DESCRIPT_SIZE));
                            int protobufBegin = CONTENT_LEN_DESCRIPT_SIZE + PROTOCOL_LEN_DESCRIPT_SIZE;
                            if (null != m_handler)
                            {
                                try
                                {
                                    m_handler.OnRecvData(protocolId, m_parseBuffer, protobufBegin, parseBufferOffset - protobufBegin);
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

        public bool Send(int protocolId)
        {
            if (protocolId <= 0)
                return false;

            bool isOk = true;
            if (isOk)
            {
                int ctxLen = sizeof(int);
                byte[] tmpBuffer = BitConverter.GetBytes(IPAddress.HostToNetworkOrder(ctxLen));
                isOk = this.Send(tmpBuffer, 0, tmpBuffer.Length);
            }
            if (isOk)
            {
                byte[] tmpBuffer = BitConverter.GetBytes(IPAddress.HostToNetworkOrder(protocolId));
                isOk = this.Send(tmpBuffer, 0, tmpBuffer.Length);
            }
            return isOk;
        }

        public bool Send(int protocolId, byte[] data, int offset = 0, int len = -1)
        {
            if (protocolId <= 0 || null == data)
                return false;

            int sendDataLen = len;
            if (sendDataLen < 0)
            {
                sendDataLen = data.Length - offset;
            }
            if (sendDataLen < 0)
            {
                return false;
            }

            MemoryStream mstream = new MemoryStream();
            {
                int ctxLen = sizeof(int) + sendDataLen;
                byte[] tmpBuffer = BitConverter.GetBytes(IPAddress.HostToNetworkOrder(ctxLen));
                // isOk = this.Send(tmpBuffer, 0, tmpBuffer.Length);
                mstream.Write(tmpBuffer, 0, tmpBuffer.Length);
            }
            {
                byte[] tmpBuffer = BitConverter.GetBytes(IPAddress.HostToNetworkOrder(protocolId));
                mstream.Write(tmpBuffer, 0, tmpBuffer.Length);
            }
            if (sendDataLen > 0)
            {
                mstream.Write(data, offset, sendDataLen);
            }
            bool isOk = this.Send(mstream.GetBuffer(), 0, (int)mstream.Position);
            return isOk;
        }
    }
}

