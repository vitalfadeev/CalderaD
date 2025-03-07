Another SDL2 Vulkan renderer in the D Programming Language. However, this one will work on Windows, Linux, and even Android.
The current 'engine' is based on the excellent vulkan-tutorial.com, and uses SDL2 via the 
[bindbc-sdl](https://github.com/BindBC/bindbc-sdl) bindings for cross-platform support. Vulkan support is bound using the 
[ErupteD](https://github.com/ParticlePeter/ErupteD) binding for Vulkan. This repository includes the SDL DLLs 
for windows, and is in itself a minimal SDL2 android_project. There are a lot of requirements to build the example 
(SDL, AndroidStudio, Android NDK). The software has been tested under x64 (Windows and Linux) and on arm64-v8a (Android 10). 

The name CalderaD, comes from the word caldera a large cauldron-like hollow that forms shortly after a volcanic eruption. 
The term comes from Spanish caldera, and Latin caldaria, meaning "cooking pot". I hope this project can help others cook up 
some nice android apps, and will show that a language like D has something to offer on the mobile platform.

### Structure
The following folders are interesting, if you're interested in how CalderaD is coded:

- [src/](./src/) which stores the D source code
- [app/jni](./app/jni/) the folder where the sdl library symlinks should be created (for android)
- [app/src/main/assets](./app/src/main/assets/) wavefront object files, texture/font files, glsl shader source code
- [app/src/main/java](./app/src/main/java) the android side of the app (android_project java files from SDL)
- [app/src/main/jniLibs](./app/src/main/jniLibs) the output folder for SDL and CalderaD libmain.so
- [libs/](./libs/) compatible set of Windows 32/64 runtime SDL2 DLLs for a standalone build on windows

Some noteworthy files:

- [dub.json](./dub.json) contains the D language dependancies, and build instructions
- [src/main.d](./src/main.d) contains the main entry function, and SDL event loop
- [app/src/main/AndroidManifest.xml](./app/src/main/AndroidManifest.xml) is CalderaD Android Manifest file with build instructions, adapted from SDL2
- [vert](./app/src/main/assets/data/shaders/wavefront.vert) and [fragment](./app/src/main/assets/data/shaders/wavefront.frag) shaders for wavefront objects

## Compiling for Windows
To compile the shaders, install the glslc compiler from [LunarG Vulkan SDK](https://vulkan.lunarg.com/), 
a glslc compiler is also included in [Android Studio](https://developer.android.com/studio). 

Make sure the glslc compiler is installed and on your $PATH variable, if it is shaders are automatically 
compiled by dub. Install the [DMD compiler](https://dlang.org/download.html), and compile the project 
using dub:

```
    git clone https://github.com/DannyArends/CalderaD.git
    cd CalderaD
    dub
```

If this doesn't work, try to manually build the vertex and fragment shaders in the 
[app/src/main/assets/data/shaders/](./app/src/main/assets/data/shaders/) folder, 
before building with dub:

```
    cd CalderaD
    glslc.exe app/src/main/assets/data/shaders/wavefront.vert -o app/src/main/assets/data/shaders/vert.spv
    glslc.exe app/src/main/assets/data/shaders/wavefront.frag -o app/src/main/assets/data/shaders/frag.spv
    dub
```

## Compiling for Linux
For Linux a working [D compiler](https://dlang.org/download.html) (DMD, LDC2, GDC) and DUB package manager are 
required as well as the following dependencies (and corresponding -dev packages):

 * [SDL2](https://www.libsdl.org/)
 * [SDL2_image](https://www.libsdl.org/projects/SDL_image/)
 * [SDL_mixer](https://www.libsdl.org/projects/SDL_mixer/)
 * [SDL_net](https://www.libsdl.org/projects/SDL_net/)
 * [SDL_ttf](https://www.libsdl.org/projects/SDL_ttf/)

These can often be installed by using the build-in package manager such as apt. Compilation steps for 
Linux are similar to Windows, the [dub.json](./dub.json) might need some paths adjusted:

```
    git clone https://github.com/DannyArends/CalderaD.git
    cd CalderaD
    glslc app/src/main/assets/data/shaders/wavefront.vert -o app/src/main/assets/data/shaders/vert.spv
    glslc app/src/main/assets/data/shaders/wavefront.frag -o app/src/main/assets/data/shaders/frag.spv
    dub
```


## Cross-Compiling for Android
To get CalderaD working on an android device, follow the following step:

```
    git clone https://github.com/DannyArends/CalderaD.git
```

###  Install Android studio and install the android NDK
Download [Andriod Studio](https://developer.android.com/studio), and install it. 
Follow [these steps](https://developer.android.com/studio/projects/install-ndk) 
to install the NDK (CMake is not required).

###  Install LDC  and the android library

1) Install the [LDC compiler](https://dlang.org/download.html) for your OS

2) Download the LDC aarch64 library for Android file "ldc2-X.XX.X-android-aarch64.tar.xz" from 
https://github.com/ldc-developers/ldc/releases/ where X.XX.X is your LDC version and extract it

Open the file PATHTOLDC/ldc2-X.XX.X/etc/ldc2.conf, where PATHTOLDC is where you installed LDC in step 1. 

To this file add the aarch64 compile target, make sure to change PATHTOSDK to the path of the Android Studio SDK&NDK, and to 
change the PATHTOLDCLIB to the path of the LDC aarch64 library (step 2):

```Gradle
"aarch64-.*-linux-android":
{
    switches = [
        "-defaultlib=phobos2-ldc,druntime-ldc",
        "-link-defaultlib-shared=false",
        "-gcc=PATHTOSDK/Android/Sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang",
    ];
    lib-dirs = [
        "<PATHTOLDCLIB>/ldc2-X.XX.X-android-aarch64/lib",
    ];
    rpath = "";
};
```

A tip: make sure API versions match, sometimes misadjusted versions can cause hour long headaches

###  Download the SDL Source zip files and link SDL into app/jni
Download and extract the SDL2 source zip-files:
[SDL2](https://www.libsdl.org/download-2.0.php), 
[SDL2_image](https://www.libsdl.org/projects/SDL_image/), 
[SDL_net](https://www.libsdl.org/projects/SDL_net/), 
[SDL_ttf](https://www.libsdl.org/projects/SDL_ttf/), 
[SDL_mixer](https://www.libsdl.org/projects/SDL_mixer/), and extract them.

Create symlinks (e.g. using mklink for windows, or ln -s in linux) in tot CalderaD\app\jni folder and 
link to the extracted SDL source packages. Change PATHTO to where your cloned CalderaD is located, and PATHSDL to 
where you downloaded the SDL libraries:

```
mklink /d "PATHTO\CalderaD\app\jni\SDL" "PATHSDL\SDL2-2.0.14"
mklink /d "PATHTO\CalderaD\app\jni\SDL2_image" "PATHSDL\SDL2_image-2.0.5"
mklink /d "PATHTO\CalderaD\app\jni\SDL2_net" "PATHSDL\SDL2_net-2.0.1"
mklink /d "PATHTO\CalderaD\app\jni\SDL2_ttf" "PATHSDL\SDL2_ttf-2.0.15"
mklink /d "PATHTO\CalderaD\app\jni\SDL2_mixer" "PATHSDL\SDL2_mixer-2.0.4"
```

### Cross-compiling the D source code (Android version)

Cross-compile the CalderaD android aarch64 library with dub:

```
cd CalderaD
dub --compiler=ldc2 --arch=aarch64-*-linux-android --config=android-64
```

This will produce a libmain.so in app/src/main/jniLibs/arm64-v8a

### Build APK, and run on Android

Open up the CalderaD project in Android Studio, and build the APK. Inspect the APK, to see if 
libmain.so and several SDL .so files are included into the APK. If so, install the APK onto 
your Android device.

## Contributing

Want to contribute? Great! Contribute to CalderaD by starring or forking on Github, and feel free 
to start an issue first to discuss idea's before sending a pull request. You're also welcome to 
post comments on commits.

Or be a maintainer, and adopt (the documentation of) a function.

### License

CalderaD is written by Danny Arends and is released under the GNU GENERAL PUBLIC LICENSE Version 3 (GPLv3). See [LICENSE.txt](./LICENSE.txt).
