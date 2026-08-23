# Auditoria de contraste — peça "Sinal de Alerta"

> **Auditado por Alba Acessibilidade (`cerebro-accessibility`), despacho real, 2026-08-22.**
>
> Contexto honesto: a versão anterior deste arquivo (preservada ao final) foi escrita pela sessão
> principal **narrando** o papel do auditor — este agente nunca tinha sido despachado de verdade.
> Esta é a primeira auditoria de contraste feita por despacho real neste projeto.

---

## Como foi medido (o instrumento, antes do resultado)

Instrumento não auditado não verifica nada. As três pernas da prova:

1. **Reimplementação independente da fórmula WCAG** (luminância relativa + composição alpha),
   escrita do zero, sem reaproveitar o `contraste.js` que já existia na pasta.
2. **Autoteste do instrumento contra valores de referência conhecidos** — o script se recusa a
   reportar qualquer par antes de reproduzir os três valores canônicos:

   ```
   [ok ] preto/branco = 21:1: 21.00 (esperado 21)
   [ok ] cinza #777 sobre branco = 4.48:1: 4.48 (esperado 4.48)
   [ok ] branco/branco = 1:1: 1.00 (esperado 1)
   ```

3. **Prova de pixel real** — as cores `rgba()` da peça não existem como hex em lugar nenhum; elas
   só nascem quando o navegador compõe. Em vez de confiar no meu cálculo de composição, renderizei
   amostras chapadas no Chromium (Playwright) e li o RGB do PNG resultante:

   ```
   CONFERE  branco 62% sobre navy: pixel real rgb(166,171,180) | meu calculo rgb(166,171,181)
   CONFERE  branco 90% sobre navy: pixel real rgb(232,233,235) | meu calculo rgb(232,233,235)
   CONFERE  ink 18% sobre paper:   pixel real rgb(207,201,187) | meu calculo rgb(207,201,187)
   CONFERE  ink 14% sobre paper:   pixel real rgb(216,209,195) | meu calculo rgb(216,209,195)
   ```

Os mínimos aplicados são os da WCAG 2.2 AA: **texto normal 4,5:1** · **texto grande 3:1**
(≥24px, ou ≥18.66px em peso ≥700) · **elemento gráfico / componente de UI 3:1** (1.4.11).
O tamanho de cada elemento foi lido do CSS da peça, não presumido — é o que decide qual mínimo vale.

---

## Resultado — 17 pares reais da peça

| Elemento (px/peso) | Par | Razão real | Mínimo aplicável | Veredito |
|---|---|---|---|---|
| `.selo` texto (22px/600) | ink-soft / paper | **7,23:1** | 4,5 (texto normal) | ✅ passa (AAA) |
| `.selo` borda (rgba ink .18) | ink 18% / paper | **1,44:1** | — decorativo | n/a |
| `.selo i` ponto dourado | gold / paper | **2,88:1** | 3,0 se for informativo | 🟡 ver ressalva |
| `h1` headline (64px/700) | navy / paper | **13,71:1** | 3,0 (texto grande) | ✅ passa |
| `h1 span` "notar primeiro" (64px/700) | gold-text / paper | **4,77:1** | 3,0 (texto grande) | ✅ passa |
| `.intro` (26px/500) | ink-soft / paper | **7,23:1** | 3,0 (texto grande) | ✅ passa |
| `.divisor` (rgba ink .14) | ink 14% / paper | **1,32:1** | — decorativo | n/a |
| `.num` 1/2/3 (40px/700) | gold-text / paper | **4,77:1** | 3,0 (texto grande) | ✅ passa |
| `.sinal` (32px/700) | navy / paper | **13,71:1** | 3,0 (texto grande) | ✅ passa |
| `.sinal small` (24px/500) | ink-soft / paper | **7,23:1** | 3,0 (texto grande, 24px no limite) | ✅ passa |
| `.diferencial` (26px/500) | branco 90% / navy | **12,92:1** | 3,0 (texto grande) | ✅ passa |
| `.diferencial b` (26px/700) | gold / navy | **4,77:1** | 3,0 (texto grande) | ✅ passa |
| `.prazo` (22px/500) | branco 62% / navy | **6,84:1** | **4,5 (texto normal)** | ✅ passa |
| `.nome` (30px/700) | branco / navy | **15,70:1** | 3,0 (texto grande) | ✅ passa |
| `.cidade` (20px/500) | branco 62% / navy | **6,84:1** | **4,5 (texto normal)** | ✅ passa |
| `.cta` rótulo (26px/700) | ink / gold | **5,23:1** | 3,0 (texto grande) | ✅ passa |
| `.cta` bloco (limite do botão) | gold / navy | **4,77:1** | 3,0 (elemento gráfico) | ✅ passa |

### Veredito: **APROVADO em contraste.**

Nenhum par de texto reprova. **Os dois pares mais apertados da peça são `.prazo` (22px) e
`.cidade` (20px)** — os únicos que caem na régua de texto normal (4,5:1) e não na de texto grande.
Ambos dão 6,84:1 e passam com folga. Nenhum outro elemento textual está abaixo de 24px.

---

## Ressalva 🟡 — o ponto dourado do selo, 2,88:1

`#D .selo i` é um círculo de 11px em `--gold` (`#b8842e`) sobre `--paper` (`#f6efe0`): **2,88:1**.

**Não reprovo, e digo por quê:** a WCAG 1.4.11 (Non-text Contrast, 3:1) só alcança componentes de
interface e objetos gráficos **necessários para entender o conteúdo**. Esse ponto é ornamento —
o rótulo ao lado ("Alfabetização · Leitura infantil") carrega todo o significado sozinho, e apagar
o ponto não tira informação nenhuma. Decorativo é isento. Bloquear aqui seria bloquear com gosto,
não com número.

