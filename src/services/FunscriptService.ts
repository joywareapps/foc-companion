// Funscript parsing and playback service
// Handles loading, parsing, and interpreting funscript files

import type {
  Funscript,
  ParsedFunscript,
  FunscriptAction,
  FunscriptResource,
  FunscriptCollection
} from '@/types/heresphere';
import type { FunscriptLocation } from '@/types/settings';
import { collectFunscripts, loadFunscriptFromPath } from './FunscriptCollector';

export class FunscriptService {
  /**
   * Parse funscript JSON data
   */
  static parseFunscript(jsonData: string): ParsedFunscript {
    try {
      const funscript: Funscript = JSON.parse(jsonData);

      if (!funscript.actions || !Array.isArray(funscript.actions)) {
        throw new Error('Invalid funscript: missing or invalid actions array');
      }

      // Sort actions by timestamp
      const sortedActions = [...funscript.actions].sort((a, b) => a.at - b.at);

      // Calculate total duration
      const duration = sortedActions.length > 0
        ? sortedActions[sortedActions.length - 1].at
        : 0;

      return {
        actions: sortedActions,
        inverted: funscript.inverted || false,
        range: funscript.range || 100,
        duration,
      };
    } catch (error: any) {
      console.error('[Funscript] Parse error:', error);
      throw new Error(`Failed to parse funscript: ${error.message}`);
    }
  }

  /**
   * Collect funscripts for a video file from configured locations
   * @param locations Array of funscript locations (WebDAV or local)
   * @param videoIdentifier Video identifier from HereSphere (with extension)
   * @returns Collection of funscripts with primary funscript loaded
   */
  static async collectForVideo(
    locations: FunscriptLocation[],
    videoIdentifier: string
  ): Promise<FunscriptCollection | null> {
    const resources = await collectFunscripts(locations, videoIdentifier);

    if (resources.length === 0) {
      return null;
    }

    // Determine primary funscript (prefer 'alpha', fallback to first)
    let primaryResource = resources.find(r => r.channel === 'alpha');
    if (!primaryResource) {
      primaryResource = resources[0];
    }

    // Load the primary funscript
    try {
      const funscriptData = await loadFunscriptFromPath(primaryResource.path, locations);
      const primaryFunscript = this.parseFunscript(JSON.stringify(funscriptData));

      // Store the parsed funscript in the resource
      primaryResource.funscript = primaryFunscript;

      // Extract video basename (strip extension)
      const videoBasename = videoIdentifier.replace(/\.[^.]+$/, '');

      return {
        videoFilename: videoBasename,
        funscripts: resources,
        primaryFunscript,
      };
    } catch (error) {
      console.error('[Funscript] Failed to load primary funscript:', error);
      throw error;
    }
  }

  /**
   * Load funscript from file path
   * @param filePath Full path to .funscript file (or webdav:// URI)
   * @param locations Optional locations for WebDAV path resolution
   * @returns Parsed funscript
   */
  static async loadFunscriptFromPath(filePath: string, locations?: FunscriptLocation[]): Promise<ParsedFunscript> {
    try {
      const funscriptData = await loadFunscriptFromPath(filePath, locations);
      return this.parseFunscript(JSON.stringify(funscriptData));
    } catch (error) {
      console.error('[Funscript] Failed to load from path:', error);
      throw error;
    }
  }

  /**
   * Get funscript position at specific timestamp
   * Uses linear interpolation between action points
   * @param funscript Parsed funscript data
   * @param timeMs Current playback time in milliseconds
   * @returns Position value (0-100)
   */
  static getPositionAt(funscript: ParsedFunscript, timeMs: number): number {
    const { actions, inverted } = funscript;

    if (actions.length === 0) {
      return 50; // Default middle position
    }

    // Before first action
    if (timeMs < actions[0].at) {
      return inverted ? 100 - actions[0].pos : actions[0].pos;
    }

    // After last action
    if (timeMs >= actions[actions.length - 1].at) {
      const lastPos = actions[actions.length - 1].pos;
      return inverted ? 100 - lastPos : lastPos;
    }

    // Find surrounding actions
    let prevAction = actions[0];
    let nextAction = actions[1];

    for (let i = 0; i < actions.length - 1; i++) {
      if (timeMs >= actions[i].at && timeMs < actions[i + 1].at) {
        prevAction = actions[i];
        nextAction = actions[i + 1];
        break;
      }
    }

    // Linear interpolation
    const timeDelta = nextAction.at - prevAction.at;
    const posDelta = nextAction.pos - prevAction.pos;
    const progress = (timeMs - prevAction.at) / timeDelta;
    const position = prevAction.pos + (posDelta * progress);

    return inverted ? 100 - position : position;
  }

  /**
   * Convert funscript position (0-100) to normalized device position (-1 to 1)
   */
  static funscriptToDevicePosition(funscriptPos: number): number {
    // Funscript: 0-100 range
    // Device: -1.0 to 1.0 range
    // Map 0->-1.0, 50->0.0, 100->1.0
    return (funscriptPos / 50.0) - 1.0;
  }

  /**
   * Validate funscript data
   */
  static validate(funscript: Funscript): { valid: boolean; errors: string[] } {
    const errors: string[] = [];

    if (!funscript.actions) {
      errors.push('Missing actions array');
    } else if (!Array.isArray(funscript.actions)) {
      errors.push('Actions must be an array');
    } else {
      // Validate each action
      funscript.actions.forEach((action, index) => {
        if (typeof action.at !== 'number') {
          errors.push(`Action ${index}: 'at' must be a number`);
        }
        if (typeof action.pos !== 'number') {
          errors.push(`Action ${index}: 'pos' must be a number`);
        }
        if (action.pos < 0 || action.pos > 100) {
          errors.push(`Action ${index}: 'pos' must be between 0 and 100`);
        }
      });
    }

    return {
      valid: errors.length === 0,
      errors,
    };
  }
}
