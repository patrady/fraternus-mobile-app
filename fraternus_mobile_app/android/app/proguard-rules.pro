# androidx.window's sidecar/extensions backends are optional, reflection-loaded
# compatibility shims for older devices — safe to not have at all, but R8 still
# complains about the missing classes without these.
-dontwarn androidx.window.sidecar.**
-dontwarn androidx.window.extensions.**
