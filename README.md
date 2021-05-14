An SDL2 Vulkan renderer for Windows, Linux, and Android in the D Programming Language (based on vulkan-tutorial.com)
Includes the SDL DLLs for windows, and a cleand up SDL2 android_project. There are a lot of requirements to build the 
software (SDL, AndroidStudio, Android NDK). The software has been tested under x64 (Windows and Linux) and on 
arm64-v8a (Android 10). 

## Compiling for windows
Install the [DMD compiler](https://dlang.org/download.html) for your OS, and compile the project:

```
    git clone https://github.com/DannyArends/VulcanoD.git
    cd VulcanoD
    dub
```

Make sure the glslc compiler is available and on your $PATH variable to build the vertex and fragment shaders in 
the app/src/main/assets/data/shaders/ folder. The glslc compiler is included in the 
[LunarG Vulkan SDK](https://vulkan.lunarg.com/), as well as in the SDK provided by [Android Studio](https://developer.android.com/studio):

```
    cd VulcanoD
    glslc.exe app/src/main/assets/data/shaders/tiangle.vert -o app/src/main/assets/data/shaders/vert.spv
    glslc.exe app/src/main/assets/data/shaders/tiangle.frag -o app/src/main/assets/data/shaders/frag.spv
    dub
```

## Compiling for linux
For Linux a working [D compiler](https://dlang.org/download.html) (DMD, LDC2, GDC), and DUB package manager are required as well as the following 
dependencies (and corresponding -dev packages):

 * [SDL2](https://www.libsdl.org/)
 * [SDL2_image](https://www.libsdl.org/projects/SDL_image/)
 * [SDL_mixer](https://www.libsdl.org/projects/SDL_mixer/)
 * [SDL_net](https://www.libsdl.org/projects/SDL_net/)
 * [SDL_ttf](https://www.libsdl.org/projects/SDL_ttf/)

These can often be installed by using the build-in package manager such as apt. Steps for Linux are similar to Windows:

```
    git clone https://github.com/DannyArends/VulcanoD.git
    cd VulcanoD
    glslc app/src/main/assets/data/shaders/tiangle.vert -o app/src/main/assets/data/shaders/vert.spv
    glslc app/src/main/assets/data/shaders/tiangle.frag -o app/src/main/assets/data/shaders/frag.spv
    dub
```


## Cross-Compiling for Android
On android we need VulcanoD and a fix for Android relating to the loading SDL2 on Android using the bindbc-sdl library:

```
    git clone https://github.com/DannyArends/VulcanoD.git
    git clone https://github.com/DannyArends/bindbc-sdl.git
```

###  Install Android studio and install the android NDK
Download [Andriod Studio](https://developer.android.com/studio), and install it. 
Follow [these steps](https://developer.android.com/studio/projects/install-ndk) 
to install the NDK (CMake is not required).

###  Install LDC  and the android library

1) Install the [LDC compiler](https://dlang.org/download.html) for your OS

2) Download the LDC aarch64 library for Android file "ldc2-X.XX.X-android-aarch64.tar.xz" from 
https://github.com/ldc-developers/ldc/releases/ where X.XX.X is your LDC version and extract it

Open the file PATHTOLDC/ldc-X.XX.X/etc/ldc2.conf, where PATHTOLDC is where you installed LDC in step 1. 

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
        "<PATHTOLDCLIB>/ldc2-1.23.0-android-aarch64/lib",
    ];
    rpath = "";
};
```

###  Download the SDL Source zip files and link SDL into app/jni
Download and extract the SDL2 source zip-files:
[SDL2](https://www.libsdl.org/download-2.0.php), 
[SDL2_image](https://www.libsdl.org/projects/SDL_image/), 
[SDL_net](https://www.libsdl.org/projects/SDL_net/), 
[SDL_ttf](https://www.libsdl.org/projects/SDL_ttf/), 
[SDL_mixer](https://www.libsdl.org/projects/SDL_mixer/), and extract them.

Create symlinks (e.g. using mklink for windows, or ln -s in linux) in tot VulcanoD\app\jni folder and 
link to the extracted SDL source packages. Change PATHTO to where your cloned VulcanoD, and PATHSDL to 
where your downloaded the SDL libraries:

```
mklink /d "PATHTO\VulcanoD\app\jni\SDL" "PATHSDL\SDL2-2.0.14"
mklink /d "PATHTO\VulcanoD\app\jni\SDL2_image" "PATHSDL\SDL2_image-2.0.5"
mklink /d "PATHTO\VulcanoD\app\jni\SDL2_net" "PATHSDL\SDL2_net-2.0.1"
mklink /d "PATHTO\VulcanoD\app\jni\SDL2_ttf" "PATHSDL\SDL2_ttf-2.0.15"
mklink /d "PATHTO\VulcanoD\app\jni\SDL2_mixer" "PATHSDL\SDL2_mixer-2.0.4"
```

### Cross-compiling the D source code (Android version)

Cross-compile the VulcanoD android aarch64 library with dub:

```
cd VulcanoD
dub --compiler=ldc2 --arch=aarch64-*-linux-android --config=android-64
```

This will produce a libmain.so in app/src/main/jniLibs/arm64-v8a

### Build APK, and run on Android

Open up the VulcanoD project in Android Studio, and build the APK and install onto your Android mobile.