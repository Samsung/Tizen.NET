using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml.Linq;
using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;

namespace Samsung.Tizen.Build.Tasks
{
    public class MergeManifest : Task
    {
        private List<ITaskItem> subManifestFileList = new List<ITaskItem>();

        [Required]
        public string MainManifestFile { get; set; }

        public ITaskItem[] SubManifestFileList
        {
            set
            {
                if (value != null)
                    subManifestFileList = value.ToList();
            }
            get { return subManifestFileList?.ToArray(); }
        }

        [Required]
        public string ResultManifestFile { get; set; }

        public override bool Execute()
        {
            if (!File.Exists(MainManifestFile))
            {
                Log.LogError("Base manifest file was not found {0}", MainManifestFile);
                return !Log.HasLoggedErrors;
            }

            Log.LogMessage(MessageImportance.High, "Base manifest file : {0}", MainManifestFile);

            foreach (var subManifest in subManifestFileList)
                Log.LogMessage(MessageImportance.High, "Sub manifest file : {0}", subManifest.ItemSpec);

            Log.LogMessage(MessageImportance.High, "Result manifest file : {0}", ResultManifestFile);

            var mainDoc = XDocument.Load(MainManifestFile);
            var ns = mainDoc.Root.GetDefaultNamespace();

            //Merge sub manifest to base manifest
            foreach (var subManifest in subManifestFileList)
            {
                if (!File.Exists(subManifest.ItemSpec))
                {
                    Log.LogError("Sub manifest file was not found {0}", subManifest.ItemSpec);
                    return !Log.HasLoggedErrors;
                }

                var subDoc = XDocument.Load(subManifest.ItemSpec);

                var subElemList = subDoc.Root.Elements();
                foreach (var subapp in subElemList)
                {
                    if (subapp.Name.LocalName == "ui-application" ||
                        subapp.Name.LocalName == "service-application" ||
                        subapp.Name.LocalName == "widget-application" ||
                        subapp.Name.LocalName == "ime-application" ||
                        subapp.Name.LocalName == "watch-application"
                        )
                    {
                        mainDoc.Root.Add(subapp);
                    }
                    else if (subapp.Name.LocalName == "privileges")
                    {
                        if (mainDoc.Root.Element(ns + "privileges") == null)
                        {
                            mainDoc.Root.Add(subapp);
                        }
                        else
                        {
                            mainDoc.Root.Element(ns + "privileges").Add(subapp.Descendants(ns + "privilege"));
                        }
                    }
                    else if (subapp.Name.LocalName == "account")
                    {
                        if (mainDoc.Root.Element(ns + "account") == null)
                        {
                            mainDoc.Root.Add(subapp);
                        }
                        else
                        {
                            mainDoc.Root.Element(ns + "account").Add(subapp.Descendants(ns + "account-provider"));
                        }
                    }
                    else if (subapp.Name.LocalName == "feature")
                    {
                        mainDoc.Root.Add(subapp);
                    }
                }
            }

            // Remove duplicate privilege
            mainDoc.Root.Elements(ns + "privileges").SelectMany(s => s.Elements(ns + "privilege").GroupBy(g => g.Value).SelectMany(m => m.Skip(1))).Remove();

            // Remove duplicate feature
            mainDoc.Root.Elements(ns + "feature").GroupBy(g => g.Attribute("name").Value).SelectMany(m => m.Skip(1)).Remove();

            // Reorder
            XElement[] sortedTables = mainDoc.Root.Elements().OrderBy(t => t, new ElementNameComparer()).ToArray();
            mainDoc.Root.ReplaceNodes(sortedTables);

            Log.LogMessage("Merged manifest document \n{0}", mainDoc.ToString());

            // Save Merged Manifest
            using (var file = File.Open(ResultManifestFile, FileMode.Create, FileAccess.Write))
            {
                mainDoc.Save(file);
            }

            return true;
        }

    }
    public static class DicHelper
    {
        public static TValue GetValueOrDefault<TKey, TValue>
            (this IDictionary<TKey, TValue> dictionary,
             TKey key,
             TValue defaultValue)
        {
            TValue value;
            return dictionary.TryGetValue(key, out value) ? value : defaultValue;
        }
    };

    internal class ElementNameComparer : IComparer<XElement>
    {
        static Dictionary<string, int> dic = new Dictionary<string, int>
            {
                { "author", 1},
                { "description", 2},
                { "profile", 3},
                { "ui-application", 4},
                { "service-application", 5},
                { "widget-application", 6},
                { "watch-application", 7},
                { "ime-application", 8},
                { "shortcut-list", 9},
                { "account", 10},
                { "privileges", 11},
                { "feature", 12},
            };

        public int Compare(XElement x, XElement y)
        {
            int x_order, y_order;

            x_order = dic.GetValueOrDefault(x.Name.LocalName, 99);
            y_order = dic.GetValueOrDefault(y.Name.LocalName, 99);

            return x_order - y_order;
        }
    }
}