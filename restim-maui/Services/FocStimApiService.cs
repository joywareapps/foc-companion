using System;
using System.Collections.Concurrent;
using System.Threading.Tasks;
using Google.Protobuf;
using RestimMaui.Core;
// Assuming these namespaces exist after running protoc
using FocstimRpc; 

namespace RestimMaui.Services
{
    public interface IFocStimApiService
    {
        bool IsConnected { get; }
        Task ConnectTcpAsync(string ip, int port);
        Task ConnectSerialAsync(string portName);
        Task DisconnectAsync();
        Task<Response> SendRequestAsync(Request request);
        Task StartSignalAsync(OutputMode mode = OutputMode.OutputThreephase);
        Task StopSignalAsync();
        
        event EventHandler<Notification> NotificationReceived;
        event EventHandler<string> ConnectionError;
        event EventHandler Disconnected;
    }

    public class FocStimApiService : IFocStimApiService
    {
        private ITransport? _transport;
        private readonly Hdlc _hdlc;
        private readonly ConcurrentDictionary<uint, TaskCompletionSource<Response>> _pendingRequests;
        private uint _requestIdCounter = 1;

        public event EventHandler<Notification>? NotificationReceived;
        public event EventHandler<string>? ConnectionError;
        public event EventHandler? Disconnected;

        public bool IsConnected => _transport?.IsConnected ?? false;

        public FocStimApiService()
        {
            _hdlc = new Hdlc();
            _pendingRequests = new ConcurrentDictionary<uint, TaskCompletionSource<Response>>();
        }

        public async Task ConnectTcpAsync(string ip, int port)
        {
            await ConnectAsync(new TcpTransport(), $"{ip}:{port}");
        }

        public async Task ConnectSerialAsync(string portName)
        {
            await ConnectAsync(new SerialTransport(), portName);
        }

        private async Task ConnectAsync(ITransport transport, string address)
        {
            if (_transport != null)
            {
                await DisconnectAsync();
            }

            _transport = transport;
            _transport.DataReceived += OnDataReceived;
            _transport.ErrorOccurred += OnErrorOccurred;
            _transport.Disconnected += OnDisconnected;

            await _transport.ConnectAsync(address);
        }

        public async Task DisconnectAsync()
        {
            if (_transport != null)
            {
                _transport.DataReceived -= OnDataReceived;
                _transport.ErrorOccurred -= OnErrorOccurred;
                _transport.Disconnected -= OnDisconnected;
                _transport.Disconnect();
                _transport = null;
            }
            _pendingRequests.Clear();
            Disconnected?.Invoke(this, EventArgs.Empty);
        }

        private void OnDataReceived(object? sender, byte[] data)
        {
            var frames = _hdlc.Parse(data);
            foreach (var frame in frames)
            {
                try
                {
                    var rpcMessage = RpcMessage.Parser.ParseFrom(frame);
                    
                    switch (rpcMessage.MessageCase)
                    {
                        case RpcMessage.MessageOneofCase.Response:
                            HandleResponse(rpcMessage.Response);
                            break;
                        case RpcMessage.MessageOneofCase.Notification:
                            NotificationReceived?.Invoke(this, rpcMessage.Notification);
                            break;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Protobuf parse error: {ex.Message}");
                }
            }
        }

        private void HandleResponse(Response response)
        {
            if (_pendingRequests.TryRemove(response.Id, out var tcs))
            {
                if (response.Error != null && response.Error.Code != Errors.ErrorUnknown)
                {
                    tcs.SetException(new Exception($"Device Error: {response.Error.Code}"));
                }
                else
                {
                    tcs.SetResult(response);
                }
            }
        }

        private void OnErrorOccurred(object? sender, string message)
        {
            ConnectionError?.Invoke(this, message);
        }

        private void OnDisconnected(object? sender, EventArgs e)
        {
            Disconnected?.Invoke(this, EventArgs.Empty);
        }

        public async Task<Response> SendRequestAsync(Request request)
        {
            if (!IsConnected || _transport == null) throw new InvalidOperationException("Not connected");

            request.Id = _requestIdCounter++;
            
            var rpcMessage = new RpcMessage { Request = request };
            var data = rpcMessage.ToByteArray();
            var framed = Hdlc.Encode(data);

            var tcs = new TaskCompletionSource<Response>();
            _pendingRequests.TryAdd(request.Id, tcs);

            await _transport.WriteAsync(framed);

            // Timeout after 5 seconds
            var timeoutTask = Task.Delay(5000);
            if (await Task.WhenAny(tcs.Task, timeoutTask) == timeoutTask)
            {
                _pendingRequests.TryRemove(request.Id, out _);
                throw new TimeoutException($"Request {request.Id} timed out");
            }

            return await tcs.Task;
        }

        public async Task StartSignalAsync(OutputMode mode = OutputMode.OutputThreephase)
        {
            var req = new Request
            {
                RequestSignalStart = new RequestSignalStart { Mode = mode }
            };
            await SendRequestAsync(req);
        }

        public async Task StopSignalAsync()
        {
            var req = new Request
            {
                RequestSignalStop = new RequestSignalStop()
            };
            await SendRequestAsync(req);
        }
    }
}
