using System;
using System.Collections.Generic;
using RestimMaui.Services;

namespace RestimMaui.Services
{
    public interface ISerialService
    {
        string[] GetAvailablePorts();
    }

    public class SerialService : ISerialService
    {
        public string[] GetAvailablePorts()
        {
#if ANDROID
            return Array.Empty<string>(); // Need Android specific library
#else
            return System.IO.Ports.SerialPort.GetPortNames();
#endif
        }
    }
}
