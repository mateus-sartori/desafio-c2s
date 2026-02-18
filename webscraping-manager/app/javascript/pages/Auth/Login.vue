<template>
  <div class="login-container">
    <div class="login-card">
      <div class="header">
      <div v-if="$page.props.flash?.error" class="text-center">
        {{ $page.props.flash.error }}
      </div>

        <h1>WebScraping Manager</h1>
        <h2>Sistema de Web Scraping de Veículos</h2>
        <p class="subtitle">Acesse sua conta para gerenciar scraping de anúncios</p>
      </div>

      <form @submit.prevent="submit" class="login-form">
        <div class="input-group">
          <label>E-mail</label>
          <input v-model="form.email" type="email" required placeholder="seu.email@exemplo.com" class="input-field" />
        </div>

        <div class="input-group">
          <label>Senha</label>
          <input v-model="form.password" type="password" required placeholder="Digite sua senha" class="input-field" />
        </div>

        <button :disabled="form.processing" type="submit" class="submit-button" :class="{ 'loading': form.processing }">
          <span v-if="form.processing">Entrando...</span>
          <span v-else>Acessar Sistema</span>
        </button>

        <div class="footer-links">
          <a href="/sign_up" class="register-link">Criar nova conta</a>
          <a href="/forgot-password" class="forgot-link">Esqueceu sua senha?</a>
        </div>

        <div class="info-section">
          <h3>Recursos do Sistema</h3>
          <p>Gerencie scraping de anúncios de veículos de múltiplas fontes em tempo real.</p>
          <div class="tech-tags">
            <span class="tag">Scraping Automatizado</span>
            <span class="tag">Análise de Dados</span>
            <span class="tag">Integração APIs</span>
            <span class="tag">Dashboard em Tempo Real</span>
          </div>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import { useForm } from '@inertiajs/vue3'

export default {
  layout: null,
  data() {
    return {
      form: useForm({
        email: '',
        password: '',
      })
    }
  },
  methods: {
    submit() {
      this.form.post(`/sign_in`, {
        onSuccess: () => {
        },
        onError: (errors) => {
          console.error('Login failed:', errors)
        },
      })
    }
  }
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1a202c 0%, #2d3748 100%);
  padding: 20px;
}

.login-card {
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

.login-form {
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
  justify-content: space-between;
  font-size: 14px;
}

.register-link {
  color: #4299e1;
  text-decoration: none;
}

.forgot-link {
  color: #718096;
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
