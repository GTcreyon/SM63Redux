#!/bin/bash

# Setting env variables
# If you already have these variables set globally, comment the exports out.
# Otherwise, fill them in with the relevant information
# See more: https://godot-rust.github.io/book/exporting/android.html

# Export the versions
export ANDROID_SDK_ROOT="/home/jaschutte/Android/Sdk"
export ANDROID_NDK_VERSION="25.1.8937393"

# Export linker settings
export CARGO_TARGET_ARMV7_LINUX_ANDROIDEABI_LINKER="/home/jaschutte/Android/Sdk/ndk/25.1.8937393/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi33-clang"
export CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER="/home/jaschutte/Android/Sdk/ndk/25.1.8937393/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android33-clang"
export CARGO_TARGET_I686_LINUX_ANDROID_LINKER="/home/jaschutte/Android/Sdk/ndk/25.1.8937393/toolchains/llvm/prebuilt/linux-x86_64/bin/i686-linux-android33-clang"
export CARGO_TARGET_X86_64_LINUX_ANDROID_LINKER="/home/jaschutte/Android/Sdk/ndk/25.1.8937393/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android33-clang"

# Also if the android NDK is 23+ then you need to apply the following fix:
# https://github.com/rust-lang/rust/pull/85806#issuecomment-1096266946

# From: https://stackoverflow.com/questions/29436275/how-to-prompt-for-yes-or-no-in-bash
function boolean_prompt {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 1;;  
            [Nn]*) return 0;;
        esac
    done
}

echo "Inorder for this builder to work properly, you first must have rust installed properly."
boolean_prompt "Do you have rust installed?"
if [ $? == 0 ]; then
	echo "Aborted."
	exit 1;
fi

# We compile for: Mac, Linux, Android, Windows, Web
echo ""
echo "In order to cross-compile, one needs to install all the required toolchains. If you have installed these before, skip this step."
echo "NOTE: Inorder to cross-compile, you MUST have the Android-SDK with NDK enabled and installed for Android."
echo "		-> https://developer.android.com/studio"
echo "NOTE: Inorder to cross-compile, you MUST have Xcode SDKs installed for MacOS."
echo "		-> https://developer.apple.com/xcode/"
echo "If one is missing one of these tools, compilation for that platform will fail."
echo ""
boolean_prompt "Do you have all the rust toolchains installed for cross-compilation?"

if [ $? == 0 ]; then
	echo "$(tput setaf 5)		Windows:"
	rustup target add i686-pc-windows-gnu
	rustup target add x86_64-pc-windows-gnu
	echo "$(tput setaf 5)		Mac:"
	rustup target add x86_64-apple-darwin
	echo "$(tput setaf 5)		Linux:"
	rustup target add i686-unknown-linux-gnu
	rustup target add x86_64-unknown-linux-gnu
	echo "$(tput setaf 5)		Web:"
	rustup target add wasm32-wasi
	echo "$(tput setaf 5)		Android:"
	rustup target add arm-linux-androideabi
	rustup target add aarch64-linux-android
	rustup target add i686-linux-android
	rustup target add x86_64-linux-android

	echo "Installation of toolchains complete."
fi
echo ""
echo "Now it will compile for all platforms."
echo "Press enter to continue."
read
echo "Compiling for all platforms."


echo "$(tput setaf 6)		Windows:"
cargo build --release --target i686-pc-windows-gnu
cargo build --release --target x86_64-pc-windows-gnu
echo "$(tput setaf 6)		Mac:"
cargo build --release --target x86_64-apple-darwin
echo "$(tput setaf 6)		Linux:"
cargo build --release --target i686-unknown-linux-gnu
cargo build --release --target x86_64-unknown-linux-gnu
echo "$(tput setaf 6)		Web:"
cargo build --release --target wasm32-wasi
echo "$(tput setaf 6)		Android:"
cargo build --release --target arm-linux-androideabi
cargo build --release --target aarch64-linux-android
cargo build --release --target i686-linux-android
cargo build --release --target x86_64-linux-android

echo ""
echo "Copying all results to /bin"
for file in target/*; do
	if [[ -e "$file/release/pipescript.dll" ]]; then
		echo -e '\t'Copying $file/release/pipescript.dll to bin/"${file:7}".dll
		cp $file/release/pipescript.dll bin/"${file:7}".dll
	fi
	if [[ -e "$file/release/libpipescript.so" ]]; then
		echo -e '\t'Copying $file/release/libpipescript.so to bin/"${file:7}".so
		cp $file/release/libpipescript.so bin/"${file:7}".so
	fi
	if [[ -e "$file/release/pipescript.wasm" ]]; then
		echo -e '\t'Copying $file/release/pipescript.wasm to bin/"${file:7}".wasm
		cp $file/release/pipescript.wasm bin/"${file:7}".wasm
	fi
done
echo ""
echo "Done!"
