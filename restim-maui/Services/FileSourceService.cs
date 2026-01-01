using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using SMBLibrary;
using SMBLibrary.Client;
using RestimMaui.Models;

namespace RestimMaui.Services
{
    public interface IFileSourceService
    {
        Task<List<string>> FindFunscriptsAsync(FunscriptLocation location, string videoFilename);
        Task<string> ReadFileAsync(FunscriptLocation location, string path);
    }

    public class FileSourceService : IFileSourceService
    {
        public async Task<List<string>> FindFunscriptsAsync(FunscriptLocation location, string videoFilename)
        {
            if (location.Type == "local")
            {
                // Local file system (Android Scoped Storage limitations might apply here in real usage)
                // For Windows, this is standard IO.
                if (!Directory.Exists(location.LocalPath)) return new List<string>();

                var files = Directory.GetFiles(location.LocalPath, "*.funscript");
                return files.Where(f => Path.GetFileName(f).StartsWith(videoFilename)).ToList();
            }
            else if (location.Type == "webdav") // Or SMB, treating logic similarly
            {
                // Note: The original request mentioned SMB, but the code had WebDAVService.
                // We'll implement SMB here as requested in alternatives.
                // Using SMBLibrary
                return await SearchSmb(location, videoFilename);
            }
            return new List<string>();
        }

        public async Task<string> ReadFileAsync(FunscriptLocation location, string path)
        {
            if (location.Type == "local")
            {
                return await File.ReadAllTextAsync(path);
            }
            else
            {
                return await ReadSmb(location, path);
            }
        }

        private async Task<List<string>> SearchSmb(FunscriptLocation location, string videoFilename)
        {
            // Simplified SMB search
            var client = new SMB2Client();
            var connected = client.Connect(location.WebDavUrl, SMBTransportType.DirectTCPTransport); // URL field used as IP for SMB
            if (!connected) return new List<string>();

            var status = client.Login(string.Empty, location.Username, location.Password);
            if (status != NTStatus.STATUS_SUCCESS) return new List<string>();

            var results = new List<string>();
            // Listing logic would go here (ListDirectory), filtering by videoFilename
            // Omitting full SMB directory walking for brevity in prototype
            client.Disconnect();
            return results;
        }

        private async Task<string> ReadSmb(FunscriptLocation location, string path)
        {
            var client = new SMB2Client();
            var connected = client.Connect(location.WebDavUrl, SMBTransportType.DirectTCPTransport);
            if (!connected) return "{}";

            var status = client.Login(string.Empty, location.Username, location.Password);
            if (status != NTStatus.STATUS_SUCCESS) return "{}";

            // Read file logic
            // ...
            client.Disconnect();
            return "{}"; // Placeholder
        }
    }
}
