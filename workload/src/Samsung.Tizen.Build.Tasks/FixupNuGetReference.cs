// https://github.com/xamarin/xamarin-android/blob/e937a470759a3ea60ea8e0ee9e9e198cb6aa619c/src/Xamarin.Android.Build.Tasks/Tasks/FixupNuGetReferences.cs

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;

namespace Samsung.Tizen.Build.Tasks
{
  /// <summary>
  /// This task contains *temporary* workarounds for NuGet in .NET 5.
  /// </summary>
  public class FixupNuGetReferences : Task
  {
    [Required]
    public string [] PackageTargetFallback { get; set; }

    public ITaskItem [] CopyLocalItems { get; set; }

    [Output]
    public string [] AssembliesToAdd { get; set; }

    [Output]
    public ITaskItem [] AssembliesToRemove { get; set; }

    public override bool Execute()
    {
      if (CopyLocalItems == null || CopyLocalItems.Length == 0)
        return true;

      var assembliesToAdd     = new Dictionary<string, string> ();
      var assembliesToRemove  = new List<ITaskItem> ();
      var fallbackDirectories = new HashSet<string> ();

      foreach (var item in CopyLocalItems) {
        var directory = Path.GetDirectoryName (item.ItemSpec);
        var directoryName = Path.GetFileName (directory);
        Log.LogMessage ($"{directoryName} -> {item.ItemSpec}");
        if (directoryName.StartsWith ("netstandard2", StringComparison.OrdinalIgnoreCase)) {
          var parent = Directory.GetParent (directory);
          foreach (var nugetDirectory in parent.EnumerateDirectories ()) {
            var name = Path.GetFileName (nugetDirectory.Name);
            foreach (var fallback in PackageTargetFallback) {
              if (!string.Equals (name, fallback, StringComparison.OrdinalIgnoreCase))
                continue;
              var fallbackDirectory = Path.Combine (parent.FullName, name);
              fallbackDirectories.Add (fallbackDirectory);

              // Remove the netstandard assembly, if there is a platform-specific one
              var path = Path.Combine (fallbackDirectory, Path.GetFileName (item.ItemSpec));
              if (File.Exists (path)) {
                Log.LogMessage ($"Removing: {item.ItemSpec}");
                assembliesToRemove.Add (item);
              }
            }
          }
        }
      }

      // Look for any platform-specific assemblies
      foreach (var directory in fallbackDirectories) {
        foreach (var assembly in Directory.GetFiles (directory, "*.dll")) {
          var assemblyName = Path.GetFileName (assembly);
          if (!assembliesToAdd.ContainsKey (assemblyName)) {
            Log.LogMessage ($"Adding: {assembly}");
            assembliesToAdd.Add (assemblyName, assembly);
          }
        }
      }

      AssembliesToAdd = assembliesToAdd.Values.ToArray ();
      AssembliesToRemove = assembliesToRemove.ToArray ();

      return !Log.HasLoggedErrors;
    }
  }
}
