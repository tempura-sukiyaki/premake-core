
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
  ['android.buildTypes.release.minifyEnabled'] = true,
  ['android.sourceSets.main.java.srcDirs'] = 'other/java',
  ['android.sourceSets.main.res.srcDirs'] = { 'other/res1', 'other/res2' },
  ['android.sourceSets.main.manifest.srcFile'] = 'other/AndroidManifest.xml',
  -- Keys you don't want to escape
  -- Values you want to empty
  ['dependencies.%(implementation project(":mylibrary"))'] = {},
}
```

will generate:

```groovy
android {
  buildTypes {
    release {
      minifyEnabled true
    }
  }
  sourceSets {
    main {
      java {
        srcDirs "other/java"
      }
      manifest {
        srcFile "other/AndroidManifest.xml"
      }
      res {
        srcDirs "other/res1", "other/res2"
      }
    }
  }
}

dependencies {
  implementation project(":mylibrary")
}
```

### See Also ###

* [workspacebuildgradle](workspacebuildgradle.md)
