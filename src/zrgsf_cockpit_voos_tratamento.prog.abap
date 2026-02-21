* Faço meu formulário zf_create_objects para criação de objetos da tela *
FORM zf_create_objects.

  CREATE OBJECT go_cc "INSTANCIA UM OBJETO e guarda a referência em go_cc
    EXPORTING "EXPORTANDO
      container_name = 'MAIN_CONTAINER'. "NOME DO CONTAINER = 'MAIN_CONTAINER' que eu criei no Screen Painter

  CREATE OBJECT go_dd. "INSTANCIA UM OBJETO e guarda a referência em go_dd
ENDFORM.

* Faço meu formulário zf_spli_main_container para configurar um container dividido (splitter container) *
FORM zf_spli_main_container.

  CREATE OBJECT go_sc "INSTANCIA UM OBJETO e guarda a referência em go_sc
    EXPORTING         "EXPORTANDO
      parent  = go_cc "Define que o container pai do splitter é go_cc
      rows    = 2     "O splitter terá 2 linhas (uma área em cima e outra embaixo)
      columns = 1.    "O splitter terá 1 coluna (ou seja, divisão vertical apenas)

  CALL METHOD go_sc->get_container "Chama o método (get_container) do splitter para obter uma subárea (um container filho)
    EXPORTING                      "EXPORTANDO
      row       = 1                "Pede a subárea da linha 1 (parte de cima)
      column    = 1                "E da coluna 1 (única coluna)
    RECEIVING                      "RECEBENDO
      container = go_part1.        "Recebe a referência dessa subárea em go_part1

  CALL METHOD go_sc->get_container "Chama o método (get_container) do splitter para obter uma subárea 2 (um container filho)
    EXPORTING                      "EXPORTANDO
      row       = 2                "Pede a subárea da linha 2 (parte de baixo)
      column    = 1                "E da coluna 1 (única coluna)
    RECEIVING                      "RECEBENDO
      container = go_part2.        "Recebe a referência dessa subárea 2 em go_part2

  CALL METHOD go_sc->set_row_height "Ajusta a altura de uma linha do splitter
    EXPORTING                       "EXPORTANDO
      id     = 2                    "Escolhe a linha 2 (a de baixo)
      height = 0.                   "Define altura 0 → na prática, esconde a parte de baixo (fica “colapsada”)

ENDFORM.

* Faço meu formulário zf_display_heading para início da sub-rotina*
FORM zf_display_heading.

  DATA head TYPE sdydo_attribute. "DECLARAR variável head TIPO sdydo_attribute (tipo usado para atributos/estilos do Dynamic Document)

  head = cl_dd_document=>heading. "Atribui a head o estilo SAP padrão de cabeçalho (constante estática (=) HEADING da classe CL_DD_DOCUMENT)

  CALL METHOD go_dd->add_text                    "Chama o método (add_text) do Dynamic Document
    EXPORTING                                    "EXPORTANDO
      text      = 'Cookpit de Manutenção de Voo' "Define o texto
      sap_style = head.                          "Aplica o estilo de cabeçalho definido acima.

  CALL METHOD go_dd->display_document "Chama o método (display_document) do Dynamic Document
    EXPORTING                         "EXPORTANDO
      container = 'HEADING'.          "No container HEADING

ENDFORM.

* Faço meu formulário zf_display_alv1 para exibição do meu primeiro ALV *
FORM zf_display_alv1.

  CREATE OBJECT go_alv1    "INSTANCIA UM OBJETO e guarda a referência em go_alv1
    EXPORTING              "EXPORTANDO
      i_parent = go_part1. "Parâmetro do container pai IGUAL a go_part1

* Faço minha busca de VOOS com as seleções *
  SELECT carrid, connid, fldate, price
  FROM sflight
  INTO CORRESPONDING FIELDS OF TABLE @gt_sflight
  WHERE carrid IN @s_carrid
  AND   connid IN @s_connid
  AND   fldate IN @s_fldate.

  IF sy-subrc IS INITIAL.

    SELECT carrid, connid, cityfrom, cityto, deptime
    FROM spfli
    INTO CORRESPONDING FIELDS OF TABLE @gt_spfli
    FOR ALL ENTRIES IN @gt_sflight
    WHERE carrid = @gt_sflight-carrid
    AND   connid = @gt_sflight-connid
    AND cityfrom IN @s_cfrom
    AND   cityto IN @s_cto.

    SELECT carrid, carrname
    FROM scarr
    INTO CORRESPONDING FIELDS OF TABLE @gt_scarr
    FOR ALL ENTRIES IN @gt_sflight
    WHERE carrid = @gt_sflight-carrid.

  ENDIF.

