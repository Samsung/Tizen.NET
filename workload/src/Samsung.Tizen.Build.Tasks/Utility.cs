using System;
using System.IO;
using System.Text;

namespace Samsung.Tizen.Build.Tasks
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
