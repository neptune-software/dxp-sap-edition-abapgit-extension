CLASS zcl_abapgit_object_zn09 DEFINITION
  PUBLIC
  INHERITING FROM zcl_abapgit_objects_super
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abapgit_object .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_lcl_enhtext,
                enhancement TYPE /neptune/enhancement,
                spot        TYPE /neptune/enhancement_spot,
                file_name   TYPE string,
               END OF ty_lcl_enhtext .
    TYPES:
      ty_tt_lcl_enhtext TYPE STANDARD TABLE OF ty_lcl_enhtext .

    CONSTANTS:
      mc_name_separator(1) TYPE c VALUE '@'. "#EC NOTEXT
    DATA mv_artifact_type TYPE /neptune/artifact_type .

    METHODS serialize_table
      IMPORTING
      !iv_tabname TYPE tabname
      !it_table TYPE any
      RAISING
      zcx_abapgit_exception .
    INTERFACE zif_abapgit_git_definitions LOAD .
    METHODS deserialize_table
      IMPORTING
      !is_file TYPE zif_abapgit_git_definitions=>ty_file
      !ir_data TYPE REF TO data
      !iv_tabname TYPE tadir-obj_name
      RAISING
      zcx_abapgit_exception .
    METHODS serialize_enhtext
      IMPORTING
      !is_table_content TYPE /neptune/if_artifact_type=>ty_table_content .
    METHODS get_values_from_filename
      IMPORTING
      !is_filename TYPE string
      EXPORTING
      !ev_tabname TYPE tadir-obj_name
      !ev_name TYPE /neptune/artifact_name .
    METHODS deserialize_enhtext
      IMPORTING
      !is_file TYPE zif_abapgit_git_definitions=>ty_file
      !it_files TYPE zif_abapgit_git_definitions=>ty_files_tt
      !ir_data TYPE REF TO data
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



