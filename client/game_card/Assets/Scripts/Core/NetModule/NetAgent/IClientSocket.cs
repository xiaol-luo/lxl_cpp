
using System.Collections.Generic;

namespace Utopia
{
    public enum ClientSocketState
    {
        Free = 0,
        Connecting,
        Connected,
        Error,
    }

    public interface IClientSocket
    {
        bool ConnectAsync(System.Action<bool> cnnCb, System.Action<List<byte[]>> recvDataCb, System.Action closeCb);
        void Reset(string _host, int _port);
        void Close();
        bool Send(byte[] data, int offset, int data_len);
        void UpdateIO();
        ClientSocketState GetState();
        int GetErrorNum();
        string GetErrorMsg();
    }
}
