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
    // Only include auth if both username AND password are provided
    // Otherwise use anonymous access (no auth headers)
    const hasCredentials = location.webdavUsername && location.webdavPassword;
    const client = createClient(
      location.webdavUrl,
      hasCredentials ? {
        username: location.webdavUsername,
        password: location.webdavPassword,
      } : {}
    );

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

      // Clear cached client to ensure we test with current credentials
      this.clients.delete(location.id);

      const client = this.getClient(location);

      console.log(`[WebDAV] Testing connection to: ${location.webdavUrl}`);
      console.log(`[WebDAV] Username: ${location.webdavUsername ? `${location.webdavUsername} (provided)` : '(none - anonymous)'}`);
      console.log(`[WebDAV] Password: ${location.webdavPassword ? '****** (provided)' : '(none)'}`);
      console.log(`[WebDAV] Auth mode: ${location.webdavUsername && location.webdavPassword ? 'Basic Auth' : 'Anonymous'}`);
      console.log(`[WebDAV] Request: PROPFIND ${location.webdavUrl}/`);

      // Try to get directory contents (root or configured path)
      const contents = await client.getDirectoryContents('/');

      console.log(`[WebDAV] Connection test successful: ${location.webdavUrl}`);
      console.log(`[WebDAV] Found ${Array.isArray(contents) ? contents.length : 0} items`);
      return true;
    } catch (error: any) {
      console.error(`[WebDAV] Connection test failed for ${location.name}:`, error);
      console.error(`[WebDAV] URL: ${location.webdavUrl}`);
      console.error(`[WebDAV] Username provided: ${!!location.webdavUsername}`);
      console.error(`[WebDAV] Password provided: ${!!location.webdavPassword}`);
      console.error(`[WebDAV] Error details:`, {
        message: error.message,
        status: error.status,
        statusText: error.statusText,
        response: error.response,
      });

      // If we get 401, try a simple fetch to see if it's WebDAV-specific
      if (error.status === 401) {
        console.log(`[WebDAV] Testing with simple HTTP GET to check if WebDAV is the issue...`);
        try {
          const response = await fetch(location.webdavUrl);
          console.log(`[WebDAV] Simple GET status: ${response.status}`);
          if (response.ok) {
            console.error(`[WebDAV] Simple GET works but WebDAV PROPFIND fails - WebDAV might not be enabled in IIS`);
          }
        } catch (fetchError) {
          console.error(`[WebDAV] Simple GET also failed:`, fetchError);
        }
      }

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
      // Build full URL
      // filePath should start with / (e.g., "/file.funscript")
      const baseUrl = location.webdavUrl?.endsWith('/')
        ? location.webdavUrl.slice(0, -1)
        : location.webdavUrl;
      const cleanPath = filePath.startsWith('/') ? filePath.slice(1) : filePath;
      const fullUrl = `${baseUrl}/${cleanPath}`;

      console.log(`[WebDAV] Reading file from: ${fullUrl}`);

      // Use simple fetch instead of WebDAV client to avoid 406 errors
      // IIS static file handler works fine with plain GET requests
      const headers: HeadersInit = {};

      // Add basic auth if credentials provided
      if (location.webdavUsername && location.webdavPassword) {
        const credentials = btoa(`${location.webdavUsername}:${location.webdavPassword}`);
        headers['Authorization'] = `Basic ${credentials}`;
      }

      const response = await fetch(fullUrl, {
        method: 'GET',
        headers,
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const contents = await response.text();
      console.log(`[WebDAV] Successfully read file (${contents.length} bytes)`);
      return contents;
    } catch (error: any) {
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
