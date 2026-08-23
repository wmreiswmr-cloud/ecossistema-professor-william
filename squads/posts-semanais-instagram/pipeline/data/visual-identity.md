# Visual Identity

## Color Palette
- **Primary background:** #0D1830 → #1B2A4A → #0A1224 (degradê azul marinho, 160deg) — fundo de todos os slides
- **Text:** #F5F3EE (branco-creme) — texto principal
- **Text muted:** #AEBBD1 (azul acinzentado claro) — texto de apoio, labels
- **Accent gold:** #E0BE7A / #C9A24B — tag de categoria, destaques, valores de card
- **Accent blue:** #5B8DEF — segunda cor de destaque, alterna com o dourado nos cards

## Typography
- **Headings:** 'Poppins', sans-serif, weight 900, 52px (título principal do slide)
- **Body:** 'Inter', sans-serif, weight 500, 34px (texto de apoio/lead)
- **Card label:** 'Inter', sans-serif, weight 500, 28px
- **Card value:** 'Poppins', sans-serif, weight 800, 38px
- **Caption/footer:** 'Inter', sans-serif, weight 500, 24px
- **Minimum sizes:** respeitar mínimo de 34px para corpo e 24px para caption (Instagram Carrossel 1080x1440)

## Layout
- **Viewport:** 1080x1440px (Instagram Carrossel, 3:4)
- **Padding:** 72px em todos os lados
- **Grid:** coluna única, flexbox vertical (tag → título → lead → cards → rodapé)
- **Spacing rules:** gap de 16px entre cards, margin de 40px acima/abaixo do bloco de cards

## Composition Rules
- Tag de categoria (ex: "SINAIS DE ALERTA") sempre no topo, fundo dourado translúcido
- Título em duas cores: texto principal em branco-creme, frase-chave em degradê azul→dourado (`.accent`)
- Cards de dado/fato: label à esquerda (cinza-azulado), valor/classificação à direita, alternando cor dourado/azul
- Rodapé: avatar circular em degradê azul→dourado + nome + (na primeira slide do carrossel) "ARRASTE →"
- Brilhos decorativos (`.glow1`, `.glow2`) nos cantos superior-direito e inferior-esquerdo, sutis, nunca sobre o texto
- Nunca incluir contador de slide — Instagram já mostra navegação nativa

## Adaptation Rules
- Slides com menos conteúdo (ex: capa/citação) podem reduzir o número de cards ou substituí-los por uma citação grande, mantendo tag + título + rodapé
- Cor de destaque (dourado vs azul) alterna por item para dar ritmo visual, nunca usar as duas ao mesmo tempo no mesmo elemento
- Todo texto sobre o fundo escuro deve manter contraste mínimo 4.5:1 — branco-creme e os dois accents já testados e aprovados
- Em slides de CTA final, o rodapé pode trocar "ARRASTE →" por uma chamada específica (ex: "Manda mensagem 💬")
