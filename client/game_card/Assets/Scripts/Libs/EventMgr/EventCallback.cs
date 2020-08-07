using System;
using System.Collections.Generic;

namespace Utopia
{
    public class EventCallbackBase
    {
        public EventCallbackBase(int paramCount)
        {
            _expectParamCount = paramCount;
        }

        protected int _expectParamCount = -1;
        public virtual void Fire(string key, params object[] args) { throw new NotImplementedException("EventCallbackBase Fire with params object[] args"); }
    }
    public class EventCallback : EventCallbackBase
    {
        public System.Action _cb_fn;
        public EventCallback(System.Action cb_fn) : base(0) { _cb_fn = cb_fn; }
        public override void Fire(string key, params object[] args)
        {
            if (null != _cb_fn)
            {
                _cb_fn();
            }
        }
    }

    public class EventCallback<T0> : EventCallbackBase
    {
        Action<T0> _cb_fn;
        public EventCallback(Action<T0> cb_fn) :base(1) { _cb_fn = cb_fn; }

        protected static T0 Default_P0 = default(T0);
        public override void Fire(string key, params object[] args)
        {

            if (null != _cb_fn)
            {
                var p0 = args.Length > 0 ? (T0)args[0] : Default_P0;
                _cb_fn(p0);
            }
        }
    }

    public class EventCallback<T0, T1> : EventCallbackBase
    {
        Action<T0, T1> _cb_fn;
        public EventCallback(Action<T0, T1> cb_fn) : base(1) { _cb_fn = cb_fn; }

        protected static T0 Default_P0 = default(T0);
        protected static T1 Default_P1 = default(T1);
        public override void Fire(string key, params object[] args)
        {

            if (null != _cb_fn)
            {
                var p0 = args.Length > 0 ? (T0)args[0] : Default_P0;
                var p1 = args.Length > 1 ? (T1)args[1] : Default_P1;
                _cb_fn(p0, p1);
            }
        }
    }
    public class EventCallback<T0, T1, T2> : EventCallbackBase
    {
        Action<T0, T1, T2> _cb_fn;
        public EventCallback(Action<T0, T1, T2> cb_fn) : base(1) { _cb_fn = cb_fn; }

        protected static T0 Default_P0 = default(T0);
        protected static T1 Default_P1 = default(T1);
        protected static T2 Default_P2 = default(T2);
        public override void Fire(string key, params object[] args)
        {

            if (null != _cb_fn)
            {
                var p0 = args.Length > 0 ? (T0)args[0] : Default_P0;
                var p1 = args.Length > 1 ? (T1)args[1] : Default_P1;
                var p2 = args.Length > 2 ? (T2)args[2] : Default_P2;
                _cb_fn(p0, p1, p2);
            }
        }
    }
    public class EventCallback<T0, T1, T2, T3> : EventCallbackBase
    {
        Action<T0, T1, T2, T3> _cb_fn;
        public EventCallback(Action<T0, T1, T2, T3> cb_fn) : base(1) { _cb_fn = cb_fn; }

        protected static T0 Default_P0 = default(T0);
        protected static T1 Default_P1 = default(T1);
        protected static T2 Default_P2 = default(T2);
        protected static T3 Default_P3 = default(T3);
        public override void Fire(string key, params object[] args)
        {

            if (null != _cb_fn)
            {
                var p0 = args.Length > 0 ? (T0)args[0] : Default_P0;
                var p1 = args.Length > 1 ? (T1)args[1] : Default_P1;
                var p2 = args.Length > 2 ? (T2)args[2] : Default_P2;
                var p3 = args.Length > 3 ? (T3)args[3] : Default_P3;
                _cb_fn(p0, p1, p2, p3);
            }
        }
    }
}