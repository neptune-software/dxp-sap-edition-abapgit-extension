CLASS zcl_abapgit_object_zn01 DEFINITION
  PUBLIC
  INHERITING FROM zcl_abapgit_objects_super
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abapgit_object .

    CONSTANTS gc_crlf TYPE abap_cr_lf VALUE cl_abap_char_utilities=>cr_lf. "#EC NOTEXT
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_lcl_evtscr,
            applid    TYPE /neptune/applid,
            field_id  TYPE /neptune/field_id,
*          version   type /neptune/version,
            event     TYPE /neptune/event_id,
            file_name TYPE string,
           END OF ty_lcl_evtscr .
    TYPES
      ty_tt_lcl_evtscr TYPE STANDARD TABLE OF ty_lcl_evtscr .
    TYPES:
      BEGIN OF ty_lcl_css,
            applid    TYPE /neptune/applid,
*          version   type /neptune/version,
            file_name TYPE string,
           END OF ty_lcl_css .
    TYPES
      ty_tt_lcl_css TYPE STANDARD TABLE OF ty_lcl_css .
    TYPES:
      BEGIN OF ty_code,
            file_name TYPE string,
            code      TYPE string,
           END OF ty_code .
    TYPES
      ty_tt_code TYPE STANDARD TABLE OF ty_code WITH NON-UNIQUE KEY file_name .

    DATA mt_skip_paths TYPE string_table .

    INTERFACE /neptune/if_artifact_type LOAD .
    METHODS serialize_evtscr
      IMPORTING
        !it_obj TYPE /neptune/obj_tt
        !is_table_content TYPE /neptune/if_artifact_type=>ty_table_content .
    METHODS serialize__evtscr
      IMPORTING
        !it_obj TYPE /neptune/obj_tt
        !is_table_content TYPE /neptune/if_artifact_type=>ty_table_content .
    METHODS serialize_table
      IMPORTING
        !iv_tabname TYPE tabname
        !it_table TYPE any
      RAISING
        zcx_abapgit_exception .
    METHODS serialize_css
      IMPORTING
        !is_table_content TYPE /neptune/if_artifact_type=>ty_table_content .
    METHODS serialize__css
      IMPORTING
        !is_table_content TYPE /neptune/if_artifact_type=>ty_table_content .
    INTERFACE zif_abapgit_git_definitions LOAD .
    METHODS deserialize_table
      IMPORTING
        !is_file TYPE zif_abapgit_git_definitions=>ty_file
        !ir_data TYPE REF TO data
        !iv_tabname TYPE tadir-obj_name
        !iv_key TYPE /neptune/artifact_key
      RAISING
        zcx_abapgit_exception .
    METHODS get_values_from_filename
      IMPORTING
        !is_filename TYPE string
      EXPORTING
        !ev_tabname TYPE tadir-obj_name
        !ev_obj_key TYPE /neptune/artifact_key .
    METHODS set_skip_fields .
    METHODS get_skip_fields
      RETURNING
        VALUE(rt_skip_paths) TYPE string_table .
    METHODS deserialize_evtscr
      IMPORTING
        !is_file TYPE zif_abapgit_git_definitions=>ty_file
        !it_files TYPE zif_abapgit_git_definitions=>ty_files_tt
        !ir_data TYPE REF TO data
        !iv_key TYPE /neptune/artifact_key
      RAISING
        zcx_abapgit_exception .
    METHODS deserialize__evtscr
      IMPORTING
        !is_file TYPE zif_abapgit_git_definitions=>ty_file
        !it_files TYPE zif_abapgit_git_definitions=>ty_files_tt
        !ir_data TYPE REF TO data
        !iv_key TYPE /neptune/artifact_key
      EXCEPTIONS
        zcx_abapgit_exception .
    METHODS deserialize_css
      IMPORTING
        !is_file TYPE zif_abapgit_git_definitions=>ty_file
        !it_files TYPE zif_abapgit_git_definitions=>ty_files_tt
        !ir_data TYPE REF TO data
        !iv_key TYPE /neptune/artifact_key
      RAISING
        zcx_abapgit_exception .
    METHODS deserialize__css
      IMPORTING
        !is_file TYPE zif_abapgit_git_definitions=>ty_file
        !it_files TYPE zif_abapgit_git_definitions=>ty_files_tt
        !ir_data TYPE REF TO data
        !iv_key TYPE /neptune/artifact_key
      RAISING
        zcx_abapgit_exception .
