import { createApp } from '@backstage/frontend-defaults';
import appPlugin from '@backstage/plugin-app';
import { beyondAppTheme } from './theme';

import catalogPlugin from '@backstage/plugin-catalog/alpha';
import scaffolderPlugin from '@backstage/plugin-scaffolder/alpha';
import techdocsPlugin from '@backstage/plugin-techdocs/alpha';
import apiDocsPlugin from '@backstage/plugin-api-docs/alpha';
import userSettingsPlugin from '@backstage/plugin-user-settings/alpha';
import orgPlugin from '@backstage/plugin-org/alpha';
import searchPlugin from '@backstage/plugin-search/alpha';
import lighthousePlugin from '@backstage-community/plugin-lighthouse/alpha';
import homePlugin from '@backstage/plugin-home/alpha';

const lighthouseHome = lighthousePlugin.withOverrides({
  extensions: [
    lighthousePlugin.getExtension('page:lighthouse').override({
      params: { path: '/lighthouse' },
    }),
  ],
});

const themedApp = appPlugin.withOverrides({
  extensions: [
    appPlugin.getExtension('theme:app/light').override({
      params: { theme: beyondAppTheme },
    }),
  ],
});

const app = createApp({
  features: [
    themedApp,           // app with custom theme
    homePlugin,          // homepage
    catalogPlugin,       // catalog
    apiDocsPlugin,       // APIs
    techdocsPlugin,      // docs
    scaffolderPlugin,    // create
    searchPlugin,        // search
    lighthouseHome,      // lighthouse
    userSettingsPlugin,  // settings
    orgPlugin,
  ],
});

export default app.createRoot();