using RestimMaui.ViewModels;

namespace RestimMaui.Views;

public partial class PulseSettingsPage : ContentPage
{
	public PulseSettingsPage(PulseSettingsViewModel vm)
	{
		InitializeComponent();
		BindingContext = vm;
	}
}
