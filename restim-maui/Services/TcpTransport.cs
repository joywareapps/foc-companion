using System;
using System.Net.Sockets;
using System.Threading;
using System.Threading.Tasks;

namespace RestimMaui.Services
{
    public class TcpTransport : ITransport
    {
        private TcpClient? _client;
        private NetworkStream? _stream;
        private CancellationTokenSource? _cts;
        private Task? _readTask;

        public bool IsConnected => _client?.Connected ?? false;

        public event EventHandler<byte[]>? DataReceived;
        public event EventHandler<string>? ErrorOccurred;
        public event EventHandler? Disconnected;

        public async Task ConnectAsync(string address)
        {
            try
            {
                var parts = address.Split(':');
                if (parts.Length != 2) throw new ArgumentException("Address must be IP:Port");

                var ip = parts[0];
                var port = int.Parse(parts[1]);

                _client = new TcpClient();
                await _client.ConnectAsync(ip, port);
                _stream = _client.GetStream();
                
                _cts = new CancellationTokenSource();
                _readTask = ReadLoop(_cts.Token);
            }
            catch (Exception ex)
            {
                ErrorOccurred?.Invoke(this, ex.Message);
                throw;
            }
        }

        public void Disconnect()
        {
            _cts?.Cancel();
            _client?.Close();
            _client = null;
            Disconnected?.Invoke(this, EventArgs.Empty);
        }

        public async Task WriteAsync(byte[] data)
        {
            if (_stream == null) return;
            await _stream.WriteAsync(data, 0, data.Length);
        }

        private async Task ReadLoop(CancellationToken token)
        {
            var buffer = new byte[4096];
            try
            {
                while (!token.IsCancellationRequested && _stream != null)
                {
                    int bytesRead = await _stream.ReadAsync(buffer, 0, buffer.Length, token);
                    if (bytesRead == 0) break; // Disconnected

                    var received = new byte[bytesRead];
                    Array.Copy(buffer, received, bytesRead);
                    DataReceived?.Invoke(this, received);
                }
            }
            catch (OperationCanceledException) { }
            catch (Exception ex)
            {
                if (!token.IsCancellationRequested)
                    ErrorOccurred?.Invoke(this, ex.Message);
            }
            finally
            {
                if (IsConnected) Disconnect();
            }
        }
    }
}
