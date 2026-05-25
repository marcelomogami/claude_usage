# Changelog

## 1.7 — 2026-05-25

- Indicador `↑XX%` do 7d agora em tempo real por minuto: usa `ELAPSED_MINUTES / CYCLE_MINUTES × 100` em vez de `DAY_IDX × 100 / 7` — sobe ~0,05% a cada ciclo de 5 min em vez de travar o dia inteiro no mesmo valor
- Cache local de 60s em `~/.cache/claudebar/usage.json` com `flock` — evita requisições duplicadas à API (ex: reload manual coincidindo com o timer)
- Refresh automático do token OAuth: detecta `expiresAt` prestes a vencer e faz `POST /v1/oauth/token` com `grant_type: refresh_token`, atualizando `~/.claude/.credentials.json` sem intervenção manual
- Indicador de pacing `(↑XX%)` adicionado também à janela de 5h, exibido entre o percentual e o horário de reset: `5h: 14% (↑12%) (13:50)`

## 1.6 — 2026-05-19

- Teto de cota do dia integrado ao `7d` como `(↑XX%)`, sem segmento separado — linguagem visual simétrica com o reset de 5h
- Ícone de reset da janela de 5h trocado de `↻` para `` (U+F0E2, Font Awesome rotate-left), renderizado via fallback de fonte no Qt6

## 1.5 — 2026-05-19

- Horário de reset da janela de 5h exibido ao lado do percentual: `5h: XX% (↻HH:MM)`
- Valor lido de `five_hour.resets_at` da própria API e formatado em hora local

## 1.4 — 2026-05-19

- Marcador `max: XX%` entre o 7d e a bolinha de status: teto acumulado de cota que se pode atingir até o fim do dia, dividindo os 100% da janela de 7 dias em 7 dias iguais (dia 1 = 14%, dia 7 = 100%)
- Início do ciclo derivado automaticamente de `seven_day.resets_at` da própria API (ciclo = 7 dias antes do próximo reset); sem configuração e auto-ajustável se o reset mudar
- Cálculo feito no próprio script (sem mudança no QML)

## 1.3 — 2026-05-16

- Menu de contexto (botão direito) com "Recarregar cota" e "Recarregar status" separados
- Script aceita argumento `usage` ou `status` para buscar só o que é necessário
- Timeout adicionado ao curl do status (3s connect, 5s total) para evitar travamento no reload manual
- Clique esquerdo mantido como reload completo (cota + status)

## 1.2 — 2026-05-15

- Bolinha colorida de status do Claude (verde/amarelo/laranja/vermelho) após os percentuais
- Consulta `status.claude.com/api/v2/status.json` a cada 5 minutos junto com o uso
- Formato exibido: `Claude  5h: XX%  |  7d: XX% | ●`

## 1.1 — 2026-05-14

- Ícone do Claude na barra (favicon extraído de claude.ai)
- Clique no widget atualiza os dados imediatamente
- Plasmoid movido para `claude_usage/plasmoid/` com symlink em `~/.local/share/plasma/plasmoids/`

## 1.0 — 2026-05-14

- Consulta autenticada via token OAuth do Claude Code
- Exibe utilização nas janelas de 5h e 7d
- Widget KDE Plasma 6 minimalista sem dependências externas
