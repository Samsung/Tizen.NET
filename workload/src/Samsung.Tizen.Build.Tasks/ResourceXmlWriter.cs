using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml;
using System.Xml.Linq;

using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;

namespace Samsung.Tizen.Build.Tasks
{
    public class ResourceXmlWriter : Task
    {
        private const string STR_RES = "res";
        private const string STR_CONTENTS = "contents";
        private const string STR_FOLDER = "folder";
        private static Dictionary<string, string> langMap;
        private static Dictionary<string, bool> dpiMap;

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
        public string ProjectFullName { get; set; }

        [Required]
        public string LangCountryListXmlPath { get; set; }

        [Output]
        public string ResourceXmlPath { get; private set; }

        private bool IsValidLanguageID(string langId)
        {
            if (langMap == null)
            {
                XDocument document = XDocument.Load(LangCountryListXmlPath + "lang_country_lists.xml");
                langMap = document.Descendants("languages").Descendants("lang")
                      .ToDictionary(d => (string)d.Attribute("id"),
                                    d => (string)d.Attribute("name"));
            }
            if (langId.Equals("default_All")) return true;

            return langMap.ContainsKey(langId);
        }

        private bool IsValidResolution(string dpi)
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

        private string GetResolution(string dpi)
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

        private Tuple<string, string> ParseLanguageAndResolution(string name)
        {
            Tuple<string, string> result = new Tuple<string, string>("default_All", "All");

            if (name.Contains("-"))
            {
                string[] nameSplit = name.Split('-');
                if (IsValidLanguageID(nameSplit[0]) && IsValidResolution(nameSplit[1]))
                {
                    result = new Tuple<string, string>(nameSplit[0], nameSplit[1]);
                }
                else
                {
                    Log.LogWarning("Invalid language or resolution. {0}", name);
                }
            }
            else
            {
                if (IsValidLanguageID(name))
                {
                    result = new Tuple<string, string>(name, "All");
                }
                else if (IsValidResolution(name))
                {
                    result = new Tuple<string, string>("default_All", name);
                }
            }
            return result;
        }

        public override bool Execute()
        {
            XmlDocument doc = new XmlDocument();
            XmlNode docNode = doc.CreateXmlDeclaration("1.0", "UTF-8", "yes");
            doc.AppendChild(docNode);

            XmlNode rootNode = doc.CreateElement(STR_RES, "http://tizen.org/ns/rm");
            doc.AppendChild(rootNode);

            XmlElement groupImageNode = doc.CreateElement("group-image", "http://tizen.org/ns/rm");
            groupImageNode.SetAttribute(STR_FOLDER, STR_CONTENTS);
            rootNode.AppendChild(groupImageNode);

            XmlElement groupLayoutNode = doc.CreateElement("group-layout", "http://tizen.org/ns/rm");
            groupLayoutNode.SetAttribute(STR_FOLDER, STR_CONTENTS);
            rootNode.AppendChild(groupLayoutNode);

            XmlElement groupSoundNode = doc.CreateElement("group-sound", "http://tizen.org/ns/rm");
            groupSoundNode.SetAttribute(STR_FOLDER, STR_CONTENTS);
            rootNode.AppendChild(groupSoundNode);

            XmlElement groupBinNode = doc.CreateElement("group-bin", "http://tizen.org/ns/rm");
            groupBinNode.SetAttribute(STR_FOLDER, STR_CONTENTS);
            rootNode.AppendChild(groupBinNode);

            DirectoryInfo contentsDir = new DirectoryInfo(Path.Combine(ProjectFullName, STR_RES, STR_CONTENTS));
            if (!contentsDir.Exists)
            {
                Log.LogMessage("No resource contents directory.");
                return true;
            }

            foreach (var dir in contentsDir.GetDirectories())
            {
                var nameParts = ParseLanguageAndResolution(dir.Name);
                if (!nameParts.Item1.Equals("default_All") || !nameParts.Item2.Equals("All"))
                {
                    foreach (XmlNode groupNode in doc.DocumentElement.ChildNodes)
                    {
                        XmlElement node = doc.CreateElement("node", "http://tizen.org/ns/rm");
                        XmlAttribute folder = doc.CreateAttribute(STR_FOLDER);
                        folder.Value = "contents/" + dir.Name;
                        node.Attributes.Append(folder);
                        if (!nameParts.Item1.Equals("default_All"))
                        {
                            XmlAttribute language = doc.CreateAttribute("language");
                            language.Value = nameParts.Item1;
                            node.Attributes.Append(language);
                        }
                        if (!nameParts.Item2.Equals("All"))
                        {
                            XmlAttribute resolution = doc.CreateAttribute("screen-dpi-range");
                            resolution.Value = GetResolution(nameParts.Item2);
                            node.Attributes.Append(resolution);
                        }
                        groupNode.AppendChild(node);
                    }
                }
            }

            ResourceXmlPath = Path.Combine(STR_RES, "res.xml");
            using (var file = File.Open(Path.Combine(ProjectFullName, ResourceXmlPath), FileMode.Create, FileAccess.Write))
            {
                doc.Save(file);
            }
            return true;
        }
    }
}

