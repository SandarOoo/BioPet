import org.gradle.api.tasks.compile.JavaCompile
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

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
    val newSubprojectBuildDir: Directory =
        newBuildDir.dir(project.name)

    project.layout.buildDirectory.value(
        newSubprojectBuildDir
    )
}

subprojects {
    project.evaluationDependsOn(":app")
}

/*
 * tflite_flutter itself compiles Java with JVM 11.
 * Therefore, compile only tflite_flutter Kotlin with JVM 11.
 *
 * Other modules, including :app, can continue using JVM 17.
 */
gradle.projectsEvaluated {
    subprojects {
        if (name == "tflite_flutter") {
            tasks.withType<JavaCompile>().configureEach {
                sourceCompatibility = "11"
                targetCompatibility = "11"
            }

            tasks.withType<KotlinCompile>().configureEach {
                compilerOptions {
                    jvmTarget.set(JvmTarget.JVM_11)
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}