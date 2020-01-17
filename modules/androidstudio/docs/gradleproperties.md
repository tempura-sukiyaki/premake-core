# gradleproperties #

gradleproperties

```Lua
gradleproperties {
  ['org.gradle.parallel'] = true
}
```

### Parameters ###

key/value pairs to apply to `gradleproperties` blocks of the generated gradle.properties

### Applies To ###

The `workspace` scope.

### Availability ###

Premake 5.0.0 alpha 15? or later.

### Examples ###

```Lua
gradleproperties {
  ['org.gradle.parallel'] = true
}
```

will generate:

```
org.gradle.parallel=true
```
