using RestimMaui.ViewModels;

namespace RestimMaui.Views;

public partial class MediaSyncPage : ContentPage
{
	public MediaSyncPage(MediaSyncViewModel vm)
	{
		InitializeComponent();
		BindingContext = vm;
	}
}
