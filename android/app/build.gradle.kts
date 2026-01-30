//import java.util.Properties
//import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
//    id("com.google.gms.google-services")
//    id("com.google.firebase.crashlytics")
}

//val keystoreProperties = Properties()
//val keystorePropertiesFile = rootProject.file("key.properties")
//if (keystorePropertiesFile.exists()) {
//    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
//}

android {
    namespace = "com.samarlandsoft.sandbox_flutter_new"
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        applicationId = "com.samarlandsoft.sandbox_flutter_new"
        minSdk = 28
        compileSdk = 36
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

//    signingConfigs {
//        create("release") {
//            keyAlias = keystoreProperties["keyAlias"] as String
//            keyPassword = keystoreProperties["keyPassword"] as String
//            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
//            storePassword = keystoreProperties["storePassword"] as String
//        }
//    }
//
//    flavorDimensions += "app"
//
//    productFlavors {
//        create("dev") {
//            dimension = "app"
//            applicationIdSuffix = ".dev"
//            resValue("string", "app_name", "Flutter Sandbox Dev")
//        }
//
//        create("stable") {
//            dimension = "app"
//            applicationIdSuffix = ".stb"
//            resValue("string", "app_name", "Flutter Sandbox Stable")
//        }
//
//        create("staging") {
//            dimension = "app"
//            applicationIdSuffix = ".stg"
//            resValue("string", "app_name", "Flutter Sandbox Staging")
//        }
//
//        create("prod") {
//            dimension = "app"
//            resValue("string", "app_name", "Flutter Sandbox")
//        }
//    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }

        release {
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false
            signingConfig = signingConfigs.getByName("debug")
        }
    }

//    applicationVariants.all {
//        val variant = this
//        variant.outputs.map { it as com.android.build.gradle.internal.api.BaseVariantOutputImpl }.forEach { output ->
//            val flavor = variant.flavorName ?: "noflavor"
//            val buildType = variant.buildType.name
//            val versionName = variant.versionName
//            val applicationId = variant.applicationId
//            val appIdSanitized = applicationId.replace(".", "-")
//
//            val outputFileName = if (flavor.contains("prod")) {
//                "$appIdSanitized-prod-$buildType-$versionName.apk"
//            } else {
//                "$appIdSanitized-$buildType-$versionName.apk"
//            }
//
//            println("OutputFileName: $outputFileName")
//            output.outputFileName = outputFileName
//        }
//    }
}

flutter {
    source = "../.."
}

//dependencies {
//    implementation(platform("com.google.firebase:firebase-bom:34.5.0"))
//    implementation("androidx.core:core-splashscreen:1.2.0")
//    implementation("com.google.firebase:firebase-crashlytics")
//    implementation("com.google.firebase:firebase-analytics")
//    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
//}