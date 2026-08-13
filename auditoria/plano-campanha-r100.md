# Plano da Primeira Campanha — R$100 (ProfGestor)

Versionado em 2026-08-09 — item da checagem "o que dos artefatos precisa ser versionado" (autoauditoria "Architecture of Intelligent Management"). Até aqui este plano só existia como Artifact publicado em 06/08 (`cerebro-trafego`); precisou ser recuperado via `WebFetch` quando a campanha foi montada, porque não havia arquivo local. Conteúdo abaixo é o texto real extraído do artefato, não reescrito.

## Honestidade de partida (do próprio plano)

R$100 é orçamento de **aprendizado** no mercado, não resultado garantido. O algoritmo do Meta só sai da fase de aprendizado com 50 eventos de conversão em 7 dias — R$100 otimizado direto pra "Compra" nunca chega lá. 3 compras é meta otimista, alcançável se tudo funcionar bem, não promessa. Não existe LTV real medido (zero cliente pagante na época) — CAC-alvo comparado contra 1 mês de mensalidade, não LTV real, por honestidade.

## Especificação

| Campo | Valor | Nota |
|---|---|---|
| Objetivo | Lead (cadastro) | Não Compra direto — evento já ativo, precisa de bem menos volume pra ter sinal |
| Estrutura | 1 campanha, 1 conjunto | Nunca dividir R$100 em vários testes |
| Público | Amplo, Brasil | Interesse em aula/professor particular, educação — sem restringir demais |
| Janela | 5-7 dias corridos | ~R$14-20/dia, folga real acima do mínimo de R$5,12/dia |
| Criativo | Foto real do hero da landing + dor específica validada | Nunca link genérico "conheça o ProfGestor" |
| Complemento | Rodar junto com post orgânico na rede pessoal do dono | Quem já viu o dono recomendando converte mais barato que tráfego frio puro |

## Passo a passo original

1. Preço final decidido (era pendência em 06/08 — resolvido 07/08, R$29,90)
2. Campanha montada pausada, sem gastar nada
3. Ativar e rodar 5-7 dias, otimizando pro Lead, orçamento concentrado num conjunto só
4. **Checar em 3 dias** — custo por lead dentro do critério de matar?
5. Fechar a janela e medir — quantos leads viraram cadastro, quantos cadastro viraram pagante

## Critério de matar (real, do plano original)

> Se em 3 dias o custo por lead passar de R$15-20, pausar e revisar criativo/público antes de gastar o resto dos R$100.

## Estado real hoje (2026-08-09) vs. o plano original

| Item do plano | O que aconteceu de verdade |
|---|---|
| Estrutura (1 campanha, 1 conjunto) | ✅ Seguido — `120250080682810305` / `120250080685030305` |
| Objetivo Lead | ✅ Seguido — `OUTCOME_LEADS`, evento `signup=true` |
| Nunca dividir teste | ⚠️ Quase violado — 2 anúncios chegaram a coexistir pausados no mesmo conjunto por causa de correções sucessivas de copy/criativo; corrigido antes de ativar (ver `riscos.md` #2) |
| Criativo = foto real + dor específica | ✅ Seguido, com correção de rumo no meio do caminho (copy inicial usava ângulo errado de "cancelamento", corrigido pra "controle manual/planilha") |
| Janela 5-7 dias | ✅ 6 dias — 09/08 08h a 15/08 23h59 |
| Ativação | ✅ 08/08, comando direto do dono ("pode ativar") |
| **Checar em 3 dias / critério de matar** | ⏳ **Ainda não aconteceu** — ver item de acompanhamento abaixo |

## Acompanhamento real pendente

O critério de matar (CPL &gt; R$15-20 após 3 dias) precisa de alguém checando ativamente por volta de **12/08**, 3 dias depois do início real da entrega (09/08). Isso não estava em nenhum lugar rastreável até este arquivo — registrado agora também como item de `problemas.md` (ver #46), pra não repetir o padrão de "decisão/plano real que existe mas não vira ação rastreada".

**Revisão:** ao fim da janela (15/08), ou antes se o critério de matar disparar — regra original mantida.
