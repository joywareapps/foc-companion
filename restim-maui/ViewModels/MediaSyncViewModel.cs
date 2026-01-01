using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using RestimMaui.Models;
using RestimMaui.Services;
using System.Collections.ObjectModel;

namespace RestimMaui.ViewModels
{
    public partial class MediaSyncViewModel : ObservableObject
    {
        private readonly ISettingsService _settings;
        private readonly IHereSphereService _hereSphere;

        [ObservableProperty] private bool _enabled;
        [ObservableProperty] private string _ip = "";
        [ObservableProperty] private string _port = "23554";
        
        public ObservableCollection<FunscriptLocation> Locations { get; } = new();

        public MediaSyncViewModel(ISettingsService settings, IHereSphereService hereSphere)
        {
            _settings = settings;
            _hereSphere = hereSphere;
            Load();
        }

        private void Load()
        {
            var s = _settings.MediaSync;
            Enabled = s.HereSphereEnabled;
            Ip = s.HereSphereIp;
            Port = s.HereSpherePort.ToString();
            
            Locations.Clear();
            foreach(var loc in s.FunscriptLocations) Locations.Add(loc);
        }

        [RelayCommand]
        private async Task Save()
        {
            _settings.MediaSync.HereSphereEnabled = Enabled;
            _settings.MediaSync.HereSphereIp = Ip;
            if (int.TryParse(Port, out int p)) _settings.MediaSync.HereSpherePort = p;
            
            // Locations are ref types, already in list, but explicit save ensures persistence
            _settings.MediaSync.FunscriptLocations = new List<FunscriptLocation>(Locations);
            
            await _settings.SaveAsync();
            
            if (Enabled)
            {
                _hereSphere.Configure(Ip, _settings.MediaSync.HereSpherePort);
            }
        }

        [RelayCommand]
        private void AddLocation()
        {
            // For prototype, just add a dummy local
            Locations.Add(new FunscriptLocation { Name = "New Location", Type = "local", LocalPath = "C:\\Data" });
        }
        
        [RelayCommand]
        private void RemoveLocation(FunscriptLocation loc)
        {
            Locations.Remove(loc);
        }
    }
}
