import { createApp } from '@backstage/frontend-defaults';

import catalogPlugin from '@backstage/plugin-catalog/alpha';
import scaffolderPlugin from '@backstage/plugin-scaffolder/alpha';
import techdocsPlugin from '@backstage/plugin-techdocs/alpha';
import apiDocsPlugin from '@backstage/plugin-api-docs/alpha';
import userSettingsPlugin from '@backstage/plugin-user-settings/alpha';
import orgPlugin from '@backstage/plugin-org/alpha';
import searchPlugin from '@backstage/plugin-search/alpha';
import lighthousePlugin from '@backstage-community/plugin-lighthouse/alpha';

const lighthouseHome = lighthousePlugin.withOverrides({
  extensions: [
    lighthousePlugin.getExtension('page:lighthouse').override({
      params: { path: '/' },
    }),
  ],
});

const app = createApp({
  features: [
    lighthouseHome,
    catalogPlugin,
    scaffolderPlugin,
    techdocsPlugin,
    apiDocsPlugin,
    userSettingsPlugin,
    orgPlugin,
    searchPlugin,
  ],
});

export default app.createRoot();