using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using UnityEngine;

namespace Utopia
{
    public class MsgNetAgent : NetAgentCSharp
    {
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

