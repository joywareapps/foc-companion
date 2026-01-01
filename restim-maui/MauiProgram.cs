using Microsoft.Extensions.Logging;
using CommunityToolkit.Maui;
using RestimMaui.Services;
using RestimMaui.ViewModels;
using RestimMaui.Views;
using RestimMaui.Core;

namespace RestimMaui
{
    public static class MauiProgram
    {
        public static MauiApp CreateMauiApp()
        {
            var builder = MauiApp.CreateBuilder();
            builder
                .UseMauiApp<App>()
                .UseMauiCommunityToolkit()
                .ConfigureFonts(fonts =>
                {
                    fonts.AddFont("SpaceMono-Regular.ttf", "SpaceMono");
                    fonts.AddFont("SpaceMono-Regular.ttf", "OpenSansRegular");
                    fonts.AddFont("SpaceMono-Regular.ttf", "OpenSansSemibold");
                });

#if DEBUG
    		builder.Logging.AddDebug();
#endif

            // Register Services
            builder.Services.AddSingleton<ISettingsService, SettingsService>();
            builder.Services.AddSingleton<IDeviceService, DeviceService>(); // Replaces DeviceStore
            builder.Services.AddSingleton<IFocStimApiService, FocStimApiService>();
            builder.Services.AddSingleton<CommandLoop>();
            builder.Services.AddSingleton<IHereSphereService, HereSphereService>();
            
            // Platform specific Serial Service (Placeholder for now)
            builder.Services.AddSingleton<ISerialService, SerialService>();

            // Register ViewModels
            builder.Services.AddTransient<ControlViewModel>();
            builder.Services.AddTransient<DeviceSettingsViewModel>();
            builder.Services.AddTransient<PulseSettingsViewModel>();
            builder.Services.AddTransient<MediaSyncViewModel>();
            builder.Services.AddTransient<SettingsViewModel>();

            // Register Views
            builder.Services.AddTransient<ControlPage>();
            builder.Services.AddTransient<DeviceSettingsPage>();
            builder.Services.AddTransient<PulseSettingsPage>();
            builder.Services.AddTransient<MediaSyncPage>();
            builder.Services.AddTransient<SettingsPage>();

            return builder.Build();
        }
    }
}
