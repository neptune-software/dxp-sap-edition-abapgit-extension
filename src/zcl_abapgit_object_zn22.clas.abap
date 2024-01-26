CLASS zcl_abapgit_object_zn22 DEFINITION
  PUBLIC
  INHERITING FROM zcl_abapgit_objects_super
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abapgit_object .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_lcl_cushead,
                    configuration TYPE /neptune/cushead-configuration,
                    file_name     TYPE string,
                   END OF ty_lcl_cushead .
    TYPES:
      ty_tt_lcl_cushead TYPE STANDARD TABLE OF ty_lcl_cushead .
    TYPES:
      BEGIN OF ty_lcl_cuslogi,
                    configuration TYPE /neptune/cuslogi-configuration,
                    file_name     TYPE string,
                   END OF ty_lcl_cuslogi .
    TYPES:
      ty_tt_lcl_cuslogi TYPE STANDARD TABLE OF ty_lcl_cuslogi .
    TYPES:
      BEGIN OF ty_lcl_confxml,
                    configuration TYPE /neptune/confxml-configuration,
                    file_name     TYPE string,
                   END OF ty_lcl_confxml .
    TYPES:
      ty_tt_lcl_confxml TYPE STANDARD TABLE OF ty_lcl_confxml .

    DATA mv_artifact_type TYPE /neptune/artifact_type .

    METHODS serialize_cushead
      IMPORTING
      !is_table_content TYPE /neptune/if_artifact_type=>ty_table_content
      RAISING
      zcx_abapgit_exception .
    METHODS serialize_confxml
      IMPORTING
      !is_table_content TYPE /neptune/if_artifact_type=>ty_table_content
      RAISING
      zcx_abapgit_exception .
    METHODS serialize_appcach
      IMPORTING
      !is_table_content TYPE /neptune/if_artifact_type=>ty_table_content
      RAISING
      zcx_abapgit_exception .
    METHODS serialize_cuslogi
      IMPORTING
      !is_table_content TYPE /neptune/if_artifact_type=>ty_table_content
      RAISING
      zcx_abapgit_exception .
    METHODS serialize_table
      IMPORTING
      !iv_tabname TYPE tabname
      !it_table TYPE any
      RAISING
      zcx_abapgit_exception .
    METHODS deserialize_table
      IMPORTING
      !is_file TYPE zif_abapgit_git_definitions=>ty_file
      !ir_data TYPE REF TO data
      !iv_key TYPE /neptune/artifact_key
      RAISING
      zcx_abapgit_exception .
    METHODS get_values_from_filename
      IMPORTING
      !is_filename TYPE string
      EXPORTING
      !ev_tabname TYPE tadir-obj_name .
    METHODS deserialize_cushead
      IMPORTING
      !is_file TYPE zif_abapgit_git_definitions=>ty_file
      !it_files TYPE zif_abapgit_git_definitions=>ty_files_tt
      !ir_data TYPE REF TO data
      !iv_key TYPE /neptune/artifact_key
      RAISING
      zcx_abapgit_exception .
    METHODS deserialize_confxml
      IMPORTING
      !is_file TYPE zif_abapgit_git_definitions=>ty_file
      !it_files TYPE zif_abapgit_git_definitions=>ty_files_tt
      !ir_data TYPE REF TO data
      !iv_key TYPE /neptune/artifact_key
      RAISING
      zcx_abapgit_exception .
    METHODS deserialize_appcach
      IMPORTING
      !is_file TYPE zif_abapgit_git_definitions=>ty_file
      !it_files TYPE zif_abapgit_git_definitions=>ty_files_tt
      !ir_data TYPE REF TO data
      !iv_key TYPE /neptune/artifact_key
      RAISING
      zcx_abapgit_exception .
    METHODS deserialize_cuslogi
      IMPORTING
      !is_file TYPE zif_abapgit_git_definitions=>ty_file
      !it_files TYPE zif_abapgit_git_definitions=>ty_files_tt
      !ir_data TYPE REF TO data
      !iv_key TYPE /neptune/artifact_key
      RAISING
      zcx_abapgit_exception .
    METHODS insert_to_transport
      IMPORTING
      !io_artifact TYPE REF TO /neptune/if_artifact_type
      !iv_transport TYPE trkorr
      !iv_package TYPE devclass
      !iv_key1 TYPE any
      !iv_artifact_type TYPE /neptune/aty-artifact_type .
ENDCLASS.



