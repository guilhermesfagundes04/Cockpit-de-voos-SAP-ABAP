CLASS lcl_event_handler DEFINITION. "CLASSE local (double click, botões, comandos) DEFINIÇÃO
  PUBLIC SECTION. "SEÇÃO PÚBLICA
    METHODS: "MÉTODOS
      on_double_click FOR EVENT double_click OF cl_gui_alv_grid "on_double_click PARA EVENTO double_click DE cl_gui_alv_grid
        IMPORTING e_row e_column es_row_no, "IMPORTANDO e_row, e_column, es_row_no (PARÂMETROS)

      on_toolbar FOR EVENT toolbar OF cl_gui_alv_grid "on_toolbar PARA EVENTO toolbar DE cl_gui_alv_grid
        IMPORTING e_object e_interactive, "IMPORTANDO e_object, e_interactive (PARÂMETROS)

      on_user_command FOR EVENT user_command OF cl_gui_alv_grid "on_user_command PARA EVENTO user_command DE cl_gui_alv_grid
        IMPORTING e_ucomm. "IMPORTANDO e_ucomm (PARÂMETROS)
ENDCLASS. "Fim da classe DEFINIÇÃO

CLASS lcl_event_handler IMPLEMENTATION. "CLASSE local (double click, botões, comandos) IMPLEMENTAÇÃO

  METHOD on_double_click. "MÉTODO on_double_click

    PERFORM zf_double_click USING e_row e_column es_row_no. "EXECUTAR (form zf_double_click) USANDO PARÂMETROS e_row, e_column, es_row_no

  ENDMETHOD. "Fim do método on_double_click

  METHOD on_toolbar. "MÉTODO on_toolbar

    DATA ls_button TYPE stb_button. "DECLARAR ESTRUTURA ls_button TIPO stb_button

    CLEAR ls_button. "LIMPAR ESTRUTURA ls_button
    ls_button-function  = 'INCLUIR'. "FUNÇÃO incluir
    ls_button-icon      = icon_insert_row. "ÍCONE próprio da SAP
    ls_button-quickinfo = 'Incluir Passagem'. "INFORMAÇÃO RÁPIDA DE UM ÍCONE
    ls_button-text      = 'Incluir'. "TEXTO
    APPEND ls_button TO e_object->mt_toolbar. "ACRESCENTAR na ESTRUTURA ls_button PARA PARÂMETRO e_object ACESSANDO (->) atributo mt_toolbar

    CLEAR ls_button. "LIMPAR ESTRUTURA ls_button
    ls_button-function  = 'DELETAR'. "FUNÇÃO deletar
    ls_button-icon      = icon_delete_row. "ÍCONE próprio da SAP
    ls_button-quickinfo = 'Cancelar Passagem'. "INFORMAÇÃO RÁPIDA DE UM ÍCONE
    ls_button-text      = 'Cancelar'. "TEXTO
    APPEND ls_button TO e_object->mt_toolbar. "ACRESCENTAR na ESTRUTURA ls_button PARA PARÂMETRO e_object ACESSANDO (->) atributo mt_toolbar

  ENDMETHOD. "Fim do método on_toolbar

  METHOD on_user_command. "MÉTODO on_user_command

    CASE e_ucomm. "CASO PARÂMETRO e_ucomm
      WHEN 'INCLUIR'. "QUANDO for INCLUIR
        CALL SCREEN 0200. "TELA DE CHAMADA 200
      WHEN 'DELETAR'. "QUANDO for DELETAR
        PERFORM zf_cancelar_passagem. "EXECUTAR (form zf_cancelar_passagem)
    ENDCASE. "Fim do caso

  ENDMETHOD. "Fim do método on_user_command

ENDCLASS. "Fim da classe IMPLEMENTAÇÃO

DATA go_event_handler TYPE REF TO lcl_event_handler. "DECLARAR OBJETO go_event_handler TIPO REFERÊNCIA DE classe local lcl_event_handler
