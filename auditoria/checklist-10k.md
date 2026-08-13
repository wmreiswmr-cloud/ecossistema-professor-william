# O Checklist dos $10K

Versionado em 2026-08-09 — item da checagem de artefatos que precisam de arquivo real. Fonte original: PDF "The $10K Checklist" (Metics Media), trazido pelo dono em 08/08, publicado como Artifact interativo (`1c4e589b-...`). Até aqui só existia como checklist clicável — nenhum agente conseguia "ler" o critério real sem abrir o link. Este arquivo é a versão consultável, usada na Fase 7 do `processo-design-final.md` e em qualquer auditoria de design daqui pra frente.

**O que separa um site de R$10.000 de um de R$200**, segundo os 8 critérios:

## 1. Ponto de vista, não template
O design tem uma decisão estética que só faz sentido pra esse produto específico — não é a paleta/composição genérica que serviria pra qualquer SaaS. Achado real aplicado hoje: hero navy/dourado do ProfGestor tem razão de ser (confiança + urgência controlada), não é escolha arbitrária.

## 2. Tipografia que faz trabalho
A fonte carrega hierarquia e tom, não só "parece bonita". Peso, tamanho e espaçamento comunicam o que é mais importante antes do leitor processar o texto. Achado real: troca de Bricolage Grotesque → DM Sans no ProfGestor foi decisão de legibilidade/tom, não gosto pessoal.

## 3. Sistema de cor contido
Poucas cores, usadas com disciplina — nunca "mais cor resolve o problema de parecer simples". Cada cor tem um papel fixo (ação primária, alerta, sucesso) e nunca é usada fora dele.

## 4. Hierarquia que respira
Espaço em branco é decisão, não sobra. O olho sabe onde ir primeiro sem esforço. Densidade alta é escolha consciente pra dashboard, nunca acidente em landing page.

## 5. Imagem com intenção
Toda foto/ilustração está ali por um motivo específico — nunca banco de imagem genérico "pra preencher espaço". Achado real: preferência por foto real do William em vez de imagem de banco, mesmo custando mais trabalho.

## 6. Motion que sussurra
Animação comunica algo (estado mudou, ação teve efeito) — nunca decoração. Sutil o bastante pra não competir com o conteúdo. Achado real de hoje: `fadeUp` genérico do ProfGestor foi trocado por coreografia com propósito + suporte a `prefers-reduced-motion`.

## 7. Mobile desenhado, não encolhido
A versão mobile é pensada como produto próprio, não o desktop espremido. Toque, distância do polegar e prioridade de conteúdo são decisões mobile-first, não adaptação de última hora.

## 8. O caro invisível
Performance, acessibilidade, HTML semântico e metadados corretos — o que o usuário nunca vê conscientemente, mas sente. Achado real de hoje: Lighthouse do ProfGestor foi de 25→56 depois de code-splitting real, não estético algum.

## Como usar

Fase 7 do `processo-design-final.md` aplica este checklist antes de qualquer aprovação final de peça visual — cada critério vira uma pergunta objetiva (sim/não/parcial), com achado real citado, nunca "parece que sim".
