using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel.Composition;
using InterfaceProcessor;

namespace SerialProcess
{
    [Export(typeof(IProcessor))]
    public class SerialProcess : IProcessor
    {
        #region IProcessor Members

        public TimeSpan ExecutionTimeSpan
        {
            get;
            set;
        }

        public long Process()
        {
            DateTime startTime = DateTime.Now;

            long j, rem, result = 0;
            for (long i = 2; i <= 5000; i++)
            {
                for (j = 2; j < i; j++)
                {
                    rem = i % j;
                    if (rem == 0)
                        break;
                }

                if (this.InvertMe != null)
                    this.InvertMe(string.Format("Step [{0}, {1}]", i, j));

                if (i == j)
                    result = i;
            }

            this.ExecutionTimeSpan = DateTime.Now.Subtract(startTime);

            this.Message = string.Format("Finished processing in {0} ticks", this.ExecutionTimeSpan.Ticks);
            return result;
        }

        public string Message
        {
            get;
            set;
        }

        public Action<string> InvertMe
        {
            get;
            set;
        }

        public int Add(int first, int second)
        {
            return first + second;
        }

        #endregion
    }
}
