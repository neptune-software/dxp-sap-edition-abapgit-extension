CLASS zcl_abapgit_object_zn07 DEFINITION
  PUBLIC
  INHERITING FROM zcl_abapgit_objects_super
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abapgit_object .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_mapping,
                  key TYPE tadir-obj_name,
                  name TYPE string,
                 END OF ty_mapping .
    TYPES:
      ty_mapping_tt TYPE STANDARD TABLE OF ty_mapping WITH KEY key .

    CONSTANTS:
      mc_name_separator(1) TYPE c VALUE '@'.                "#EC NOTEXT
    CLASS-DATA gt_mapping TYPE ty_mapping_tt .
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
      !it_files TYPE zif_abapgit_git_definitions=>ty_files_tt
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



CLASS zcl_abapgit_object_zn07 IMPLEMENTATION.


  METHOD deserialize_table.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    DATA lt_table_content TYPE REF TO data.
    DATA ls_file LIKE LINE OF it_files.

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

        lo_ajson->zif_abapgit_ajson~to_abap( EXPORTING iv_corresponding = abap_true
                                             IMPORTING ev_container     = <lt_standard_table> ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.

    IF iv_tabname = '/NEPTUNE/CUSLAY' ##NO_TEXT.
      READ TABLE <lt_standard_table> ASSIGNING <ls_line> INDEX 1.
      IF sy-subrc = 0.

        ASSIGN COMPONENT 'CUSTOM_CSS' OF STRUCTURE <ls_line> TO <lv_field> ##NO_TEXT.
        IF sy-subrc = 0 AND <lv_field> IS NOT INITIAL.

          READ TABLE it_files INTO ls_file WITH KEY filename = <lv_field>.
          IF sy-subrc = 0.

            <lv_field> = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.


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

    DATA ls_cuslay TYPE /neptune/cuslay.

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

        READ TABLE lt_table_content INTO ls_table_content WITH TABLE KEY tabname = '/NEPTUNE/CUSLAY'.
        IF sy-subrc = 0.
          ASSIGN ls_table_content-table_content->* TO <lt_standard_table>.
          CHECK sy-subrc = 0.
          READ TABLE <lt_standard_table> INTO ls_cuslay INDEX 1.
          IF sy-subrc = 0 AND ls_cuslay-updnam IS NOT INITIAL.
            rv_user = ls_cuslay-updnam.
          ELSE.
            rv_user = ls_cuslay-crenam.
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
    DATA ls_settings TYPE /neptune/aty.

    DATA: lt_files TYPE zif_abapgit_git_definitions=>ty_files_tt,
          ls_files LIKE LINE OF lt_files.

    DATA: lt_table_content TYPE /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content LIKE LINE OF lt_table_content.

    DATA lt_system_field_values TYPE /neptune/if_artifact_type=>ty_t_system_field_values.

    DATA lr_data    TYPE REF TO data.
    DATA lv_tabname TYPE tadir-obj_name.
    DATA lv_key     TYPE /neptune/artifact_key.
    DATA lv_name    TYPE /neptune/artifact_name.
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

      CREATE DATA lr_data TYPE STANDARD TABLE OF (lv_tabname) WITH NON-UNIQUE DEFAULT KEY.

      deserialize_table(
        is_file    = ls_files
        iv_tabname = lv_tabname
        ir_data    = lr_data
        it_files   = lt_files ).

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

    DATA lt_parts TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA: lv_artifact_name TYPE string,
          lv_key TYPE string,
          lv_filename TYPE string.
    DATA ls_mapping LIKE LINE OF gt_mapping.

    SPLIT iv_filename AT mc_name_separator INTO lv_artifact_name lv_filename.
    SPLIT lv_filename AT '.' INTO TABLE lt_parts.
    READ TABLE lt_parts INTO lv_key INDEX 1.
    CHECK sy-subrc = 0.

    IF lv_artifact_name IS NOT INITIAL.
      TRANSLATE lv_key TO UPPER CASE.
      cs_item-obj_name = lv_key.

      READ TABLE gt_mapping TRANSPORTING NO FIELDS WITH KEY key = lv_key.
      CHECK sy-subrc <> 0.

      ls_mapping-key = lv_key.
      ls_mapping-name = lv_artifact_name.
      APPEND ls_mapping TO gt_mapping.

    ENDIF.

  ENDMETHOD.


  METHOD zif_abapgit_object~map_object_to_filename.

    DATA ls_mapping LIKE LINE OF gt_mapping.
    DATA ls_tadir TYPE /neptune/if_artifact_type=>ty_lcl_tadir.
    DATA lv_key TYPE /neptune/artifact_key.

    CHECK is_item-devclass IS NOT INITIAL.

    lv_key = is_item-obj_name.

    TRY.
        " Ongoing from DXP 23 fetch wie tadir framework (all artifacts can be assigned to a devclass)
        CALL METHOD ('/NEPTUNE/CL_TADIR')=>('GET_ARTIFACT_ENTRY')
*          call method  /neptune/cl_tadir=>get_artifact_entry
          EXPORTING
            iv_key           =  lv_key
            iv_devclass      =  is_item-devclass
            iv_artifact_type = /neptune/if_artifact_type=>gc_artifact_type-launchpad_layout
          RECEIVING
            rs_tadir    = ls_tadir          ##called.

      CATCH cx_sy_dyn_call_illegal_class
            cx_sy_dyn_call_illegal_method.

        RETURN.

    ENDTRY.

    IF ls_tadir IS NOT INITIAL.
      CONCATENATE ls_tadir-artifact_name cv_filename INTO cv_filename SEPARATED BY mc_name_separator.
    ELSE.
      READ TABLE gt_mapping INTO ls_mapping WITH KEY key = is_item-obj_name.
      IF sy-subrc = 0.
        CONCATENATE ls_mapping-name cv_filename INTO cv_filename SEPARATED BY mc_name_separator.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD zif_abapgit_object~serialize.

    DATA: lo_artifact      TYPE REF TO /neptune/if_artifact_type,
          lt_table_content TYPE /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content LIKE LINE OF lt_table_content,
          lv_key           TYPE /neptune/artifact_key,
          ls_file          TYPE zif_abapgit_git_definitions=>ty_file.

    DATA lv_message TYPE string.

    FIELD-SYMBOLS <lr_object_files> TYPE REF TO zcl_abapgit_objects_files.

    FIELD-SYMBOLS: <lt_standard_table> TYPE STANDARD TABLE,
                   <ls_line>           TYPE any,
                   <lv_field_value>    TYPE any,
                   <lv_name>           TYPE any.

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

      IF ls_table_content-tabname = '/NEPTUNE/CUSLAY'.
        READ TABLE <lt_standard_table> ASSIGNING <ls_line> INDEX 1.
        IF sy-subrc = 0.
          ASSIGN COMPONENT 'CUSTOM_CSS' OF STRUCTURE <ls_line> TO <lv_field_value>.
          IF sy-subrc = 0 AND <lv_field_value> IS NOT INITIAL.

            ASSIGN COMPONENT 'NAME' OF STRUCTURE <ls_line> TO <lv_name> CASTING TYPE /neptune/cuslay-name.
            IF sy-subrc = 0.

              CONCATENATE ms_item-obj_name
                          ms_item-obj_type
                          ls_table_content-tabname
                          'css' INTO ls_file-filename SEPARATED BY '.'.

              REPLACE ALL OCCURRENCES OF '/' IN ls_file-filename WITH '#'.
              CONCATENATE <lv_name> ls_file-filename INTO ls_file-filename SEPARATED BY mc_name_separator.
              TRANSLATE ls_file-filename TO LOWER CASE.

              ls_file-path = '/'.
              ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( <lv_field_value> ).

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*              zif_abapgit_object~mo_files->add( ls_file ).
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
                CONCATENATE 'Error serializing' ms_item-obj_type ms_item-obj_name ls_table_content-tabname INTO lv_message SEPARATED BY space.
                zcx_abapgit_exception=>raise( lv_message ).
              ENDIF.

              <lv_field_value> = ls_file-filename.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      serialize_table(
        iv_tabname = ls_table_content-tabname
        it_table   = <lt_standard_table> ).

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
