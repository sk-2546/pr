module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      '@react-native-firebase/app',
      'react-native-reanimated/plugin',
    ],
  };
};