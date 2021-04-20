using System;
using System.Globalization;

namespace Samsung.Tizen.Build.Tasks
{
    public class TizenSignException : Exception
    {
        public TizenSignException() : base()
        {
        }

        public TizenSignException(string message) : base(message)
        {
        }

        public TizenSignException(string message, System.Exception inner) : base(message, inner)
        {
        }

        public TizenSignException(string format, params string[] args)
            : this(string.Format(CultureInfo.CurrentCulture, format, args))
        {
        }
    }
}
