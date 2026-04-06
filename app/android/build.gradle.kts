allprojects {
    repositories {
        google()
        mavenCentral()
    }
    configurations.configureEach {
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.core" && requested.name.startsWith("core")) {
                useVersion("1.6.0")
            }
        }
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
