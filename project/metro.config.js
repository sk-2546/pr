const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Add support for Firebase
config.resolver.assetExts.push('cjs');

module.exports = config;