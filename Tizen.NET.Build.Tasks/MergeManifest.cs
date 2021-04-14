/*
 * Copyright 2017 (c) Samsung Electronics Co., Ltd  All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * 	http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

using System;
using System.IO;
using System.IO.Compression;
using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;
using System.Xml;
using System.Xml.Linq;
using System.Linq;
using System.Collections.Generic;

namespace Tizen.NET.Build.Tasks
{
    public class MergeManifest : Task
    {
        private string mainManifestFile;
        private List<ITaskItem> subManifestFileList = new List<ITaskItem>();
        private string resultManifestFile;

        [Required]
        public string MainManifestFile
        {
            get { return mainManifestFile; }
            set { mainManifestFile = value; }
        }

        public ITaskItem[] SubManifestFileList
        {
            set {
                if (value != null)
                    subManifestFileList = value.ToList();
            }
            get { return subManifestFileList?.ToArray(); }
        }

        [Required]
        public string ResultManifestFile
        {
            get { return resultManifestFile; }
            set { resultManifestFile = value; }
        }

        public override bool Execute()
        {
            if (!File.Exists(this.MainManifestFile))
            {
                Log.LogError("Base manifest file was not found {0}", this.MainManifestFile);
                return !Log.HasLoggedErrors;
            }

            Log.LogMessage(MessageImportance.High, "Base manifest file : {0}", this.MainManifestFile);

            foreach (var subManifest in this.subManifestFileList)
                Log.LogMessage(MessageImportance.High, "Sub manifest file : {0}", subManifest.ItemSpec);

            Log.LogMessage(MessageImportance.High, "Result manifest file : {0}", this.resultManifestFile);

            var mainDoc = XDocument.Load(this.MainManifestFile);
            var ns = mainDoc.Root.GetDefaultNamespace();

            //Merge sub manifest to base manifest
            foreach (var subManifest in this.subManifestFileList)
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
                        mainDoc.Root.Element(ns + "privileges").Add(subapp.Descendants(ns + "privilege"));
                    }
                    else if (subapp.Name.LocalName == "account")
                    {
                        mainDoc.Root.Element(ns + "account").Add(subapp.Descendants(ns + "account-provider"));
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
            using (System.IO.FileStream file = System.IO.File.Open(resultManifestFile, FileMode.Create, FileAccess.Write))
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