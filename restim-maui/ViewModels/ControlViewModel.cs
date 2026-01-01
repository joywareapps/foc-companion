using System.Windows.Input;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using RestimMaui.Core;
using RestimMaui.Services;

namespace RestimMaui.ViewModels
{
    public partial class ControlViewModel : ObservableObject
    {
        private readonly IDeviceService _deviceService;
        private readonly IFocStimApiService _api;
        private readonly CommandLoop _loop;
        private readonly ISettingsService _settings;

        [ObservableProperty]
        private string _connectionStatus = "Disconnected";

        [ObservableProperty]
        private string _connectionColor = "Gray";

        [ObservableProperty]
        private string _deviceIp;

        [ObservableProperty]
        private bool _isLoopRunning;

        [ObservableProperty]
        private double _patternSpeed = 2.0;

        [ObservableProperty]
        private string _buttonText = "Start Circle Pattern";

        [ObservableProperty]
        private string _buttonColor = "#27ae60";

        // Device Status
        [ObservableProperty] private string _temperature = "--";
        [ObservableProperty] private string _batteryVoltage = "--";
        [ObservableProperty] private string _batterySoc = "--";
        [ObservableProperty] private bool _wallPower;

        public ControlViewModel(
            IDeviceService deviceService,
            IFocStimApiService api,
            CommandLoop loop,
            ISettingsService settings)
        {
            _deviceService = deviceService;
            _api = api;
            _loop = loop;
            _settings = settings;

            _deviceIp = _settings.FocStim.WifiIp;

            _api.NotificationReceived += OnNotification;
            _api.ConnectionError += OnError;
            _api.Disconnected += OnDisconnected;
            _deviceService.StatusUpdated += OnStatusUpdated;
        }

        [RelayCommand]
        private async Task Connect()
        {
            if (_api.IsConnected)
            {
                await _api.DisconnectAsync();
                ConnectionStatus = "Disconnected";
                ConnectionColor = "Gray";
            }
            else
            {
                try
                {
                    ConnectionStatus = "Connecting...";
                    ConnectionColor = "Orange";
                    await _api.ConnectTcpAsync(_deviceIp, 8080); // Default port from RN
                    ConnectionStatus = $"Connected to {_deviceIp}";
                    ConnectionColor = "#2f95dc";
                }
                catch (Exception ex)
                {
                    ConnectionStatus = "Error";
                    ConnectionColor = "Red";
                    await Application.Current.MainPage.DisplayAlert("Error", ex.Message, "OK");
                }
            }
        }

        [RelayCommand]
        private async Task ToggleLoop()
        {
            if (!_api.IsConnected)
            {
                await Application.Current.MainPage.DisplayAlert("Error", "Not connected", "OK");
                return;
            }

            if (IsLoopRunning)
            {
                await _loop.StopAsync();
                IsLoopRunning = false;
                ButtonText = "Start Circle Pattern";
                ButtonColor = "#27ae60";
            }
            else
            {
                _loop.SetPatternSpeed(PatternSpeed);
                await _loop.StartAsync();
                IsLoopRunning = true;
                ButtonText = "Stop Circle Pattern";
                ButtonColor = "#e67e22";
            }
        }

        partial void OnPatternSpeedChanged(double value)
        {
            if (IsLoopRunning)
            {
                _loop.SetPatternSpeed(value);
            }
        }

        private void OnNotification(object? sender, FocstimRpc.Notification e)
        {
            // Handled by DeviceService mostly, but we can react here if needed
        }

        private void OnError(object? sender, string e)
        {
            MainThread.BeginInvokeOnMainThread(() =>
            {
                ConnectionStatus = "Error";
                ConnectionColor = "Red";
            });
        }

        private void OnDisconnected(object? sender, EventArgs e)
        {
            MainThread.BeginInvokeOnMainThread(() =>
            {
                ConnectionStatus = "Disconnected";
                ConnectionColor = "Gray";
                IsLoopRunning = false;
                ButtonText = "Start Circle Pattern";
                ButtonColor = "#27ae60";
            });
        }

        private void OnStatusUpdated(object? sender, EventArgs e)
        {
            var s = _deviceService.Status;
            MainThread.BeginInvokeOnMainThread(() =>
            {
                Temperature = $"{s.Temperature:F1}°C";
                BatteryVoltage = $"{s.BatteryVoltage:F2}V";
                BatterySoc = $"{s.BatterySoc * 100:F0}%";
                WallPower = s.WallPower;
            });
        }
    }
}
