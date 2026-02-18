import { createApp, h } from "vue";
import { createInertiaApp } from "@inertiajs/vue3";
import ActionCableVue from "actioncable-vue";

// 1. Import Vuetify
import "vuetify/styles";
import { createVuetify } from "vuetify";
import * as components from "vuetify/components";
import * as directives from "vuetify/directives";

// Importe o CSS dos ícones MDI
import "@mdi/font/css/materialdesignicons.css";

import AppLayout from "../Layouts/AppLayout.vue";

const pages = import.meta.glob("../pages/**/*.vue", { eager: true });

const vuetify = createVuetify({
  components,
  directives,
});

createInertiaApp({
  resolve: async (name) => {
    const path = `../pages/${name}.vue`;
    const entry = pages[path];

    if (!entry) {
      throw new Error(`Página não encontrada: ${path}`);
    }

    const page = typeof entry === "function" ? await entry() : entry;

    if (!Object.prototype.hasOwnProperty.call(page.default, "layout")) {
      page.default.layout = (h, p) => h(AppLayout, {}, () => p);
    }

    return page;
  },

  setup({ el, App, props, plugin }) {
    const app = createApp({ render: () => h(App, props) });
    const userId = props.initialPage.props.user?.id

    const actionCableVueOptions = {
      debug: true,
      debugLevel: "error",
      connectionUrl: `ws://localhost:3002/api/cable?user_id=${userId}`,
      connectImmediately: true,
      unsubscribeOnUnmount: true,
    };

    app.use(plugin);
    app.use(vuetify);
    app.use(ActionCableVue, actionCableVueOptions)
    app.mount(el);
  },
});

// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
console.log("Vite ⚡️ Rails");

// If using a TypeScript entrypoint file:
//     <%= vite_typescript_tag 'application' %>
//
// If you want to use .jsx or .tsx, add the extension:
//     <%= vite_javascript_tag 'application.jsx' %>

// Example: Load Rails libraries in Vite.
//
// import * as Turbo from '@hotwired/turbo'
// Turbo.start()
//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.glob('./**/*_channel.js', { eager: true })

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'