ENDCLASS.



CLASS zcl_abapgit_object_zn01 IMPLEMENTATION.


  METHOD deserialize_css.

    DATA lt_lcl_css TYPE ty_tt_lcl_css.
    DATA ls_lcl_css LIKE LINE OF lt_lcl_css.

    DATA lt_css TYPE STANDARD TABLE OF /neptune/css WITH DEFAULT KEY.
    DATA ls_css LIKE LINE OF lt_css.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    DATA ls_file LIKE LINE OF it_files.

    DATA lt_code TYPE string_table.
    DATA lv_code TYPE string.

    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.

    ASSIGN ir_data->* TO <lt_tab>.
    CHECK sy-subrc = 0.

    TRY.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( IMPORTING ev_container = lt_lcl_css ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.

    LOOP AT lt_lcl_css INTO ls_lcl_css.

      MOVE-CORRESPONDING ls_lcl_css TO ls_css.

      READ TABLE it_files INTO ls_file WITH KEY filename = ls_lcl_css-file_name.
      IF sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

        SPLIT lv_code AT gc_crlf INTO TABLE lt_code.
        LOOP AT lt_code INTO lv_code.
          ls_css-applid = iv_key.
          ls_css-seqnr  = sy-tabix.
          ls_css-text   = lv_code.
          APPEND ls_css TO lt_css.
        ENDLOOP.


      ENDIF.
    ENDLOOP.

    <lt_tab> = lt_css.

  ENDMETHOD.


  METHOD deserialize_evtscr.

    DATA lt_lcl_evtscr TYPE ty_tt_lcl_evtscr.
    DATA ls_lcl_evtscr LIKE LINE OF lt_lcl_evtscr.

    DATA lt_evtscr TYPE STANDARD TABLE OF /neptune/evtscr WITH DEFAULT KEY.
    DATA ls_evtscr LIKE LINE OF lt_evtscr.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    DATA ls_file LIKE LINE OF it_files.

    DATA lt_code TYPE string_table.
    DATA lv_code TYPE string.

    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.

    ASSIGN ir_data->* TO <lt_tab>.
    CHECK sy-subrc = 0.

    TRY.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( IMPORTING ev_container = lt_lcl_evtscr ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.

    LOOP AT lt_lcl_evtscr INTO ls_lcl_evtscr.

      MOVE-CORRESPONDING ls_lcl_evtscr TO ls_evtscr.

      READ TABLE it_files INTO ls_file WITH KEY filename = ls_lcl_evtscr-file_name.
      IF sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

        SPLIT lv_code AT gc_crlf INTO TABLE lt_code.
        LOOP AT lt_code INTO lv_code.
          ls_evtscr-applid = iv_key.
          ls_evtscr-seqnr  = sy-tabix.
          ls_evtscr-text   = lv_code.
          APPEND ls_evtscr TO lt_evtscr.
        ENDLOOP.


      ENDIF.
    ENDLOOP.

    <lt_tab> = lt_evtscr.

  ENDMETHOD.


  METHOD deserialize_table.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    DATA lt_table_content TYPE REF TO data.

    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.
    FIELD-SYMBOLS <ls_line> TYPE any.
    FIELD-SYMBOLS <lv_field> TYPE any.
    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    ASSIGN ir_data->* TO <lt_tab>.
    CHECK sy-subrc = 0.

    CREATE DATA lt_table_content TYPE STANDARD TABLE OF (iv_tabname) WITH NON-UNIQUE DEFAULT KEY.
    ASSIGN lt_table_content->* TO <lt_standard_table>.
    CHECK sy-subrc = 0.

    TRY.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).

        lo_ajson->zif_abapgit_ajson~to_abap( IMPORTING ev_container = <lt_standard_table> ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.


    LOOP AT <lt_standard_table> ASSIGNING <ls_line>.
      ASSIGN COMPONENT 'APPLID' OF STRUCTURE <ls_line> TO <lv_field>.
      IF <lv_field> IS ASSIGNED.
        <lv_field> = iv_key.
        UNASSIGN <lv_field>.
      ENDIF.

      ASSIGN COMPONENT 'VERSION' OF STRUCTURE <ls_line> TO <lv_field>.
      IF <lv_field> IS ASSIGNED.
        <lv_field> = 1.
        UNASSIGN <lv_field>.
      ENDIF.

    ENDLOOP.

    <lt_tab> = <lt_standard_table>.

  ENDMETHOD.


  METHOD deserialize__css.

    DATA lt_lcl_css TYPE ty_tt_lcl_css.
    DATA ls_lcl_css LIKE LINE OF lt_lcl_css.

    DATA lt_css TYPE STANDARD TABLE OF /neptune/_css_d WITH DEFAULT KEY.
    DATA ls_css LIKE LINE OF lt_css.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    DATA ls_file LIKE LINE OF it_files.

    DATA lt_code TYPE string_table.
    DATA lv_code TYPE string.

    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.

    ASSIGN ir_data->* TO <lt_tab>.
    CHECK sy-subrc = 0.

    TRY.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( IMPORTING ev_container = lt_lcl_css ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.

    LOOP AT lt_lcl_css INTO ls_lcl_css.

      MOVE-CORRESPONDING ls_lcl_css TO ls_css.

      READ TABLE it_files INTO ls_file WITH KEY filename = ls_lcl_css-file_name.
      IF sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

        SPLIT lv_code AT gc_crlf INTO TABLE lt_code.
        LOOP AT lt_code INTO lv_code.
          ls_css-applid  = iv_key.
          ls_css-version = 1.
          ls_css-seqnr   = sy-tabix.
          ls_css-text    = lv_code.
          APPEND ls_css TO lt_css.
        ENDLOOP.


      ENDIF.
    ENDLOOP.

    <lt_tab> = lt_css.

  ENDMETHOD.


  METHOD deserialize__evtscr.

    DATA lt_lcl_evtscr TYPE ty_tt_lcl_evtscr.
    DATA ls_lcl_evtscr LIKE LINE OF lt_lcl_evtscr.

    DATA lt_evtscr TYPE STANDARD TABLE OF /neptune/_evtscr WITH DEFAULT KEY.
    DATA ls_evtscr LIKE LINE OF lt_evtscr.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    DATA ls_file LIKE LINE OF it_files.

    DATA lt_code TYPE string_table.
    DATA lv_code TYPE string.

    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.

    ASSIGN ir_data->* TO <lt_tab>.
    CHECK sy-subrc = 0.

    TRY.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( IMPORTING ev_container = lt_lcl_evtscr ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
      CATCH zcx_abapgit_exception.
    ENDTRY.

    LOOP AT lt_lcl_evtscr INTO ls_lcl_evtscr.

      MOVE-CORRESPONDING ls_lcl_evtscr TO ls_evtscr.

      READ TABLE it_files INTO ls_file WITH KEY filename = ls_lcl_evtscr-file_name.
      IF sy-subrc = 0.
        TRY.
            lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).
          CATCH zcx_abapgit_exception.
        ENDTRY.

        SPLIT lv_code AT gc_crlf INTO TABLE lt_code.
        LOOP AT lt_code INTO lv_code.
          ls_evtscr-applid = iv_key.
          ls_evtscr-version = 1.
          ls_evtscr-seqnr  = sy-tabix.
          ls_evtscr-text   = lv_code.
          APPEND ls_evtscr TO lt_evtscr.
        ENDLOOP.

      ENDIF.
    ENDLOOP.

    <lt_tab> = lt_evtscr.

  ENDMETHOD.


  METHOD get_skip_fields.
    rt_skip_paths = mt_skip_paths.
  ENDMETHOD.


  METHOD get_values_from_filename.

    DATA lt_comp TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA ls_comp LIKE LINE OF lt_comp.

    SPLIT is_filename AT '.' INTO TABLE lt_comp.

    READ TABLE lt_comp INTO ls_comp INDEX 1.
    IF sy-subrc = 0.
      TRANSLATE ls_comp TO UPPER CASE.
      ev_obj_key = ls_comp.
    ENDIF.

    READ TABLE lt_comp INTO ls_comp INDEX 3.
    IF sy-subrc = 0.
      REPLACE ALL OCCURRENCES OF '#' IN ls_comp WITH '/'.
      TRANSLATE ls_comp TO UPPER CASE.
      ev_tabname = ls_comp.
    ENDIF.

  ENDMETHOD.


  METHOD serialize_css.

    DATA ls_file TYPE zif_abapgit_git_definitions=>ty_file.
    DATA lv_code TYPE string.

    DATA lt_lcl_css TYPE ty_tt_lcl_css.
    DATA ls_lcl_css LIKE LINE OF lt_lcl_css.

    DATA lt_css TYPE STANDARD TABLE OF /neptune/css WITH DEFAULT KEY.
    DATA ls_css LIKE LINE OF lt_css.

    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    ASSIGN is_table_content-table_content->* TO <lt_standard_table>.
    CHECK sy-subrc = 0 AND <lt_standard_table> IS NOT INITIAL.

    lt_css = <lt_standard_table>.

    SORT lt_css.

    READ TABLE lt_css INTO ls_css INDEX 1.
    CHECK sy-subrc = 0.

    MOVE-CORRESPONDING ls_css TO ls_lcl_css.

    LOOP AT lt_css INTO ls_css.
      IF lv_code IS INITIAL.
        lv_code = ls_css-text.
      ELSE.
        CONCATENATE lv_code ls_css-text INTO lv_code SEPARATED BY gc_crlf.
      ENDIF.
    ENDLOOP.

    CONCATENATE me->ms_item-obj_name
                me->ms_item-obj_type
                is_table_content-tabname
                'css' INTO ls_lcl_css-file_name SEPARATED BY '.'.

    REPLACE ALL OCCURRENCES OF '/' IN ls_lcl_css-file_name WITH '#'.

    TRANSLATE ls_lcl_css-file_name TO LOWER CASE.
    APPEND ls_lcl_css TO lt_lcl_css.

    TRY.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_css ).

** loop at code table to add each entry as a file
        ls_file-path = '/'.

        ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
      CATCH zcx_abapgit_exception.
    ENDTRY.

    ls_file-filename = ls_lcl_css-file_name.

    zif_abapgit_object~mo_files->add( ls_file ).

  ENDMETHOD.


  METHOD serialize_evtscr.

    DATA ls_file TYPE zif_abapgit_git_definitions=>ty_file.

    DATA lt_lcl_evtscr TYPE ty_tt_lcl_evtscr.
    DATA ls_lcl_evtscr LIKE LINE OF lt_lcl_evtscr.

    DATA lt_evtscr TYPE STANDARD TABLE OF /neptune/evtscr WITH DEFAULT KEY.
    DATA ls_evtscr LIKE LINE OF lt_evtscr.

    DATA: lt_code TYPE ty_tt_code,
          ls_code LIKE LINE OF lt_code.

    DATA ls_obj LIKE LINE OF it_obj.

    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    ASSIGN is_table_content-table_content->* TO <lt_standard_table>.
    CHECK sy-subrc = 0 AND <lt_standard_table> IS NOT INITIAL.

    lt_evtscr = <lt_standard_table>.
    LOOP AT lt_evtscr INTO ls_evtscr.
      AT NEW event.
        MOVE-CORRESPONDING ls_evtscr TO ls_lcl_evtscr.
        CLEAR ls_code.
      ENDAT.

      IF ls_code-code IS INITIAL.
        ls_code-code = ls_evtscr-text.
      ELSE.
        CONCATENATE ls_code-code ls_evtscr-text INTO ls_code-code SEPARATED BY gc_crlf.
      ENDIF.

      AT END OF event.
        READ TABLE it_obj INTO ls_obj WITH KEY applid = ls_evtscr-applid
                                               field_id = ls_evtscr-field_id.
        IF sy-subrc = 0.
          CONCATENATE me->ms_item-obj_name
                      me->ms_item-obj_type
                      is_table_content-tabname INTO ls_lcl_evtscr-file_name SEPARATED BY '.'.

          REPLACE ALL OCCURRENCES OF '/' IN ls_lcl_evtscr-file_name WITH '#'.

          TRANSLATE ls_lcl_evtscr-file_name TO LOWER CASE.

          CONCATENATE ls_lcl_evtscr-file_name
                      ls_obj-field_name
                      ls_lcl_evtscr-event
                      'js' INTO ls_lcl_evtscr-file_name SEPARATED BY '.'.

          APPEND ls_lcl_evtscr TO lt_lcl_evtscr.

          ls_code-file_name = ls_lcl_evtscr-file_name.
          APPEND ls_code TO lt_code.
        ENDIF.

      ENDAT.
    ENDLOOP.

    TRY.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_evtscr ).

** loop at code table to add each entry as a file
        LOOP AT lt_code INTO ls_code.

          ls_file-path = '/'.

          ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( ls_code-code ).

          ls_file-filename = ls_code-file_name.

          zif_abapgit_object~mo_files->add( ls_file ).

        ENDLOOP.
      CATCH zcx_abapgit_exception.
    ENDTRY.

  ENDMETHOD.


  METHOD serialize_table.

    DATA: lo_ajson         TYPE REF TO zcl_abapgit_ajson,
          lx_ajson         TYPE REF TO zcx_abapgit_ajson_error,
          lv_json          TYPE string,
          ls_file          TYPE zif_abapgit_git_definitions=>ty_file.

    DATA lt_skip_paths TYPE string_table.

    CHECK it_table IS NOT INITIAL.

    TRY.
        lo_ajson = zcl_abapgit_ajson=>create_empty( ).
        lo_ajson->keep_item_order( ).
        lo_ajson->set(
          iv_path = '/'
          iv_val  = it_table ).

* Remove fields that have initial value
        lo_ajson = zcl_abapgit_ajson=>create_from(
          ii_source_json = lo_ajson
          ii_filter      = zcl_abapgit_ajson_filter_lib=>create_empty_filter( ) ).

* Remove unwanted fields
        lt_skip_paths = get_skip_fields( ).
        IF lt_skip_paths IS NOT INITIAL.
          lo_ajson = zcl_abapgit_ajson=>create_from(
            ii_source_json = lo_ajson
            ii_filter      = zcl_abapgit_ajson_filter_lib=>create_path_filter(
                                                             it_skip_paths     = lt_skip_paths
                                                             iv_pattern_search = abap_true ) ).
        ENDIF.

        lv_json = lo_ajson->stringify( 2 ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.

    ls_file-path = '/'.
    TRY.
        ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_json ).
      CATCH zcx_abapgit_exception.
    ENDTRY.
    ls_file-filename = zcl_abapgit_filename_logic=>object_to_file(
                           is_item  = ms_item
                           iv_extra = iv_tabname
                           iv_ext   = 'json' ).

    zif_abapgit_object~mo_files->add( ls_file ).

  ENDMETHOD.


  METHOD serialize__css.

    DATA ls_file TYPE zif_abapgit_git_definitions=>ty_file.
    DATA lv_code TYPE string.

    DATA lt_lcl_css TYPE ty_tt_lcl_css.
    DATA ls_lcl_css LIKE LINE OF lt_lcl_css.

    DATA lt_css TYPE STANDARD TABLE OF /neptune/_css_d WITH DEFAULT KEY.
    DATA ls_css LIKE LINE OF lt_css.

    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    ASSIGN is_table_content-table_content->* TO <lt_standard_table>.
    CHECK sy-subrc = 0 AND <lt_standard_table> IS NOT INITIAL.

    lt_css = <lt_standard_table>.

    SORT lt_css.

    READ TABLE lt_css INTO ls_css INDEX 1.
    CHECK sy-subrc = 0.

    MOVE-CORRESPONDING ls_css TO ls_lcl_css.

    LOOP AT lt_css INTO ls_css.
      IF lv_code IS INITIAL.
        lv_code = ls_css-text.
      ELSE.
        CONCATENATE lv_code ls_css-text INTO lv_code SEPARATED BY gc_crlf.
      ENDIF.
    ENDLOOP.

    CONCATENATE me->ms_item-obj_name
                me->ms_item-obj_type
                is_table_content-tabname
                'css' INTO ls_lcl_css-file_name SEPARATED BY '.'.

    REPLACE ALL OCCURRENCES OF '/' IN ls_lcl_css-file_name WITH '#'.

    TRANSLATE ls_lcl_css-file_name TO LOWER CASE.
    APPEND ls_lcl_css TO lt_lcl_css.
    TRY.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_css ).

