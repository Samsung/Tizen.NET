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
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using System.Text;

using System.Security.Cryptography;
using System.Runtime.InteropServices;

namespace Tizen.NET.Build.Tasks.Signer
{
    public enum WidgetDigSig
    {
        Author,
        Distributor
    }

    public class XmldsigForWidgetDigSig
    {
        public const string XmldsigNSURI = "http://www.w3.org/2000/09/xmldsig#";
        public const string XmldsigPropNSURI = "http://www.w3.org/2009/xmldsig-properties";
        public const string CanonicalizationMethodURI = "http://www.w3.org/2001/10/xml-exc-c14n#";
        public const string PropCanonicalizationMethodURI = "http://www.w3.org/TR/2001/REC-xml-c14n-20010315";
        public const string SignatureMethodURI = "http://www.w3.org/2001/04/xmldsig-more#rsa-sha512";
        public const string DigestMethodURI = "http://www.w3.org/2001/04/xmlenc#sha512";

        public const string WidgetDigSigURI = "http://www.w3.org/ns/widgets-digsig#";

        private const int Base64Column = 76;

        private string SignatureId;
        private string SignatureRole;

        public SHA512WithRSA Signer { get; private set; }

        public string SigningRoot { get; private set; }
        public WidgetDigSig Role
        {
            set
            {
                _role = value;
                if (_role == WidgetDigSig.Author)
                {
                    SignatureId = "AuthorSignature";
                    SignatureRole = "role-author";
                }
                else if (_role == WidgetDigSig.Distributor)
                {
                    SignatureId = "DistributorSignature";
                    SignatureRole = "role-distributor";
                }
            }

            get
            {
                return _role;
            }
        }

        private WidgetDigSig _role;
        public string SignatureValue { get; set; }
        public List<string> CertificateChain { get; set; }

        public XmldsigForWidgetDigSig(WidgetDigSig role, SHA512WithRSA signer, string root)
        {
            Role = role;
            SigningRoot = root;

            Signer = signer;
            CertificateChain = new List<string>(signer.Base64KeyChain);
        }

        private string NormalizePath(string path)
        {
#if NET46
            bool isWindows = true;
#else
            //bool isWindows = System.Runtime.InteropServices.RuntimeInformation.IsOSPlatform(OSPlatform.Windows);
            bool isWindows = true;
#endif
            if (isWindows)
            {
                string relPath = path.Substring(SigningRoot.Length + 1).Replace('\\', '/');
                return Uri.EscapeDataString(relPath);
            }
            else
            {
                return Uri.EscapeDataString(path.Substring(SigningRoot.Length + 1));
            }
        }

        private string GenerateXMLTemplate()
        {
            List<string> signingFiles = new List<string>();
            var files = Directory.GetFiles(SigningRoot, "*", SearchOption.AllDirectories);

            foreach (string f in Directory.GetFiles(SigningRoot, "*", SearchOption.AllDirectories))
            {
                string sPattern = "^signature.*xml$"; //distributor signature file pattern

                if (!System.Text.RegularExpressions.Regex.IsMatch(Path.GetFileName(f), sPattern))
                {
                    signingFiles.Add(f);
                }
            }

            XNamespace ns = XmldsigNSURI;
            XNamespace nsdsp = XmldsigPropNSURI;
            XDocument doc = new XDocument(
                    new XElement(ns + "Signature",
                        new XAttribute("Id", SignatureId),
                        new XElement(ns + "SignedInfo",
                            new XElement(ns + "CanonicalizationMethod", new XAttribute("Algorithm", CanonicalizationMethodURI)),
                            new XElement(ns + "SignatureMethod", new XAttribute("Algorithm", SignatureMethodURI)),
                            from file in signingFiles
                            orderby file.ToString() descending
                            select new XElement(ns + "Reference",
                                new XAttribute("URI", NormalizePath(file)),
                                new XElement(ns + "DigestMethod", new XAttribute("Algorithm", DigestMethodURI)),
                                new XElement(ns + "DigestValue", GetBase64FileHash(file))),
                            new XElement(ns + "Reference",
                                new XAttribute("URI", "#prop"),
                                new XElement(ns + "Transforms",
                                    new XElement(ns + "Transform", new XAttribute("Algorithm", PropCanonicalizationMethodURI))),
                                new XElement(ns + "DigestMethod", new XAttribute("Algorithm", DigestMethodURI)),
                                new XElement(ns + "DigestValue"))),
                        new XElement(ns + "SignatureValue"),
                        new XElement(ns + "KeyInfo",
                            new XElement(ns + "X509Data",
                                from cert in CertificateChain
                                select new XElement(ns + "X509Certificate", '\n' + Utility.SplitToLines(cert, Base64Column)))),
                        new XElement(ns + "Object",
                                new XAttribute("Id", "prop"),
                                new XElement(ns + "SignatureProperties",
                                    new XAttribute(XNamespace.Xmlns + "dsp", XmldsigPropNSURI),
                                    new XElement(ns + "SignatureProperty",
                                        new XAttribute("Id", "profile"),
                                        new XAttribute("Target", $"#{SignatureId}"),
                                        new XElement(nsdsp + "Profile", new XAttribute("URI", WidgetDigSigURI + "profile"))),
                                    new XElement(ns + "SignatureProperty",
                                        new XAttribute("Id", "role"),
                                        new XAttribute("Target", $"#{SignatureId}"),
                                        new XElement(nsdsp + "Role", new XAttribute("URI", WidgetDigSigURI + SignatureRole))),
                                    new XElement(ns + "SignatureProperty",
                                        new XAttribute("Id", "identifier"),
                                        new XAttribute("Target", $"#{SignatureId}"),
                                        new XElement(nsdsp + "Identifier"))))));

            return doc.ToString();
        }

