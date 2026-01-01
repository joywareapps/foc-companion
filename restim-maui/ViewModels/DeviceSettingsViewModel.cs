using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using RestimMaui.Models;
using RestimMaui.Services;

namespace RestimMaui.ViewModels
{
    public partial class DeviceSettingsViewModel : ObservableObject
    {
        private readonly ISettingsService _settingsService;

        [ObservableProperty] private float _minFrequency;
        [ObservableProperty] private float _maxFrequency;
        [ObservableProperty] private float _amplitude;
        [ObservableProperty] private float _calCenter;
        [ObservableProperty] private float _calUp;
        [ObservableProperty] private float _calLeft;

        public DeviceSettingsViewModel(ISettingsService settingsService)
        {
            _settingsService = settingsService;
            Load();
        }

        private void Load()
        {
            var s = _settingsService.Device;
            MinFrequency = s.MinFrequency;
            MaxFrequency = s.MaxFrequency;
            Amplitude = s.WaveformAmplitude * 1000; // mA display
            CalCenter = s.Calibration3Center;
            CalUp = s.Calibration3Up;
            CalLeft = s.Calibration3Left;
        }

        [RelayCommand]
        private async Task Save()
        {
            var s = _settingsService.Device;
            s.MinFrequency = MinFrequency;
            s.MaxFrequency = MaxFrequency;
            s.WaveformAmplitude = Amplitude / 1000f; // Store as Amps
            s.Calibration3Center = CalCenter;
            s.Calibration3Up = CalUp;
            s.Calibration3Left = CalLeft;

            await _settingsService.SaveAsync();
            await Application.Current.MainPage.DisplayAlert("Success", "Settings saved", "OK");
        }

        [RelayCommand]
        private async Task Reset()
        {
            await _settingsService.ResetAsync();
            Load();
        }
    }
}
