#!/bin/zsh

TARGET_DIR_1="./PomPadDo.mobileUITests"
echo "🔄 Change dir to: $TARGET_DIR_1"
cd "$TARGET_DIR_1" || {
    echo "❌ Error changing directory: $TARGET_DIR_1"
    exit 1
}

echo "🚀 Run fastlane snapshot..."
if ! fastlane snapshot; then
    echo "❌ Error running fastlane snapshot"
    exit 1
fi

TARGET_DIR_2="../screenshots/mobile"
echo "\n🔄 Change dir to: $TARGET_DIR_2"
cd "$TARGET_DIR_2" || {
    echo "❌ Error changing directory: $TARGET_DIR_2"
    exit 1
}

echo "🎨 Run fastlane frameit..."
if ! fastlane frameit; then
    echo "❌ Error running fastlane frameit"
    exit 1
fi

echo "\n✅ All done!"