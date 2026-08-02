allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory.dir("../../build").get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory =
        newBuildDir.dir(project.name)

    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// tflite_flutter Java target က 11 ဖြစ်တဲ့အတွက်
// Kotlin target ကိုလည်း 11 တူအောင် သတ်မှတ်ခြင်း
subprojects {
    if (project.name == "tflite_flutter") {
        tasks.withType<
                org.jetbrains.kotlin.gradle.tasks.KotlinCompile
                >().configureEach {
            compilerOptions {
                jvmTarget.set(
                    org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
                )
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}