<template>
  <div class="pa-4">
    <!-- Header + Voltar -->
    <div class="d-flex align-center justify-space-between mb-3">
      <div>
        <v-btn
          variant="text"
          density="compact"
          prepend-icon="mdi-arrow-left"
          class="px-0"
          @click="goBack"
        >
          Voltar
        </v-btn>

        <div>
          <div class="text-h6 font-weight-bold">Tarefas de Scraping</div>
          <div class="text-caption text-medium-emphasis">
            Crie tarefas com URL da Webmotors e acompanhe o status/resultado.
          </div>
        </div>
      </div>

      <v-btn variant="tonal" prepend-icon="mdi-plus" @click="openCreate">
        Nova tarefa
      </v-btn>
    </div>

    <!-- Filtros -->
    <v-card rounded="lg" class="mb-4">
      <v-card-text>
        <v-row dense>
          <v-col cols="12" md="6">
            <v-text-field
              v-model="filters.q"
              label="Buscar por título, URL, usuário, marca/modelo"
              prepend-inner-icon="mdi-magnify"
              density="compact"
              variant="outlined"
              clearable
            />
          </v-col>

          <v-col cols="12" md="3">
            <v-select
              v-model="filters.status"
              :items="statusOptions"
              item-title="label"
              item-value="value"
              label="Status"
              density="compact"
              variant="outlined"
              clearable
            />
          </v-col>

          <v-col cols="12" md="3" class="d-flex align-center justify-end ga-2">
            <v-btn
              variant="text"
              prepend-icon="mdi-refresh"
              @click="resetFilters"
            >
              Limpar
            </v-btn>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>

    <!-- KPIs -->
    <v-row dense class="mb-2">
      <v-col cols="12" md="3">
        <v-card rounded="lg" variant="tonal">
          <v-card-text class="d-flex align-center justify-space-between">
            <div>
              <div class="text-caption text-medium-emphasis">Pendentes</div>
              <div class="text-h6 font-weight-bold">{{ kpi.pending }}</div>
            </div>
            <v-icon size="26" icon="mdi-clock-outline" />
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="3">
        <v-card rounded="lg" variant="tonal">
          <v-card-text class="d-flex align-center justify-space-between">
            <div>
              <div class="text-caption text-medium-emphasis">Processando</div>
              <div class="text-h6 font-weight-bold">{{ kpi.processing }}</div>
            </div>
            <v-icon size="26" icon="mdi-progress-clock" />
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="3">
        <v-card rounded="lg" variant="tonal">
          <v-card-text class="d-flex align-center justify-space-between">
            <div>
              <div class="text-caption text-medium-emphasis">Concluídas</div>
              <div class="text-h6 font-weight-bold">{{ kpi.finished }}</div>
            </div>
            <v-icon size="26" icon="mdi-check-circle-outline" />
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="3">
        <v-card rounded="lg" variant="tonal">
          <v-card-text class="d-flex align-center justify-space-between">
            <div>
              <div class="text-caption text-medium-emphasis">Falhas</div>
              <div class="text-h6 font-weight-bold">{{ kpi.failed }}</div>
            </div>
            <v-icon size="26" icon="mdi-alert-circle-outline" />
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <!-- Tabela -->
    <v-card rounded="lg">
      <v-card-title class="d-flex align-center justify-space-between">
        <div class="text-subtitle-1 font-weight-bold">Lista de tarefas</div>
        <div class="text-caption text-medium-emphasis">
          {{ filtered.length }} registros
        </div>
      </v-card-title>

      <v-divider />

      <v-table density="comfortable" class="text-body-2">
        <thead>
          <tr>
            <th>ID</th>
            <th>Título</th>
            <th>URL</th>
            <th>Status</th>
            <th>Resultado</th>
            <th>Usuário</th>
            <th class="text-right">Criada</th>
            <th class="text-right">Ações</th>
          </tr>
        </thead>

        <tbody>
          <tr v-for="t in filtered" :key="t.id">
            <td class="font-weight-medium">
              <a href="#" class="text-decoration-none">
                {{ t.id || "—" }}
              </a>
            </td>

            <td class="font-weight-medium">
              <a
                href="#"
                @click.prevent="openDetails(t)"
                class="text-decoration-none"
              >
                {{ t.title || "—" }}
              </a>
            </td>

            <td style="max-width: 360px">
              <div class="text-truncate">
                <a
                  :href="t.url"
                  target="_blank"
                  rel="noreferrer"
                  class="text-decoration-none"
                >
                  {{ t.url }}
                </a>
              </div>
              <div class="text-caption text-medium-emphasis">Webmotors</div>
            </td>

            <td>
              <v-chip
                size="small"
                :color="statusColor(t.status)"
                variant="tonal"
              >
                {{ statusLabel(t.status) }}
              </v-chip>
            </td>

            <td>
              <template v-if="t['status'] === 'finished' && t.result">
                <div class="font-weight-medium">
                  {{ t.result }}
                </div>
              </template>

              <template v-else-if="t.status === 'failed'">
                <div class="text-caption text-error">
                  {{ t.error_message || "Falha na coleta" }}
                </div>
              </template>

              <template v-else>
                <span class="text-medium-emphasis">—</span>
              </template>
            </td>

            <td>
              <div class="font-weight-medium">{{ t.user?.name || "—" }}</div>
              <div class="text-caption text-medium-emphasis">
                {{ t.user?.email || "" }}
              </div>
            </td>

            <td class="text-right text-medium-emphasis">
              {{ fmtDateTime(t.created_at) }}
            </td>

            <td class="text-right">
              <v-btn
                icon
                size="small"
                variant="text"
                @click="openDetails(t)"
                title="Detalhes"
              >
                <v-icon icon="mdi-eye-outline" />
              </v-btn>

              <v-btn
                icon
                size="small"
                variant="text"
                color="error"
                @click="confirmDelete(t)"
                title="Excluir"
              >
                <v-icon icon="mdi-delete-outline" />
              </v-btn>
            </td>
          </tr>

          <tr v-if="filtered.length === 0">
            <td colspan="8" class="text-center text-medium-emphasis py-6">
              Nenhuma tarefa encontrada com os filtros atuais.
            </td>
          </tr>
        </tbody>
      </v-table>
    </v-card>

    <!-- Dialog: Criar tarefa -->
    <v-dialog v-model="createDialog" max-width="720">
      <v-card rounded="lg">
        <v-card-title class="text-subtitle-1 font-weight-bold">
          Nova tarefa
        </v-card-title>

        <v-divider />

        <v-card-text class="pt-4">
          <v-row dense>
            <v-col cols="12" md="6">
              <v-text-field
                v-model="form.title"
                label="Título"
                density="compact"
                variant="outlined"
                :error-messages="form.errors.title"
                placeholder="Ex.: Coletar anúncio BMW X2"
              />
            </v-col>

            <v-col cols="12">
              <v-text-field
                v-model="form.url"
                label="URL do anúncio (Webmotors)"
                density="compact"
                variant="outlined"
                :error-messages="form.errors.url"
                placeholder="https://www.webmotors.com.br/comprar/..."
              />
              <div class="text-caption text-medium-emphasis mt-1">
                A tarefa começa como <strong>pendente</strong> e o worker
                atualiza para <strong>processando</strong> →
                <strong>concluída</strong> ou <strong>falha</strong>.
              </div>
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions class="justify-end">
          <v-btn variant="text" @click="createDialog = false">Cancelar</v-btn>
          <v-btn color="primary" @click="createTask" :loading="form.processing">
            Criar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Drawer: detalhes -->
    <v-navigation-drawer
      v-model="detailsOpen"
      location="right"
      width="460"
      temporary
    >
      <div class="pa-4">
        <div class="d-flex align-center justify-space-between">
          <div>
            <div class="text-subtitle-1 font-weight-bold">
              {{ selected?.title || "Detalhes da tarefa" }}
            </div>
            <div class="text-caption text-medium-emphasis">
              {{ selected?.url || "" }}
            </div>
          </div>

          <v-btn icon variant="text" @click="detailsOpen = false">
            <v-icon icon="mdi-close" />
          </v-btn>
        </div>

        <v-divider class="my-3" />

        <template v-if="selected">
          <div class="mb-3">
            <div class="text-caption text-medium-emphasis">Status</div>
            <v-chip
              size="small"
              :color="statusColor(selected.status)"
              variant="tonal"
            >
              {{ statusLabel(selected.status) }}
            </v-chip>
          </div>

          <div class="mb-3">
            <div class="text-caption text-medium-emphasis">Usuário</div>
            <div class="font-weight-medium">
              {{ selected.user?.name || "—" }}
            </div>
            <div class="text-caption text-medium-emphasis">
              {{ selected.user?.email || "" }}
            </div>
          </div>

          <v-divider class="my-3" />

          <div class="mb-3">
            <div class="text-caption text-medium-emphasis">Timestamps</div>
            <div class="text-body-2">
              <div>
                <strong>Criada:</strong> {{ fmtDateTime(selected.created_at) }}
              </div>
              <div>
                <strong>Atualizada:</strong>
                {{ fmtDateTime(selected.updated_at) }}
              </div>
            </div>
          </div>

          <v-divider class="my-3" />

          <div class="mb-3">
            <div class="text-caption text-medium-emphasis">Resultado</div>

            <template v-if="selected.status === 'finished' && selected.result">
              <v-card variant="tonal" rounded="lg">
                <v-card-text>
                  <div class="d-flex align-center justify-space-between">
                    <div>
                      <div class="font-weight-bold">
                        {{ selected.result.brand }} {{ selected.result.model }}
                      </div>
                      <div class="text-caption text-medium-emphasis">
                        {{ selected.result.price }}
                      </div>
                    </div>
                    <v-icon icon="mdi-car-outline" />
                  </div>
                </v-card-text>
              </v-card>
            </template>

            <template v-else-if="selected.status === 'failed'">
              <v-alert type="error" variant="tonal" class="mt-2">
                {{ selected.error_message || "Falha ao coletar o anúncio." }}
              </v-alert>
            </template>

            <template v-else>
              <div class="text-medium-emphasis">Ainda sem resultado.</div>
            </template>
          </div>

          <div class="d-flex ga-2 mt-3">
            <v-btn
              color="error"
              variant="tonal"
              prepend-icon="mdi-delete-outline"
              @click="confirmDelete(selected)"
            >
              Excluir
            </v-btn>
          </div>
        </template>

        <template v-else>
          <div class="text-medium-emphasis">
            Selecione uma tarefa para ver detalhes.
          </div>
        </template>
      </div>
    </v-navigation-drawer>

    <!-- Confirm delete -->
    <v-dialog v-model="deleteDialog" max-width="520">
      <v-card rounded="lg">
        <v-card-title class="text-subtitle-1 font-weight-bold">
          Excluir tarefa
        </v-card-title>
        <v-divider />
        <v-card-text class="pt-4">
          Tem certeza que deseja excluir
          <strong>{{ toDelete?.title || "esta tarefa" }}</strong
          >?
        </v-card-text>
        <v-card-actions class="justify-end">
          <v-btn variant="text" @click="deleteDialog = false">Cancelar</v-btn>
          <v-btn color="error" @click="deleteTask">Excluir</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>
