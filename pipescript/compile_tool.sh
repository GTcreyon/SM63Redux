
# Setting env variables
# If you already have these variables set globally, comment the exports out.
# Otherwise, fill them in with the relevant information
# See more: https://godot-rust.github.io/book/exporting/android.html

# Export the versions
export ANDROID_SDK_ROOT=
export ANDROID_NDK_VERSION=

# Export linker settings
export CARGO_TARGET_ARMV7_LINUX_ANDROIDEABI_LINKER=
export CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER=
export CARGO_TARGET_I686_LINUX_ANDROID_LINKER=
export CARGO_TARGET_X86_64_LINUX_ANDROID_LINKER=

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
echo "If you're trying to compile a release build, this step is required."
echo "If you're trying to compile just to develop and have access to PipeScript, say no."
boolean_prompt "Compile for all platforms?"
if [ $? == 1 ]; then

	echo ""
	echo "In order to cross-compile, one needs to install all the required toolchains. If you have installed these before, skip this step."
	echo "NOTE: Inorder to cross-compile, you MUST have msvc installed for windows."
	echo "		-> https://visualstudio.microsoft.com/downloads"
	echo "NOTE: Inorder to cross-compile, you MUST have the Android-SDK with NDK enabled and installed for Android."
	echo "		-> https://developer.android.com/studio"
	echo "NOTE: Inorder to cross-compile, you MUST have Xcode SDKs installed for MacOS."
	echo "		-> https://developer.apple.com/xcode/"
	echo "If one is missing one of these tools, compilation for that platform will fail."
	echo ""
	boolean_prompt "Do you have all the rust toolchains installed for cross-compilation?"

	if [ $? == 0 ]; then
		echo "		Windows:"
		rustup target add i686-pc-windows-msvc
		rustup target add x86_64-pc-windows-msvc
		echo "		Mac:"
		rustup target add x86_64-apple-darwin
		echo "		Linux:"
		rustup target add i686-unknown-linux-gnu
		rustup target add x86_64-unknown-linux-gnu
		echo "		Web:"
		rustup target add wasm32-wasi
		echo "		Android:"
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
	

	echo "		Windows:"
	cargo build --release --target i686-pc-windows-msvc
	cargo build --release --target x86_64-pc-windows-msvc
	echo "		Mac:"
	cargo build --release --target x86_64-apple-darwin
	echo "		Linux:"
	cargo build --release --target i686-unknown-linux-gnu
	cargo build --release --target x86_64-unknown-linux-gnu
	echo "		Web:"
	cargo build --release --target wasm32-wasi
	echo "		Android:"
	cargo build --release --target arm-linux-androideabi
	cargo build --release --target aarch64-linux-android
	cargo build --release --target i686-linux-android
	cargo build --release --target x86_64-linux-android
else
	echo "Compiling for local platform only."
	cargo build --release
fi

echo "Done!"
echo "Press enter to continue."
read
