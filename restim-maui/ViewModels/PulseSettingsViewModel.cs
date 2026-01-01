using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using RestimMaui.Services;

namespace RestimMaui.ViewModels
{
    public partial class PulseSettingsViewModel : ObservableObject
    {
        private readonly ISettingsService _settingsService;

        [ObservableProperty] private float _carrierFreq;
        [ObservableProperty] private float _pulseFreq;
        [ObservableProperty] private float _pulseWidth;
        [ObservableProperty] private float _pulseRise;
        [ObservableProperty] private float _pulseRandom;

        // Limits for Sliders
        public float MinCarrier => _settingsService.Device.MinFrequency;
        public float MaxCarrier => _settingsService.Device.MaxFrequency;

        public PulseSettingsViewModel(ISettingsService settingsService)
        {
            _settingsService = settingsService;
            Load();
        }

        public void Load()
        {
            var s = _settingsService.Pulse;
            CarrierFreq = s.CarrierFrequency;
            PulseFreq = s.PulseFrequency;
            PulseWidth = s.PulseWidth;
            PulseRise = s.PulseRiseTime;
            PulseRandom = s.PulseIntervalRandom;
            OnPropertyChanged(nameof(MinCarrier));
            OnPropertyChanged(nameof(MaxCarrier));
        }

        [RelayCommand]
        private async Task Save()
        {
            var s = _settingsService.Pulse;
            s.CarrierFrequency = CarrierFreq;
            s.PulseFrequency = PulseFreq;
            s.PulseWidth = PulseWidth;
            s.PulseRiseTime = PulseRise;
            s.PulseIntervalRandom = PulseRandom;

            await _settingsService.SaveAsync();
            await Application.Current.MainPage.DisplayAlert("Success", "Pulse settings saved", "OK");
        }
    }
}
