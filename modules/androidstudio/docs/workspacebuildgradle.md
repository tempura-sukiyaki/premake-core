
# workspacebuildgradle #

workspacebuildgradle

```Lua
workspacebuildgradle {
  ['ext.applicationId'] = 'ApplicationId',
}
```

### Parameters ###

key/value pairs to apply to `workspacebuildgradle` blocks of the generated build.gradle

### Applies To ###

The `workspace` scope.

### Availability ###

Premake 5.0.0 alpha 15 or later.

### Examples ###

```Lua
workspacebuildgradle {
  ['ext.applicationId'] = 'ApplicationId',
}
```

will generate:

```groovy
ext {
  applicationId = "ApplicationId"
}
```

### See Also ###

* [projectbuildgradle](projectbuildgradle.md)
