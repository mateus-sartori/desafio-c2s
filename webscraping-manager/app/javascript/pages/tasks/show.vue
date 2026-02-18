<template>
  <div class="pa-4">
    <!-- Header + Voltar -->
    <div class="d-flex align-center justify-space-between mb-4">
      <div>
        <v-btn
          variant="text"
          density="compact"
          prepend-icon="mdi-arrow-left"
          class="px-0 mb-2"
          @click="goBack"
        >
          Voltar para lista
        </v-btn>

        <div class="text-h5 font-weight-bold">{{ task.title }}</div>
        <div class="text-caption text-medium-emphasis">
          Tarefa #{{ task.id }}
        </div>
      </div>

      <v-chip :color="statusColor(task.status)" variant="tonal" size="large">
        <v-icon start :icon="statusIcon(task.status)" />
        {{ statusLabel(task.status) }}
      </v-chip>
    </div>

    <v-row>
      <!-- Coluna Principal -->
      <v-col cols="12" md="8">
        <!-- Card URL -->
        <v-card rounded="lg" class="mb-4">
          <v-card-title class="text-subtitle-1 font-weight-bold">
            <v-icon start icon="mdi-link-variant" />
            URL do Anúncio
          </v-card-title>
          <v-divider />
          <v-card-text>
            <a
              :href="task.url"
              target="_blank"
              rel="noreferrer"
              class="text-decoration-none text-primary"
            >
              {{ task.url }}
              <v-icon size="small" icon="mdi-open-in-new" />
            </a>
            <div class="text-caption text-medium-emphasis mt-1">
              Fonte: Webmotors
            </div>
          </v-card-text>
        </v-card>

        <!-- Card Resultado -->
        <v-card rounded="lg" class="mb-4">
          <v-card-title class="text-subtitle-1 font-weight-bold">
            <v-icon start icon="mdi-car-outline" />
            Resultado da Coleta
          </v-card-title>
          <v-divider />
          <v-card-text>
            <template v-if="task.status === 'finished' && task.result">
              <v-row dense>
                <v-col cols="12" md="4">
                  <v-card variant="tonal" color="primary" rounded="lg">
                    <v-card-text class="text-center">
                      <v-icon size="32" icon="mdi-car-side" class="mb-2" />
                      <div class="text-caption text-medium-emphasis">Marca</div>
                      <div class="text-h6 font-weight-bold">
                        {{ task.result.brand || "—" }}
                      </div>
                    </v-card-text>
                  </v-card>
                </v-col>

                <v-col cols="12" md="4">
                  <v-card variant="tonal" color="secondary" rounded="lg">
                    <v-card-text class="text-center">
                      <v-icon size="32" icon="mdi-tag-outline" class="mb-2" />
                      <div class="text-caption text-medium-emphasis">Modelo</div>
                      <div class="text-h6 font-weight-bold">
                        {{ task.result.model || "—" }}
                      </div>
                    </v-card-text>
                  </v-card>
                </v-col>

                <v-col cols="12" md="4">
                  <v-card variant="tonal" color="success" rounded="lg">
                    <v-card-text class="text-center">
                      <v-icon
                        size="32"
                        icon="mdi-currency-usd"
                        class="mb-2"
                      />
                      <div class="text-caption text-medium-emphasis">Preço</div>
                      <div class="text-h6 font-weight-bold">
                        {{ task.result.price || "—" }}
                      </div>
                    </v-card-text>
                  </v-card>
                </v-col>
              </v-row>

              <!-- JSON Completo -->
              <v-expansion-panels class="mt-4">
                <v-expansion-panel>
                  <v-expansion-panel-title>
                    <v-icon start icon="mdi-code-json" />
                    Ver dados brutos (JSON)
                  </v-expansion-panel-title>
                  <v-expansion-panel-text>
                    <pre class="text-body-2 bg-grey-lighten-4 pa-3 rounded">{{
                      JSON.stringify(task.result, null, 2)
                    }}</pre>
                  </v-expansion-panel-text>
                </v-expansion-panel>
              </v-expansion-panels>
            </template>

            <template v-else-if="task.status === 'failed'">
              <v-alert type="error" variant="tonal" prominent>
                <v-alert-title>Falha na coleta</v-alert-title>
                {{ task.error_message || "Erro desconhecido ao processar a tarefa." }}
              </v-alert>
            </template>

            <template v-else-if="task.status === 'processing'">
              <div class="d-flex align-center justify-center pa-6">
                <v-progress-circular
                  indeterminate
                  color="primary"
                  size="48"
                  class="mr-4"
                />
                <div>
                  <div class="text-body-1 font-weight-medium">
                    Processando...
                  </div>
                  <div class="text-caption text-medium-emphasis">
                    Aguarde enquanto coletamos os dados do anúncio.
                  </div>
                </div>
              </div>
            </template>

            <template v-else>
              <div class="text-center pa-6 text-medium-emphasis">
                <v-icon size="48" icon="mdi-clock-outline" class="mb-2" />
                <div>Tarefa pendente - aguardando processamento</div>
              </div>
            </template>
          </v-card-text>
        </v-card>
      </v-col>

      <!-- Coluna Lateral -->
      <v-col cols="12" md="4">
        <!-- Card Usuário -->
        <v-card rounded="lg" class="mb-4">
          <v-card-title class="text-subtitle-1 font-weight-bold">
            <v-icon start icon="mdi-account-outline" />
            Criado por
          </v-card-title>
          <v-divider />
          <v-card-text>
            <div class="d-flex align-center">
              <v-avatar color="primary" size="48" class="mr-3">
                <span class="text-h6">{{ userInitials }}</span>
              </v-avatar>
              <div>
                <div class="font-weight-medium">
                  {{ task.user?.name || "Usuário desconhecido" }}
                </div>
                <div class="text-caption text-medium-emphasis">
                  {{ task.user?.email || "—" }}
                </div>
              </div>
            </div>
          </v-card-text>
        </v-card>

        <!-- Card Timestamps -->
        <v-card rounded="lg" class="mb-4">
          <v-card-title class="text-subtitle-1 font-weight-bold">
            <v-icon start icon="mdi-clock-outline" />
            Timestamps
          </v-card-title>
          <v-divider />
          <v-card-text>
            <v-list density="compact" class="pa-0">
              <v-list-item>
                <template v-slot:prepend>
                  <v-icon icon="mdi-calendar-plus" size="small" />
                </template>
                <v-list-item-title class="text-caption text-medium-emphasis">
                  Criada em
                </v-list-item-title>
                <v-list-item-subtitle class="font-weight-medium">
                  {{ fmtDateTime(task.created_at) }}
                </v-list-item-subtitle>
              </v-list-item>

              <v-list-item>
                <template v-slot:prepend>
                  <v-icon icon="mdi-calendar-edit" size="small" />
                </template>
                <v-list-item-title class="text-caption text-medium-emphasis">
                  Atualizada em
                </v-list-item-title>
                <v-list-item-subtitle class="font-weight-medium">
                  {{ fmtDateTime(task.updated_at) }}
                </v-list-item-subtitle>
              </v-list-item>

              <v-list-item v-if="task.started_at">
                <template v-slot:prepend>
                  <v-icon icon="mdi-play-circle-outline" size="small" />
                </template>
                <v-list-item-title class="text-caption text-medium-emphasis">
                  Iniciada em
                </v-list-item-title>
                <v-list-item-subtitle class="font-weight-medium">
                  {{ fmtDateTime(task.started_at) }}
                </v-list-item-subtitle>
              </v-list-item>

              <v-list-item v-if="task.finished_at">
                <template v-slot:prepend>
                  <v-icon icon="mdi-check-circle-outline" size="small" />
                </template>
                <v-list-item-title class="text-caption text-medium-emphasis">
                  Finalizada em
                </v-list-item-title>
                <v-list-item-subtitle class="font-weight-medium">
                  {{ fmtDateTime(task.finished_at) }}
                </v-list-item-subtitle>
              </v-list-item>
            </v-list>
          </v-card-text>
        </v-card>

        <!-- Card Ações -->
        <v-card rounded="lg">
          <v-card-title class="text-subtitle-1 font-weight-bold">
            <v-icon start icon="mdi-cog-outline" />
            Ações
          </v-card-title>
          <v-divider />
          <v-card-text>
            <v-btn
              block
              color="error"
              variant="tonal"
              prepend-icon="mdi-delete-outline"
              @click="confirmDelete"
              class="mb-2"
            >
              Excluir tarefa
            </v-btn>

            <v-btn
              block
              variant="outlined"
              prepend-icon="mdi-refresh"
              @click="reload"
            >
              Atualizar
            </v-btn>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <!-- Dialog Confirmar Exclusão -->
    <v-dialog v-model="deleteDialog" max-width="520">
      <v-card rounded="lg">
        <v-card-title class="text-subtitle-1 font-weight-bold">
          Excluir tarefa
        </v-card-title>
        <v-divider />
        <v-card-text class="pt-4">
          Tem certeza que deseja excluir a tarefa
          <strong>"{{ task.title }}"</strong>?
          <br />
          <span class="text-caption text-medium-emphasis">
            Esta ação não pode ser desfeita.
          </span>
        </v-card-text>
        <v-card-actions class="justify-end">
          <v-btn variant="text" @click="deleteDialog = false">Cancelar</v-btn>
          <v-btn color="error" @click="deleteTask" :loading="deleting">
            Excluir
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>
import { router } from "@inertiajs/vue3";