CLASS zcl_abapgit_object_zn09 IMPLEMENTATION.


  METHOD deserialize_enhtext.

    DATA lt_lcl_enhtext TYPE ty_tt_lcl_enhtext.
    DATA ls_lcl_enhtext LIKE LINE OF lt_lcl_enhtext.

    DATA lt_enhtext TYPE STANDARD TABLE OF /neptune/enhtext WITH DEFAULT KEY.
    DATA ls_enhtext LIKE LINE OF lt_enhtext.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    DATA ls_file LIKE LINE OF it_files.

    DATA lt_code TYPE string_table.
    DATA lv_code TYPE string.

    DATA lv_seqnr TYPE /neptune/enhtext-seqnr VALUE 0.

    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.

    ASSIGN ir_data->* TO <lt_tab>.
    CHECK sy-subrc = 0.

    TRY.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( IMPORTING ev_container = lt_lcl_enhtext ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.

    LOOP AT lt_lcl_enhtext INTO ls_lcl_enhtext.

      MOVE-CORRESPONDING ls_lcl_enhtext TO ls_enhtext.

      READ TABLE it_files INTO ls_file WITH KEY filename = ls_lcl_enhtext-file_name.
      IF sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

        lt_code = zcl_neptune_abapgit_utilities=>string_to_code_lines( iv_string = lv_code ).
        LOOP AT lt_code INTO lv_code.
          lv_seqnr = lv_seqnr + 1.

          ls_enhtext-seqnr  = lv_seqnr.
          ls_enhtext-text   = lv_code.
          APPEND ls_enhtext TO lt_enhtext.
        ENDLOOP.


      ENDIF.
    ENDLOOP.

    <lt_tab> = lt_enhtext.

  ENDMETHOD.


  METHOD deserialize_table.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    DATA lt_table_content TYPE REF TO data.

    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.
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

    <lt_tab> = <lt_standard_table>.

  ENDMETHOD.


  METHOD get_values_from_filename.

    DATA lt_comp TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA ls_comp LIKE LINE OF lt_comp.
    DATA lv_key TYPE /neptune/artifact_key.
    DATA lv_name TYPE string.

    SPLIT is_filename AT '.' INTO TABLE lt_comp.

    READ TABLE lt_comp INTO ls_comp INDEX 1.
    IF sy-subrc = 0.
      SPLIT ls_comp AT mc_name_separator INTO lv_name lv_key.
      TRANSLATE lv_name TO UPPER CASE.
      ev_name = lv_name.
    ENDIF.

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


  METHOD serialize_enhtext.

    DATA ls_file TYPE zif_abapgit_git_definitions=>ty_file.
    DATA lv_code TYPE string.

    DATA lt_lcl_enhtext TYPE ty_tt_lcl_enhtext.
    DATA ls_lcl_enhtext LIKE LINE OF lt_lcl_enhtext.

    DATA lt_enhtext TYPE STANDARD TABLE OF /neptune/enhtext WITH DEFAULT KEY.
    DATA ls_enhtext LIKE LINE OF lt_enhtext.

    DATA lt_code_lines TYPE string_table.

    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    ASSIGN is_table_content-table_content->* TO <lt_standard_table>.
    CHECK sy-subrc = 0 AND <lt_standard_table> IS NOT INITIAL.

    lt_enhtext = <lt_standard_table>.

    SORT lt_enhtext.

    LOOP AT lt_enhtext INTO ls_enhtext.
      AT NEW spot.
        CLEAR lv_code.
        MOVE-CORRESPONDING ls_enhtext TO ls_lcl_enhtext.
      ENDAT.

      APPEND ls_enhtext-text TO lt_code_lines.

      AT END OF spot.

        CONCATENATE me->ms_item-obj_name
                    me->ms_item-obj_type
                    is_table_content-tabname
                    ls_enhtext-spot
                    'js' INTO ls_lcl_enhtext-file_name SEPARATED BY '.'.

        REPLACE ALL OCCURRENCES OF '/' IN ls_lcl_enhtext-file_name WITH '#'.
        TRANSLATE ls_lcl_enhtext-file_name TO LOWER CASE.
        APPEND ls_lcl_enhtext TO lt_lcl_enhtext.

        TRY.
** loop at code table to add each entry as a file
            ls_file-path = '/'.
            lv_code = zcl_neptune_abapgit_utilities=>code_lines_to_string( it_code_lines = lt_code_lines ).
            CLEAR: lt_code_lines.

            ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
          CATCH zcx_abapgit_exception.
        ENDTRY.

        ls_file-filename = ls_lcl_enhtext-file_name.

        zif_abapgit_object~mo_files->add( ls_file ).

      ENDAT.
    ENDLOOP.

    IF lt_lcl_enhtext IS NOT INITIAL.
      TRY.
** Add adjusted table to files
          serialize_table(
            iv_tabname = is_table_content-tabname
            it_table   = lt_lcl_enhtext ).

        CATCH zcx_abapgit_exception.
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD serialize_table.

    DATA: lo_ajson         TYPE REF TO zcl_abapgit_ajson,
          lx_ajson         TYPE REF TO zcx_abapgit_ajson_error,
          lv_json          TYPE string,
          ls_file          TYPE zif_abapgit_git_definitions=>ty_file.

    DATA lt_skip_paths TYPE string_table.

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

    zif_abapgit_object~mo_files->add( ls_file ).

  ENDMETHOD.


  METHOD zif_abapgit_object~changed_by.

    DATA: lo_artifact TYPE REF TO /neptune/if_artifact_type,
          lt_table_content TYPE /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content LIKE LINE OF lt_table_content,
          lv_key           TYPE /neptune/artifact_key.

    DATA ls_enhance TYPE /neptune/enhance.

    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

    lv_key = ms_item-obj_name.

    lo_artifact->get_table_content(
      EXPORTING iv_key1                 = lv_key
                iv_only_sys_independent = abap_true
      IMPORTING et_table_content        = lt_table_content ).

    READ TABLE lt_table_content INTO ls_table_content WITH TABLE KEY tabname = '/NEPTUNE/ENHANCE'.
    IF sy-subrc = 0.
      ASSIGN ls_table_content-table_content->* TO <lt_standard_table>.
      CHECK sy-subrc = 0.
      READ TABLE <lt_standard_table> INTO ls_enhance INDEX 1.
      IF sy-subrc = 0 AND ls_enhance-updnam IS NOT INITIAL.
        rv_user = ls_enhance-updnam.
      ELSE.
        rv_user = ls_enhance-crenam.
      ENDIF.
    ENDIF.

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

** pick up logic from CLASS ZCL_ABAPGIT_DATA_DESERIALIZER

    DATA: lt_files TYPE zif_abapgit_git_definitions=>ty_files_tt,
          ls_files LIKE LINE OF lt_files.

    DATA: lt_table_content TYPE /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content LIKE LINE OF lt_table_content.

    DATA lr_data    TYPE REF TO data.
    DATA lv_tabname TYPE tadir-obj_name.
    DATA lv_key     TYPE /neptune/artifact_key.

    DATA lo_artifact TYPE REF TO /neptune/if_artifact_type.
    DATA ls_settings TYPE /neptune/aty.

    TRY.
        io_xml->read(
          EXPORTING
            iv_name = 'key'
          CHANGING
            cg_data = lv_key ).
      CATCH zcx_abapgit_exception.
    ENDTRY.

    lt_files = zif_abapgit_object~mo_files->get_files( ).

    LOOP AT lt_files INTO ls_files WHERE filename CS '.json'.

      get_values_from_filename(
        EXPORTING
          is_filename = ls_files-filename
        IMPORTING
          ev_tabname  = lv_tabname ).

      CREATE DATA lr_data TYPE STANDARD TABLE OF (lv_tabname) WITH NON-UNIQUE DEFAULT KEY.

      CASE lv_tabname.
        WHEN '/NEPTUNE/ENHTEXT'.

          deserialize_enhtext(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data ).

        WHEN OTHERS.

          deserialize_table(
            is_file    = ls_files
            iv_tabname = lv_tabname
            ir_data    = lr_data ).

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
        iv_key1     = lv_key
        iv_devclass = iv_package ).

      lo_artifact->set_table_content(
        iv_key1                 = lv_key
        it_insert_table_content = lt_table_content ).

      lo_artifact->update_tadir_entry(
          iv_key1     = lv_key
          iv_devclass = ms_item-devclass ).

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

    FIELD-SYMBOLS: <lt_standard_table> TYPE STANDARD TABLE.

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

      CASE ls_table_content-tabname.
        WHEN '/NEPTUNE/ENHTEXT'.

          serialize_enhtext( is_table_content = ls_table_content ).

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
