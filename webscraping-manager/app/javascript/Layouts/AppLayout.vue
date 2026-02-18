<template>
  <v-app>
    <v-app-bar density="compact" color="primary" dark flat class="px-3">
      <v-toolbar-title class="text-subtitle-1 font-weight-bold">
        {{ title || "Webscraping Veículos" }}
      </v-toolbar-title>

      <!-- 🔔 Notificações -->
      <v-menu
        v-model="notificationsMenu"
        location="bottom end"
        offset="4"
        min-width="320"
      >
        <template #activator="{ props }">
          <v-btn v-bind="props" icon variant="text" size="small">
            <v-badge
              :content="unreadCount"
              :model-value="unreadCount > 0"
              color="error"
              overlap
            >
              <v-icon icon="mdi-bell-outline" />
            </v-badge>
          </v-btn>
        </template>

        <v-card max-height="400" class="pa-2">
          <v-card-title class="text-subtitle-2 font-weight-bold">
            Notificações
          </v-card-title>

          <v-divider class="my-2" />

          <v-list density="compact">
            <v-list-item
              v-for="(n, index) in notifications"
              :key="index"
              @click="markAsRead(n)"
            >
              <v-list-item-title>
                {{ n.message }}
              </v-list-item-title>
              <v-list-item-subtitle class="text-caption">
                {{ n.time }}
              </v-list-item-subtitle>
            </v-list-item>

            <v-list-item v-if="notifications.length === 0">
              <v-list-item-title class="text-caption">
                Nenhuma notificação
              </v-list-item-title>
            </v-list-item>
          </v-list>
        </v-card>
      </v-menu>

      <!-- Menu usuário -->
      <v-menu v-model="menu" location="bottom end" offset="4" min-width="200">
        <template #activator="{ props }">
          <v-btn v-bind="props" icon variant="text" size="small">
            <v-avatar size="32" color="grey-darken-2">
              <span class="text-white text-caption font-weight-medium">
                {{ userInitials }}
              </span>
            </v-avatar>
          </v-btn>
        </template>

        <v-card min-width="200" class="pa-1">
          <v-list density="compact" class="py-1">
            <v-list-item>
              <v-list-item-title class="font-weight-medium">
                {{ user?.name || "Usuário" }}
              </v-list-item-title>
              <v-list-item-subtitle class="text-caption">
                {{ user?.email || "—" }}
              </v-list-item-subtitle>
            </v-list-item>

            <v-divider class="my-1" />

            <v-list-item
              color="error"
              @click="logout"
              density="compact"
              rounded
            >
              <template #prepend>
                <v-icon icon="mdi-logout" size="small" class="mr-3" />
              </template>
              <v-list-item-title class="text-body-2 text-error">
                Sair
              </v-list-item-title>
            </v-list-item>
          </v-list>
        </v-card>
      </v-menu>
    </v-app-bar>

    <v-main>
      <div class="pa-4">
        <slot />
      </div>
    </v-main>

    <v-snackbar
      v-model="snackbar.show"
      :timeout="4000"
      location="top right"
      color="success"
    >
      {{ snackbar.message }}
    </v-snackbar>
  </v-app>
</template>

<script>
export default {
  props: {
    title: { type: String, default: null },
  },

  data() {
    return {
      menu: false,
      notificationsMenu: false,
      subscription: null,

      notifications: [],
      unreadCount: 0,

      snackbar: {
        show: false,
        message: "",
      },
    };
  },

  computed: {
    user() {
      return this.$page?.props?.user || null;
    },

    userInitials() {
      const email = this.user?.email;
      if (!email) return "??";
      const local = email.split("@")[0] || "";
      const letters = local.replace(/[^a-zA-Z]/g, "").toUpperCase();
      return (letters.slice(0, 2) || "??").padEnd(2, "?");
    },
  },

  methods: {
    go(path) {
      this.$inertia.visit(path, { preserveScroll: true });
    },

    routeUrl(path) {
      return path;
    },

    logout() {
      this.$inertia.delete("/logout", {
        onSuccess: () => (this.menu = false),
        preserveScroll: true,
      });
    },

    addNotification(data) {
      const notification = {
        message: data.message || "Nova notificação",
        time: new Date().toLocaleTimeString(),
        read: false,
      };

      this.notifications.unshift(notification);
      this.unreadCount++;

      // Snackbar
      this.snackbar.message = notification.message;
      this.snackbar.show = true;
    },

    markAsRead(notification) {
      if (!notification.read) {
        notification.read = true;
        this.unreadCount = Math.max(0, this.unreadCount - 1);
      }
    },
  },

  mounted() {
    this.$cable.subscribe({
      channel: "NotificationsChannel",
      room: "public",
    });
  },

  channels: {
    NotificationsChannel: {
      connected() {
        console.log("Conectado ao NotificationChannel");
      },

      rejected() {},
      received(data) {
        this.$inertia.reload({
          only: ["kpis", "recent_runs", "health", "top_sources", "tasks"],
          preserveScroll: true,
        });
        this.addNotification(data);
      },
      disconnected() {},
    },
  },
};
</script>
