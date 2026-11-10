#!/bin/zsh

TARGET_DIR_1="./PomPadDo.mobileUITests"
echo "🔄 Change dir to: $TARGET_DIR_1"
cd "$TARGET_DIR_1" || {
    echo "❌ Error changing directory: $TARGET_DIR_1"
    exit 1
}

echo "🚀 Run iOS fastlane snapshot..."
if ! fastlane snapshot; then
    echo "❌ Error running fastlane snapshot"
    exit 1
fi

cd ../screenshots/mobile/en-US
./frameit.sh

cd ../ru
./frameit.sh

cd ..


TARGET_DIR_3="../../PomPadDo.watchUITests"
echo "🔄 Change dir to: $TARGET_DIR_3"
cd "$TARGET_DIR_3" || {
    echo "❌ Error changing directory: $TARGET_DIR_3"
    exit 1
}

echo "🚀 Run watchOS fastlane snapshot..."
if ! fastlane snapshot; then
    echo "❌ Error running fastlane snapshot"
    exit 1
fi

echo "\n✅ All done!"