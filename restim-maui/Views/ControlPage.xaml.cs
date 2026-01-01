using RestimMaui.ViewModels;

namespace RestimMaui.Views;

public partial class ControlPage : ContentPage
{
	public ControlPage(ControlViewModel vm)
	{
		InitializeComponent();
		BindingContext = vm;
	}
}
