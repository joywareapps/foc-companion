using System;
using System.IO.Ports;
using System.Threading;
using System.Threading.Tasks;

namespace RestimMaui.Services
{
    // Note: System.IO.Ports works on Windows. 
    // On Android, this will likely throw PlatformNotSupportedException unless
    // a specific Android implementation is injected.
    public class SerialTransport : ITransport
    {
        private SerialPort? _serialPort;

        public bool IsConnected => _serialPort?.IsOpen ?? false;

        public event EventHandler<byte[]>? DataReceived;
        public event EventHandler<string>? ErrorOccurred;
        public event EventHandler? Disconnected;

        public Task ConnectAsync(string address)
        {
            // Address format: "COM3" or "/dev/ttyUSB0"
            // For Android, we might need to handle this differently in a platform-specific service
            
#if ANDROID
            throw new NotImplementedException("Direct Serial not supported on Android in this prototype. Use a library like UsbSerialForAndroid.");
#else
            return Task.Run(() =>
            {
                try
                {
                    _serialPort = new SerialPort(address, 115200); // Default baud
                    _serialPort.DataReceived += OnSerialDataReceived;
                    _serialPort.Open();
                }
                catch (Exception ex)
                {
                    ErrorOccurred?.Invoke(this, ex.Message);
                    throw;
                }
            });
#endif
        }

        private void OnSerialDataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            if (_serialPort == null || !_serialPort.IsOpen) return;
            try
            {
                int bytesToRead = _serialPort.BytesToRead;
                byte[] buffer = new byte[bytesToRead];
                _serialPort.Read(buffer, 0, bytesToRead);
                DataReceived?.Invoke(this, buffer);
            }
            catch (Exception ex)
            {
                ErrorOccurred?.Invoke(this, ex.Message);
            }
        }

        public void Disconnect()
        {
            if (_serialPort != null && _serialPort.IsOpen)
            {
                _serialPort.Close();
            }
            _serialPort = null;
            Disconnected?.Invoke(this, EventArgs.Empty);
        }

        public Task WriteAsync(byte[] data)
        {
            return Task.Run(() =>
            {
                if (_serialPort != null && _serialPort.IsOpen)
                {
                    _serialPort.Write(data, 0, data.Length);
                }
            });
        }
    }
}
