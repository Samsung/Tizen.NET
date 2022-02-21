using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

using System.Text.RegularExpressions;
using System.Xml.Linq;

using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;

using Samsung.Tizen;

namespace Samsung.Tizen.Build.Tasks
{
    public class CheckApiVersion : Task
    {
        [Required]
        public string ManifestApiVersion { get; set; }

        [Required]
        public string TargetFramework { get; set; }

        [Required]
        public string TargetFrameworkIdentifier { get; set; }

        [Required]
        public string TargetPlatformIdentifier { get; set; }

        [Required]
        public string TargetFrameworkVersion { get; set; }

        [Required]
        public string TargetPlatformVersion { get; set; }

        [Required]
        public ITaskItem[] SupportedAPILevelList { get; set; }

        Version ApiVersion;

        public override bool Execute()
        {
            if (string.IsNullOrEmpty(ManifestApiVersion))
            {
                Log.LogError("ManifestApiVersion is Invalid {0}", ManifestApiVersion);
                return false;
            }
            Version.TryParse(ManifestApiVersion + ".0", out Version parsedManifestApiVersion);

            if (TargetFrameworkIdentifier == ".NETCoreApp" && TargetPlatformIdentifier == "tizen")
            {
                if (string.IsNullOrEmpty(TargetPlatformVersion))
                {
                    Log.LogError("TargetPlatformVersion is Invalid {0}", TargetPlatformVersion);
                    return false;
                }
                Version.TryParse(TargetPlatformVersion, out ApiVersion);

                if (parsedManifestApiVersion < ApiVersion)
                {
                    Log.LogError("The api-version specified in tizen-manifest file is {0}.", ManifestApiVersion);
                    Log.LogError("Current target framework {0} is not supported in this api-version.", TargetFramework);
                    return false;
                }
            }
            else if (TargetFrameworkIdentifier == "Tizen")
            {
                if (string.IsNullOrEmpty(TargetFrameworkVersion))
                {
                    Log.LogError("TargetFrameworkVersion is Invalid {0}", TargetFrameworkVersion);
                    return false;
                }

                foreach(ITaskItem item in SupportedAPILevelList)
                {
                    if (Regex.IsMatch(item.ItemSpec, TargetFrameworkVersion))
                    {
                        Version.TryParse(item.GetMetadata("MappedAPIVersion"), out ApiVersion);
                        break;
                    }
                }

                if (parsedManifestApiVersion < ApiVersion)
                {
                    Log.LogError("The api-version specified in tizen-manifest file is {0}.", ManifestApiVersion);
                    Log.LogError("Current target framework {0} is not supported in this api-version.", TargetFramework);
                    return false;
                }
            }

            return true;
        }
    }
}
