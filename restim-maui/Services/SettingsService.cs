using System.Text.Json;
using RestimMaui.Models;

namespace RestimMaui.Services
{
    public interface ISettingsService
    {
        DeviceSettings Device { get; }
        PulseSettings Pulse { get; }
        MediaSyncSettings MediaSync { get; }
        FocStimSettings FocStim { get; }
        
        Task SaveAsync();
        Task ResetAsync();
    }

    public class SettingsService : ISettingsService
    {
        public DeviceSettings Device { get; private set; }
        public PulseSettings Pulse { get; private set; }
        public MediaSyncSettings MediaSync { get; private set; }
        public FocStimSettings FocStim { get; private set; }

        public SettingsService()
        {
            // Load synchronously for simplicity in constructor, or use async Init
            Load();
        }

        private void Load()
        {
            Device = LoadSetting<DeviceSettings>("device_settings") ?? new DeviceSettings();
            Pulse = LoadSetting<PulseSettings>("pulse_settings") ?? new PulseSettings();
            MediaSync = LoadSetting<MediaSyncSettings>("media_settings") ?? new MediaSyncSettings();
            FocStim = LoadSetting<FocStimSettings>("focstim_settings") ?? new FocStimSettings();
        }

        private T? LoadSetting<T>(string key)
        {
            var json = Preferences.Default.Get(key, string.Empty);
            return string.IsNullOrEmpty(json) ? default : JsonSerializer.Deserialize<T>(json);
        }

        public async Task SaveAsync()
        {
            Preferences.Default.Set("device_settings", JsonSerializer.Serialize(Device));
            Preferences.Default.Set("pulse_settings", JsonSerializer.Serialize(Pulse));
            Preferences.Default.Set("media_settings", JsonSerializer.Serialize(MediaSync));
            Preferences.Default.Set("focstim_settings", JsonSerializer.Serialize(FocStim));
            await Task.CompletedTask;
        }

        public async Task ResetAsync()
        {
            Device = new DeviceSettings();
            Pulse = new PulseSettings();
            MediaSync = new MediaSyncSettings();
            FocStim = new FocStimSettings();
            await SaveAsync();
        }
    }
}
