MODULE pbo_0200 OUTPUT. "MÓDULO pbo_0200 OUTPUT (Processo antes da saída tela 200) VOU ENTRAR NA TELA

  SET PF-STATUS 'S0200'. "DEFINIR STATUS GUI da tela 200
  SET TITLEBAR 'T0200'.  "DEFINIR TÍTULO GUI da tela 200

ENDMODULE. "Fim do módulo PBO_0100

MODULE pai_0200 INPUT. "MÓDULO pai_0200 INPUT (Processo depois da entrada tela 200) JÁ ESTOU NA TELA

  CASE sy-ucomm. "CASO sy-ucomm (variável de sistema que guarda o código de função, sobrescrita a cada ação)
    WHEN 'SALVAR'. "QUANDO for SALVAR
      PERFORM zf_incluir_passagem. "EXECUTAR (form zf_incluir_passagem)
      IF sy-subrc IS INITIAL. "SE sy-subrc É INICIAL (tem seu valor padrão = 0)
        LEAVE TO SCREEN 100. "DEIXAR PARA A TELA 100 (VOLTAR)
      ENDIF. "Fim do IF
    WHEN 'VOLTAR' OR 'EXIT' OR 'BACK'. "QUANDO for VOLTAR OU EXIT OU BACK
      LEAVE TO SCREEN 100. "DEIXAR PARA A TELA 100 (VOLTAR)
  ENDCASE. "Fim do caso

ENDMODULE. "Fim do módulo PAI_0100
