CLASS zcl_abapgit_object_zn04 DEFINITION
  PUBLIC
  INHERITING FROM zcl_abapgit_objects_super
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abapgit_object .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS zcl_neptune_abapgit_utilities DEFINITION LOAD .
    CLASS-DATA gt_mapping TYPE zcl_neptune_abapgit_utilities=>ty_mapping_tt .
    DATA mv_artifact_type TYPE /neptune/artifact_type .

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
      !iv_tabname TYPE tadir-obj_name
      RAISING
      zcx_abapgit_exception .
    METHODS get_values_from_filename
      IMPORTING
      !is_filename TYPE string
      EXPORTING
      !ev_tabname TYPE tadir-obj_name
      !ev_name TYPE /neptune/artifact_name .
    METHODS insert_to_transport
      IMPORTING
      !io_artifact TYPE REF TO /neptune/if_artifact_type
      !iv_transport TYPE trkorr
      !iv_package TYPE devclass
      !iv_key1 TYPE any
      !iv_artifact_type TYPE /neptune/aty-artifact_type .
ENDCLASS.



CLASS zcl_abapgit_object_zn04 IMPLEMENTATION.


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

        lo_ajson->zif_abapgit_ajson~to_abap( EXPORTING iv_corresponding = abap_true
                                             IMPORTING ev_container     = <lt_standard_table> ).
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
      SPLIT ls_comp AT zcl_neptune_abapgit_utilities=>mc_name_separator INTO lv_name lv_key.
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

    DATA ls_categor TYPE /neptune/categor.

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

        READ TABLE lt_table_content INTO ls_table_content WITH TABLE KEY tabname = '/NEPTUNE/CATEGOR'.
        IF sy-subrc = 0.
          ASSIGN ls_table_content-table_content->* TO <lt_standard_table>.
          CHECK sy-subrc = 0.
          READ TABLE <lt_standard_table> INTO ls_categor INDEX 1.
          IF sy-subrc = 0 AND ls_categor-updnam IS NOT INITIAL.
            rv_user = ls_categor-updnam.
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

** pick up logic from CLASS ZCL_ABAPGIT_DATA_DESERIALIZER

    DATA lo_artifact TYPE REF TO /neptune/if_artifact_type.

    DATA: lt_files TYPE zif_abapgit_git_definitions=>ty_files_tt,
          ls_files LIKE LINE OF lt_files.

    DATA: lt_table_content TYPE /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content LIKE LINE OF lt_table_content.

    DATA lt_system_field_values TYPE /neptune/if_artifact_type=>ty_t_system_field_values.

    DATA lr_data    TYPE REF TO data.
    DATA lv_tabname TYPE tadir-obj_name.
    DATA lv_key     TYPE /neptune/artifact_key.
    DATA lv_name    TYPE /neptune/artifact_name.
    DATA ls_settings TYPE /neptune/aty.
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
          ev_tabname  = lv_tabname
          ev_name     = lv_name ).

      TRY.
          CREATE DATA lr_data TYPE STANDARD TABLE OF (lv_tabname) WITH NON-UNIQUE DEFAULT KEY.

          deserialize_table(
            is_file    = ls_files
            iv_tabname = lv_tabname
            ir_data    = lr_data ).

          ls_table_content-tabname = lv_tabname.
          ls_table_content-table_content = lr_data.
          APPEND ls_table_content TO lt_table_content.
          CLEAR ls_table_content.

        CATCH cx_sy_create_data_error.

      ENDTRY.

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
          iv_key1          = lv_key
          iv_devclass      = iv_package
          iv_artifact_name = lv_name ).

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

    FIELD-SYMBOLS: <lv_filename> TYPE clike.

    ASSIGN ('IV_FILENAME') TO <lv_filename>.
    IF sy-subrc <> 0.
      " new signature starting with abapGit v1.132.0
      ASSIGN ('IV_ITEM_PART_OF_FILENAME') TO <lv_filename>.
      IF sy-subrc <> 0.
        zcx_abapgit_exception=>raise( 'IV_ITEM_PART_OF_FILENAME assignment failed. Version COMPATIBILITY ERROR!' ).
      ENDIF.
    ENDIF.

    zcl_neptune_abapgit_utilities=>map_filename_to_object(
      EXPORTING iv_item_part_of_filename = <lv_filename>
*               iv_path                  = iv_path
*               io_dot                   = io_dot
*               iv_package               = iv_package
      CHANGING cs_item                   = cs_item
               ct_mapping                = gt_mapping ).


  ENDMETHOD.


  METHOD zif_abapgit_object~map_object_to_filename.

    DATA lv_key                TYPE /neptune/artifact_key.
    DATA lv_modular_file_parts TYPE abap_bool.
    DATA lv_ext                TYPE string.
    DATA lv_extra              TYPE string.

    FIELD-SYMBOLS: <lv_item_part_of_filename> TYPE clike,
                   <lv_ext>                   TYPE clike,
                   <lv_extra>                 TYPE clike.

    ASSIGN ('CV_FILENAME') TO <lv_item_part_of_filename>.
    IF sy-subrc <> 0.
      " new signature starting with abapGit v1.132.0
      ASSIGN ('CV_ITEM_PART_OF_FILENAME') TO <lv_item_part_of_filename>.
      IF sy-subrc <> 0.
        zcx_abapgit_exception=>raise( 'CV_ITEM_PART_OF_FILENAME assignment failed. Version COMPATIBILITY ERROR!' ).
      ENDIF.
      ASSIGN ('IV_EXT') TO <lv_ext>.
      IF sy-subrc <> 0.
        zcx_abapgit_exception=>raise( 'IV_EXT assignment failed. Version COMPATIBILITY ERROR!' ).
      ENDIF.
      ASSIGN ('IV_EXTRA') TO <lv_extra>.
      IF sy-subrc <> 0.
        zcx_abapgit_exception=>raise( 'IV_EXTRA assignment failed. Version COMPATIBILITY ERROR!' ).
      ENDIF.
      lv_ext = <lv_ext>.
      lv_extra = <lv_extra>.
      lv_modular_file_parts = abap_true.
    ENDIF.

    lv_key = is_item-obj_name.

    zcl_neptune_abapgit_utilities=>map_object_to_filename(
      EXPORTING is_item                  = is_item
                it_mapping               = gt_mapping
                iv_modular_file_parts    = lv_modular_file_parts
                iv_ext                   = lv_ext
                iv_extra                 = lv_extra
                iv_artifact_key          = lv_key
                iv_artifact_type         = /neptune/if_artifact_type=>gc_artifact_type-tilegroup
      CHANGING  cv_item_part_of_filename = <lv_item_part_of_filename> ).

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
      CHECK sy-subrc = 0.

      CHECK <lt_standard_table> IS NOT INITIAL.

      serialize_table(
        iv_tabname = ls_table_content-tabname
        it_table   = <lt_standard_table> ).

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
