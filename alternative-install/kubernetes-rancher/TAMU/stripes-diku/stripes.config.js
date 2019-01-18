const platformCore = require('@folio/platform-core/stripes.config.js');
const { merge } = require('lodash');

const platformComplete = {
  modules: {
    '@folio/agreements' : {},
    '@folio/calendar' : {},
    '@folio/data-import' : {},
    '@folio/eholdings' : {},
    '@folio/erm-usage' : {},
    '@folio/finance' : {},
    '@folio/licenses' : {},
    '@folio/marccat' : {},
    '@folio/plugin-find-vendor' : {},
    '@folio/orders' : {},
    '@folio/vendors' : {}
  },
  branding: {
    logo: {
      src: './tenant-assets/opentown-libraries-logo.png',
      alt: 'Opentown Libraries',
    },
    favicon: {
      src: './tenant-assets/opentown-libraries-favicon.png',
    },
  }
};

module.exports = merge({}, platformCore, platformComplete);