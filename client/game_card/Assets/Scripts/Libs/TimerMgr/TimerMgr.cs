using System;
using System.Collections.Generic;

namespace Utopia
{
    public class TimerMgr
    {
        public const ulong INVALID_ID = 0;

        public delegate float FnDateTime();
        FnDateTime m_fnNowSec;

        float nowSec { get { return m_fnNowSec(); } }

        public TimerMgr(FnDateTime fn)
        {
            m_fnNowSec = fn;
        }

        class Item
        {
            public ulong id = 0;
            public long nextTick = 0;
            public long spanTicks = 0;
            public int callTimes = 0;
            public System.Action callFn;
        }

        class ItemSortWay : IComparer<Item>
        {
            int IComparer<Item>.Compare(Item x, Item y)
            {
                int ret = x.nextTick.CompareTo(y.nextTick);
                if (0 != ret)
                    return ret;
                ret = x.id.CompareTo(y.id);
                return ret;
            }
        }

        SortedSet<Item> m_sortedItems = new SortedSet<Item>(new ItemSortWay());
        ulong m_lastId = 0;
        Dictionary<ulong, Item> m_id2Item = new Dictionary<ulong, Item>();

        public ulong Add(System.Action cb, float delaySec, int callTimes, float callSpanSec)
        {
            if (null == cb)
                return 0;

            ++m_lastId;
            if (0 == m_lastId)
                ++m_lastId;

            Item item = new Item();
            item.id = m_lastId;
            item.callFn = cb;
            item.callTimes = callTimes;
            float NextSec = this.nowSec + delaySec;
            item.nextTick = (long)Math.Ceiling(TimeSpan.TicksPerSecond * NextSec) ;
            item.spanTicks = 0;
            if (callSpanSec > 0)
            {
                item.spanTicks = (long)Math.Ceiling(TimeSpan.TicksPerSecond * callSpanSec);
                if (item.spanTicks <= 0)
                    item.spanTicks = 1;
            }
            m_id2Item.Add(item.id, item);
            m_sortedItems.Add(item);
            return m_lastId;
        }

        public ulong Delay(System.Action cb, float delaySec)
        {
            ulong ret = this.Add(cb, delaySec, 1, 0);
            return ret;
        }

        public ulong Firm(System.Action cb, int callTimes, float spanSec)
        {
            ulong ret = this.Add(cb, 0, callTimes, spanSec);
            return ret;
        }

        public void Remove(ulong id)
        {
            Item item;
            if (m_id2Item.TryGetValue(id, out item))
            {
                if (m_isCheckingTrigger)
                {
                    m_waitRemoveTimerIds.Add(item);
                }
                else
                {
                    m_id2Item.Remove(id);
                    m_sortedItems.Remove(item);
                }
            }
        }

        public void ClearAll()
        {
            if (m_isCheckingTrigger)
            {
                m_waitRemoveTimerIds.UnionWith(m_id2Item.Values);
            }
            else
            {
                m_id2Item.Clear();
                m_sortedItems.Clear();
                m_waitRemoveTimerIds.Clear();
            }
        }

        bool m_isCheckingTrigger = false;
        HashSet<Item> m_waitRemoveTimerIds = new HashSet<Item>();
        public void CheckTrigger()
        {
            m_isCheckingTrigger = true;
            long nowTicks = (long)Math.Ceiling(TimeSpan.TicksPerSecond * this.nowSec);

            if (m_sortedItems.Count > 0 && nowTicks >= m_sortedItems.Min.nextTick)
            {
                List<Item> hitItems = new List<Item>();
                foreach (Item item in m_sortedItems)
                {
                    if (item.nextTick > nowTicks)
                        break;
                    hitItems.Add(item);
                }
                m_sortedItems.ExceptWith(hitItems);

                List<Item> toRemoveItems = new List<Item>();
                List<Item> toReAddItems = new List<Item>();
                foreach (Item item in hitItems)
                {
                    try { item.callFn(); } catch (System.Exception){}

                    bool willRemove = item.callTimes >= 0 && item.callTimes <= 1;
                    if (willRemove)
                    {
                        toRemoveItems.Add(item);
                    }
                    else
                    {
                        if (item.callTimes > 0)
                            --item.callTimes;
                        item.nextTick = nowTicks + item.spanTicks;
                        toReAddItems.Add(item);
                    }
                }

                m_sortedItems.UnionWith(toReAddItems);
                foreach (Item elem in toRemoveItems)
                {
                    this.Remove(elem.id);
                }
            }

            m_isCheckingTrigger = false;
            if (m_waitRemoveTimerIds.Count > 0)
            {
                foreach (Item elem in m_waitRemoveTimerIds)
                {
                    m_id2Item.Remove(elem.id);
                    m_sortedItems.Remove(elem);
                }
                m_waitRemoveTimerIds.Clear();
            }
        }
    }
}

