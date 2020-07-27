using System.Collections.Generic;

namespace Utopia
{
    public class NetModule : CoreModule
    {
        ulong m_lastId = 0;
        Dictionary<ulong, NetAgentBase> m_netAgents = new Dictionary<ulong, NetAgentBase>();

        public NetModule(Core _app) : base(_app, EModule.NetModule)
        {
           
        }  

        public ulong AddNetAgent(NetAgentBase netAgent)
        {
            ++m_lastId;
            netAgent.id = m_lastId;
            m_netAgents.Add(m_lastId, netAgent);
            return m_lastId;
        }

        public void RemoveNetAgent(ulong id)
        {
            NetAgentBase na = this.GetNetAgent(id);
            m_netAgents.Remove(id);
            if (null != na)
            {
                this.Fire(NetModuleEventDef.Remove_NetAgent, na);
            }
        }

        public NetAgentBase GetNetAgent(ulong id)
        {
            NetAgentBase ret = null;
            m_netAgents.TryGetValue(id, out ret);
            return ret;
        }

        protected override void OnUpdate()
        {
            base.OnUpdate();

            List<ulong> toRemoveAgentIds = new List<ulong>();
            var tmpAgents = new Dictionary<ulong, NetAgentBase>(m_netAgents);
            foreach (var kvPair in tmpAgents)
            {
                ulong id = kvPair.Key;
                NetAgentBase na = kvPair.Value;

                NetAgentState curr_state = na.GetState();
                if (NetAgentState.Closed == curr_state || NetAgentState.Free == curr_state)
                {
                    toRemoveAgentIds.Add(id);
                }
                na.UpdateIO();
            }
            foreach (ulong id in toRemoveAgentIds)
            {
                RemoveNetAgent(id);
            }
        }
    }
}