* Ordenação das minhas tabelas *
  SORT: gt_sflight BY carrid ASCENDING connid ASCENDING fldate ASCENDING,
        gt_spfli   BY carrid ASCENDING connid ASCENDING,
        gt_scarr   BY carrid ASCENDING.

* Faço meu tratamento (lógica) para exibir os dados no ALV1 *
  FIELD-SYMBOLS: <fs_voos>    TYPE ty_voo,
                 <fs_sflight> TYPE ty_sflight,
                 <fs_scarr>   TYPE ty_scarr,
                 <fs_spfli>   TYPE ty_spfli.

  LOOP AT gt_sflight ASSIGNING <fs_sflight>.

    READ TABLE gt_spfli ASSIGNING <fs_spfli> WITH KEY carrid = <fs_sflight>-carrid connid = <fs_sflight>-connid.
    READ TABLE gt_scarr ASSIGNING <fs_scarr> WITH KEY carrid = <fs_sflight>-carrid BINARY SEARCH.
    IF sy-subrc IS NOT INITIAL.
      CONTINUE.
    ENDIF.

    READ TABLE gt_voos ASSIGNING <fs_voos> WITH KEY carrname = <fs_scarr>-carrname connid = <fs_sflight>-connid fldate = <fs_sflight>-fldate.
    IF sy-subrc IS INITIAL.
      CONTINUE.
    ELSE.
      APPEND INITIAL LINE TO gt_voos ASSIGNING <fs_voos>.
      <fs_voos>-carrid   = <fs_scarr>-carrid.
      <fs_voos>-carrname = <fs_scarr>-carrname.
      <fs_voos>-connid   = <fs_sflight>-connid.
      <fs_voos>-fldate   = <fs_sflight>-fldate.
    ENDIF.

    <fs_voos>-price    = <fs_sflight>-price.
    <fs_voos>-cityfrom = <fs_spfli>-cityfrom.
    <fs_voos>-cityto   = <fs_spfli>-cityto.
    <fs_voos>-deptime  = <fs_spfli>-deptime.

  ENDLOOP.

  DATA: lt_fieldcat TYPE lvc_t_fcat, "Declarar minha tabela local lt_fieldcar TIPO lvc_t_fcat (field catalog do ALV grid)
        ls_fieldcat TYPE lvc_s_fcat. "Declarar minha estrutura local ls_fieldcar TIPO lvc_s_fcat (field catalog do ALV grid)

  CLEAR lt_fieldcat. "LIMPAR lt_fieldcat

* Aqui vai ser definifo o fieldname, texto e comprimento de cada campo que vou exibir no ALV1 e depois atribuir a estrutura local na tabela local
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'CARRID'.
  ls_fieldcat-coltext     = 'Companhia Aérea'.
  ls_fieldcat-outputlen   = 12.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'CARRNAME'.
  ls_fieldcat-coltext     = 'Nome Cia. Aérea'.
  ls_fieldcat-outputlen   = 11.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'CONNID'.
  ls_fieldcat-coltext     = 'Número do Voo'.
  ls_fieldcat-outputlen   = 10.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'FLDATE'.
  ls_fieldcat-coltext     = 'Data voo'.
  ls_fieldcat-outputlen   = 7.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'DEPTIME'.
  ls_fieldcat-coltext     = 'Partida'.
  ls_fieldcat-outputlen   = 6.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'PRICE'.
  ls_fieldcat-coltext     = 'Preço Voo'.
  ls_fieldcat-outputlen   = 7.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'CITYFROM'.
  ls_fieldcat-coltext     = 'Cidade de Partida'.
  ls_fieldcat-outputlen   = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname   = 'CITYTO'.
  ls_fieldcat-coltext     = 'Cidade de Chegada'.
  ls_fieldcat-outputlen   = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

  CALL METHOD go_alv1->set_table_for_first_display "Chama o método (set_table_for_first_display) do objeto go_alv1
    EXPORTING                                      "EXPORTANDO
      i_save          = 'A'                        "Parâmetro save IGUAL a 'A' - indica que a configuração de layout do ALV será salva automaticamente
    CHANGING                                       "MUDANDO
      it_outtab       = gt_voos                    "Tabela interna que será exibida
      it_fieldcatalog = lt_fieldcat.               "Field catalog que descreve quais campos mostrar e como

  CREATE OBJECT go_event_handler.                            "INSTANCIA UM OBJETO e guarda a referência em go_event_handler
  SET HANDLER go_event_handler->on_double_click FOR go_alv1. "DEFINIR MANIPULADOR chamando método on_double_click PARA objeto go_alv1

