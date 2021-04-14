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
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Tizen.NET.Build.Tasks
{
    public static class Utility
    {
        public static string SplitToLines(string str, int cols)
        {
            StringBuilder sb = new StringBuilder();

            int chunkSize = cols;
            for (int i = 0; i < str.Length; i += chunkSize)
            {
                if (i + chunkSize > str.Length)
                {
                    chunkSize = str.Length - i;
                }

                sb.Append(str.Substring(i, chunkSize));
                sb.Append('\n');
            }

            return sb.ToString();
        }

        public static string AskPassword()
        {
            return AskPassword("Insert Password : ");
        }

        public static string AskPassword(string text)
        {
            Console.Write(text);
            StringBuilder sb = new StringBuilder();
            ConsoleKeyInfo info = Console.ReadKey(true);
            while (info.Key != ConsoleKey.Enter)
            {
                if (info.Key != ConsoleKey.Backspace)
                {
                    Console.Write("*");
                    sb.Append(info.KeyChar);
                }
                else
                {
                    if (sb.Length > 0)
                    {
                        sb.Remove(sb.Length - 1, 1);
                        int pos = Console.CursorLeft;
                        Console.SetCursorPosition(pos - 1, Console.CursorTop);
                        Console.Write(" ");
                        Console.SetCursorPosition(pos - 1, Console.CursorTop);
                    }
                }

                info = Console.ReadKey(true);
            }

            Console.WriteLine();

            return sb.ToString();
        }

        public static string GetTempDirectory()
        {
            string path = Path.GetTempPath() + Path.GetRandomFileName();
            while (Directory.Exists(path))
            {
                path = Path.GetTempPath() + Path.GetRandomFileName();
            }

            Directory.CreateDirectory(path);
            return path;
        }
    }
}
