allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

// Combined into one subprojects block (rather than two separate ones) to
// work around a Flutter 3.44.0 libapp.so packaging bug — splitting this
// across blocks makes AGP eagerly resolve the jniLibs source-set directory
// before the Flutter Gradle Plugin's copy task has lazily written to it,
// which manifests as "failed to strip debug symbols from native libraries"
// on `flutter build appbundle`. See
// https://github.com/flutter/flutter/issues/186810 and the fix in
// https://github.com/flutter/flutter/pull/188119 (merged after 3.44.8).
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
