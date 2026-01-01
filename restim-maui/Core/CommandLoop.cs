using System;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;
using RestimMaui.Services;
using FocstimRpc;

namespace RestimMaui.Core
{
    public class CommandLoop
    {
        private readonly IFocStimApiService _api;
        private readonly ISettingsService _settings;
        private readonly IThreephasePattern _pattern;
        
        private CancellationTokenSource? _cts;
        private Task? _loopTask;
        private bool _isRunning;
        private double _patternSpeed = 2.0;

        public CommandLoop(IFocStimApiService api, ISettingsService settings)
        {
            _api = api;
            _settings = settings;
            _pattern = new CirclePattern(1.0, _patternSpeed);
        }

        public bool IsRunning => _isRunning;

        public void SetPatternSpeed(double speed)
        {
            _patternSpeed = speed;
            _pattern.SetVelocity(speed);
        }

        public async Task StartAsync()
        {
            if (_isRunning) return;

            // Send initial config
            await SetupSignalParameters();
            await _api.StartSignalAsync();

            _cts = new CancellationTokenSource();
            _isRunning = true;
            _loopTask = Loop(_cts.Token);
        }

        public async Task StopAsync()
        {
            if (!_isRunning) return;

            _cts?.Cancel();
            try
            {
                if (_loopTask != null) await _loopTask;
            }
            catch (OperationCanceledException) { }

            _isRunning = false;
            await _api.StopSignalAsync();
        }

        private async Task Loop(CancellationToken token)
        {
            var timer = new PeriodicTimer(TimeSpan.FromMilliseconds(16)); // ~60Hz
            var sw = Stopwatch.StartNew();
            double lastTime = 0;
            double startTime = sw.Elapsed.TotalSeconds;

            while (await timer.WaitForNextTickAsync(token))
            {
                if (!_api.IsConnected) continue;

                double currentTime = sw.Elapsed.TotalSeconds;
                double dt = currentTime - lastTime;
                lastTime = currentTime;

                // Update pattern
                var pos = _pattern.Update(dt);

                // Ramp logic
                double elapsed = currentTime - startTime;
                float targetAmp = _settings.Device.WaveformAmplitude;
                float currentAmp = (float)(targetAmp * Math.Min(elapsed / 5.0, 1.0)); // 5s ramp

                // Send updates
                // Note: We fire and forget these sends to keep the loop tight, 
                // or await them if we want backpressure. 
                // For 60Hz, fire-and-forget is risky if the transport is slow.
                // We'll await but with a very short timeout or just assume the buffer handles it.
                // Protocol buffer creation:
                
                try 
                {
                    // Alpha
                    await _api.SendRequestAsync(new Request {
                        RequestAxisMoveTo = new RequestAxisMoveTo {
                            Axis = AxisType.AxisPositionAlpha,
                            Value = (float)pos.X,
                            Interval = 50
                        }
                    });

                    // Beta
                    await _api.SendRequestAsync(new Request {
                        RequestAxisMoveTo = new RequestAxisMoveTo {
                            Axis = AxisType.AxisPositionBeta,
                            Value = (float)pos.Y,
                            Interval = 50
                        }
                    });

                    // Amplitude
                    await _api.SendRequestAsync(new Request {
                        RequestAxisMoveTo = new RequestAxisMoveTo {
                            Axis = AxisType.AxisWaveformAmplitudeAmps,
                            Value = currentAmp,
                            Interval = 50
                        }
                    });
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Loop error: {ex.Message}");
                }
            }
        }

        private async Task SetupSignalParameters()
        {
            var p = _settings.Pulse;
            var d = _settings.Device;

            // Helper to send MoveTo
            async Task Send(AxisType axis, float val) => await _api.SendRequestAsync(new Request {
                RequestAxisMoveTo = new RequestAxisMoveTo { Axis = axis, Value = val, Interval = 0 }
            });

            await Send(AxisType.AxisCarrierFrequencyHz, p.CarrierFrequency);
            await Send(AxisType.AxisPulseFrequencyHz, p.PulseFrequency);
            await Send(AxisType.AxisPulseWidthInCycles, p.PulseWidth);
            await Send(AxisType.AxisPulseRiseTimeCycles, p.PulseRiseTime);
            await Send(AxisType.AxisPulseIntervalRandomPercent, p.PulseIntervalRandom / 100f);
            
            await Send(AxisType.AxisCalibration3Center, d.Calibration3Center);
            await Send(AxisType.AxisCalibration3Up, d.Calibration3Up);
            await Send(AxisType.AxisCalibration3Left, d.Calibration3Left);
        }
    }
}
