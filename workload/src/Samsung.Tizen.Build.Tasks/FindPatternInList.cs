using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;

using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;

namespace Samsung.Tizen.Build.Tasks
{
    /// <summary>
    /// A task that finds an item with the specified itemspec, if present,
    /// in the provided list.
    /// </summary>
    public class FindPatternInList : Task
    {

        // The matched itemList
        private readonly List<ITaskItem> _matchList = new List<ITaskItem>();

        /// <summary>
        /// The list to search through
        /// </summary>
        [Required]
        public ITaskItem[] List { get; set; }

        /// <summary>
        /// The itemspec to try to find
        /// </summary>
        [Required]
        public string Patterns { get; set; }

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

            Patterns = Regex.Replace(Patterns, @"\s+", ""); //remove whitespce
            Patterns = FixFilePath(Patterns); //DirecotrySeparator Fix

            string[] patternList =
                Patterns.Split(new string[] { "\n", "\r\n", ";" }, StringSplitOptions.RemoveEmptyEntries);

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
