
# projectbuildgradle #

projectbuildgradle

```Lua
projectbuildgradle {
  ['android.sourceSets.main.java.srcDirs'] = 'other/java',
  ['android.sourceSets.main.res.srcDirs'] = { 'other/res1', 'other/res2' },
  ['android.sourceSets.main.manifest.srcFile'] = 'other/AndroidManifest.xml',
}
```

### Parameters ###

key/value pairs to apply to `projectbuildgradle` blocks of the generated build.gradle

### Applies To ###

The `project` scope.

### Availability ###

Premake 5.0.0 alpha 15 or later.

### Examples ###

```Lua
projectbuildgradle {
  ['android.sourceSets.main.java.srcDirs'] = 'other/java',
  ['android.sourceSets.main.res.srcDirs'] = { 'other/res1', 'other/res2' },
  ['android.sourceSets.main.manifest.srcFile'] = 'other/AndroidManifest.xml',
}
```

will generate:

```groovy
android {
  sourceSets {
    main {
      java {
        srcDirs "othre/java"
      }
      manifest {
        srcFile "othre/AndroidManifest.xml"
      }
      res {
        srcDirs "othre/res1", "othre/res2"
      }
    }
  }
}
```
