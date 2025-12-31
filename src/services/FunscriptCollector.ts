// Funscript file collection service
// Based on restim-desktop/funscript/collect_funscripts.py
// Searches locations (WebDAV + local) for funscript files matching video filename

import RNFS from 'react-native-fs';
import type { FunscriptResource } from '@/types/heresphere';
import type { FunscriptLocation } from '@/types/settings';
import { webdavService } from './WebDAVService';

/**
 * Split funscript path into components
 * Example: "video.alpha.funscript" -> ["video", "alpha", "funscript"]
 * Example: "video.funscript" -> ["video", "", "funscript"]
 */
function splitFunscriptPath(filename: string): [string, string, string] {
  const parts = filename.split('.');
  const extension = parts[parts.length - 1];

  if (parts.length === 1) {
    return [parts[0], '', ''];
  }
  if (parts.length === 2) {
    return [parts[0], '', extension];
  }

  // parts.length >= 3
  const basename = parts.slice(0, -2).join('.');
  const channel = parts[parts.length - 2];
  return [basename, channel, extension];
}

/**
 * Extract video filename without extension
 * Example: "/path/to/video.mp4" -> "video"
 * Example: "video.mkv" -> "video"
 */
function getVideoBasename(videoPath: string): string {
  const filename = videoPath.split('/').pop() || videoPath.split('\\').pop() || videoPath;
  const parts = filename.split('.');
  if (parts.length === 1) {
    return parts[0];
  }
  // Remove extension
  return parts.slice(0, -1).join('.');
}

/**
 * Case-insensitive string comparison
 */
function caseInsensitiveCompare(a: string, b: string): boolean {
  return a.toLowerCase() === b.toLowerCase();
}

/**
 * Collect funscripts from a local directory
 */
async function collectFromLocalLocation(
  location: FunscriptLocation,
  videoBasename: string
): Promise<FunscriptResource[]> {
  const resources: FunscriptResource[] = [];

  if (!location.localPath) {
    console.warn(`[FunscriptCollector] Local location ${location.name} has no path`);
    return resources;
  }

  try {
    // Check if directory exists
    const dirExists = await RNFS.exists(location.localPath);
    if (!dirExists) {
      console.warn(`[FunscriptCollector] Directory does not exist: ${location.localPath}`);
      return resources;
    }

    // Read directory contents
    const items = await RNFS.readDir(location.localPath);

    for (const item of items) {
      // Skip subdirectories
      if (item.isDirectory()) {
        continue;
      }

      const filename = item.name;
      const [basename, channel, extension] = splitFunscriptPath(filename);

      // Check if this file matches our video
      if (caseInsensitiveCompare(basename, videoBasename) &&
          caseInsensitiveCompare(extension, 'funscript')) {
        console.log(`[FunscriptCollector] Found (local): ${filename} (channel: ${channel || 'default'})`);

        resources.push({
          filename,
          channel: channel || 'default',
          path: item.path,
        });
      }
    }
  } catch (error) {
    console.error(`[FunscriptCollector] Error reading local directory ${location.localPath}:`, error);
  }

  return resources;
}

/**
 * Collect funscripts from a WebDAV location
 */
async function collectFromWebDAVLocation(
  location: FunscriptLocation,
  videoBasename: string
): Promise<FunscriptResource[]> {
  const resources: FunscriptResource[] = [];

  try {
    // Pass videoBasename to WebDAV service (extension already stripped)
    const funscriptPaths = await webdavService.findFunscripts(location, videoBasename);

    for (const filePath of funscriptPaths) {
      const filename = filePath.split('/').pop() || filePath;
      const [basename, channel, extension] = splitFunscriptPath(filename);

      console.log(`[FunscriptCollector] Found (WebDAV): ${filename} (channel: ${channel || 'default'})`);

      resources.push({
        filename,
        channel: channel || 'default',
        path: `webdav://${location.id}:${filePath}`,  // Special path format for WebDAV
      });
    }
  } catch (error) {
    console.error(`[FunscriptCollector] Error reading WebDAV location ${location.name}:`, error);
  }

  return resources;
}

/**
 * Collect funscripts matching the video identifier from configured locations
 *
 * @param locations - Array of funscript locations (WebDAV or local)
 * @param videoIdentifier - Video identifier from HereSphere (e.g., "video.mp4")
 * @returns Array of funscript resources matching the video
 *
 * Example:
 * - Video identifier: "video.mp4"
 * - Finds: "video.funscript", "video.alpha.funscript", "video.beta.funscript"
 */
export async function collectFunscripts(
  locations: FunscriptLocation[],
  videoIdentifier: string
): Promise<FunscriptResource[]> {
  // Strip extension from identifier to get base filename
  const videoBasename = videoIdentifier.replace(/\.[^.]+$/, '');
  const collectedResources: FunscriptResource[] = [];

  console.log(`[FunscriptCollector] Searching for funscripts matching: ${videoBasename} (from identifier: ${videoIdentifier})`);

  // Search all enabled locations
  for (const location of locations) {
    if (!location.enabled) {
      console.log(`[FunscriptCollector] Skipping disabled location: ${location.name}`);
      continue;
    }

    console.log(`[FunscriptCollector] Searching location: ${location.name} (${location.type})`);

    let locationResources: FunscriptResource[] = [];

    if (location.type === 'local') {
      locationResources = await collectFromLocalLocation(location, videoBasename);
    } else if (location.type === 'webdav') {
      locationResources = await collectFromWebDAVLocation(location, videoBasename);
    }

    collectedResources.push(...locationResources);

    // Stop at first location with funscripts (matches desktop behavior)
    if (locationResources.length > 0) {
      console.log(`[FunscriptCollector] Found ${locationResources.length} funscripts in ${location.name}`);
      break;
    }
  }

  if (collectedResources.length === 0) {
    console.log(`[FunscriptCollector] No funscripts found for ${videoBasename}`);
  }

  return collectedResources;
}

/**
 * Load funscript data from file or WebDAV
 *
 * @param path - File path (local or webdav://locationId:path format)
 * @param location - Optional location for WebDAV paths
 * @returns Parsed funscript JSON
 */
export async function loadFunscriptFromPath(path: string, locations?: FunscriptLocation[]): Promise<any> {
  try {
    // Check if this is a WebDAV path
    if (path.startsWith('webdav://')) {
      const match = path.match(/^webdav:\/\/([^:]+):(.+)$/);
      if (!match) {
        throw new Error('Invalid WebDAV path format');
      }

      const [, locationId, filePath] = match;

      // Find the location
      const location = locations?.find(l => l.id === locationId);
      if (!location) {
        throw new Error(`WebDAV location not found: ${locationId}`);
      }

      // Read from WebDAV
      const fileContent = await webdavService.readFile(location, filePath);
      return JSON.parse(fileContent);
    } else {
      // Read from local filesystem
      const fileContent = await RNFS.readFile(path, 'utf8');
      return JSON.parse(fileContent);
    }
  } catch (error) {
    console.error(`[FunscriptCollector] Failed to load funscript from ${path}:`, error);
    throw new Error(`Failed to load funscript: ${error}`);
  }
}
