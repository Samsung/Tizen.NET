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
using System.Text.RegularExpressions;

namespace Tizen.NET.Build.Tasks
{
    /// <summary>
    /// A task that finds an item with the specified itemspec, if present,
    /// in the provided list.
    /// </summary>
    public class FindPatternInList : Task
    {
        // The list to search through
        private ITaskItem[] _list;

        // The wildcard pattern to find
        private string _patterns;

        // The matched itemList
        private readonly List<ITaskItem> _matchList = new List<ITaskItem>();

        /// <summary>
        /// The list to search through
        /// </summary>
        [Required]
        public ITaskItem[] List
        {
            get { return _list; }
            set { _list = value; }
        }

        /// <summary>
        /// The itemspec to try to find
        /// </summary>
        [Required]
        public string Patterns
        {
            get { return _patterns; }
            set { _patterns = value; }
        }

        [Output]
        public ITaskItem[] MatchList
        {
            get { return _matchList.ToArray(); }
        }

        internal static string FixFilePath(string path)
        {
            return string.IsNullOrEmpty(path) || Path.DirectorySeparatorChar == '\\' ? path : path.Replace('\\', '/');
        }

        public override bool Execute()
        {

            _patterns = Regex.Replace(_patterns, @"\s+", ""); //remove whitespce
            _patterns = FixFilePath(_patterns); //DirecotrySeparator Fix

            string[] patternList =
                _patterns.Split(new string[] { "\n", "\r\n", ";" }, StringSplitOptions.RemoveEmptyEntries);

            foreach (string _pattern in patternList)
            {
                string p = "(^|[\\\\]|[/])"
                           + Regex.Escape(_pattern)
                               .Replace("\\*\\*", ".*")
                               .Replace("\\*", "[^\\\\/]*")
                               .Replace("\\?", "[^\\\\/]?")
                           + "$";

                Log.LogMessage(MessageImportance.Low, "Pattern {0}", p);

                foreach (ITaskItem item in List)
                {
                    if (Regex.IsMatch(item.ItemSpec, p))
                    {
                        Log.LogMessage(MessageImportance.Low, "Found {0}", item.ItemSpec);

                        if (!_matchList.Contains(item))
                        {
                            _matchList.Add(item);
                        }
                    }
                }
            }

            return true;
        }
    }
}
