<template>
  <div class="register-container">
    <div class="register-card">
      <div class="header">
        <div v-if="this.form.errors" class="text-center">
          <div v-for="error in this.form.errors" v-bind:key="error">
            {{ error}}
          </div>
        </div>

        <h1>WebScraping Manager</h1>
        <h2>Criar Nova Conta</h2>
        <p class="subtitle">
          Cadastre-se para começar a gerenciar scraping de anúncios
        </p>
      </div>

      <form @submit.prevent="submit" class="register-form">
        <div class="input-group">
          <label>Nome Completo</label>
          <input
            v-model="form.name"
            type="text"
            required
            placeholder="Seu nome completo"
            class="input-field"
          />
        </div>

        <div class="input-group">
          <label>E-mail</label>
          <input
            v-model="form.email"
            type="email"
            required
            placeholder="seu.email@exemplo.com"
            class="input-field"
          />
        </div>

        <div class="input-group">
          <label>Senha</label>
          <input
            v-model="form.password"
            type="password"
            required
            placeholder="Digite sua senha"
            class="input-field"
          />
        </div>

        <div class="input-group">
          <label>Confirmar Senha</label>
          <input
            v-model="form.password_confirmation"
            type="password"
            required
            placeholder="Confirme sua senha"
            class="input-field"
          />
        </div>

        <button
          :disabled="form.processing"
          type="submit"
          class="submit-button"
          :class="{ loading: form.processing }"
        >
          <span v-if="form.processing">Criando conta...</span>
          <span v-else>Criar Conta</span>
        </button>

        <div class="footer-links">
          <a href="/login" class="login-link">Já tem uma conta? Faça login</a>
        </div>

        <div class="info-section">
          <h3>Benefícios da Conta</h3>
          <p>
            Ao criar sua conta, você terá acesso completo a todas as
            funcionalidades do sistema de web scraping.
          </p>
          <div class="tech-tags">
            <span class="tag">Scraping Ilimitado</span>
            <span class="tag">Dashboard Personalizado</span>
            <span class="tag">Suporte Prioritário</span>
            <span class="tag">Exportação de Dados</span>
          </div>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  layout: null,
  data() {
    return {
      form: {
        name: "",
        email: "",
        password: "",
        password_confirmation: "",
        processing: false,

        errors: null,
      },
    };
  },
  methods: {
    submit() {
      this.form.processing = true;
      this.$inertia.post("/sign_up", this.form, {
        preserveScroll: true,
        onError: (errors) => {
          this.form.errors = errors;
        },
        onFinish: () => {
          this.form.processing = false;
        },
      });
    },
  },
};
</script>

<style scoped>
.register-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1a202c 0%, #2d3748 100%);
  padding: 20px;
}

.register-card {
  background: white;
  border-radius: 12px;
  padding: 32px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  width: 100%;
  max-width: 420px;
}

.header {
  text-align: center;
  margin-bottom: 32px;
}

.header h1 {
  color: #2d3748;
  font-size: 28px;
  font-weight: 700;
  margin-bottom: 8px;
}

.header h2 {
  color: #4a5568;
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 8px;
}

.subtitle {
  color: #718096;
  font-size: 14px;
}

.register-form {
  display: grid;
  gap: 20px;
}

.input-group {
  display: grid;
  gap: 8px;
}

.input-group label {
  font-weight: 600;
  color: #2d3748;
  font-size: 14px;
}

.input-field {
  padding: 12px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 16px;
  transition: border-color 0.2s;
}

.input-field:focus {
  outline: none;
  border-color: #4299e1;
}

.submit-button {
  background: #4299e1;
  color: white;
  padding: 14px;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s;
}

.submit-button:hover:not(:disabled) {
  background: #3182ce;
}

.submit-button:disabled {
  background: #cbd5e0;
  cursor: not-allowed;
}

.footer-links {
  display: flex;
  justify-content: center;
  font-size: 14px;
}

.login-link {
  color: #4299e1;
  text-decoration: none;
}

.info-section {
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #e2e8f0;
}

.info-section h3 {
  color: #2d3748;
  font-size: 16px;
  margin-bottom: 12px;
}

.info-section p {
  color: #718096;
  font-size: 14px;
  line-height: 1.5;
  margin-bottom: 16px;
}

.tech-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag {
  background: #ebf8ff;
  color: #2b6cb0;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
}
</style>
