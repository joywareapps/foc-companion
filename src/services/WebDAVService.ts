// WebDAV client service for accessing funscripts on network shares
// Uses webdav library for HTTP-based WebDAV protocol

import { createClient, WebDAVClient, FileStat } from 'webdav';
import type { FunscriptLocation } from '@/types/settings';

/**
 * WebDAV service for accessing funscript files on network shares
 */
export class WebDAVService {
  private clients: Map<string, WebDAVClient> = new Map();

  /**
   * Get or create WebDAV client for a location
   */
  private getClient(location: FunscriptLocation): WebDAVClient {
    if (!location.webdavUrl || !location.id) {
      throw new Error('Invalid WebDAV location configuration');
    }

    // Check if we already have a client for this location
    if (this.clients.has(location.id)) {
      return this.clients.get(location.id)!;
    }

    // Create new client
    const client = createClient(location.webdavUrl, {
      username: location.webdavUsername || undefined,
      password: location.webdavPassword || undefined,
    });

    this.clients.set(location.id, client);
    return client;
  }

  /**
   * Test WebDAV connection
   * @param location WebDAV location to test
   * @returns true if connection successful, false otherwise
   */
  async testConnection(location: FunscriptLocation): Promise<boolean> {
    try {
      if (location.type !== 'webdav' || !location.webdavUrl) {
        throw new Error('Not a WebDAV location');
      }

      const client = this.getClient(location);

      // Try to get directory contents (root or configured path)
      await client.getDirectoryContents('/');

      console.log(`[WebDAV] Connection test successful: ${location.webdavUrl}`);
      return true;
    } catch (error) {
      console.error(`[WebDAV] Connection test failed for ${location.name}:`, error);
      return false;
    }
  }

  /**
   * List files in a WebDAV directory
   * @param location WebDAV location
   * @param path Path within the WebDAV share (default: root)
   * @returns Array of file statistics
   */
  async listDirectory(location: FunscriptLocation, path: string = '/'): Promise<FileStat[]> {
    try {
      const client = this.getClient(location);
      const contents = await client.getDirectoryContents(path) as FileStat[];
      return contents;
    } catch (error) {
      console.error(`[WebDAV] Failed to list directory ${path}:`, error);
      throw error;
    }
  }

  /**
   * Read file contents from WebDAV share
   * @param location WebDAV location
   * @param filePath Full path to file on WebDAV share
   * @returns File contents as string
   */
  async readFile(location: FunscriptLocation, filePath: string): Promise<string> {
    try {
      const client = this.getClient(location);
      const contents = await client.getFileContents(filePath, { format: 'text' });
      return contents as string;
    } catch (error) {
      console.error(`[WebDAV] Failed to read file ${filePath}:`, error);
      throw error;
    }
  }

  /**
   * Find funscripts matching video basename in WebDAV location
   * @param location WebDAV location to search
   * @param videoBasename Video basename without extension (e.g., "video")
   * @returns Array of matching funscript file paths
   */
  async findFunscripts(location: FunscriptLocation, videoBasename: string): Promise<string[]> {
    try {
      const matchingFiles: string[] = [];

      // List root directory contents
      const files = await this.listDirectory(location, '/');

      // Find matching funscripts
      for (const file of files) {
        if (file.type === 'file' && file.filename.endsWith('.funscript')) {
          // Extract basename from funscript filename
          // e.g., "video.alpha.funscript" -> "video.alpha"
          const funscriptBase = file.basename.replace(/\.funscript$/, '');

          // Match: video.funscript -> "video"
          //        video.alpha.funscript -> "video.alpha"
          // Check if starts with videoBasename
          if (funscriptBase === videoBasename || funscriptBase.startsWith(`${videoBasename}.`)) {
            matchingFiles.push(file.filename);
            console.log(`[WebDAV] Found matching funscript: ${file.filename}`);
          }
        }
      }

      return matchingFiles;
    } catch (error) {
      console.error(`[WebDAV] Error finding funscripts for ${videoBasename}:`, error);
      return [];
    }
  }

  /**
   * Clear cached client for a location
   * Useful when credentials change
   */
  clearClient(locationId: string) {
    this.clients.delete(locationId);
  }

  /**
   * Clear all cached clients
   */
  clearAllClients() {
    this.clients.clear();
  }
}

// Singleton instance
export const webdavService = new WebDAVService();
