import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

// Opt-in for size-gate builds that have no keystore. Default = refuse, so a
// debug-signed "release" can never be produced by accident.
val allowDebugReleaseSigning =
    System.getenv("SIFFERSAFARI_ALLOW_DEBUG_RELEASE_SIGNING") == "true" ||
        (project.findProperty("siffersafari.allowDebugReleaseSigning") as String?)
            ?.toBoolean() == true

android {
    namespace = "se.cognifox.Siffersafari"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "se.cognifox.Siffersafari"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Note: With Flutter 3.41.x, the effective minSdkVersion is currently 24 (Android 7.0).
        // Keep using flutter.minSdkVersion so it stays aligned with the Flutter SDK requirements.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Only wire Play signing when key.properties exists (local/CI with secrets).
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // A debug-signed release APK can never be updated (and Play rejects
            // it), so falling back to the debug key must be an explicit decision
            // for size-gate builds — never a silent default.
            when {
                keystorePropertiesFile.exists() ->
                    signingConfig = signingConfigs.getByName("release")

                allowDebugReleaseSigning -> {
                    logger.lifecycle(
                        "⚠️ Release variant is signed with the DEBUG key " +
                            "(SIFFERSAFARI_ALLOW_DEBUG_RELEASE_SIGNING=true). " +
                            "This artifact is for size checks only and must not be published.",
                    )
                    signingConfig = signingConfigs.getByName("debug")
                }

                // Leave unset; the task-graph check below fails release builds.
            }
        }
    }
}

// Fail only when a release artifact is actually requested, so debug builds and
// `flutter run` keep working without a keystore.
gradle.taskGraph.whenReady { graph ->
    val buildingRelease = graph.allTasks.any { task ->
        val name = task.name
        (name.startsWith("bundle") ||
            name.startsWith("assemble") ||
            name.startsWith("package")) && name.contains("Release")
    }

    if (buildingRelease && !keystorePropertiesFile.exists() && !allowDebugReleaseSigning) {
        throw GradleException(
            "Refusing to build a release artifact without android/key.properties. " +
                "Add signing secrets, or set " +
                "SIFFERSAFARI_ALLOW_DEBUG_RELEASE_SIGNING=true for a size-gate-only build.",
        )
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}

if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}
