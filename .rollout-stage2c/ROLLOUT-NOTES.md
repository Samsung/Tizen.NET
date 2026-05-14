# Stage 2c — GitHub Packages NuGet source 4개 브랜치 수평전개

## 적용 대상

main, net9.0, net8.0, net7.0 4개 브랜치의 `workload/NuGet.config`에 추가:

```xml
<add key="github" value="https://nuget.pkg.github.com/Samsung/index.json" />
```

+ packageSourceCredentials 주석 블록 (개발자가 본인 PAT로 채워 사용)

net10.0은 이미 적용됨.

## PowerShell loop

```powershell
cd C:\Users\samsung1!\workspace\github\Tizen.NET

foreach ($b in @("main", "net9.0", "net8.0", "net7.0")) {
    git checkout $b
    git pull --ff-only
    Copy-Item ".rollout-stage2c\NuGet.config.$b" "workload\NuGet.config" -Force
    git add workload/NuGet.config
    git commit -m "chore: add GitHub Packages NuGet source for TizenFX ref packs"
    git push origin $b
}
git checkout net10.0
```

## 검증

각 브랜치에 push 후 한 곳에서 확인:

```powershell
foreach ($b in @("main", "net9.0", "net8.0", "net7.0", "net10.0")) {
    $c = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Samsung/Tizen.NET/$b/workload/NuGet.config" -SkipHttpErrorCheck).Content
    $has = if ($c -match 'pkg\.github\.com') { "YES" } else { "NO" }
    Write-Host "$b → github source: $has"
}
```

5개 브랜치 모두 YES이어야 함.
