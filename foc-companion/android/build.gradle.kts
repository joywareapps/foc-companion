plugins {
    id("com.google.gms.google-services") version "4.4.4" apply false
    id("org.jetbrains.kotlin.android") apply false
}

// file_picker 11.x skips applying the Kotlin Gradle plugin on AGP 9+, assuming
// AGP's built-in Kotlin. We run with android.builtInKotlin=false (Flutter's
// template default), so its Kotlin sources would never compile. Apply KGP for it.
// Remove once file_picker is upgraded to a version that handles this.
val pluginsNeedingKgp = setOf("file_picker")
subprojects {
    if (name in pluginsNeedingKgp) {
        plugins.withId("com.android.library") {
            apply(plugin = "org.jetbrains.kotlin.android")
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }
}

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
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
