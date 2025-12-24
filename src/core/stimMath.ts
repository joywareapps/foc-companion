/**
 * Ported from restim-desktop/stim_math/threephase.py
 */

export interface AbCoefs {
  t11: number;
  t12: number;
  t21: number;
  t22: number;
}

/**
 * deriviation of this matrix is listed on the wiki:
 * https://github.com/diglet48/restim/wiki/technical-documentation
 * 
 * squeeze is this funky projection matrix:
 * [[2 - r + alpha, -beta],
 *  [-beta,         2 - r - alpha]] * 0.5
 */
export function projectOnAbCoefs(alpha: number, beta: number): AbCoefs {
  let r = Math.sqrt(alpha ** 2 + beta ** 2);
  
  // sanitize input
  if (r > 1) {
    alpha /= r;
    beta /= r;
    r = 1;
  }

  const t11 = (2 - r + alpha) / 2;
  const t12 = -beta / 2;
  const t21 = t12;
  const t22 = (2 - r - alpha) / 2;
  
  return { t11, t12, t21, t22 };
}

/**
 * Helper to normalize alpha/beta/gamma to [-1, 1] range if needed,
 * though the patterns usually handle this.
 */
export function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}
