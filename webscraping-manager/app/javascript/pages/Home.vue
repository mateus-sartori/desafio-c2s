<template>
  <v-app>
    <v-main>
      <div class="pa-4">
        <div class="d-flex align-center justify-space-between mb-4">
          <div>
            <div class="text-h6 font-weight-bold">Dashboard</div>
            <div class="text-caption text-medium-emphasis">Visão geral</div>
          </div>

          <div class="d-flex ga-2">
            <v-btn
              color="primary"
              prepend-icon="mdi-plus"
              @click="goToScrapings"
            >
              Scrapings
            </v-btn>
          </div>
        </div>

        <!-- KPIs -->
        <v-row dense>
          <v-col cols="12" md="3">
            <v-card rounded="lg" variant="tonal">
              <v-card-text class="d-flex align-center justify-space-between">
                <div>
                  <div class="text-caption text-medium-emphasis">
                    Coletas (7d)
                  </div>
                  <div class="text-h5 font-weight-bold">{{ kpis.runs7d }}</div>
                </div>
                <v-icon size="28" icon="mdi-robot" />
              </v-card-text>
            </v-card>
          </v-col>

          <v-col cols="12" md="3">
            <v-card rounded="lg" variant="tonal">
              <v-card-text class="d-flex align-center justify-space-between">
                <div>
                  <div class="text-caption text-medium-emphasis">
                    Anúncios capturados
                  </div>
                  <div class="text-h5 font-weight-bold">
                    {{ kpis.listings }}
                  </div>
                </div>
                <v-icon size="28" icon="mdi-car-multiple" />
              </v-card-text>
            </v-card>
          </v-col>

          <v-col cols="12" md="3">
            <v-card rounded="lg" variant="tonal">
              <v-card-text class="d-flex align-center justify-space-between">
                <div>
                  <div class="text-caption text-medium-emphasis">Erros</div>
                  <div class="text-h5 font-weight-bold">{{ kpis.errors }}</div>
                </div>
                <v-icon size="28" icon="mdi-alert-circle-outline" />
              </v-card-text>
            </v-card>
          </v-col>

          <v-col cols="12" md="3">
            <v-card rounded="lg" variant="tonal">
              <v-card-text class="d-flex align-center justify-space-between">
                <div>
                  <div class="text-caption text-medium-emphasis">
                    Tempo médio
                  </div>
                  <div class="text-h5 font-weight-bold">{{ kpis.avgTime }}</div>
                </div>
                <v-icon size="28" icon="mdi-timer-outline" />
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>

        <v-row dense class="mt-2">
          <!-- Últimas execuções -->
          <v-col cols="12" md="7">
            <v-card rounded="lg">
              <v-card-title class="text-subtitle-1 font-weight-bold">
                Últimas execuções
              </v-card-title>
              <v-divider />

              <v-table density="comfortable" class="text-body-2">
                <thead>
                  <tr>
                    <th>Job</th>
                    <th>Status</th>
                    <th class="text-right">Duração</th>
                    <th class="text-right">Capturados</th>
                    <th class="text-right">Quando</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="run in recent_runs" :key="run.id">
                    <td class="font-weight-medium">{{ run.name }}</td>
                    <td>
                      <v-chip
                        size="small"
                        :color="statusColor(run.status.toLowerCase())"
                        variant="tonal"
                      >
                        {{ statusLabel(run.status.toLowerCase()) }}
                      </v-chip>
                    </td>
                    <td class="text-right">{{ run.duration }}</td>
                    <td class="text-right">{{ run.items }}</td>
                    <td class="text-right text-medium-emphasis">
                      {{ run.ago }}
                    </td>
                  </tr>
                </tbody>
              </v-table>
            </v-card>
          </v-col>

          <!-- Alertas / saúde -->
          <v-col cols="12" md="5">
            <v-card rounded="lg" class="mb-3">
              <v-card-title class="text-subtitle-1 font-weight-bold">
                Saúde do sistema
              </v-card-title>
              <v-divider />
              <v-card-text class="pt-4">
                <div class="d-flex align-center justify-space-between mb-3">
                  <div>
                    <div class="text-caption text-medium-emphasis">
                      Tentativas (Pendentes)
                    </div>
                    <div class="font-weight-bold">
                      {{ health.retrySize }} jobs
                    </div>
                  </div>
                  <v-chip
                    size="small"
                    :color="health.retryColor"
                    variant="tonal"
                  >
                    {{ health.retryStatus }}
                  </v-chip>
                </div>

                <div class="d-flex align-center justify-space-between mb-3">
                  <div>
                    <div class="text-caption text-medium-emphasis">Fila</div>
                    <div class="font-weight-bold">
                      {{ health.queueSize }} jobs
                    </div>
                    <div class="text-caption text-medium-emphasis">
                      Latência: {{ health.queueLatency }}
                    </div>
                  </div>
                  <v-chip
                    size="small"
                    :color="health.queueColor"
                    variant="tonal"
                  >
                    {{ health.queueStatus }}
                  </v-chip>
                </div>

                <div class="d-flex align-center justify-space-between mb-3">
                  <div>
                    <div class="text-caption text-medium-emphasis">
                      Dead Jobs
                    </div>
                    <div class="font-weight-bold">
                      {{ health.deadSize }}
                    </div>
                  </div>
                  <v-chip
                    size="small"
                    :color="health.deadColor"
                    variant="tonal"
                  >
                    {{ health.deadStatus }}
                  </v-chip>
                </div>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>

        <!-- Top fontes -->
        <v-card rounded="lg" class="mt-3">
          <v-card-title class="text-subtitle-1 font-weight-bold">
            Top fontes (últimos 7 dias)
          </v-card-title>
          <v-divider />
          <v-card-text>
            <v-row dense>
              <v-col
                v-for="s in top_sources"
                :key="s.name"
                cols="12"
                sm="6"
                md="3"
              >
                <v-card variant="tonal" rounded="lg">
                  <v-card-text>
                    <div class="d-flex align-center justify-space-between">
                      <div class="font-weight-bold">{{ s.name }}</div>
                      <v-chip size="x-small" variant="tonal">{{
                        s.category
                      }}</v-chip>
                    </div>

                    <div class="mt-2 text-caption text-medium-emphasis">
                      Anúncios capturados
                    </div>
                    <div class="text-h6 font-weight-bold">{{ s.items }}</div>

                    <div class="mt-2 d-flex ga-2">
                      <v-chip size="x-small" :color="s.okColor" variant="tonal">
                        OK {{ s.ok }}
                      </v-chip>
                      <v-chip
                        size="x-small"
                        :color="s.errColor"
                        variant="tonal"
                      >
                        Erros {{ s.err }}
                      </v-chip>
                    </div>
                  </v-card-text>
                </v-card>
              </v-col>
            </v-row>
          </v-card-text>
        </v-card>
      </div>
    </v-main>
  </v-app>
</template>

<script>
export default {
  props: {
    kpis: Object,
    recent_runs: Array,
    health: Object,
    top_sources: Array,
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

  created() {
    this.$inertia.reload({
      only: ["kpis", "recent_runs", "health", "top_sources"],
      preserveScroll: true,
    });
  },

  methods: {
    statusLabel(status) {
      const map = {
        pending: "Pendente",
        processing: "Processando",
        finished: "Concluída",
        failed: "Falha",
      };
      return map[status] || status;
    },

    statusColor(status) {
      if (status === "pending") return "info";
      if (status === "processing") return "warning";
      if (status === "finished") return "success";
      if (status === "failed") return "error";
      return "default";
    },

    goToScrapings() {
      this.$inertia.get("/tasks");
    },

    logout() {
      this.$inertia.delete("/logout", {
        onSuccess: () => {
          this.menu = false;
        },
        preserveScroll: true,
      });
    },
  },
};
</script>
