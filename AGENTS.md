# AGENTS.md — claude_usage

Widget KDE Plasma 6 que exibe o uso da cota do Claude Pro na barra do painel.

**Owner:** Marcelo Mogami
**Versão atual:** 1.6
**Documentado em Logseq:** `[[Ferramentas Pessoais/claude_usage]]`

---

## Estrutura

```
claude_usage/
├── claude_usage.sh              # Script bash que consulta as APIs
├── plasmoid/
│   ├── metadata.json            # Metadados do pacote KDE (id, nome, versão)
│   └── contents/
│       ├── ui/main.qml          # Interface QML do widget
│       └── icons/claude.png     # Ícone exibido na barra
├── README.md
├── CHANGELOG.md
├── AGENTS.md                    # Este arquivo
└── CLAUDE.md                    # Instruções para Claude Code
```

Instalado via symlink: `~/.local/share/plasma/plasmoids/com.celo.claudeusage/ → plasmoid/`

---

## Funcionamento

### Script (`claude_usage.sh`)

Aceita um argumento `$1` com três modos:

| Modo | O que faz | Saída |
|------|-----------|-------|
| `usage` | Consulta cota via API Anthropic | `Claude  5h: X% (HH:MM)  \|  7d: Y% (↑Z%)` |
| `status` | Consulta status operacional | `none` / `minor` / `major` / `critical` / `unknown` |
| `all` (padrão) | Ambos | `<uso>::<status>` |

**Credenciais:** lê token OAuth de `~/.claude/.credentials.json` (campo `claudeAiOauth.accessToken`).

**APIs consultadas:**
- `https://api.anthropic.com/api/oauth/usage` — uso de cota (5h e 7d)
- `https://status.claude.com/api/v2/status.json` — status operacional

**Cálculo do teto diário (`↑XX%`):** derivado de `seven_day.resets_at` — ciclo = 7 dias antes do próximo reset. Dia 1 = ~14%, dia 7 = 100%. Auto-ajustável se a Anthropic mudar o reset.

### Widget (`main.qml`)

Exibição na barra:
```
[ícone]  Claude  5h: 20% (18:30)  |  7d: 40% (↑57%)  |  ●
```

- **Clique esquerdo:** recarrega cota + status (`reloadAll`)
- **Menu de contexto (botão direito):**
  - "Recarregar cota" — executa script com `usage`
  - "Recarregar status" — executa script com `status`
- **Timer automático:** 5 minutos (`interval: 300000`)
- **Bolinha de status:** verde (`none`) / amarelo (`minor`) / laranja (`major`) / vermelho (`critical`) / cinza (`unknown`)

**Caminho hardcoded do script:**
```qml
readonly property string scriptBase: "bash /home/celo/projects/personal/claude_usage/claude_usage.sh"
```

---

## Dependências

- KDE Plasma 6
- `jq`, `curl`
- Claude Code instalado e autenticado (`~/.claude/.credentials.json` deve existir)

---

## Linguagem

- Código e comentários: português (pt-BR) ou inglês — seguir estilo existente
- Chat com agente: português do Brasil (pt-BR)
