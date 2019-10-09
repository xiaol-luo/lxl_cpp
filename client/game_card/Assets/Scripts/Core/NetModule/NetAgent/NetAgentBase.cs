using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using UnityEngine;

namespace Utopia
{

    public enum NetAgentState
    {
        Free,
        Connecting,
        Connected,
        Closed,
    }

    public class NetAgentBase
    {
        public string host { get; protected set; }
        public int port { get; protected set; }
        public ulong id { get; set; }
        protected IClientSocket m_socket;
        protected INetAgentHandler m_handler;
        protected NetAgentState m_state = NetAgentState.Free;
        protected int m_error_num;
        protected string m_error_msg;

        virtual protected IClientSocket NewSocket()
        {
            throw new NotImplementedException();
        }

        public void SetHandler(INetAgentHandler handler)
        {
            UnityEngine.Debug.Assert(null == m_handler && null != handler);
            m_handler = handler;
            m_handler.SetNetAgent(this);
        }

        public bool Connect(string _host, int _port)
        {
            this.Close();
            host = _host;
            port = _port;
            m_socket = this.NewSocket();
            m_state = NetAgentState.Connecting;
            return m_socket.ConnectAsync(OnSocketOpen, OnSocketRecvData, OnSocketClose);
        }

        public bool ReConnect()
        {
            return this.Connect(host, port);
        }

        public void Close()
        {
            if (null != m_socket)
                m_socket.Close();
            m_socket = null;
        }

        public bool Send(byte[] data, int offset, int len)
        {
            if (null != m_socket && 0 == m_socket.GetErrorNum() &&
                null != data && offset >= 0 && len > 0 && offset + len <= data.Length)
            {
                return m_socket.Send(data, offset, len);

            }
            return false;
        }

        public void UpdateIO()
        {
            if (null != m_socket)
                m_socket.UpdateIO();
        }

        void OnSocketOpen(bool isSucc)
        {
            m_state = isSucc ? NetAgentState.Connected : NetAgentState.Closed;

            if (null != m_handler)
            {
                m_handler.OnOpen(isSucc);
            }
            if (!isSucc)
            {
                this.Close();
            }

            AppLog.Info("OnSocketOpen");
        }

        void OnSocketClose()
        {
            m_error_num = m_socket.GetErrorNum();
            m_error_msg = m_socket.GetErrorMsg();
            if (null != m_handler)
            {
                m_handler.OnClose(m_error_num, m_error_msg);
            }

            m_state = NetAgentState.Closed;

            AppLog.Info("OnSocketClose");
        }

        protected virtual void OnSocketRecvData(List<byte[]> bytesList)
        {
            foreach (byte[] bytes in bytesList)
            {
                if (null != m_handler)
                {
                    m_handler.OnRecvData(bytes, 0, bytes.Length);
                }
            }
        }

        public NetAgentState GetState()
        {
            return m_state;
        }

        public int GetErrorNum()
        {
            return m_error_num;
        }

        public string GetErrorMsg()
        {
            return m_error_msg;
        }
    }
}
