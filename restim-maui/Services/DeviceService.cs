using System.ComponentModel;
using CommunityToolkit.Mvvm.ComponentModel;
using RestimMaui.Models;

namespace RestimMaui.Services
{
    public interface IDeviceService
    {
        DeviceStatus Status { get; }
        event EventHandler StatusUpdated;
        void UpdateStatus(DeviceStatus status);
    }

    public class DeviceStatus
    {
        public float Temperature { get; set; }
        public float BatteryVoltage { get; set; }
        public float BatterySoc { get; set; }
        public bool WallPower { get; set; }
        public float PulseFrequency { get; set; }
        public float VDrive { get; set; }
    }

    public partial class DeviceService : ObservableObject, IDeviceService
    {
        [ObservableProperty]
        private DeviceStatus _status = new DeviceStatus();

        public event EventHandler? StatusUpdated;

        public void UpdateStatus(DeviceStatus status)
        {
            Status = status;
            StatusUpdated?.Invoke(this, EventArgs.Empty);
        }
    }
}
