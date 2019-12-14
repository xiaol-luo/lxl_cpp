
using System;
using System.IO;
using Utopia;
using XLua;

namespace Utopia
{
    public class LuaGameNet : GameNet
    {
        protected LuaFunction m_openCb = null;
        protected LuaFunction m_closeCb = null;
        protected LuaFunction m_recvMsgCb = null;

        public LuaGameNet() : base()
        {
            this.SetCallbacks(this.OnOpenWrap, this.OnCloseWrap, this.OnRecvMsgWrap);
        }

        public void SetLuaCallbacks(LuaFunction openCb, LuaFunction closeCb, LuaFunction recvMsgCb)
        {
            m_openCb = openCb;
            m_closeCb = closeCb;
            m_recvMsgCb = recvMsgCb;
        }
        protected void OnCloseWrap(int errno, string errMsg)
        {
            if (null != m_closeCb)
            {
                m_closeCb.Call(errno, errMsg);
            }
        }

        protected void OnOpenWrap(bool isSucc)
        {
            if (null != m_openCb)
            {
                m_openCb.Call(isSucc);
            }
        }

        protected void OnRecvMsgWrap(int protocolId, byte[] data, int dataBegin, int dataLen)
        {
            if (null != m_recvMsgCb)
            {
                byte[] newBytes = new byte[dataLen];
                Array.Copy(data, dataBegin, newBytes, 0, dataLen);
                m_recvMsgCb.Call(protocolId, newBytes, dataLen);
            }
        }
    }
}
