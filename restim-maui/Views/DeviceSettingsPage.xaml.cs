using RestimMaui.ViewModels;

namespace RestimMaui.Views;

public partial class DeviceSettingsPage : ContentPage
{
	public DeviceSettingsPage(DeviceSettingsViewModel vm)
	{
		InitializeComponent();
		BindingContext = vm;
	}
}
