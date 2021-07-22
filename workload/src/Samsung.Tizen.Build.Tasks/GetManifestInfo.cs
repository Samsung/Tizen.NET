using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml.Linq;

using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;

namespace Samsung.Tizen.Build.Tasks
{
    public class GetManifestInfo : Task
    {
        private readonly List<ITaskItem> _applicatonList = new List<ITaskItem>();

        [Required]
        public string ManifestFilePath { get; set; }

        [Output]
        public string PackageName { get; private set; }

        [Output]
        public string PackageVersion { get; private set; }

        [Output]
        public ITaskItem FirstApplication => _applicatonList.Any() ? _applicatonList[0] : null;

        [Output]
        public ITaskItem[] ApplicationList => _applicatonList.ToArray();

        public override bool Execute()
        {
            Log.LogMessage("ManifestFilePath: {0}", ManifestFilePath);

            if (!File.Exists(this.ManifestFilePath))
            {
                Log.LogError("ManifestFilePath is Invalid {0}", ManifestFilePath);
                return !Log.HasLoggedErrors;
            }

            var doc = XDocument.Load(ManifestFilePath);
            Log.LogMessage("{0}", doc.ToString());

            var ns = doc.Root.GetDefaultNamespace();

            PackageName = doc.Element(ns + "manifest")?.Attribute("package")?.Value;
            PackageVersion = doc.Element(ns + "manifest")?.Attribute("version")?.Value;

            if (string.IsNullOrEmpty(PackageName))
            {
                Log.LogError("PackageName is Invalid {0}", PackageName);
                return false;
            }

            if (string.IsNullOrEmpty(PackageVersion))
            {
                Log.LogError("PackageVersion is Invalid {0}", PackageVersion);
                return false;
            }

            Log.LogMessage("Package name : " + PackageName);
            Log.LogMessage("Package version : " + PackageVersion);

            // Get application list
            IEnumerable<XElement> appList = from e in doc.Root.Elements()
                                           where e.Name.Namespace == ns && e.Name.LocalName.EndsWith("-application")
                                           select e;

            foreach (var app in appList) {
                var item = new TaskItem(app.Attribute("appid").Value);
                item.SetMetadata("Exec", app.Attribute("exec").Value);
                item.SetMetadata("Type", app.Name.LocalName);
                _applicatonList.Add(item);
            }

            return true;
        }
    }
}