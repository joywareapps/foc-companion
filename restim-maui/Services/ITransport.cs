using System;
using System.Threading.Tasks;

namespace RestimMaui.Services
{
    public interface ITransport
    {
        bool IsConnected { get; }
        Task ConnectAsync(string address); // address can be "IP:Port" or "COM3"
        void Disconnect();
        Task WriteAsync(byte[] data);
        event EventHandler<byte[]> DataReceived;
        event EventHandler<string> ErrorOccurred;
        event EventHandler Disconnected;
    }
}
