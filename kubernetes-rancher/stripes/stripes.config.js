module.exports = {
  okapi: { 'url':'http://folio-okapi-traffic-arecord.org', 'tenant':'diku' },
  config: {
    logCategories: 'core,path,action,xhr',
    logPrefix: '--',
    showPerms: false
  },
  modules: {
    "@folio/users" : {},
    "@folio/inventory" : {},
    "@folio/checkout" : {},
    "@folio/checkin" : {},
    "@folio/requests" : {},
    "@folio/calendar" : {},
    "@folio/search" : {},
    "@folio/organization" : {},
    "@folio/developer" : {},
    "@folio/circulation" : {},
    "@folio/eholdings" : {},
    "@folio/vendors": {},
    "@folio/plugin-find-user" : {}
  },
  branding: {
    logo: {
      src: './tenant-assets/opentown-libraries-logo.png',
      alt: 'Opentown Libraries',
    },
    favicon: {
      src: './tenant-assets/opentown-libraries-favicon.png',
    },
  },
};