import { router } from "@inertiajs/vue3";

export default {
  props: {
    tasks: {
      type: Array,
      required: true,
    },
  },

  data() {
    return {
      createDialog: false,
      detailsOpen: false,
      deleteDialog: false,
      selected: null,
      toDelete: null,
      poller: null,

      filters: {
        q: "",
        status: null,
      },

      statusOptions: [
        { label: "Pendente", value: "pending" },
        { label: "Processando", value: "processing" },
        { label: "Concluída", value: "finished" },
        { label: "Falha", value: "failed" },
      ],

      form: {
        title: "teste",
        url: "https://www.webmotors.com.br/comprar/bmw/x2/20-turbo-gasolina-xdrive-m35i-steptronic/4-portas/2025-2026/65066397",
        errors: {},
        processing: false,
      },
    };
  },

  computed: {
    user() {
      return this.$page?.props?.user || null;
    },

    filtered() {
      const q = (this.filters.q || "").toLowerCase().trim();

      return this.tasks.filter((t) => {
        const hay = [
          t.title,
          t.url,
          t.status,
          t.user?.name,
          t.user?.email,
          t.result?.brand,
          t.result?.model,
          String(t.result?.price ?? ""),
          t.error_message,
        ]
          .filter(Boolean)
          .join(" ")
          .toLowerCase();

        const matchesQ = !q || hay.includes(q);
        const matchesStatus =
          !this.filters.status || t.status === this.filters.status;

        return matchesQ && matchesStatus;
      });
    },

    kpi() {
      const by = (s) => this.tasks.filter((t) => t.status === s).length;
      return {
        pending: by("pending"),
        processing: by("processing"),
        finished: by("finished"),
        failed: by("failed"),
      };
    },
  },

  methods: {
    goBack() {
      window.history.back();
    },

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

    resetFilters() {
      this.filters = { q: "", status: null };
    },

    openCreate() {
      this.createDialog = true;
    },

    createTask() {
      this.form.processing = true;

      router.post(
        "/tasks",
        { task: { title: this.form.title, url: this.form.url } },
        {
          preserveScroll: true,
          onSuccess: () => {
            this.createDialog = false;
            this.form.processing = false;
            this.$inertia.reload({
              only: ["tasks"],
              preserveScroll: true,
            });
          },
          onError: (errors) => {
            this.form.errors = errors;
            this.form.processing = false;
          },
        },
      );
    },

    openDetails(task) {
      this.selected = task;
      this.detailsOpen = true;
    },

    confirmDelete(task) {
      this.toDelete = task;
      this.deleteDialog = true;
    },

    deleteTask() {
      if (!this.toDelete) return;

      router.delete(`/tasks/${this.toDelete.id}`, {
        preserveScroll: true,
        onSuccess: () => {
          this.deleteDialog = false;
          if (this.selected?.id === this.toDelete.id) this.detailsOpen = false;
          this.toDelete = null;
        },
      });
    },

    fmtDateTime(iso) {
      if (!iso) return "—";
      const d = new Date(iso);
      return d.toLocaleString("pt-BR");
    },
  },
};
</script>

<style scoped>
a.text-decoration-none {
  color: inherit;
}
.text-truncate {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
