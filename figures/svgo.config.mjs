export default {
  multipass: true, // boolean
  plugins: [
    {
      name: 'preset-default',
      params: {
        overrides: {
          // disable a default plugin
          convertPathData: false,
        },
      },
    },
  ],
};
/*
export default {
  multipass: false, // boolean
  plugins: [
    'preset-default', // built-in plugins enabled by default
    'convertStyleToAttrs', // enable built-in plugins by name
  ],
};
*/
