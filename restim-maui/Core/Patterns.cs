using System;

namespace RestimMaui.Core
{
    public struct PatternPosition
    {
        public double X;
        public double Y;
    }

    public interface IThreephasePattern
    {
        string Name { get; }
        PatternPosition Update(double dt);
        void SetVelocity(double velocity);
    }

    public class CirclePattern : IThreephasePattern
    {
        private double _angle = 0;
        private double _amplitude;
        private double _velocity;

        public CirclePattern(double amplitude = 1.0, double velocity = 1.0)
        {
            _amplitude = amplitude;
            _velocity = velocity;
        }

        public string Name => "Circle";

        public PatternPosition Update(double dt)
        {
            _angle += dt * _velocity;
            _angle %= (2 * Math.PI);

            var x = Math.Cos(_angle) * _amplitude;
            var y = Math.Sin(_angle) * _amplitude;

            return new PatternPosition { X = x, Y = y };
        }

        public void SetAmplitude(double amplitude)
        {
            _amplitude = amplitude;
        }

        public void SetVelocity(double velocity)
        {
            _velocity = velocity;
        }
    }
}
