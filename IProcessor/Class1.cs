using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InterfaceProcessor
{
    public interface IProcessor
    {
        TimeSpan ExecutionTimeSpan { get; set; }

        long Process();

        string Message { get; set; }

        Action<string> InvertMe { get; set; }
    }
}