ENDFORM.

* Faço meu formulário zf_double_click para o duplo clique no ALV1 *
FORM zf_double_click USING e_row     TYPE lvc_s_row   "USANDO e_row TIPO lvc_s_row (estrutura)
                           e_column  TYPE lvc_s_col   "USANDO e_column TIPO lvc_s_Col (estrutura)
                           es_row_no TYPE lvc_s_roid. "USANDO es_row_no TIPO lvc_s_roid (estrutura)

* Faço meu tratamento (lógica) para exibir os dados no ALV2 *
  DATA: ls_voo        TYPE ty_voo,
        ls_passageiro TYPE ty_pass.

  READ TABLE gt_voos INTO ls_voo INDEX es_row_no-row_id.
  IF sy-subrc IS NOT INITIAL.
    RETURN.
  ENDIF.

  CLEAR: gt_pass.

  SELECT carrid, connid, fldate, customid, bookid, class, agencynum, luggweight
  FROM sbook
  INTO CORRESPONDING FIELDS OF TABLE @gt_pass
  WHERE carrid = @ls_voo-carrid
  AND   connid = @ls_voo-connid
  AND   fldate = @ls_voo-fldate.

  IF go_alv2 IS INITIAL.              "SE go_alv2 FOR INICIAL
    PERFORM zf_display_alv2.          "EXECUTAR (form zf_display_alv2)
    CALL METHOD go_sc->set_row_height "Ajusta a altura de uma linha do splitter
      EXPORTING                       "EXPORTANDO
        id     = 2                    "Escolhe a linha 2 (a de baixo)
        height = 100.                 "Define altura 100
  ELSE.                               "SENÃO
    CALL METHOD go_alv2->refresh_table_display "Chama o método (refresh_table_display) do objeto go_alv2
      EXPORTING                                "EXPORTANDO
        is_stable = VALUE lvc_s_stbl( row = 'X' col = 'X' ).
  ENDIF.

ENDFORM.

FORM zf_display_alv2.

  CREATE OBJECT go_alv2
    EXPORTING
      i_parent = go_part2.

  IF go_event_handler IS INITIAL.
    CREATE OBJECT go_event_handler.
  ENDIF.

  SET HANDLER go_event_handler->on_toolbar      FOR go_alv2.
  SET HANDLER go_event_handler->on_user_command FOR go_alv2.

  DATA: lt_fieldcat TYPE lvc_t_fcat,
        ls_fieldcat TYPE lvc_s_fcat.

  CLEAR lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CARRID'.
  ls_fieldcat-coltext   = 'Companhia Aérea'.
  ls_fieldcat-outputlen   = 12.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CONNID'.
  ls_fieldcat-coltext   = 'Número do Voo'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'FLDATE'.
  ls_fieldcat-coltext   = 'Data do Voo'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CUSTOMID'.
  ls_fieldcat-coltext   = 'N° Cliente'.
  ls_fieldcat-outputlen   = 7.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BOOKID'.
  ls_fieldcat-coltext   = 'N° de Marcação'.
  ls_fieldcat-outputlen   = 11.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'LUGGWEIGHT'.
  ls_fieldcat-coltext   = 'Peso da bagagem'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CLASS'.
  ls_fieldcat-coltext   = 'Classe'.
  ls_fieldcat-outputlen   = 5.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AGENCYNUM'.
  ls_fieldcat-coltext   = 'N° Agência Viagens'.
  ls_fieldcat-outputlen   = 14.
  APPEND ls_fieldcat TO lt_fieldcat.

  DATA: ls_variant TYPE disvariant.
  CLEAR ls_variant.

  CALL METHOD go_alv2->set_table_for_first_display
    EXPORTING
      i_structure_name = ''
      is_variant       = ls_variant
      i_save           = 'A'
      is_layout        = VALUE lvc_s_layo( zebra = abap_true )
    CHANGING
      it_outtab        = gt_pass
      it_fieldcatalog  = lt_fieldcat.

  IF go_event_handler IS INITIAL.
    CREATE OBJECT go_event_handler.
  ENDIF.

