# claude_usage

Widget KDE Plasma 6 que exibe o uso da cota do Claude Pro na barra do painel.

## O que exibe

```
Claude  5h:20%  7d:40%
```

- **5h:** utilização na janela de 5 horas
- **7d:** utilização na janela de 7 dias

Clique no widget para atualizar na hora.

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
o endpoint `https://api.anthropic.com/api/oauth/usage`. O widget roda o script a cada
5 minutos e exibe o resultado na barra.

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
