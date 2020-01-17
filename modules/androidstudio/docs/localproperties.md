# localproperties #

localproperties

```Lua
localproperties {
  ['sdk.dir'] = '/Users/foo/Library/Android/sdk'
}
```

### Parameters ###

key/value pairs to apply to `localproperties` blocks of the generated local.properties

### Applies To ###

The `workspace` scope.

### Availability ###

Premake 5.0.0 alpha 15? or later.

### Examples ###

```Lua
localproperties {
  ['sdk.dir'] = '/Users/foo/Library/Android/sdk'
}
```

will generate:

```
sdk.dir=/Users/foo/Library/Android/sdk
```
