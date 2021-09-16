// https://github.com/xamarin/xamarin-macios/blob/ef91c798dc6a12acf6521d65add255ab0e435dbe/dotnet/generate-wix.csharp

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;

namespace Samsung.Tizen.Build.PrepTasks
{
    public class GenerateWixFile : Task
    {
        [Required]
        public ITaskItem SourceFile { get; set; }

        [Required]
        public string ProductName { get; set; }

        [Required]
        public string ProductCode { get; set; }

        [Required]
        public string ProductVersion { get; set; }

        [Required]
        public string WorkloadVersion { get; set; }

        [Required]
        public string UpgradeCode { get; set; }

        [Required]
        public ITaskItem DestinationFile { get; set; }

        [Required]
        public string BaseDirectory { get; set; }

        [Required]
        public string SourceDirectory { get; set; }

        private Dictionary<string, string> replacements = new Dictionary<string, string>();
        private List<string> components = new List<string>();
        private List<string> componentFiles = new List<string>();

        public override bool Execute()
        {
            replacements.Add("@PRODUCT_NAME@", ProductName);
            replacements.Add("@PRODUCT_CODE@", ProductCode);
            replacements.Add("@PRODUCT_VERSION@", ProductVersion);
            replacements.Add("@UPGRADE_CODE@", UpgradeCode);
            replacements.Add("@DIRECTORIES@", GetDirectoriesPart(BaseDirectory));
            replacements.Add("@COMPONENTS@", GetComponentsPart());

            var outDir = Directory.CreateDirectory(Path.GetDirectoryName(DestinationFile.ItemSpec));

            if (File.Exists(DestinationFile.ItemSpec))
            {
                File.Delete(DestinationFile.ItemSpec);
            }

            using (var i = File.OpenText(SourceFile.ItemSpec))
            using (var o = File.CreateText(DestinationFile.ItemSpec))
            {
                string line;
                while ((line = i.ReadLine()) != null)
                {
                    foreach (var e in replacements)
                    {
                        line = line.Replace(e.Key, e.Value);
                    }
                    o.WriteLine(line);
                }
            }

            // Generate msi.json file
            var msiJsonFile = Path.Combine(outDir.FullName, "msi.json");
            if (File.Exists(msiJsonFile))
            {
                File.Delete(msiJsonFile);
            }
            long installedSize = 0;
            foreach (var entry in componentFiles)
            {
                installedSize += new FileInfo(entry).Length;
            }
            var payload = Path.GetFileNameWithoutExtension(DestinationFile.ItemSpec) + "-x64.msi";
            var content = "{"
                    + $@"""InstallSize"":{installedSize},""Language"":1033,"
                    + $@"""Payload"":""{payload}"","
                    + $@"""ProductCode"":""{{{ProductCode}}}"",""ProductVersion"":""{ProductVersion}"","
                    + $@"""ProviderKeyName"":""{ProductName},{WorkloadVersion},x64"","
                    + $@"""UpgradeCode"":""{{{UpgradeCode}}}"","
                    + $@"""RelatedProducts"":[]}}";
            File.WriteAllText(msiJsonFile, content);

            return !Log.HasLoggedErrors;
        }

        private string GetDirectoriesPart(string directory)
        {
            var ret = new StringBuilder();
            var entries = Directory.GetFileSystemEntries(directory);
            foreach (var entry in entries)
            {
                if (!entry.StartsWith(SourceDirectory) && !SourceDirectory.StartsWith(entry + Path.DirectorySeparatorChar)) continue;

                var id = GetId(entry);
                var name = Path.GetFileName(entry);
                if (Directory.Exists(entry))
                {
                    ret.AppendLine($"<Directory Id=\"{ id }\" Name=\"{ name }\">");
                    ret.Append(GetDirectoriesPart(entry));
                    ret.AppendLine("</Directory>");
                }
                else
                {
                    components.Add(id);
                    componentFiles.Add(entry);
                    ret.AppendLine($"<Component Id=\"{ id }\" Guid=\"*\">");
                    ret.AppendLine($"  <File Id=\"file_{ id }\" Name=\"{ name }\" KeyPath=\"yes\" Source=\"{ entry }\" />");
                    ret.AppendLine("</Component>");
                }
            }

            return ret.ToString();
        }

        private string GetComponentsPart()
        {
            var ret = new StringBuilder();
            foreach (var component in components)
            {
                ret.AppendLine($"  <ComponentRef Id=\"{ component }\" />");
            }

            return ret.ToString();
        }

        private byte[] GetHash(string inputString)
        {
            using (var algorithm = SHA256.Create())
            {
                return algorithm.ComputeHash(Encoding.UTF8.GetBytes(inputString));
            }
        }

        private string GetHashString(string inputString)
        {
            var sb = new StringBuilder("S", 65);
            foreach (byte b in GetHash(inputString))
                sb.Append(b.ToString("X2"));
            Console.WriteLine($"{inputString} => {sb.ToString()}");
            return sb.ToString();
        }

        private string GetId(string path)
        {
            var top_dir = SourceDirectory;
            if (string.IsNullOrEmpty(path))
                return path;
            if (path.Length > top_dir.Length + 1)
            {
                path = path.Substring(top_dir.Length);
            }
            return GetHashString(path);
        }

    }
}
