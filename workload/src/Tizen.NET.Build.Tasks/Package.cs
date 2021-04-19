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

namespace Tizen.NET.Build.Tasks
{
    class SlashEncoder : System.Text.UTF8Encoding
    {
        public override byte[] GetBytes(string s)
        {
            s = s.Replace("\\", "/");
            return base.GetBytes(s);
        }
    }

    public class Package : Task
    {
        private string tpkSrcPath;
        private string unSignedTpkFile;

        [Required]
        public string TpkSrcPath
        {
            get { return tpkSrcPath; }
            set { tpkSrcPath = value; }
        }

        [Required]
        [Output]
        public string UnSignedTpkFile
        {
            get { return unSignedTpkFile; }
            set { unSignedTpkFile = value; }
        }

        public override bool Execute()
        {
            Log.LogMessage("Package");
            Log.LogMessage("TpkSrcPath : {0}", TpkSrcPath);
            Log.LogMessage("UnSignedTpkFile : {0}", UnSignedTpkFile);

            // Check Path
            if (!Directory.Exists(TpkSrcPath))
            {
                Log.LogError("TpkOutPath is Invalid {0}", TpkSrcPath);
                return !Log.HasLoggedErrors;
            }

            if (File.Exists(UnSignedTpkFile))
            {
                Log.LogWarning("UnSignedTpkFile is already exist. Remove previouse file {0}", UnSignedTpkFile);
                File.Delete(UnSignedTpkFile);
            }

            // Zipping to TPK
            ZipFile.CreateFromDirectory(
                                    TpkSrcPath,
                                    UnSignedTpkFile,
                                    CompressionLevel.Optimal, false,
                                    new SlashEncoder());

            return !Log.HasLoggedErrors;
        }
    }
}