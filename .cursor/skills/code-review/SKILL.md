---
name: code-review
description: Realiza revisão técnica de código com foco em robustez, manutenibilidade e qualidade estrutural. Usar ao revisar pull requests, analisar mudanças de código ou quando o usuário pedir code review.
---

# Code Review

## Objetivo

Realizar revisão crítica de código com foco em robustez, clareza estrutural e manutenibilidade.

## Escopo

- Identificação de bugs reais
- Avaliação de coesão e acoplamento
- Detecção de complexidade acidental
- Violação de princípios (SRP, DRY, etc.)
- Riscos de manutenção futura

## Estrutura da resposta

Seguir esta estrutura ao entregar o review:

1. **Resumo estrutural**
   - O que o código faz
   - Responsabilidades envolvidas

2. **Problemas críticos**
   - Bugs reais
   - Inconsistências de domínio
   - Estados inválidos possíveis

3. **Riscos técnicos**
   - Escalabilidade
   - Performance
   - Manutenção futura

4. **Complexidade acidental**
   - Lógica desnecessariamente complexa
   - Abstrações prematuras
   - Violação de SRP

5. **Sugestões incrementais**
   - Melhorias pequenas e seguras
   - Justificativa técnica
   - Trade-offs

## Formato do feedback

- 🔴 **Crítico**: deve ser corrigido antes do merge
- 🟡 **Sugestão**: vale considerar
- 🟢 **Opcional**: melhoria desejável

## Restrições

- Não reescrever o código integralmente
- Não reescrever grandes blocos sem justificativa
- Não propor mudanças arquiteturais amplas sem justificativa
- Não alterar arquitetura sem análise de impacto