**Mas fica registrado, porque 2,88 é literalmente o número da Armadilha 20** (*"dourado sobre papel
parece bom e dá 2,88"*). No momento em que esse ponto — ou qualquer outro elemento em `--gold`
sobre `--paper` — virar indicador de estado, ícone com significado, borda de campo ou seta,
ele **reprova na hora**.

**Instrução específica, se um dia precisar passar:** trocar `background:var(--gold)` por
`background:var(--gold-text)` (`#8a6220`) na linha `#D .selo i` — mesma família de cor do Brand
Book, já usada na peça, e dá **4,77:1** contra `paper`. Nenhuma cor nova precisa ser criada.

## Ressalva 🟡 — o texto da peça é pixel, e nada no pipeline exige alt

A peça inteira é publicada como PNG: os três sinais, a headline e o prazo não existem como texto
para leitor de tela. Isso não é falha do arquivo HTML (ele é fonte de render, não página), é falha
de **cobertura do pipeline**: nenhum portão exige a descrição alternativa que vai junto do post.

**Instrução específica:** o portão 5 (edição final) deve passar a exigir um campo `alt` no
artefato de publicação, com a headline + os três sinais em texto corrido — não "imagem do post".
Registrado no quadro como **#118**.

---

## O que NÃO cobri

- **Só contraste.** Semântica, ordem de tab, foco visível e `prefers-reduced-motion` não se
  aplicam a um artefato que sai como imagem estática — o `<div class="cta">` não é botão de
  verdade e não precisa ser. Se esta peça um dia virar página, a auditoria é outra.
- **Medi a fonte CSS + a composição real do navegador, não os pixels do glifo renderizado.**
  Antialiasing de traço fino baixa o contraste efetivo nas bordas da letra; a WCAG mede a cor
  declarada, e é isso que está aqui.
- **Não rodei axe/pa11y/Lighthouse** — são auditores de URL, e não existe URL: o artefato é um
  PNG local. Ferramenta errada para o alvo, não ferramenta pulada.
- **Não testei com leitor de tela real** (NVDA/VoiceOver) — não há um neste ambiente.

---

# Versão anterior (narrada, não auditada)

> Preservada na íntegra. Conteúdo original do arquivo antes de 2026-08-22.

```markdown
# Auditoria de contraste — peça "Sinal de Alerta"

Calculado por luminância relativa (WCAG), script `contraste.js` neste diretório — não estimado visualmente.

| Par | Contraste | Texto normal (AA 4.5:1) |
|---|---|---|
| navy sobre paper (headline) | 13.71:1 | ✅ AAA |
| ink-soft sobre paper (corpo/intro) | 7.23:1 | ✅ AAA |
| gold-text sobre paper (destaque headline/número) | 4.77:1 | ✅ AA |
| branco 90% sobre navy (linha do diferencial) | 12.92:1 | ✅ AAA |
| branco 62% sobre navy (prazo/cidade) | 6.84:1 | ✅ AA |
| ink sobre gold (botão CTA) | 5.23:1 | ✅ AA |
| gold sobre navy (destaque "sempre individual") | 4.77:1 | ✅ AA |

**Veredito: APROVADO.** Todos os 7 pares passam AA para texto normal; nenhum reprovado.
Mesmos tokens do Brand Book já auditado — nenhuma cor nova, nenhum par recalculado difere do
que já está documentado em `auditoria/evolucao-brand-book-2026-08-08.md`.
```

## Comparação: os números anteriores batem com os meus?

**Batem — os 7. Todos os sete valores da tabela narrada conferem com o meu cálculo independente,
até a segunda casa.** Rodei o `contraste.js` da pasta e o meu, lado a lado, e os dois dão
13.71 / 7.23 / 4.77 / 12.92 / 6.84 / 5.23 / 4.77. O `contraste.js` existe de verdade e faz a
conta certa — a narração não inventou número.

**A divergência real não é de valor, é de cobertura e de régua.** Três achados:

1. **Cobriu 7 de 17 pares.** Faltaram os quatro elementos não-textuais (ponto do selo, borda do
   selo, divisor, limite do bloco do CTA) e a discriminação por elemento — `ink-soft/paper` foi
   contado uma vez como "corpo/intro" quando aparece em três tamanhos diferentes, cada um com um
   mínimo diferente. **Nenhum elemento gráfico foi medido**, e é exatamente ali que estava o
   único valor abaixo de 3,0 da peça (o ponto, 2,88).
2. **Aplicou 4,5:1 a tudo.** A coluna se chama "Texto normal (AA 4.5:1)" e todos os 7 pares foram
   julgados por ela. Dos 13 elementos textuais da peça, **10 são texto grande** (mínimo 3,0) e só
   3 caem em texto normal (`.selo` 22px, `.prazo` 22px, `.cidade` 20px); os outros 2 pares medidos
   são gráficos (mínimo 3,0). Aqui a régua errada foi *mais* severa que a real, então não passou nada indevido
   — mas uma régua que nunca sabe qual é o mínimo aplicável é uma régua que também não sabe
   reprovar quando o mínimo for 3,0.
3. **O `contraste.js` lista 7 pares escritos à mão, sem nenhuma ligação com o HTML.** Cor nova
   numa peça futura não aparece na saída do script — some em silêncio. É o padrão da Armadilha 25
   (regra escrita, regra não ligada ao motor), agora no portão 4.

**Nenhum dos três muda o veredito desta peça** — ela passa. Os três mudam a confiança no portão
para a **próxima** peça, e é isso que foi para o quadro como **#118**.
