#!/bin/bash

# 🔥 Firebase Setup Script for Men Barbería
# This script installs Firebase CLI and FlutterFire CLI

echo "🔥 Setting up Firebase for Men Barbería..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required but not installed."
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js found: $(node --version)"

# Install Firebase CLI
echo "📦 Installing Firebase CLI..."
npm install -g firebase-tools

# Verify Firebase CLI installation
if command -v firebase &> /dev/null; then
    echo "✅ Firebase CLI installed: $(firebase --version)"
else
    echo "❌ Firebase CLI installation failed"
    exit 1
fi

# Install FlutterFire CLI
echo "📦 Installing FlutterFire CLI..."
dart pub global activate flutterfire_cli

# Verify FlutterFire CLI installation
if command -v flutterfire &> /dev/null; then
    echo "✅ FlutterFire CLI installed successfully"
else
    echo "❌ FlutterFire CLI installation failed"
    echo "Make sure ~/.pub-cache/bin is in your PATH"
fi

echo ""
echo "🎉 Firebase setup complete!"
echo ""
echo "Next steps:"
echo "1. Run: firebase login"
echo "2. Create a project in Firebase Console"
echo "3. Run: flutterfire configure"
echo "4. Follow the setup guide in setup_firebase.md"
echo ""
