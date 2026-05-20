# claude_usage

Widget KDE Plasma 6 que exibe o uso da cota do Claude Pro na barra do painel.

## O que exibe

```
Claude  5h: 20% (18:30)  |  7d: 40% (↑57%) | ●
```

- **5h:** utilização na janela de 5 horas; entre parênteses, ícone  (U+F0E2, Font Awesome) + hora local em que a janela reinicia (`five_hour.resets_at`)
- **7d:** utilização na janela de 7 dias; entre parênteses, `↑` + teto de cota acumulado até o fim do dia (`seven_day.resets_at`)
- **max:** teto de cota acumulado que se pode atingir até o fim do dia, dividindo os 100% da janela de 7 dias em 7 dias iguais. O início do ciclo é derivado automaticamente de `seven_day.resets_at` da própria API — sem configuração
- **●:** status operacional do Claude (`status.claude.com`) — verde, amarelo, laranja ou vermelho

Clique esquerdo no widget atualiza cota e status ao mesmo tempo. Botão direito abre menu com opções separadas: **Recarregar cota** e **Recarregar status**.

## Estrutura

```
claude_usage/
├── claude_usage.sh        # script bash que consulta a API
├── plasmoid/              # pacote do widget KDE
│   ├── metadata.json
│   └── contents/
│       ├── ui/main.qml
│       └── icons/claude.png
├── README.md
└── CHANGELOG.md
```

O plasmoid é instalado via symlink em `~/.local/share/plasma/plasmoids/com.celo.claudeusage/`.

## Como funciona

O script lê o token OAuth do Claude Code em `~/.claude/.credentials.json` e consulta
o endpoint `https://api.anthropic.com/api/oauth/usage` para o uso de cota, e
`https://status.claude.com/api/v2/status.json` para o status operacional. O widget
roda o script a cada 5 minutos e exibe o resultado na barra.

O marcador **max** não tem configuração: o início do ciclo de 7 dias é derivado
do campo `seven_day.resets_at` que a própria API retorna (o ciclo começa 7 dias
antes do próximo reset). Se a Anthropic mudar o dia/hora do reset, o widget se
ajusta sozinho no refresh seguinte.

## Instalação

```bash
# 1. clonar o repositório
git clone <repo> ~/projects/personal/claude_usage
cd ~/projects/personal/claude_usage

# 2. tornar o script executável
chmod +x claude_usage.sh

# 3. criar o symlink do plasmoid
ln -s "$PWD/plasmoid" ~/.local/share/plasma/plasmoids/com.celo.claudeusage

# 4. reiniciar o plasmashell
kquitapp6 plasmashell && plasmashell &

# 5. adicionar o widget "Claude Usage" à barra pelo menu do KDE
```

## Requisitos

- KDE Plasma 6
- `jq` e `curl`
- Claude Code instalado e autenticado (`~/.claude/.credentials.json`)

## Changelog

Ver [CHANGELOG.md](CHANGELOG.md).
