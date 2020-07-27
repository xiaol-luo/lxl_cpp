using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using UnityEngine;

namespace Utopia
{
    public class NetAgentCSharp : NetAgentBase
    {
        override protected IClientSocket NewSocket()
        {
            return new ClientSocketCSharp();
        }
    }
}

