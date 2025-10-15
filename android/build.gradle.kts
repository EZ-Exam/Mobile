buildscript {
    val kotlin_version by extra("1.9.10")

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.2.1")
        classpath("com.google.gms:google-services:4.4.1") // ✅ Firebase plugin
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Cấu hình lại build output directory theo Flutter
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ✅ Đảm bảo App được build trước
subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ Task clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
