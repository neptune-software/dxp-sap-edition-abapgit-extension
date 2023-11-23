CLASS zcl_abapgit_object_zn19 DEFINITION
  PUBLIC
  INHERITING FROM zcl_abapgit_objects_super
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abapgit_object .
  PROTECTED SECTION.
private section.

  types:
    BEGIN OF ty_mapping,
                          key TYPE tadir-obj_name,
                          name TYPE string,
                         END OF ty_mapping .
  types:
    ty_mapping_tt TYPE STANDARD TABLE OF ty_mapping WITH KEY key .
  types:
    ty_t_mime_t TYPE STANDARD TABLE OF /neptune/mime_t WITH NON-UNIQUE DEFAULT KEY .
  types:
    BEGIN OF ty_lcl_mime.
            INCLUDE TYPE /neptune/mime.
    TYPES: file_name      TYPE string,
      END OF ty_lcl_mime .
  types:
    ty_tt_lcl_mime TYPE STANDARD TABLE OF ty_lcl_mime .

  constants:
    mc_name_separator(1) TYPE c value '@'. "#EC NOTEXT
  constants GC_MIME_TABLE type TABNAME value '/NEPTUNE/MIME'. "#EC NOTEXT
  constants GC_MEDPACK type TABNAME value '/NEPTUNE/MEDPACK'. "#EC NOTEXT
  constants GC_MIME_T_TABLE type TABNAME value '/NEPTUNE/MIME_T'. "#EC NOTEXT
  data MT_SKIP_PATHS type STRING_TABLE .
  class-data GT_MAPPING type TY_MAPPING_TT .
  data MV_ARTIFACT_TYPE type /NEPTUNE/ARTIFACT_TYPE .

  methods SERIALIZE_TABLE
    importing
      !IV_TABNAME type TABNAME
      !IT_TABLE type ANY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  interface ZIF_ABAPGIT_GIT_DEFINITIONS load .
  methods DESERIALIZE_MIME_TABLE
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IR_DATA type ref to DATA
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods DESERIALIZE_TABLE
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IR_DATA type ref to DATA
      !IV_TABNAME type TADIR-OBJ_NAME
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods GET_VALUES_FROM_FILENAME
    importing
      !IS_FILENAME type STRING
    exporting
      !EV_TABNAME type TADIR-OBJ_NAME
      !EV_NAME type /NEPTUNE/ARTIFACT_NAME .
  methods GET_FULL_FILE_PATH
    importing
      !IV_PARENT type /NEPTUNE/MIME_T-PARENT
      !IT_MIME_T type TY_T_MIME_T
    returning
      value(RV_PATH) type STRING .
  interface /NEPTUNE/IF_ARTIFACT_TYPE load .
  methods SERIALIZE_MIME_TABLE
    importing
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
      !IS_TABLE_CONTENT type /NEPTUNE/IF_ARTIFACT_TYPE=>TY_TABLE_CONTENT
      !IT_MIME_T type TY_T_MIME_T optional
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods INSERT_TO_TRANSPORT
    importing
      !IO_ARTIFACT type ref to /NEPTUNE/IF_ARTIFACT_TYPE
      !IV_TRANSPORT type TRKORR
      !IV_PACKAGE type DEVCLASS
      !IV_KEY1 type ANY
      !IV_ARTIFACT_TYPE type /NEPTUNE/ATY-ARTIFACT_TYPE .
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN19 IMPLEMENTATION.


  METHOD deserialize_mime_table.

    DATA lt_lcl_mime TYPE ty_tt_lcl_mime.
    DATA ls_lcl_mime LIKE LINE OF lt_lcl_mime.

    DATA lt_mime TYPE STANDARD TABLE OF /neptune/mime WITH DEFAULT KEY.
    DATA ls_mime LIKE LINE OF lt_mime.

    DATA lo_ajson TYPE REF TO zcl_abapgit_ajson.
    DATA lx_ajson TYPE REF TO zcx_abapgit_ajson_error.

    DATA ls_file LIKE LINE OF it_files.

    FIELD-SYMBOLS <lt_tab> TYPE ANY TABLE.

    ASSIGN ir_data->* TO <lt_tab>.
    CHECK sy-subrc = 0.

    TRY.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( IMPORTING ev_container = lt_lcl_mime ).
      CATCH zcx_abapgit_ajson_error INTO lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    ENDTRY.

    LOOP AT lt_lcl_mime INTO ls_lcl_mime.

      MOVE-CORRESPONDING ls_lcl_mime TO ls_mime.

      READ TABLE it_files INTO ls_file WITH KEY filename = ls_lcl_mime-file_name.
      IF sy-subrc = 0.

        ls_mime-data = ls_file-data.

      ENDIF.
      APPEND ls_mime TO lt_mime.
    ENDLOOP.