CLASS zcl_abapgit_object_zn22 IMPLEMENTATION.


  METHOD deserialize_appcach.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    DATA ls_file LIKE LINE OF it_files.

    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.
    FIELD-SYMBOLS <ls_line> TYPE any.
    FIELD-SYMBOLS <lv_code> TYPE any.
    FIELD-SYMBOLS <lv_field> TYPE any.

    ASSIGN ir_data->* TO <lt_tab>.
    CHECK sy-subrc = 0.

    TRY.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( EXPORTING iv_corresponding = abap_true
                                             IMPORTING ev_container     = <lt_tab> ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.

    LOOP AT <lt_tab> ASSIGNING <ls_line>.

      ASSIGN COMPONENT 'CONFIGURATION' OF STRUCTURE <ls_line> TO <lv_field>.
      IF <lv_field> IS ASSIGNED.
        <lv_field> = iv_key.
        TRANSLATE <lv_field> TO UPPER CASE.
        UNASSIGN <lv_field>.
      ENDIF.

      ASSIGN COMPONENT 'GLOBAL_STYLE' OF STRUCTURE <ls_line> TO <lv_code>.
      IF <lv_code> IS ASSIGNED AND <lv_code> IS NOT INITIAL.

        READ TABLE it_files INTO ls_file WITH KEY filename = <lv_code>.
        IF sy-subrc = 0.
          <lv_code> = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).
          zcl_neptune_abapgit_utilities=>fix_string_deserialize( CHANGING cv_string = <lv_code> ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD deserialize_confxml.

    DATA lt_lcl_confxml TYPE ty_tt_lcl_confxml.
    DATA ls_lcl_confxml LIKE LINE OF lt_lcl_confxml.

    DATA lt_confxml TYPE STANDARD TABLE OF /neptune/confxml WITH DEFAULT KEY.
    DATA ls_confxml LIKE LINE OF lt_confxml.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    DATA ls_file LIKE LINE OF it_files.

    DATA lt_code TYPE string_table.
    DATA lv_code TYPE string.

    DATA lv_seqnr TYPE /neptune/confxml-seqnr VALUE 0.

    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.

    ASSIGN ir_data->* TO <lt_tab>.
    CHECK sy-subrc = 0.

    TRY.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( IMPORTING ev_container = lt_lcl_confxml ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.

    LOOP AT lt_lcl_confxml INTO ls_lcl_confxml.

      MOVE-CORRESPONDING ls_lcl_confxml TO ls_confxml.

      READ TABLE it_files INTO ls_file WITH KEY filename = ls_lcl_confxml-file_name.
      IF sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

        lt_code = zcl_neptune_abapgit_utilities=>string_to_code_lines( iv_string = lv_code ).

        LOOP AT lt_code INTO lv_code.
          lv_seqnr = lv_seqnr + 1.

          ls_confxml-configuration = iv_key.
          ls_confxml-seqnr         = lv_seqnr.
          ls_confxml-value         = lv_code.

          APPEND ls_confxml TO lt_confxml.
        ENDLOOP.


      ENDIF.
    ENDLOOP.

    <lt_tab> = lt_confxml.

  ENDMETHOD.


  METHOD deserialize_cushead.

    DATA lt_lcl_cushead TYPE ty_tt_lcl_cushead.
    DATA ls_lcl_cushead LIKE LINE OF lt_lcl_cushead.

    DATA lt_cushead TYPE STANDARD TABLE OF /neptune/cushead WITH DEFAULT KEY.
    DATA ls_cushead LIKE LINE OF lt_cushead.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    DATA ls_file LIKE LINE OF it_files.

    DATA lt_code TYPE string_table.
    DATA lv_code TYPE string.

    DATA lv_seqnr TYPE /neptune/cushead-seqnr VALUE 0.

    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.

    ASSIGN ir_data->* TO <lt_tab>.
    CHECK sy-subrc = 0.

    TRY.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( IMPORTING ev_container = lt_lcl_cushead ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.

    LOOP AT lt_lcl_cushead INTO ls_lcl_cushead.

      MOVE-CORRESPONDING ls_lcl_cushead TO ls_cushead.

      READ TABLE it_files INTO ls_file WITH KEY filename = ls_lcl_cushead-file_name.
      IF sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

        lt_code = zcl_neptune_abapgit_utilities=>string_to_code_lines( iv_string = lv_code ).

        LOOP AT lt_code INTO lv_code.
          lv_seqnr = lv_seqnr + 1.

          ls_cushead-configuration = iv_key.
          ls_cushead-seqnr         = lv_seqnr.
          ls_cushead-text          = lv_code.

          APPEND ls_cushead TO lt_cushead.
        ENDLOOP.

      ENDIF.
    ENDLOOP.

    <lt_tab> = lt_cushead.

  ENDMETHOD.


  METHOD deserialize_cuslogi.

    DATA lt_lcl_cuslogi TYPE ty_tt_lcl_cuslogi.
    DATA ls_lcl_cuslogi LIKE LINE OF lt_lcl_cuslogi.

    DATA lt_cuslogi TYPE STANDARD TABLE OF /neptune/cuslogi WITH DEFAULT KEY.
    DATA ls_cuslogi LIKE LINE OF lt_cuslogi.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    DATA ls_file LIKE LINE OF it_files.

    DATA lt_code TYPE string_table.
    DATA lv_code TYPE string.

    DATA lv_seqnr TYPE /neptune/cuslogi-seqnr VALUE 0.

    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.

    ASSIGN ir_data->* TO <lt_tab>.
    CHECK sy-subrc = 0.

    TRY.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( IMPORTING ev_container = lt_lcl_cuslogi ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.

    LOOP AT lt_lcl_cuslogi INTO ls_lcl_cuslogi.

      MOVE-CORRESPONDING ls_lcl_cuslogi TO ls_cuslogi.

      READ TABLE it_files INTO ls_file WITH KEY filename = ls_lcl_cuslogi-file_name.
      IF sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

        lt_code = zcl_neptune_abapgit_utilities=>string_to_code_lines( iv_string = lv_code ).

        LOOP AT lt_code INTO lv_code.
          lv_seqnr = lv_seqnr + 1.

          ls_cuslogi-configuration = iv_key.
          ls_cuslogi-seqnr         = lv_seqnr.
          ls_cuslogi-text          = lv_code.

          APPEND ls_cuslogi TO lt_cuslogi.
        ENDLOOP.


      ENDIF.
    ENDLOOP.

    <lt_tab> = lt_cuslogi.

  ENDMETHOD.


  METHOD deserialize_table.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.
    FIELD-SYMBOLS <ls_line> TYPE any.
    FIELD-SYMBOLS <lv_field> TYPE any.

    ASSIGN ir_data->* TO <lt_tab>.
    CHECK sy-subrc = 0.

    TRY.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( EXPORTING iv_corresponding = abap_true
                                             IMPORTING ev_container     = <lt_tab> ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.


    LOOP AT <lt_tab> ASSIGNING <ls_line>.
      ASSIGN COMPONENT 'CONFIGURATION' OF STRUCTURE <ls_line> TO <lv_field>.
      IF <lv_field> IS ASSIGNED.
        <lv_field> = iv_key.
        TRANSLATE <lv_field> TO UPPER CASE.
        UNASSIGN <lv_field>.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_values_from_filename.

    DATA lt_comp TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA ls_comp LIKE LINE OF lt_comp.

    SPLIT is_filename AT '.' INTO TABLE lt_comp.

    READ TABLE lt_comp INTO ls_comp INDEX 3.
    IF sy-subrc = 0.
      REPLACE ALL OCCURRENCES OF '#' IN ls_comp WITH '/'.
      TRANSLATE ls_comp TO UPPER CASE.
      ev_tabname = ls_comp.
    ENDIF.

  ENDMETHOD.


  METHOD insert_to_transport.

    DATA ls_message TYPE /neptune/message.
    DATA lv_task TYPE trkorr.

    /neptune/cl_nad_transport=>transport_task_find(
      EXPORTING
        transport = iv_transport
      IMPORTING
        task      = lv_task ).

    io_artifact->insert_to_transport(
      EXPORTING
        iv_korrnum = lv_task
        iv_key1    = iv_key1
      IMPORTING
        ev_message = ls_message ).

    TRY.
        CALL METHOD ('/NEPTUNE/CL_TADIR')=>('INSERT_TO_TRANSPORT')
*            call method /neptune/cl_tadir=>insert_to_transport
            EXPORTING
              iv_korrnum       = lv_task
              iv_devclass      = iv_package
              iv_artifact_key  = iv_key1
              iv_artifact_type = iv_artifact_type
            IMPORTING
              ev_message      = ls_message.
      CATCH cx_sy_dyn_call_illegal_class
            cx_sy_dyn_call_illegal_method.
    ENDTRY.

  ENDMETHOD.


  METHOD serialize_appcach.

    DATA ls_file TYPE zif_abapgit_git_definitions=>ty_file.

    DATA lt_appcach TYPE STANDARD TABLE OF /neptune/appcach WITH DEFAULT KEY.

    DATA lv_message TYPE string.

    FIELD-SYMBOLS <lr_object_files> TYPE REF TO zcl_abapgit_objects_files.
    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_line> TYPE any.
    FIELD-SYMBOLS <lv_code> TYPE any.

    ASSIGN is_table_content-table_content->* TO <lt_standard_table>.
    CHECK sy-subrc = 0 AND <lt_standard_table> IS NOT INITIAL.

    lt_appcach = <lt_standard_table>.

    LOOP AT <lt_standard_table> ASSIGNING <ls_line>.

      ASSIGN COMPONENT 'GLOBAL_STYLE' OF STRUCTURE <ls_line> TO <lv_code>.
      IF <lv_code> IS ASSIGNED AND <lv_code> IS NOT INITIAL.

        CONCATENATE me->ms_item-obj_name
                    me->ms_item-obj_type
                    is_table_content-tabname INTO ls_file-filename SEPARATED BY '.'.

        REPLACE ALL OCCURRENCES OF '/' IN ls_file-filename WITH '#'.

        CONCATENATE ls_file-filename
                    'css' INTO ls_file-filename SEPARATED BY '.'.

        TRANSLATE ls_file-filename TO LOWER CASE.

        TRY.
            ls_file-path = '/'.

            zcl_neptune_abapgit_utilities=>fix_string_serialize( CHANGING cv_string = <lv_code> ).
            ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( <lv_code> ).

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*            zif_abapgit_object~mo_files->add( ls_file ).
            " for version 1.125.0
            ASSIGN ('ZIF_ABAPGIT_OBJECT~MO_FILES') TO <lr_object_files>.
            IF <lr_object_files> IS NOT ASSIGNED.
              " for version 1.126.0
              ASSIGN ('MO_FILES') TO <lr_object_files>.
            ENDIF.

            IF <lr_object_files> IS ASSIGNED.
              CALL METHOD <lr_object_files>->add
                EXPORTING
                  is_file = ls_file.
            ELSE.
              CONCATENATE 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname INTO lv_message SEPARATED BY space.
              zcx_abapgit_exception=>raise( lv_message ).
            ENDIF.

          CATCH zcx_abapgit_exception.
        ENDTRY.

        <lv_code> = ls_file-filename.
      ENDIF.
    ENDLOOP.

    TRY.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = <lt_standard_table> ).

      CATCH zcx_abapgit_exception.
    ENDTRY.

  ENDMETHOD.


  METHOD serialize_confxml.

    DATA ls_file TYPE zif_abapgit_git_definitions=>ty_file.

    DATA lt_lcl_confxml TYPE ty_tt_lcl_confxml.
    DATA ls_lcl_confxml LIKE LINE OF lt_lcl_confxml.

    DATA lt_confxml TYPE STANDARD TABLE OF /neptune/confxml WITH DEFAULT KEY.
    DATA ls_confxml LIKE LINE OF lt_confxml.

    DATA lv_code TYPE string.

    DATA lt_code_lines TYPE string_table.

    DATA lv_message TYPE string.

    FIELD-SYMBOLS <lr_object_files> TYPE REF TO zcl_abapgit_objects_files.
    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    ASSIGN is_table_content-table_content->* TO <lt_standard_table>.
    CHECK sy-subrc = 0 AND <lt_standard_table> IS NOT INITIAL.

    lt_confxml = <lt_standard_table>.

    LOOP AT lt_confxml INTO ls_confxml.
      IF sy-tabix EQ 1.
        MOVE-CORRESPONDING ls_confxml TO ls_lcl_confxml.
        CLEAR lv_code.
      ENDIF.

      APPEND ls_confxml-value  TO lt_code_lines.

    ENDLOOP.

    CONCATENATE me->ms_item-obj_name
                me->ms_item-obj_type
                is_table_content-tabname INTO ls_lcl_confxml-file_name SEPARATED BY '.'.

    REPLACE ALL OCCURRENCES OF '/' IN ls_lcl_confxml-file_name WITH '#'.

    TRANSLATE ls_lcl_confxml-file_name TO LOWER CASE.

    CONCATENATE ls_lcl_confxml-file_name
                'xml' INTO ls_lcl_confxml-file_name SEPARATED BY '.'.

    APPEND ls_lcl_confxml TO lt_lcl_confxml.

    TRY.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_confxml ).

        ls_file-path = '/'.
        lv_code = zcl_neptune_abapgit_utilities=>code_lines_to_string( it_code_lines = lt_code_lines ).
        CLEAR: lt_code_lines.
        ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
        ls_file-filename = ls_lcl_confxml-file_name.

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*        zif_abapgit_object~mo_files->add( ls_file ).
        " for version 1.125.0
        ASSIGN ('ZIF_ABAPGIT_OBJECT~MO_FILES') TO <lr_object_files>.
        IF <lr_object_files> IS NOT ASSIGNED.
          " for version 1.126.0
          ASSIGN ('MO_FILES') TO <lr_object_files>.
        ENDIF.

        IF <lr_object_files> IS ASSIGNED.
          CALL METHOD <lr_object_files>->add
            EXPORTING
              is_file = ls_file.
        ELSE.
          CONCATENATE 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname INTO lv_message SEPARATED BY space.
          zcx_abapgit_exception=>raise( lv_message ).
        ENDIF.

      CATCH zcx_abapgit_exception.
    ENDTRY.

  ENDMETHOD.


  METHOD serialize_cushead.

    DATA ls_file TYPE zif_abapgit_git_definitions=>ty_file.

    DATA lt_lcl_cushead TYPE ty_tt_lcl_cushead.
    DATA ls_lcl_cushead LIKE LINE OF lt_lcl_cushead.

    DATA lt_cushead TYPE STANDARD TABLE OF /neptune/cushead WITH DEFAULT KEY.
    DATA ls_cushead LIKE LINE OF lt_cushead.

    DATA lv_code TYPE string.

    DATA lt_code_lines TYPE string_table.

    DATA lv_message TYPE string.

    FIELD-SYMBOLS <lr_object_files> TYPE REF TO zcl_abapgit_objects_files.
    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    ASSIGN is_table_content-table_content->* TO <lt_standard_table>.
    CHECK sy-subrc = 0 AND <lt_standard_table> IS NOT INITIAL.

    lt_cushead = <lt_standard_table>.

    LOOP AT lt_cushead INTO ls_cushead.
      IF sy-tabix EQ 1.
        MOVE-CORRESPONDING ls_cushead TO ls_lcl_cushead.
        CLEAR lv_code.
      ENDIF.

      APPEND ls_cushead-text  TO lt_code_lines.
    ENDLOOP.

    CONCATENATE me->ms_item-obj_name
                me->ms_item-obj_type
                is_table_content-tabname INTO ls_lcl_cushead-file_name SEPARATED BY '.'.

    REPLACE ALL OCCURRENCES OF '/' IN ls_lcl_cushead-file_name WITH '#'.

    TRANSLATE ls_lcl_cushead-file_name TO LOWER CASE.

    CONCATENATE ls_lcl_cushead-file_name
                'html' INTO ls_lcl_cushead-file_name SEPARATED BY '.'.

    APPEND ls_lcl_cushead TO lt_lcl_cushead.

    TRY.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_cushead ).

        ls_file-path = '/'.
        lv_code = zcl_neptune_abapgit_utilities=>code_lines_to_string( it_code_lines = lt_code_lines ).
        CLEAR: lt_code_lines.
        ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
        ls_file-filename = ls_lcl_cushead-file_name.

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*        zif_abapgit_object~mo_files->add( ls_file ).
        " for version 1.125.0
        ASSIGN ('ZIF_ABAPGIT_OBJECT~MO_FILES') TO <lr_object_files>.
        IF <lr_object_files> IS NOT ASSIGNED.
          " for version 1.126.0
          ASSIGN ('MO_FILES') TO <lr_object_files>.
        ENDIF.

        IF <lr_object_files> IS ASSIGNED.
          CALL METHOD <lr_object_files>->add
            EXPORTING
              is_file = ls_file.
        ELSE.
          CONCATENATE 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname INTO lv_message SEPARATED BY space.
          zcx_abapgit_exception=>raise( lv_message ).
        ENDIF.

      CATCH zcx_abapgit_exception.
    ENDTRY.

  ENDMETHOD.


  METHOD serialize_cuslogi.

    DATA ls_file TYPE zif_abapgit_git_definitions=>ty_file.

    DATA lt_lcl_cuslogi TYPE ty_tt_lcl_cuslogi.
    DATA ls_lcl_cuslogi LIKE LINE OF lt_lcl_cuslogi.

    DATA lt_cuslogi TYPE STANDARD TABLE OF /neptune/cuslogi WITH DEFAULT KEY.
    DATA ls_cuslogi LIKE LINE OF lt_cuslogi.

    DATA lv_code TYPE string.

    DATA lt_code_lines TYPE string_table.

    DATA lv_message TYPE string.

    FIELD-SYMBOLS <lr_object_files> TYPE REF TO zcl_abapgit_objects_files.

    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    ASSIGN is_table_content-table_content->* TO <lt_standard_table>.
    CHECK sy-subrc = 0 AND <lt_standard_table> IS NOT INITIAL.

    lt_cuslogi = <lt_standard_table>.

    LOOP AT lt_cuslogi INTO ls_cuslogi.
      IF sy-tabix EQ 1.
        MOVE-CORRESPONDING ls_cuslogi TO ls_lcl_cuslogi.
        CLEAR lv_code.
      ENDIF.

      APPEND ls_cuslogi-text  TO lt_code_lines.

    ENDLOOP.

    CONCATENATE me->ms_item-obj_name
                me->ms_item-obj_type
                is_table_content-tabname INTO ls_lcl_cuslogi-file_name SEPARATED BY '.'.

    REPLACE ALL OCCURRENCES OF '/' IN ls_lcl_cuslogi-file_name WITH '#'.

    TRANSLATE ls_lcl_cuslogi-file_name TO LOWER CASE.

    CONCATENATE ls_lcl_cuslogi-file_name
                'js' INTO ls_lcl_cuslogi-file_name SEPARATED BY '.'.

    APPEND ls_lcl_cuslogi TO lt_lcl_cuslogi.

    TRY.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_cuslogi ).

        ls_file-path = '/'.
        lv_code = zcl_neptune_abapgit_utilities=>code_lines_to_string( it_code_lines = lt_code_lines ).
        CLEAR: lt_code_lines.

        ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
        ls_file-filename = ls_lcl_cuslogi-file_name.

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*        zif_abapgit_object~mo_files->add( ls_file ).
        " for version 1.125.0
        ASSIGN ('ZIF_ABAPGIT_OBJECT~MO_FILES') TO <lr_object_files>.
        IF <lr_object_files> IS NOT ASSIGNED.
          " for version 1.126.0
          ASSIGN ('MO_FILES') TO <lr_object_files>.
        ENDIF.

        IF <lr_object_files> IS ASSIGNED.
          CALL METHOD <lr_object_files>->add
            EXPORTING
              is_file = ls_file.
        ELSE.
          CONCATENATE 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname INTO lv_message SEPARATED BY space.
          zcx_abapgit_exception=>raise( lv_message ).
        ENDIF.

      CATCH zcx_abapgit_exception.
    ENDTRY.

  ENDMETHOD.


  METHOD serialize_table.

    DATA: lo_ajson         TYPE REF TO zcl_abapgit_ajson,
          lx_ajson         TYPE REF TO zcx_abapgit_ajson_error,
          lv_json          TYPE string,
          ls_file          TYPE zif_abapgit_git_definitions=>ty_file.

    DATA lt_skip_paths TYPE string_table.

    DATA lv_message TYPE string.

    FIELD-SYMBOLS <lr_object_files> TYPE REF TO zcl_abapgit_objects_files.

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
        lt_skip_paths = zcl_neptune_abapgit_utilities=>get_skip_fields_for_artifact(
                                                          iv_artifact_type = mv_artifact_type
                                                          iv_serialize     = abap_true ).
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
    ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_json ).
    ls_file-filename = zcl_abapgit_filename_logic=>object_to_file(
                           is_item  = ms_item
                           iv_extra = iv_tabname
                           iv_ext   = 'json' ).

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*    zif_abapgit_object~mo_files->add( ls_file ).
    " for version 1.125.0
    ASSIGN ('ZIF_ABAPGIT_OBJECT~MO_FILES') TO <lr_object_files>.
    IF <lr_object_files> IS NOT ASSIGNED.
      " for version 1.126.0
      ASSIGN ('MO_FILES') TO <lr_object_files>.
    ENDIF.

    IF <lr_object_files> IS ASSIGNED.
      CALL METHOD <lr_object_files>->add
        EXPORTING
          is_file = ls_file.
    ELSE.
      CONCATENATE 'Error serializing' ms_item-obj_type ms_item-obj_name iv_tabname INTO lv_message SEPARATED BY space.
      zcx_abapgit_exception=>raise( lv_message ).
    ENDIF.

  ENDMETHOD.


  METHOD zif_abapgit_object~changed_by.

    DATA: lo_artifact TYPE REF TO /neptune/if_artifact_type,
          lt_table_content TYPE /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content LIKE LINE OF lt_table_content,
          lv_key           TYPE /neptune/artifact_key.

    DATA ls_appcach TYPE /neptune/appcach.

    DATA: lv_crenam TYPE /neptune/create_user,
          lv_credat TYPE /neptune/create_date,
          lv_cretim TYPE /neptune/create_time,
          lv_updnam TYPE /neptune/update_user,
          lv_upddat TYPE /neptune/update_date,
          lv_updtim TYPE /neptune/update_time.

    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

    lv_key = ms_item-obj_name.

    TRY.
        CALL METHOD lo_artifact->('GET_METADATA')
          EXPORTING
            iv_key1   = lv_key
          IMPORTING
            ev_crenam = lv_crenam
            ev_credat = lv_credat
            ev_cretim = lv_cretim
            ev_updnam = lv_updnam
            ev_upddat = lv_upddat
            ev_updtim = lv_updtim.

        IF lv_upddat IS NOT INITIAL.
          rv_user = lv_updnam.
        ELSE.
          rv_user = lv_crenam.
        ENDIF.

      CATCH cx_sy_dyn_call_illegal_class
            cx_sy_dyn_call_illegal_method.

        lo_artifact->get_table_content(
          EXPORTING iv_key1                 = lv_key
                    iv_only_sys_independent = abap_true
          IMPORTING et_table_content        = lt_table_content ).

        READ TABLE lt_table_content INTO ls_table_content WITH TABLE KEY tabname = '/NEPTUNE/APPCACH'.
        IF sy-subrc = 0.
          ASSIGN ls_table_content-table_content->* TO <lt_standard_table>.
          CHECK sy-subrc = 0.
          READ TABLE <lt_standard_table> INTO ls_appcach INDEX 1.
          IF sy-subrc = 0 AND ls_appcach-updnam IS NOT INITIAL.
            rv_user = ls_appcach-updnam.
          ELSE.
            rv_user = ls_appcach-crenam.
          ENDIF.
        ENDIF.

    ENDTRY.

  ENDMETHOD.


  METHOD zif_abapgit_object~delete.

    DATA: lo_artifact TYPE REF TO /neptune/if_artifact_type,
          ls_settings TYPE /neptune/aty,
          lv_key1     TYPE /neptune/artifact_key.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    ls_settings = lo_artifact->get_settings( ).

    lv_key1 = ms_item-obj_name.

    lo_artifact->delete_artifact(
      iv_key1     = lv_key1
      iv_devclass = iv_package ).

    lo_artifact->delete_tadir_entry( iv_key1 = lv_key1 ).

    IF ls_settings-transportable IS NOT INITIAL AND iv_transport IS NOT INITIAL.

      insert_to_transport(
        io_artifact      = lo_artifact
        iv_transport     = iv_transport
        iv_package       = iv_package
        iv_key1          = lv_key1
        iv_artifact_type = ls_settings-artifact_type ).

    ENDIF.

  ENDMETHOD.


  METHOD zif_abapgit_object~deserialize.

    DATA lo_artifact TYPE REF TO /neptune/if_artifact_type.
    DATA ls_settings TYPE /neptune/aty.

    DATA: lt_files TYPE zif_abapgit_git_definitions=>ty_files_tt,
          ls_files LIKE LINE OF lt_files.

    DATA: lt_table_content TYPE /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content LIKE LINE OF lt_table_content.

    DATA lt_system_field_values TYPE /neptune/if_artifact_type=>ty_t_system_field_values.

    DATA lr_data    TYPE REF TO data.
    DATA lv_tabname TYPE tadir-obj_name.
    DATA lv_key     TYPE /neptune/artifact_key.
    DATA lv_message TYPE string.

    FIELD-SYMBOLS <lr_object_files> TYPE REF TO zcl_abapgit_objects_files.

    TRY.
        io_xml->read(
          EXPORTING
            iv_name = 'key'
          CHANGING
            cg_data = lv_key ).
      CATCH zcx_abapgit_exception.
    ENDTRY.

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->GET_FILES does not work anymore
*    lt_files = zif_abapgit_object~mo_files->get_files( ).
    " for version 1.125.0
    ASSIGN ('ZIF_ABAPGIT_OBJECT~MO_FILES') TO <lr_object_files>.
    IF <lr_object_files> IS NOT ASSIGNED.
      " for version 1.126.0
      ASSIGN ('MO_FILES') TO <lr_object_files>.
    ENDIF.

    IF <lr_object_files> IS ASSIGNED.
      CALL METHOD <lr_object_files>->get_files
        RECEIVING
          rt_files = lt_files.
    ELSE.
      CONCATENATE 'Error deserializing' ms_item-obj_type  ms_item-obj_name lv_key INTO lv_message SEPARATED BY space.
      zcx_abapgit_exception=>raise( lv_message ).
    ENDIF.

    LOOP AT lt_files INTO ls_files WHERE filename CP '*.json'.

      get_values_from_filename(
        EXPORTING
          is_filename = ls_files-filename
        IMPORTING
          ev_tabname  = lv_tabname ).

      CREATE DATA lr_data TYPE STANDARD TABLE OF (lv_tabname) WITH NON-UNIQUE DEFAULT KEY.

      CASE lv_tabname.
        WHEN '/NEPTUNE/CUSHEAD'.
          deserialize_cushead(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        WHEN '/NEPTUNE/CUSLOGI'.
          deserialize_cushead(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        WHEN '/NEPTUNE/CONFXML'.
          deserialize_confxml(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        WHEN '/NEPTUNE/APPCACH'.
          deserialize_appcach(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        WHEN OTHERS.
          deserialize_table(
            is_file = ls_files
            iv_key  = lv_key
            ir_data = lr_data ).
      ENDCASE.


      ls_table_content-tabname = lv_tabname.
      ls_table_content-table_content = lr_data.
      APPEND ls_table_content TO lt_table_content.
      CLEAR ls_table_content.

    ENDLOOP.

    IF lt_table_content IS NOT INITIAL.

      lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
      ls_settings = lo_artifact->get_settings( ).

      lo_artifact->delete_artifact(
        EXPORTING
          iv_key1                = lv_key
          iv_devclass            = iv_package
        IMPORTING
          et_system_field_values = lt_system_field_values ).

      lo_artifact->set_table_content(
        iv_key1                 = lv_key
        it_insert_table_content = lt_table_content
        it_system_fields_values = lt_system_field_values ).

      lo_artifact->update_tadir_entry(
          iv_key1     = lv_key
          iv_devclass = iv_package ).

      IF ls_settings-transportable IS NOT INITIAL AND iv_transport IS NOT INITIAL.

        insert_to_transport(
          io_artifact      = lo_artifact
          iv_transport     = iv_transport
          iv_package       = iv_package
          iv_key1          = lv_key
          iv_artifact_type = ls_settings-artifact_type ).

      ENDIF.

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

    DATA lo_artifact TYPE REF TO /neptune/if_artifact_type.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    rv_is_locked = lo_artifact->check_artifact_is_locked( iv_key = ms_item-obj_name ).

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

    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    mv_artifact_type = lo_artifact->artifact_type.

    TRY.
        io_xml->add(
          iv_name = 'key'
          ig_data = ms_item-obj_name ).
      CATCH zcx_abapgit_exception.
    ENDTRY.

    lv_key = ms_item-obj_name.

    lo_artifact->get_table_content(
      EXPORTING iv_key1                 = lv_key
                iv_only_sys_independent = abap_true
      IMPORTING et_table_content        = lt_table_content ).

* serialize
    LOOP AT lt_table_content INTO ls_table_content.

      ASSIGN ls_table_content-table_content->* TO <lt_standard_table>.
      CHECK sy-subrc = 0 AND <lt_standard_table> IS NOT INITIAL.

      CASE ls_table_content-tabname.
        WHEN '/NEPTUNE/CUSHEAD'.
          serialize_cushead( is_table_content = ls_table_content ).

        WHEN '/NEPTUNE/CUSLOGI'.
          serialize_cuslogi( is_table_content = ls_table_content ).

        WHEN '/NEPTUNE/CONFXML'.
          serialize_confxml( is_table_content = ls_table_content ).

        WHEN '/NEPTUNE/APPCACH'.
          serialize_appcach( is_table_content = ls_table_content ).

        WHEN OTHERS.
          serialize_table(
            iv_tabname = ls_table_content-tabname
            it_table   = <lt_standard_table> ).
      ENDCASE.



    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
