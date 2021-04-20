using System.IO;
using System.IO.Compression;

using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;

namespace Samsung.Tizen.Build.Tasks
{
    class SlashEncoder : System.Text.UTF8Encoding
    {
        public override byte[] GetBytes(string s)
        {
            s = s.Replace("\\", "/");
            return base.GetBytes(s);
        }
    }

    public class Package : Task
    {
        [Required]
        public string TpkSrcPath { get; set; }

        [Required]
        [Output]
        public string UnSignedTpkFile { get; set; }

        public override bool Execute()
        {
            Log.LogMessage("Package");
            Log.LogMessage("TpkSrcPath : {0}", TpkSrcPath);
            Log.LogMessage("UnSignedTpkFile : {0}", UnSignedTpkFile);

            // Check Path
            if (!Directory.Exists(TpkSrcPath))
            {
                Log.LogError("TpkOutPath is Invalid {0}", TpkSrcPath);
                return !Log.HasLoggedErrors;
            }

            if (File.Exists(UnSignedTpkFile))
            {
                Log.LogWarning("UnSignedTpkFile is already exist. Remove previouse file {0}", UnSignedTpkFile);
                File.Delete(UnSignedTpkFile);
            }

            // Zipping to TPK
            ZipFile.CreateFromDirectory(
                                    TpkSrcPath,
                                    UnSignedTpkFile,
                                    CompressionLevel.Optimal, false,
                                    new SlashEncoder());

            return !Log.HasLoggedErrors;
        }
    }
}