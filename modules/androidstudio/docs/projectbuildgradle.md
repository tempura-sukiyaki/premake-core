
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

Premake 5.0.0 alpha 15? or later.

### Examples ###

```Lua
projectbuildgradle {
  -- Boolean valeues are not quoted
  ['android.buildTypes.release.minifyEnabled'] = true,
  -- Values in table are concatenated by `, `
  ['android.buildTypes.release.proguardFiles'] = {
    -- Function return value is not quoted
    function () return 'getDefaultProguardFile("proguard-android-optimize.txt")' end,
    -- String values are quoted
    'proguard-rules.pro',
  },
  -- Keys enclosed in `%(` and `)` are not quoted
  ['dependencies.%(implementation project(":mylibrary"))'] = {
      -- Use an empty table if you don't want to give anything to value
  },
}
```

will generate:

```groovy
android {
  buildTypes {
    release {
      minifyEnabled true
      proguardFiles getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"
    }
  }
}

dependencies {
  implementation project(":mylibrary")
}
```

### See Also ###

* [workspacebuildgradle](workspacebuildgradle.md)
