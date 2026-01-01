using System;
using System.Collections.Generic;

namespace RestimMaui.Models
{
    public enum DeviceType { None, AudioThreePhase, FocStimThreePhase, NeoStimThreePhase, FocStimFourPhase }
    public enum WaveformType { Continuous, PulseBased, ABTesting }

    public class DeviceSettings
    {
        public DeviceType DeviceType { get; set; } = DeviceType.FocStimThreePhase;
        public WaveformType WaveformType { get; set; } = WaveformType.Continuous;
        public float MinFrequency { get; set; } = 500;
        public float MaxFrequency { get; set; } = 1500;
        public float WaveformAmplitude { get; set; } = 0.120f;
        public float Calibration3Center { get; set; } = -0.5f;
        public float Calibration3Up { get; set; } = 0f;
        public float Calibration3Left { get; set; } = 0f;
    }

    public class PulseSettings
    {
        public float CarrierFrequency { get; set; } = 700;
        public float PulseFrequency { get; set; } = 50;
        public float PulseWidth { get; set; } = 5;
        public float PulseRiseTime { get; set; } = 3;
        public float PulseIntervalRandom { get; set; } = 10;
    }

    public class MediaSyncSettings
    {
        public bool HereSphereEnabled { get; set; }
        public string HereSphereIp { get; set; } = "";
        public int HereSpherePort { get; set; } = 23554;
        public List<FunscriptLocation> FunscriptLocations { get; set; } = new List<FunscriptLocation>();
    }

    public class FunscriptLocation
    {
        public string Id { get; set; } = Guid.NewGuid().ToString();
        public string Name { get; set; } = "";
        public string Type { get; set; } = "local"; // local, webdav
        public bool Enabled { get; set; } = true;
        public string LocalPath { get; set; } = "";
        public string WebDavUrl { get; set; } = "";
        public string Username { get; set; } = "";
        public string Password { get; set; } = "";
    }
    
    public class FocStimSettings
    {
        public string WifiIp { get; set; } = "192.168.1.1";
        public string SerialPort { get; set; } = "COM3";
    }
}
