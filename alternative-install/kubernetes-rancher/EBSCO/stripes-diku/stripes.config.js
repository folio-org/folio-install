module.exports = {
  okapi: { 'url':'http://localhost:9130', 'tenant':'diku' },
  config: {
    logCategories: 'core,path,action,xhr',
    logPrefix: '--',
    showPerms: false
  },
  modules: {
    '@folio/agreements': {},
    '@folio/calendar' : {},
    '@folio/checkin' : {},
    '@folio/checkout' : {},
    '@folio/circulation' : {},
    '@folio/data-import' : {},
    '@folio/developer' : {},
    '@folio/eholdings' : {},
    '@folio/erm-usage': {},
    '@folio/finance' : {},
    '@folio/inventory' : {},
    '@folio/licenses': {},
    '@folio/myprofile' : {},
    '@folio/notes' : {},
    '@folio/orders': {},
    '@folio/organizations' : {},
    '@folio/plugin-create-item': {},
    '@folio/plugin-find-agreement': {},
    '@folio/plugin-find-contact': {},
    '@folio/plugin-find-instance' : {},
    '@folio/plugin-find-license': {},
    '@folio/plugin-find-user' : {},
    '@folio/plugin-find-organization': {},
    '@folio/requests' : {},
    '@folio/search' : {},
    '@folio/servicepoints' : {},
    '@folio/stripes-erm-components': {},
    '@folio/tags': {},
    '@folio/tenant-settings' : {},
    '@folio/users' : {}
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