ENDFORM.

DATA: p_carrid     TYPE sbook-carrid,
      p_connid     TYPE sbook-connid,
      p_fldate     TYPE sbook-fldate,
      p_customid   TYPE sbook-customid,
      p_class      TYPE sbook-class,
      p_luggweight TYPE sbook-luggweight,
      p_agencynum  TYPE sbook-agencynum.

FORM zf_cancelar_passagem.

  DATA: ls_pass          TYPE ty_pass,
        lv_return        TYPE bapiret2,
        lt_selected_rows TYPE lvc_t_row,
        ls_row           TYPE lvc_s_row.

  IF go_alv2 IS INITIAL.
    MESSAGE TEXT-002 TYPE 'I'.
    RETURN.
  ENDIF.

  CALL METHOD go_alv2->get_selected_rows
    IMPORTING
      et_index_rows = lt_selected_rows.

  IF lt_selected_rows IS INITIAL.
    MESSAGE TEXT-003 TYPE 'I'.
    RETURN.
  ENDIF.

  READ TABLE lt_selected_rows INTO ls_row INDEX 1.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE TEXT-004 TYPE 'I'.
    RETURN.
  ENDIF.

  READ TABLE gt_pass INTO ls_pass INDEX ls_row-index.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE TEXT-005 TYPE 'I'.
    RETURN.
  ENDIF.

  CALL FUNCTION 'BAPI_SBOOK_CANCEL'
    EXPORTING
      airlinecarrier   = ls_pass-carrid
      connectionnumber = ls_pass-connid
      dateofflight     = ls_pass-fldate
      customernumber   = ls_pass-customid
      bookingnumber    = ls_pass-bookid
    IMPORTING
      return           = lv_return.

  IF lv_return-type CA 'EA'.
    MESSAGE lv_return-message TYPE 'E'.
  ELSE.
    COMMIT WORK AND WAIT.
    MESSAGE TEXT-006 TYPE 'S'.
    DELETE gt_pass INDEX ls_row-index.
    CALL METHOD go_alv2->refresh_table_display.
  ENDIF.

ENDFORM.

MODULE validar_dados INPUT.

  IF p_carrid IS INITIAL OR p_connid IS INITIAL OR p_fldate IS INITIAL OR p_customid IS INITIAL .
    MESSAGE TEXT-007 TYPE 'E'.
  ENDIF.

ENDMODULE.

FORM zf_incluir_passagem.

  DATA: lv_return      TYPE bapiret2,
        ls_bapisbook   TYPE bapisbdtin,
        lv_bookingdata TYPE bapisbdeta.

  CLEAR ls_bapisbook.

  ls_bapisbook-carrid       = p_carrid.
  ls_bapisbook-connid       = p_connid.
  ls_bapisbook-fldate       = p_fldate.
  ls_bapisbook-customid     = p_customid.
  ls_bapisbook-luggweight   = p_luggweight.
  ls_bapisbook-class        = p_class.
  ls_bapisbook-agencynum    = p_agencynum.

  CALL FUNCTION 'BAPI_SBOOK_CREATEFROMDATA'
    EXPORTING
      bookingdata_in = ls_bapisbook
    IMPORTING
      return         = lv_return
      bookingdata    = lv_bookingdata.

  IF lv_return-type CA 'EA'.

    MESSAGE lv_return-message TYPE 'E'.
    sy-subrc = 1.
    RETURN.
  ELSE.
    COMMIT WORK AND WAIT.

    CLEAR gt_pass.

    SELECT carrid, connid, fldate, customid, bookid, luggweight, class, agencynum
    FROM sbook
    INTO TABLE @gt_pass
    WHERE carrid = @p_carrid
    AND   connid = @p_connid
    AND   fldate = @p_fldate.

    CALL METHOD go_alv2->refresh_table_display.
    MESSAGE TEXT-008 TYPE 'S'.
    sy-subrc = 0.

  ENDIF.

ENDFORM.
