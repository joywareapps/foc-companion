/**
 * Ported from restim-desktop/qt_ui/patterns/threephase/
 */

export interface PatternPosition {
  x: number;
  y: number;
}

export interface ThreephasePattern {
  name(): string;
  update(dt: number): PatternPosition;
}

export class CirclePattern implements ThreephasePattern {
  private angle: number = 0;
  private amplitude: number;
  private velocity: number;

  constructor(amplitude: number = 1.0, velocity: number = 1.0) {
    this.amplitude = amplitude;
    this.velocity = velocity;
  }

  name(): string {
    return "Circle";
  }

  update(dt: number): PatternPosition {
    this.angle += dt * this.velocity;
    
    // Normalize angle to keep it within [0, 2*PI] to avoid precision issues over long runs
    this.angle = this.angle % (2 * Math.PI);

    const x = Math.cos(this.angle) * this.amplitude;
    const y = Math.sin(this.angle) * this.amplitude;
    
    return { x, y };
  }
  
  setAmplitude(amplitude: number) {
    this.amplitude = amplitude;
  }
  
  setVelocity(velocity: number) {
    this.velocity = velocity;
  }
}
