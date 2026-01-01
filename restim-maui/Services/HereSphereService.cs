using System;
using System.IO;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using RestimMaui.Models;

namespace RestimMaui.Services
{
    public class HereSphereStatus
    {
        public string Identifier { get; set; } = "";
        public string Path { get; set; } = "";
        public double CurrentTime { get; set; }
        public double PlaybackSpeed { get; set; }
        public int PlayerState { get; set; } // 0 = playing
    }

    public interface IHereSphereService
    {
        void Configure(string ip, int port);
        Task ConnectAsync();
        void Disconnect();
        event EventHandler<HereSphereStatus> StatusReceived;
    }

    public class HereSphereService : IHereSphereService
    {
        private TcpClient? _client;
        private NetworkStream? _stream;
        private CancellationTokenSource? _cts;
        private string _ip = "";
        private int _port = 23554;

        public event EventHandler<HereSphereStatus>? StatusReceived;

        public void Configure(string ip, int port)
        {
            _ip = ip;
            _port = port;
        }

        public async Task ConnectAsync()
        {
            if (string.IsNullOrEmpty(_ip)) throw new InvalidOperationException("IP not configured");

            _client = new TcpClient();
            await _client.ConnectAsync(_ip, _port);
            _stream = _client.GetStream();
            _cts = new CancellationTokenSource();

            _ = ReadLoop(_cts.Token);
            _ = KeepAliveLoop(_cts.Token);
        }

        public void Disconnect()
        {
            _cts?.Cancel();
            _client?.Close();
            _client = null;
        }

        private async Task ReadLoop(CancellationToken token)
        {
            var headerBuffer = new byte[4];
            try
            {
                while (!token.IsCancellationRequested && _stream != null)
                {
                    // Read Length (4 bytes little endian)
                    int bytesRead = await ReadExactAsync(_stream, headerBuffer, 4, token);
                    if (bytesRead == 0) break;

                    int length = BitConverter.ToInt32(headerBuffer, 0);
                    if (length == 0) continue; // Keep-alive

                    // Read JSON
                    var jsonBuffer = new byte[length];
                    await ReadExactAsync(_stream, jsonBuffer, length, token);
                    
                    var json = Encoding.UTF8.GetString(jsonBuffer);
                    var status = JsonSerializer.Deserialize<HereSphereStatus>(json, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                    
                    if (status != null)
                    {
                        StatusReceived?.Invoke(this, status);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"HereSphere Read Error: {ex.Message}");
            }
        }

        private async Task KeepAliveLoop(CancellationToken token)
        {
            var keepAlive = new byte[] { 0, 0, 0, 0 };
            while (!token.IsCancellationRequested && _stream != null)
            {
                try
                {
                    await _stream.WriteAsync(keepAlive, 0, 4, token);
                    await Task.Delay(1000, token);
                }
                catch { break; }
            }
        }

        private async Task<int> ReadExactAsync(NetworkStream stream, byte[] buffer, int count, CancellationToken token)
        {
            int totalRead = 0;
            while (totalRead < count)
            {
                int read = await stream.ReadAsync(buffer, totalRead, count - totalRead, token);
                if (read == 0) return 0;
                totalRead += read;
            }
            return totalRead;
        }
    }
}
