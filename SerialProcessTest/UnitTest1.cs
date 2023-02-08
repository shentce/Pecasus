using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace SerialProcessTest
{
    [TestClass]
    public class UnitTest1
    {
        private readonly SerialProcess.SerialProcess _serialProcess;

        public UnitTest1()
        {
            _serialProcess = new SerialProcess.SerialProcess();
        }

        [TestMethod, Priority(1), TestCategory("CategoryA")]
        public void AddTest1()
        {
            int result = _serialProcess.Add(10, 20);
            Assert.AreEqual(result, 30);
        }

        [TestMethod, Priority(1), TestCategory("CategoryB")]
        public void AddTest2()
        {
            int result = _serialProcess.Add((-10), 20);
            Assert.AreEqual(result, 10);
        }

        [TestMethod, Priority(2), TestCategory("CategoryA")]
        public void AddTest3()
        {
            int result = _serialProcess.Add(0, 20);
            Assert.AreEqual(result, 20);
        }

        [TestMethod, Priority(2), TestCategory("CategoryB")]
        public void AddTest4()
        {
            int result = _serialProcess.Add(int.MaxValue, 20);
            Assert.AreEqual(result, 20);
        }
    }
}
