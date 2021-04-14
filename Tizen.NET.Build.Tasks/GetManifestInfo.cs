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
    public class GetManifestInfo : Task
    {
        private string manifestFilePath;
        private string tpkName;
        private string tpkVersion;
        private readonly List<ITaskItem> _tpkExecList = new List<ITaskItem>();

        [Required]
        public string ManifestFilePath
        {
            get { return manifestFilePath; }
            set { manifestFilePath = value; }
        }

        [Output]
        public string TpkName
        {
            get { return tpkName; }
        }

        [Output]
        public string TpkVersion
        {
            get { return tpkVersion; }
        }

        [Output]
        public ITaskItem[] TpkExecList
        {
            get { return _tpkExecList.ToArray(); }
        }

        public override bool Execute()
        {
            Log.LogMessage("ManifestFilePath: {0}", this.ManifestFilePath);

            if (!File.Exists(this.ManifestFilePath))
            {
                Log.LogError("ManifestFilePath is Invalid {0}", this.ManifestFilePath);
                return !Log.HasLoggedErrors;
            }

            var doc = XDocument.Load(ManifestFilePath);
            Log.LogMessage("{0}", doc.ToString());

            var ns = doc.Root.GetDefaultNamespace();

            tpkName = doc.Element(ns + "manifest")?.Attribute("package")?.Value;
            tpkVersion = doc.Element(ns + "manifest")?.Attribute("version")?.Value;

            if (String.IsNullOrEmpty(tpkName))
            {
                Log.LogError("tpkName is Invalid {0}", tpkName);
                return false;
            }

            if (String.IsNullOrEmpty(tpkVersion))
            {
                Log.LogError("tpkVersion is Invalid {0}", tpkVersion);
                return false;
            }

            Log.LogMessage("Package name : " + tpkName);
            Log.LogMessage("Package version : " + tpkVersion);

            // Get exec list
            var a = from e in doc.Root.Elements()
                    where (e.Name == ns + "ui-application") && (e.Attribute("exec") != null)
                    select e.Attribute("exec").Value;

            Log.LogMessage("Exec Count : " + a.Count());
            int count = 0;
            foreach (var x in a)
            {
                Log.LogMessage("Exec[{0}] Name : {1}" , count++, x);
                _tpkExecList.Add(new TaskItem(x));
            }

            return true;
        }
    }
}