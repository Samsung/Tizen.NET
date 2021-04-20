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
        private readonly List<ITaskItem> _tpkExecList = new List<ITaskItem>();

        [Required]
        public string ManifestFilePath { get; set; }

        [Output]
        public string TpkName { get; private set; }

        [Output]
        public string TpkVersion { get; private set; }

        [Output]
        public ITaskItem[] TpkExecList
        {
            get { return _tpkExecList.ToArray(); }
        }

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

            TpkName = doc.Element(ns + "manifest")?.Attribute("package")?.Value;
            TpkVersion = doc.Element(ns + "manifest")?.Attribute("version")?.Value;

            if (string.IsNullOrEmpty(TpkName))
            {
                Log.LogError("tpkName is Invalid {0}", TpkName);
                return false;
            }

            if (string.IsNullOrEmpty(TpkVersion))
            {
                Log.LogError("tpkVersion is Invalid {0}", TpkVersion);
                return false;
            }

            Log.LogMessage("Package name : " + TpkName);
            Log.LogMessage("Package version : " + TpkVersion);

            // Get exec list
            IEnumerable<string> execList = from e in doc.Root.Elements()
                                           where (e.Name == ns + "ui-application") && (e.Attribute("exec") != null)
                                           select e.Attribute("exec").Value;

            Log.LogMessage("Exec Count : " + execList.Count());
            int count = 0;
            foreach (var exec in execList)
            {
                Log.LogMessage("Exec[{0}] Name : {1}", count++, exec);
                _tpkExecList.Add(new TaskItem(exec));
            }

            return true;
        }
    }
}