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
using Microsoft.Build.Evaluation;

namespace Tizen.NET.Build.Tasks
{
    public class ResourceXmlWriter : Task
    {
        public static readonly string STR_res = "res";
        public static readonly string STR_contents = "contents";
        public static readonly string STR_folder = "folder";
        private static Dictionary<string, string> langMap;
        private static Dictionary<string, bool> dpiMap;
        private string projFullName;
        private string langCountryListXmlPath;

        public enum ResolutionDPI
        {
            All,
            LDPI,
            MDPI,
            HDPI,
            XHDPI,
            XXHDPI
        }

        [Required]
        public string ProjectFullName
        {
            get { return projFullName; }
            set { projFullName = value; }
        }

        [Required]
        public string LangCountryListXmlPath
        {
            get { return langCountryListXmlPath; }
            set { langCountryListXmlPath = value; }
        }


        private bool isValidLanguageID(string langId)
        {
            if (langMap == null)
            {
               XDocument document = XDocument.Load(langCountryListXmlPath + "lang_country_lists.xml");
                langMap = document.Descendants("languages").Descendants("lang")
                      .ToDictionary(d => (string)d.Attribute("id"),
                                    d => (string)d.Attribute("name"));
            }
            if (langId.Equals("default_All")) return true;

            return langMap.ContainsKey(langId);
        }

        private bool isValidResolution(string dpi)
        {
            if (dpiMap == null)
            {
                dpiMap = new Dictionary<string, bool>();
                foreach (string item in Enum.GetNames(typeof(ResolutionDPI)))
                {
                    dpiMap.Add(item, true);
                }
            }
            return dpiMap.ContainsKey(dpi);
        }

        private string getResolution(string dpi)
        {
            switch (dpi)
            {
                case "All": return "";
                case "LDPI": return "from 0 to 240";
                case "MDPI": return "from 241 to 300";
                case "HDPI": return "from 301 to 380";
                case "XHDPI": return "from 381 to 480";
                case "XXHDPI": return "from 481 to 600";
                default: return "";
            }
        }

        public override bool Execute()
        {
           
            string resFolderPath = projFullName + "\\res\\";
            XmlDocument doc = new XmlDocument(); 
            XmlNode docNode = doc.CreateXmlDeclaration("1.0", "UTF-8", "yes");
            doc.AppendChild(docNode);

            XmlNode rootNode = doc.CreateElement(STR_res, "http://tizen.org/ns/rm");
            doc.AppendChild(rootNode);

            XmlElement groupImageNode = doc.CreateElement("group-image", "http://tizen.org/ns/rm");
            groupImageNode.SetAttribute(STR_folder, STR_contents);
            rootNode.AppendChild(groupImageNode);

            XmlElement groupLayoutNode = doc.CreateElement("group-layout", "http://tizen.org/ns/rm");
            groupLayoutNode.SetAttribute(STR_folder, STR_contents);
            rootNode.AppendChild(groupLayoutNode);

            XmlElement groupSoundNode = doc.CreateElement("group-sound", "http://tizen.org/ns/rm");
            groupSoundNode.SetAttribute(STR_folder, STR_contents);
            rootNode.AppendChild(groupSoundNode);

            XmlElement groupBinNode = doc.CreateElement("group-bin", "http://tizen.org/ns/rm");
            groupBinNode.SetAttribute(STR_folder, STR_contents);
            rootNode.AppendChild(groupBinNode);

            DirectoryInfo di = new DirectoryInfo(@resFolderPath + STR_contents);
            if (!di.Exists)
            {
                return true;
            }
            foreach (XmlNode groupNode in doc.DocumentElement.ChildNodes)
            {
                foreach (var fi in di.GetDirectories())
                {
                    String languageID = null;
                    String resolutionRange = null;
                    String folderPath = null;

                    String fileName = fi.Name;
                    folderPath = "contents/" + fileName;
                    if (fileName.Contains("-"))
                    {
                        String[] names = fileName.Split('-');
                        names[0] = names[0];
                        if (isValidLanguageID(names[0]))
                        {
                            languageID = names[0].Equals("default_All") ? "All" : names[0];
                        }
                        if (isValidResolution(names[1]))
                        {
                            resolutionRange = getResolution(names[1]);
                        }
                    }
                    if (languageID == null || resolutionRange == null)
                    {
                        continue;
                    }
                    else
                    {
                        XmlElement node = doc.CreateElement("node", "http://tizen.org/ns/rm");
                        XmlAttribute folder = doc.CreateAttribute(STR_folder);
                        folder.Value = folderPath;
                        node.Attributes.Append(folder);
                        if (resolutionRange.Length != 0)
                        {
                            XmlAttribute screen_dpi_range = doc.CreateAttribute("screen-dpi-range");
                            screen_dpi_range.Value = resolutionRange;
                            node.Attributes.Append(screen_dpi_range);
                        }
                        // Language attribute is not emitted when ALL language is selected
                        if (!languageID.Equals("All"))
                        {
                            XmlAttribute language = doc.CreateAttribute("language");
                            language.Value = languageID;
                            node.Attributes.Append(language);
                        }

                        groupNode.AppendChild(node);
                    }
                }
            }

            using (System.IO.FileStream file = System.IO.File.Open(@resFolderPath + "res.xml", FileMode.Create, FileAccess.Write))
            {
                doc.Save(file);
            }
            return true;
        }
    }
}

