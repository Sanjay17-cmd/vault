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

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library") || project.plugins.hasPlugin("com.android.application")) {
            project.extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.let { android ->
                android.compileSdkVersion(36)
            }
        }
    }

    // Auto-inject namespace for older plugins that only declare package in AndroidManifest.xml
    // (required by AGP 9.x). Fires lazily when the library plugin is applied.
    pluginManager.withPlugin("com.android.library") {
        val android = extensions.getByType(com.android.build.gradle.LibraryExtension::class.java)
        if (android.namespace.isNullOrEmpty()) {
            val manifest = file("src/main/AndroidManifest.xml")
            if (manifest.exists()) {
                val match = Regex("""package\s*=\s*"([^"]+)"""").find(manifest.readText())
                if (match != null) {
                    android.namespace = match.groupValues[1]
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