export default {
  props: {
    task: {
      type: Object,
      required: true,
    },
  },

  data() {
    return {
      deleteDialog: false,
      deleting: false,
    };
  },

  computed: {
    userInitials() {
      const name = this.task.user?.name || "U";
      return name
        .split(" ")
        .map((n) => n[0])
        .join("")
        .toUpperCase()
        .slice(0, 2);
    },
  },

  methods: {
    goBack() {
      router.visit("/tasks");
    },

    reload() {
      router.reload();
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
      const map = {
        pending: "info",
        processing: "warning",
        finished: "success",
        failed: "error",
      };
      return map[status] || "default";
    },

    statusIcon(status) {
      const map = {
        pending: "mdi-clock-outline",
        processing: "mdi-progress-clock",
        finished: "mdi-check-circle-outline",
        failed: "mdi-alert-circle-outline",
      };
      return map[status] || "mdi-help-circle-outline";
    },

    fmtDateTime(iso) {
      if (!iso) return "—";
      const d = new Date(iso);
      return d.toLocaleString("pt-BR", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      });
    },

    confirmDelete() {
      this.deleteDialog = true;
    },

    deleteTask() {
      this.deleting = true;
      router.delete(`/tasks/${this.task.id}`, {
        onSuccess: () => {
          this.deleteDialog = false;
          this.deleting = false;
        },
        onError: () => {
          this.deleting = false;
        },
      });
    },
  },
};
</script>

<style scoped>
pre {
  white-space: pre-wrap;
  word-wrap: break-word;
}
</style>
