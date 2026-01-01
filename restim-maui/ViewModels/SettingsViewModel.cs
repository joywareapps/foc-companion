using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using RestimMaui.Services;

namespace RestimMaui.ViewModels
{
    public partial class SettingsViewModel : ObservableObject
    {
        private readonly ISettingsService _settings;

        [ObservableProperty] private string _wifiIp;

        public SettingsViewModel(ISettingsService settings)
        {
            _settings = settings;
            _wifiIp = _settings.FocStim.WifiIp;
        }

        [RelayCommand]
        private async Task Save()
        {
            _settings.FocStim.WifiIp = WifiIp;
            await _settings.SaveAsync();
            await Application.Current.MainPage.DisplayAlert("Success", "Settings Saved", "OK");
        }
    }
}
