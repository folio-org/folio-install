const platformCore = require('@folio/platform-core/stripes.config.js');
const { merge } = require('lodash');

const platformComplete = {
  okapi: { 'url':'DOCKER_OKAPI_SCHEME://DOCKER_OKAPI_HOSTPORT', 'tenant':'DOCKER_OKAPI_TENANT' },
  modules: {
    '@folio/calendar' : {},
    '@folio/eholdings' : {},
    '@folio/finance' : {},
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