** loop at code table to add each entry as a file
        ls_file-path = '/'.

        ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
      CATCH zcx_abapgit_exception.
    ENDTRY.
    ls_file-filename = ls_lcl_css-file_name.

    zif_abapgit_object~mo_files->add( ls_file ).

  ENDMETHOD.


  METHOD serialize__evtscr.

    DATA ls_file TYPE zif_abapgit_git_definitions=>ty_file.

    DATA lt_lcl_evtscr TYPE ty_tt_lcl_evtscr.
    DATA ls_lcl_evtscr LIKE LINE OF lt_lcl_evtscr.

    DATA lt_evtscr TYPE STANDARD TABLE OF /neptune/_evtscr WITH DEFAULT KEY.
    DATA ls_evtscr LIKE LINE OF lt_evtscr.

    DATA: lt_code TYPE ty_tt_code,
          ls_code LIKE LINE OF lt_code.

    DATA ls_obj LIKE LINE OF it_obj.

    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    ASSIGN is_table_content-table_content->* TO <lt_standard_table>.
    CHECK sy-subrc = 0 AND <lt_standard_table> IS NOT INITIAL.

    lt_evtscr = <lt_standard_table>.
    LOOP AT lt_evtscr INTO ls_evtscr.
      AT NEW event.
        MOVE-CORRESPONDING ls_evtscr TO ls_lcl_evtscr.
        CLEAR ls_code.
      ENDAT.

      IF ls_code-code IS INITIAL.
        ls_code-code = ls_evtscr-text.
      ELSE.
        CONCATENATE ls_code-code ls_evtscr-text INTO ls_code-code SEPARATED BY gc_crlf.
      ENDIF.

      AT END OF event.
        READ TABLE it_obj INTO ls_obj WITH KEY applid = ls_evtscr-applid
                                               field_id = ls_evtscr-field_id.
        IF sy-subrc = 0.
          CONCATENATE me->ms_item-obj_name
                      me->ms_item-obj_type
                      is_table_content-tabname INTO ls_lcl_evtscr-file_name SEPARATED BY '.'.

          REPLACE ALL OCCURRENCES OF '/' IN ls_lcl_evtscr-file_name WITH '#'.

          TRANSLATE ls_lcl_evtscr-file_name TO LOWER CASE.

          CONCATENATE ls_lcl_evtscr-file_name
                      ls_obj-field_name
                      ls_lcl_evtscr-event
                      'js' INTO ls_lcl_evtscr-file_name SEPARATED BY '.'.

          APPEND ls_lcl_evtscr TO lt_lcl_evtscr.

          ls_code-file_name = ls_lcl_evtscr-file_name.
          APPEND ls_code TO lt_code.
        ENDIF.

      ENDAT.
    ENDLOOP.

    TRY.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_evtscr ).

