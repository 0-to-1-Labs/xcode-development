# packages/

Shared Swift packages that more than one app uses. The factory tracks these.
Apps reference them with a relative path in `project.yml`:

```yaml
packages:
  FamilyKit:
    path: ../../packages/FamilyKit
```

Empty until a second app needs the same code. Do not create a package for
code that only one app uses.
