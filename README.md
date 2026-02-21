# Cockpit-de-voos-SAP-ABAP

**Objetivo** 
Ter uma tela de manutenção dos voos. Com possibilidade de incluir e cancelar passagens em voos futuros. Usuário final será o atendente de compra e venda de passagens. 

**Detalhamento** 
**Seleção** 

- Cia Aérea (scarr-carrid) 
- Conexão (spfli-connid) 
- Data (sflight-fldate) 
- Cidade Partida (spfli-cityfrom) 
- Cidade Destino (spfli-cityto) 
- Código Cliente (sbook-customid) 

**Tela** 
Deverá mostrar 2 ALVs, com interação de duplo clique do primeiro para o segundo. O primeiro irá conter os Voos (sflight), conforme seleção. 
O segundo terá a informações dos passageiros (sbook) do voo selecionado, com opção de cancelar passagem (utilizar BAPI_SBOOK_CANCEL) e opção de incluir um novo passageiro (utilizando BAPI_SBOOK _CREATEFROMDATA). 
Na opção de incluir precisaremos abrir uma nova tela para preenchimento dos dados. 