** loop at code table to add each entry as a file
        LOOP AT lt_code INTO ls_code.

          ls_file-path = '/'.

          ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( ls_code-code ).

          ls_file-filename = ls_code-file_name.

          zif_abapgit_object~mo_files->add( ls_file ).

        ENDLOOP.

      CATCH zcx_abapgit_exception.
    ENDTRY.

  ENDMETHOD.


  METHOD set_skip_fields.

    DATA lv_skip TYPE string.

    lv_skip = '*APPLID'.
    APPEND lv_skip TO mt_skip_paths.
    lv_skip = '*CREDAT'.
    APPEND lv_skip TO mt_skip_paths.
    lv_skip = '*CRETIM'.
    APPEND lv_skip TO mt_skip_paths.
    lv_skip = '*CRENAM'.
    APPEND lv_skip TO mt_skip_paths.
    lv_skip = '*UPDDAT'.
    APPEND lv_skip TO mt_skip_paths.
    lv_skip = '*UPDTIM'.
    APPEND lv_skip TO mt_skip_paths.
    lv_skip = '*UPDNAM'.
    APPEND lv_skip TO mt_skip_paths.


  ENDMETHOD.


  METHOD zif_abapgit_object~changed_by.

    DATA: lo_artifact TYPE REF TO /neptune/if_artifact_type,
          lt_table_content TYPE /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content LIKE LINE OF lt_table_content,
          lv_key           TYPE /neptune/artifact_key.

    DATA ls_app TYPE /neptune/app.

    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

    lv_key = me->ms_item-obj_name.

    lo_artifact->get_table_content(
      EXPORTING iv_key1          = lv_key
      IMPORTING et_table_content = lt_table_content ).

    READ TABLE lt_table_content INTO ls_table_content WITH TABLE KEY tabname = '/NEPTUNE/APP'.
    IF sy-subrc = 0.
      ASSIGN ls_table_content-table_content->* TO <lt_standard_table>.
      CHECK sy-subrc = 0.
      READ TABLE <lt_standard_table> INTO ls_app INDEX 1.
      CHECK sy-subrc = 0.
      IF ls_app-updnam IS NOT INITIAL.
        rv_user = ls_app-updnam.
      ELSE.
        rv_user = ls_app-crenam.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD zif_abapgit_object~delete.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_object~deserialize.
