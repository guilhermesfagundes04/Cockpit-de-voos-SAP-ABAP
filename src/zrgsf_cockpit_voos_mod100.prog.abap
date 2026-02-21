MODULE pbo_0100 OUTPUT. "MÓDULO pbo_0100 OUTPUT (Processo antes da saída tela 100) VOU ENTRAR NA TELA

  SET PF-STATUS 'S0100'. "DEFINIR STATUS GUI da tela 100
  SET TITLEBAR 'T0100'.  "DEFINIR TÍTULO GUI da tela 100
  PERFORM zf_create_objects. "EXECUTAR (form zf_create_objects)
  PERFORM zf_spli_main_container. "EXECUTAR (form zf_spli_main_container)
  PERFORM zf_display_heading. "EXECUTAR (form zf_display_heading)
  PERFORM zf_display_alv1. "EXECUTAR (form zf_display_alv1)

ENDMODULE. "Fim do módulo PBO_0100

MODULE pai_0100 INPUT. "MÓDULO pai_0100 INPUT (Processo depois da entrada tela 100) JÁ ESTOU NA TELA

  CASE sy-ucomm. "CASO sy-ucomm (variável de sistema que guarda o código de função, sobrescrita a cada ação)
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'. "QUANDO for BACK OU EXIT OU CANCEL
      LEAVE PROGRAM. "DEIXAR O PROGRAMA (SAIR)
  ENDCASE. "Fim do caso

ENDMODULE. "Fim do módulo PAI_0100
