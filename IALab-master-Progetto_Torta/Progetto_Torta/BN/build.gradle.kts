import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

buildscript {
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath(kotlin("gradle-plugin", "1.3.11"))
    }
}

plugins {
    java
    eclipse
    idea
    kotlin("jvm") version "1.3.11"
    id("org.jetbrains.dokka") version "0.9.17"
}

group = "org.devalot"
version = "0.0.1"

repositories {
    mavenCentral()
}

dependencies {
    implementation(kotlin("reflect"))
    implementation(kotlin("stdlib-jdk8"))
    implementation("com.googlecode.aima-java", "aima-core", "3.0.0")
    implementation("com.google.guava", "guava", "27.0.1-jre")
    implementation("org.encog", "encog-core", "3.3.0")
    testImplementation("org.junit.jupiter:junit-jupiter-api:5.3.2")
    testImplementation("org.junit.jupiter:junit-jupiter-params:5.3.2")
    testRuntime("org.junit.jupiter:junit-jupiter-engine:5.3.2")
}

val compileKotlin: KotlinCompile by tasks
compileKotlin.kotlinOptions {
    jvmTarget = "1.8"
}
val compileTestKotlin: KotlinCompile by tasks
compileTestKotlin.kotlinOptions {
    jvmTarget = "1.8"
}

configure<JavaPluginConvention> {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
}

tasks.withType<Test> {
    useJUnitPlatform()
    minHeapSize = "4g"
    maxHeapSize = "16g"
}