** pick up logic from CLASS ZCL_ABAPGIT_DATA_DESERIALIZER

    DATA: lt_files TYPE zif_abapgit_git_definitions=>ty_files_tt,
          ls_files LIKE LINE OF lt_files.

    DATA: lt_table_content TYPE /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content LIKE LINE OF lt_table_content.

    DATA lr_data    TYPE REF TO data.
    DATA lv_tabname TYPE tadir-obj_name.
    DATA lv_key     TYPE /neptune/artifact_key.

    DATA lo_artifact TYPE REF TO /neptune/if_artifact_type.

**********************************************************************

    lt_files = zif_abapgit_object~mo_files->get_files( ).

    LOOP AT lt_files INTO ls_files WHERE filename CS '.json'.

      get_values_from_filename(
        EXPORTING
          is_filename = ls_files-filename
        IMPORTING
          ev_tabname  = lv_tabname
          ev_obj_key  = lv_key ).

      CREATE DATA lr_data TYPE STANDARD TABLE OF (lv_tabname) WITH NON-UNIQUE DEFAULT KEY.

      CASE lv_tabname.
        WHEN '/NEPTUNE/EVTSCR'.

          deserialize_evtscr(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).


        WHEN '/NEPTUNE/_EVTSCR'.

          deserialize__evtscr(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        WHEN '/NEPTUNE/CSS'.

          deserialize_css(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        WHEN '/NEPTUNE/_CSS_D' OR
             '/NEPTUNE/_CSS_P' OR
             '/NEPTUNE/_CSS_T'.

          deserialize__css(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        WHEN OTHERS.

          deserialize_table(
            is_file    = ls_files
            iv_tabname = lv_tabname
            iv_key     = lv_key
            ir_data    = lr_data ).

      ENDCASE.

      ls_table_content-tabname = lv_tabname.
      ls_table_content-table_content = lr_data.
      APPEND ls_table_content TO lt_table_content.
      CLEAR ls_table_content.


    ENDLOOP.

    IF lt_table_content IS NOT INITIAL.

      lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

      lo_artifact->set_table_content(
        iv_key1                 = lv_key
        it_insert_table_content = lt_table_content ).

    ENDIF.

  ENDMETHOD.


  METHOD zif_abapgit_object~exists.
    rv_bool = abap_true.
  ENDMETHOD.


  METHOD zif_abapgit_object~get_comparator.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_object~get_deserialize_order.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_object~get_deserialize_steps.
    APPEND zif_abapgit_object=>gc_step_id-late TO rt_steps.
  ENDMETHOD.


  METHOD zif_abapgit_object~get_metadata.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_object~is_active.
    rv_active = abap_true.
  ENDMETHOD.


  METHOD zif_abapgit_object~is_locked.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_object~jump.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_object~map_filename_to_object.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_object~map_object_to_filename.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_object~serialize.

    DATA: lo_artifact      TYPE REF TO /neptune/if_artifact_type,
          lt_table_content TYPE /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content LIKE LINE OF lt_table_content,
          lv_key           TYPE /neptune/artifact_key.

    DATA lt_obj TYPE STANDARD TABLE OF /neptune/obj WITH DEFAULT KEY.

    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

    lv_key = ms_item-obj_name.

    lo_artifact->get_table_content(
      EXPORTING iv_key1          = lv_key
      IMPORTING et_table_content = lt_table_content ).

* Save OBJ Table so we can read the name of objects with the FIELD_ID
    READ TABLE lt_table_content INTO ls_table_content WITH KEY tabname = '/NEPTUNE/OBJ'.
    IF sy-subrc = 0.
      ASSIGN ls_table_content-table_content->* TO <lt_standard_table>.
      CHECK sy-subrc = 0.
      lt_obj = <lt_standard_table>.
    ENDIF.

* set fields that will be skipped in the serialization process
    set_skip_fields( ).

* serialize
    LOOP AT lt_table_content INTO ls_table_content.

      CASE ls_table_content-tabname.
        WHEN '/NEPTUNE/EVTSCR'.

          serialize_evtscr(
            it_obj           = lt_obj
            is_table_content = ls_table_content ).

        WHEN '/NEPTUNE/_EVTSCR'.

          serialize__evtscr(
            it_obj           = lt_obj
            is_table_content = ls_table_content ).

        WHEN '/NEPTUNE/CSS'.

          serialize_css( is_table_content = ls_table_content ).

        WHEN '/NEPTUNE/_CSS_D' OR
             '/NEPTUNE/_CSS_P' OR
             '/NEPTUNE/_CSS_T'.

          serialize__css( is_table_content = ls_table_content ).

        WHEN OTHERS.

          ASSIGN ls_table_content-table_content->* TO <lt_standard_table>.

          CHECK sy-subrc = 0 AND <lt_standard_table> IS NOT INITIAL.

          serialize_table(
            iv_tabname = ls_table_content-tabname
            it_table   = <lt_standard_table> ).

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
