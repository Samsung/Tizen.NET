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

      // PackageTargetFallback is an ORDERED preference list (highest/most specific first).
      // Build a rank map so selection is by declared priority rather than by whatever order
      // the filesystem happens to enumerate directories in.
      var rank = new Dictionary<string, int> (StringComparer.OrdinalIgnoreCase);
      for (int i = 0; i < PackageTargetFallback.Length; i++) {
        var name = PackageTargetFallback [i]?.Trim ();
        if (string.IsNullOrEmpty (name) || rank.ContainsKey (name))
          continue;
        rank [name] = i;
      }

      // Group the netstandard items by their containing package (the lib/ directory), so a
      // single fallback TFM can be chosen ATOMICALLY per package. Previously every matching
      // fallback directory was added to an unordered HashSet and assemblies were taken
      // first-wins across all of them, which could both ignore the declared priority and mix
      // assemblies from different TFMs within one package.
      var itemsByPackage = new Dictionary<string, List<ITaskItem>> (StringComparer.OrdinalIgnoreCase);
      foreach (var item in CopyLocalItems) {
        var directory = Path.GetDirectoryName (item.ItemSpec);
        var directoryName = Path.GetFileName (directory);
        Log.LogMessage ($"{directoryName} -> {item.ItemSpec}");
        if (!directoryName.StartsWith ("netstandard2", StringComparison.OrdinalIgnoreCase))
          continue;
        var parent = Directory.GetParent (directory);
        if (parent == null)
          continue;
        List<ITaskItem> list;
        if (!itemsByPackage.TryGetValue (parent.FullName, out list)) {
          list = new List<ITaskItem> ();
          itemsByPackage [parent.FullName] = list;
        }
        list.Add (item);
      }

      foreach (var package in itemsByPackage) {
        var parentPath = package.Key;

        // Pick exactly ONE fallback TFM for this package: the compatible candidate with the
        // best (lowest) rank. Enumeration order is explicitly sorted first so the result is
        // deterministic regardless of how the filesystem returns directories.
        string selectedDirectory = null;
        var selectedRank = int.MaxValue;

        var candidates = Directory.EnumerateDirectories (parentPath)
                                  .Select (d => Path.GetFileName (d))
                                  .OrderBy (n => n, StringComparer.OrdinalIgnoreCase);
        foreach (var name in candidates) {
          int candidateRank;
          if (!rank.TryGetValue (name, out candidateRank))
            continue;
          if (candidateRank >= selectedRank)
            continue;
          selectedRank = candidateRank;
          selectedDirectory = Path.Combine (parentPath, name);
        }

        if (selectedDirectory == null)
          continue;

        Log.LogMessage ($"Selected fallback '{Path.GetFileName (selectedDirectory)}' for {parentPath}");

        // Replace the package's netstandard asset group ATOMICALLY - remove ALL of it, not
        // just the files the fallback happens to share a name with.
        //
        // Removing only name-matching assets left the remaining netstandard DLLs in the
        // reference set, so the build ended up with a mixture: some assemblies from the
        // platform-specific TFM and some from netstandard, for the SAME package. That is the
        // very mixing this selection is meant to prevent, and it silently reintroduces the
        // netstandard build of any assembly the fallback group happens not to carry.
        foreach (var item in package.Value) {
          Log.LogMessage ($"Removing: {item.ItemSpec}");
          assembliesToRemove.Add (item);
        }

        // ...and add the selected group's assets in their entirety.
        foreach (var assembly in Directory.GetFiles (selectedDirectory, "*.dll")) {
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
