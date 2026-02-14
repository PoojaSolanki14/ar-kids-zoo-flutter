plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle plugin MUST be last
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ar_kids_zoo"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // ✅ IMPORTANT: Must be Java 1.8 for ar_flutter_plugin
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    // ✅ IMPORTANT: Kotlin JVM target must match Java
    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.ar_kids_zoo"

        // ✅ REQUIRED for ARCore + Sceneform
        minSdk = 28

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Using debug signing for now (fine for internship/demo)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