        private string GenerateSignedXML()
        {
            // XML Canonical don't modify whitespace between tags.
            // so we need formated xml and reparse with preserve whitespace
            // for remained whitespace if we don't want xml in oneline.
            string xmltpl = GenerateXMLTemplate();

            var doc = XDocument.Parse(xmltpl, LoadOptions.PreserveWhitespace);

            var ns = doc.Root.GetDefaultNamespace();

            XElement propReference = doc.Descendants(ns + "Reference").
                Where(a => a.Attribute("URI").Value == "#prop").
                First().
                Element(ns + "DigestValue");
            XElement prop = doc.Descendants(ns + "Object").Where(a => a.Attribute("Id").Value == "prop").First();
            string propHash = GetHashFromSegment(prop);
            propReference.Add(propHash);

            XElement SignatureValueReference = doc.Descendants(ns + "SignatureValue").First();

            XElement signedInfo = doc.Descendants(ns + "SignedInfo").First();
            string signedInfoHash = GetRSA_SHA512(signedInfo);
            SignatureValueReference.Add('\n' + Utility.SplitToLines(signedInfoHash, Base64Column));


            return doc.ToString(SaveOptions.DisableFormatting);
        }

        public override string ToString()
        {
            return GenerateSignedXML();
        }

        private string GetBase64FileHash(string file)
        {
            using (FileStream stream = File.OpenRead(file))
            {
                var sha = SHA512.Create();
                byte[] checksum = sha.ComputeHash(stream);
                return Convert.ToBase64String(checksum);
            }
        }

        private string GetRSA_SHA512(XElement el)
        {
            XDocument doc = new XDocument(el);
            XElement obj = doc.Root;
            NSPropagation(obj);
            C14N(obj);

            //Console.WriteLine(obj.ToString(SaveOptions.DisableFormatting) + "\n");

            using (var sha = SHA512.Create())
            {
                byte[] data = Signer.Sign(obj.ToString(SaveOptions.DisableFormatting).Replace("\r\n", "\n"));
                return Convert.ToBase64String(data);
            }
        }

        private string GetHashFromSegment(XElement el)
        {
            XDocument doc = new XDocument(el);
            XElement obj = doc.Root;
            NSPropagation(obj);
            C14N(obj);

            //Console.WriteLine(obj.ToString(SaveOptions.DisableFormatting) + "\n");

            using (var sha = SHA512.Create())
            {
                byte[] xmlb = Encoding.UTF8.GetBytes(obj.ToString(SaveOptions.DisableFormatting).Replace("\r\n", "\n"));
                byte[] checksum = sha.ComputeHash(xmlb);
                return Convert.ToBase64String(checksum);
            }
        }

        private static void C14N(XElement oel)
        {
            // This method did not work same as https://www.w3.org/TR/2001/REC-xml-c14n-20010315
            // like Loss of DTD or XML declration.
            // Because this program should not use for varification.
            // We just canonicalize xml on the fly that should be verificated with other tools.
            foreach (XElement el in oel.DescendantsAndSelf())
            {
                // for create endtag without content in tag
                if (el.IsEmpty)
                {
                    el.Value = String.Empty;
                }

                // sort attribute
                var defaultns = el.Attributes().Where(a => a.Name.LocalName == "xmlns");
                var nsattrs = el.Attributes().Where(a => a.IsNamespaceDeclaration && a.Name.LocalName != "xmlns").OrderBy(a => a.Name.LocalName);
                var attrs = el.Attributes().Where(a => !a.IsNamespaceDeclaration).OrderBy(a => a.Name.NamespaceName).ThenBy(a => a.Name.LocalName);
                foreach (XAttribute attr in defaultns)
                {
                    attr.Remove();
                    el.Add(attr);
                }

                foreach (XAttribute attr in nsattrs)
                {
                    attr.Remove();
                    el.Add(attr);
                }

                foreach (XAttribute attr in attrs)
                {
                    attr.Remove();
                    el.Add(attr);
                }
            }
        }

        private static void NSPropagation(XElement el)
        {
            if (!el.Attributes().Any(a => a.IsNamespaceDeclaration && a.Name.LocalName == "xmlns"))
            {
                el.Add(new XAttribute("xmlns", XmldsigNSURI));
            }
        }
    }

}
