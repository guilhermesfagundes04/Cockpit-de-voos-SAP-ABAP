TABLES: sbook, scarr, sflight, spfli.

* Declarando meus tipos que vão ser utilizados *
TYPES: BEGIN OF ty_voo,
         carrid   TYPE scarr-carrid,
         carrname TYPE scarr-carrname,
         connid   TYPE sflight-connid,
         fldate   TYPE sflight-fldate,
         deptime  TYPE spfli-deptime,
         price    TYPE sflight-price,
         cityfrom TYPE spfli-cityfrom,
         cityto   TYPE spfli-cityto,
       END OF ty_voo,

       BEGIN OF ty_pass,
         carrid     TYPE sflight-carrid,
         connid     TYPE sflight-connid,
         fldate     TYPE sflight-fldate,
         customid   TYPE sbook-customid,
         bookid     TYPE sbook-bookid,
         luggweight TYPE sbook-luggweight,
         class      TYPE sbook-class,
         agencynum  TYPE sbook-agencynum,
       END OF ty_pass,

       BEGIN OF ty_scarr,
         carrid   TYPE scarr-carrid,
         carrname TYPE scarr-carrname,
       END OF ty_scarr,

       BEGIN OF ty_sflight,
         carrid TYPE sflight-carrid,
         connid TYPE sflight-connid,
         fldate TYPE sflight-fldate,
         price  TYPE sflight-price,
       END OF ty_sflight,

       BEGIN OF ty_spfli,
         carrid   TYPE spfli-carrid,
         connid   TYPE spfli-connid,
         cityfrom TYPE spfli-cityfrom,
         cityto   TYPE spfli-cityto,
         deptime  TYPE spfli-deptime,
       END OF ty_spfli.

* Declarando minhas tabelas para o tratamento *
DATA: gt_voos    TYPE STANDARD TABLE OF ty_voo,
      gt_pass    TYPE STANDARD TABLE OF ty_pass,
      gt_scarr   TYPE STANDARD TABLE OF ty_scarr,
      gt_sflight TYPE STANDARD TABLE OF ty_sflight,
      gt_spfli   TYPE STANDARD TABLE OF ty_spfli.

* Declarando meus objetos, fazendo referência as respectivas classes *
DATA: go_cc    TYPE REF TO cl_gui_custom_container,
      go_sc    TYPE REF TO cl_gui_splitter_container,
      go_part1 TYPE REF TO cl_gui_container,
      go_part2 TYPE REF TO cl_gui_container,
      go_alv1  TYPE REF TO cl_gui_alv_grid,
      go_alv2  TYPE REF TO cl_gui_alv_grid,
      go_dd    TYPE REF TO cl_dd_document.

* Faço um SELECTION-SCREEN para por na tela as minhas seleções que vão ser utilizadas para filtrar os dados que vão ser pesquisados. *
SELECTION-SCREEN BEGIN OF BLOCK bc01 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS: s_carrid FOR scarr-carrid,
                  s_connid FOR spfli-connid,
                  s_fldate FOR sflight-fldate,
                  s_cfrom  FOR spfli-cityfrom,
                  s_cto    FOR spfli-cityto,
                  s_id     FOR sbook-customid.

SELECTION-SCREEN END OF BLOCK bc01.