*
    <lt_tab> = lt_mime.

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


  METHOD get_full_file_path.

    DATA lv_parent TYPE /neptune/mime_t-parent.

    FIELD-SYMBOLS <ls_mime_t> LIKE LINE OF it_mime_t.

    lv_parent = iv_parent.

    WHILE lv_parent IS NOT INITIAL.
      READ TABLE it_mime_t ASSIGNING <ls_mime_t> WITH KEY guid = lv_parent.
      IF sy-subrc = 0.
        CONCATENATE <ls_mime_t>-name rv_path INTO rv_path SEPARATED BY '_'.
        IF <ls_mime_t>-parent IS INITIAL AND <ls_mime_t>-guid <> /neptune/cl_nad_cockpit=>media_folder-media_pack.
          CONCATENATE 'Media Library' rv_path INTO rv_path SEPARATED BY '_'.
        ENDIF.
        lv_parent = <ls_mime_t>-parent.
      ELSE.
        CLEAR lv_parent.
      ENDIF.
    ENDWHILE.

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


  method serialize_mime_table.

    data lt_lcl_mime type ty_tt_lcl_mime.
    data ls_lcl_mime like line of lt_lcl_mime.

    data lt_mime type standard table of /neptune/mime with default key.
    data ls_mime like line of lt_mime.
    data ls_mime_t like line of it_mime_t.

    data: ls_file type zif_abapgit_git_definitions=>ty_file,
          lv_guid type string.


    field-symbols: <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_mime = <lt_standard_table>.

    read table it_mime_t into ls_mime_t with key guid = iv_key. "#EC CI_SUBRC

    loop at lt_mime into ls_mime.
      move-corresponding ls_mime to ls_lcl_mime.
      " clear the image from this field because the image will be its own file
      clear ls_lcl_mime-data.

      lv_guid = ls_mime-guid.

      concatenate iv_key
                  ms_item-obj_type
                  is_table_content-tabname into ls_file-filename separated by '.'.

      replace all occurrences of '/' in ls_file-filename with '#'.

      concatenate ls_file-filename lv_guid  into ls_file-filename separated by mc_name_separator.
      concatenate ls_file-filename ls_mime-name into ls_file-filename separated by '.'.

      concatenate ls_mime_t-name ls_file-filename into ls_file-filename separated by mc_name_separator.

      translate ls_file-filename to lower case.

      ls_file-path = '/'.
      ls_file-data = ls_mime-data.

      zif_abapgit_object~mo_files->add( ls_file ).

      ls_lcl_mime-file_name = ls_file-filename.

      append ls_lcl_mime to lt_lcl_mime.
    endloop.

    serialize_table(
      iv_tabname = is_table_content-tabname
      it_table   = lt_lcl_mime ).

  endmethod.


  method serialize_table.

    data: lo_ajson         type ref to zcl_abapgit_ajson,
          lx_ajson         type ref to zcx_abapgit_ajson_error,
          lv_json          type string,
          ls_file          type zif_abapgit_git_definitions=>ty_file.

    data lx_ex type ref to zcx_abapgit_exception.

    data lt_skip_paths type string_table.

    try.
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
        if lt_skip_paths is not initial.
          lo_ajson = zcl_abapgit_ajson=>create_from(
                        ii_source_json = lo_ajson
                        ii_filter      = zcl_abapgit_ajson_filter_lib=>create_path_filter(
                                            it_skip_paths     = lt_skip_paths
                                            iv_pattern_search = abap_true ) ).
        endif.

        lv_json = lo_ajson->stringify( 2 ).

        ls_file-path = '/'.
        ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_json ).
        ls_file-filename = zcl_abapgit_filename_logic=>object_to_file(
                           is_item  = ms_item
                           iv_extra = iv_tabname
                           iv_ext   = 'json' ).

        zif_abapgit_object~mo_files->add( ls_file ).

      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
      catch zcx_abapgit_exception into lx_ex.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

  endmethod.


  METHOD zif_abapgit_object~changed_by.

    DATA: lo_artifact TYPE REF TO /neptune/if_artifact_type,
          lt_table_content TYPE /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content LIKE LINE OF lt_table_content,
          lv_key           TYPE /neptune/artifact_key.

    DATA ls_medpack TYPE /neptune/medpack.

    FIELD-SYMBOLS <lt_standard_table> TYPE STANDARD TABLE.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

    lv_key = ms_item-obj_name.

    lo_artifact->get_table_content(
      exporting iv_key1                 = lv_key
                iv_only_sys_independent = abap_true
      importing et_table_content        = lt_table_content ).

    READ TABLE lt_table_content INTO ls_table_content WITH TABLE KEY tabname = gc_medpack.
    IF sy-subrc = 0.
      ASSIGN ls_table_content-table_content->* TO <lt_standard_table>.
      CHECK sy-subrc = 0.
      READ TABLE <lt_standard_table> INTO ls_medpack INDEX 1.
      IF sy-subrc = 0 AND ls_medpack-updnam IS NOT INITIAL.
        rv_user = ls_medpack-updnam.
      ELSE.
        rv_user = ls_medpack-crenam.
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

    DATA lo_artifact TYPE REF TO /neptune/if_artifact_type.
    DATA ls_settings TYPE /neptune/aty.

    DATA: lt_files TYPE zif_abapgit_git_definitions=>ty_files_tt,
          ls_files LIKE LINE OF lt_files.

    DATA: lt_table_content TYPE /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content LIKE LINE OF lt_table_content.

    DATA lr_data    TYPE REF TO data.
    DATA lv_tabname TYPE tadir-obj_name.
    DATA lv_key     TYPE /neptune/artifact_key.
    DATA lv_name    TYPE /neptune/artifact_name.

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
          ev_tabname  = lv_tabname
          ev_name     = lv_name ).

      CREATE DATA lr_data TYPE STANDARD TABLE OF (lv_tabname) WITH NON-UNIQUE DEFAULT KEY.

      CASE lv_tabname.
        WHEN gc_mime_table.
          deserialize_mime_table(
            is_file  = ls_files
            ir_data  = lr_data
            it_files = lt_files ).

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
          iv_key1          = lv_key
          iv_devclass      = ms_item-devclass
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
            iv_key           = lv_key
            iv_devclass      = is_item-devclass
            iv_artifact_type = /neptune/if_artifact_type=>gc_artifact_type-media_pack
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
          lv_key           TYPE /neptune/artifact_key.

    FIELD-SYMBOLS: <lt_standard_table> TYPE STANDARD TABLE.

    FIELD-SYMBOLS <lt_mime_t> TYPE ty_t_mime_t.

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
      exporting iv_key1                 = lv_key
                iv_only_sys_independent = abap_true
      importing et_table_content        = lt_table_content ).

* get folders table
    READ TABLE lt_table_content INTO ls_table_content WITH KEY tabname = gc_mime_t_table.
    IF sy-subrc = 0.
      ASSIGN ls_table_content-table_content->* TO <lt_mime_t>.
    ENDIF.

    CHECK <lt_mime_t> IS ASSIGNED.

* serialize
    LOOP AT lt_table_content INTO ls_table_content.

      ASSIGN ls_table_content-table_content->* TO <lt_standard_table>.

      CHECK sy-subrc = 0 AND <lt_standard_table> IS NOT INITIAL.

      CASE ls_table_content-tabname.
        WHEN gc_mime_table.
          serialize_mime_table(
            iv_key           = lv_key
            is_table_content = ls_table_content
            it_mime_t        = <lt_mime_t> ).

        WHEN OTHERS.
          serialize_table(
            iv_tabname = ls_table_content-tabname
            it_table   = <lt_standard_table> ).
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
