class ZCL_ABAPGIT_OBJECT_ZN04 definition
  public
  inheriting from ZCL_ABAPGIT_OBJECTS_SUPER
  final
  create public .

public section.

  interfaces ZIF_ABAPGIT_OBJECT .
  protected section.
private section.

  data GT_SKIP_PATHS type STRING_TABLE .

  methods SERIALIZE_TABLE
    importing
      !IV_TABNAME type TABNAME
      !IT_TABLE type ANY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods SET_SKIP_FIELDS .
  methods GET_SKIP_FIELDS
    returning
      value(RT_SKIP_PATHS) type STRING_TABLE .
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
      !EV_OBJ_KEY type /NEPTUNE/ARTIFACT_KEY .
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN04 IMPLEMENTATION.


  method DESERIALIZE_TABLE.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data lt_table_content type ref to data.

    field-symbols <lt_tab> type any table.
*    field-symbols <ls_line> type any.
*    field-symbols <lv_field> type any.
    field-symbols: <lt_standard_table> type standard table.

**********************************************************************

    assign ir_data->* to <lt_tab>.

    create data lt_table_content type standard table of (iv_tabname) with non-unique default key.
    assign lt_table_content->* to <lt_standard_table>.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).

        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = <lt_standard_table> ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.


*    loop at <lt_standard_table> assigning <ls_line>.
*      assign component 'GUID' of structure <ls_line> to <lv_field>.
*      if <lv_field> is assigned.
*        <lv_field> = iv_key.
*        unassign <lv_field>.
*      endif.
*    endloop.

    <lt_tab> = <lt_standard_table>.

  endmethod.


  method GET_SKIP_FIELDS.

    rt_skip_paths = gt_skip_paths.

  endmethod.


  method GET_VALUES_FROM_FILENAME.

    data lt_comp type standard table of string.
    data ls_comp like line of lt_comp.

    split is_filename at '.' into table lt_comp.

    read table lt_comp into ls_comp index 1.
    if sy-subrc = 0.
*    translate ls_comp to upper case.
      ev_obj_key = ls_comp.
    endif.

    read table lt_comp into ls_comp index 3.
    if sy-subrc = 0.
      replace all occurrences of '#' in ls_comp with '/'.
      translate ls_comp to upper case.
      ev_tabname = ls_comp.
    endif.

  endmethod.


  method SERIALIZE_TABLE.

    data: lo_ajson         type ref to zcl_abapgit_ajson,
          lx_ajson         type ref to zcx_abapgit_ajson_error,
          lv_json          type string,
          ls_file          type zif_abapgit_git_definitions=>ty_file.

    data it_skip_paths type string_table.

    try.
        lo_ajson = zcl_abapgit_ajson=>create_empty( ).
        lo_ajson->keep_item_order( ).
        lo_ajson->set(
          iv_path = '/'
          iv_val = it_table ).

* Remove fields that have initial value
        lo_ajson = zcl_abapgit_ajson=>create_from(
          ii_source_json = lo_ajson
          ii_filter = zcl_abapgit_ajson_filter_lib=>create_empty_filter( ) ).

* Remove unwanted fields
      it_skip_paths = get_skip_fields( ).
      if it_skip_paths is not initial.
        lo_ajson = zcl_abapgit_ajson=>create_from(
          ii_source_json = lo_ajson
          ii_filter = zcl_abapgit_ajson_filter_lib=>create_path_filter(
                                                      it_skip_paths     = it_skip_paths
                                                      iv_pattern_search = abap_true ) ).
      endif.

        lv_json = lo_ajson->stringify( 2 ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    ls_file-path = '/'.
    ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_json ).
    ls_file-filename = zcl_abapgit_filename_logic=>object_to_file(
                           is_item  = me->ms_item
                           iv_extra = iv_tabname
                           iv_ext   = 'json' ).

    zif_abapgit_object~mo_files->add( ls_file ).

  endmethod.


  method SET_SKIP_FIELDS.

    data: lv_skip type string.

    lv_skip = '*MANDT'.
    append lv_skip to gt_skip_paths.
    lv_skip = '*CONFIGURATION'.
    append lv_skip to gt_skip_paths.
    lv_skip = '*CREDAT'.
    append lv_skip to gt_skip_paths.
    lv_skip = '*CRETIM'.
    append lv_skip to gt_skip_paths.
    lv_skip = '*CRENAM'.
    append lv_skip to gt_skip_paths.
    lv_skip = '*UPDDAT'.
    append lv_skip to gt_skip_paths.
    lv_skip = '*UPDTIM'.
    append lv_skip to gt_skip_paths.
    lv_skip = '*UPDNAM'.
    append lv_skip to gt_skip_paths.


  endmethod.


  method ZIF_ABAPGIT_OBJECT~CHANGED_BY.

    data: lo_artifact type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    data ls_appcach type /neptune/appcach.

    field-symbols <lt_standard_table> type standard table.

**********************************************************************

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = me->ms_item-obj_type ).

    lv_key = me->ms_item-obj_name.

    lo_artifact->get_table_content(
      exporting iv_key1          = lv_key
      importing et_table_content = lt_table_content ).

    read table lt_table_content into ls_table_content with table key tabname = '/NEPTUNE/APPCACH'.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_standard_table>.
      read table <lt_standard_table> into ls_appcach index 1.
      if ls_appcach-updnam is not initial.
        rv_user = ls_appcach-updnam.
      else.
        rv_user = ls_appcach-crenam.
      endif.
    endif.

  endmethod.


  method zif_abapgit_object~delete.
    return.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~DESERIALIZE.

** pick up logic from CLASS ZCL_ABAPGIT_DATA_DESERIALIZER

    data lo_artifact type ref to /neptune/if_artifact_type.

    data: lt_files type zif_abapgit_git_definitions=>ty_files_tt,
          ls_files like line of lt_files.

    data: lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content.

    data lr_data    type ref to data.
    data lv_tabname type tadir-obj_name.
    data lv_key     type /neptune/artifact_key.

**********************************************************************

    lt_files = zif_abapgit_object~mo_files->get_files( ).

    loop at lt_files into ls_files where filename cs '.json'..

      get_values_from_filename(
        exporting
          is_filename = ls_files-filename    " File Name
        importing
          ev_tabname  = lv_tabname           " Object Name in Object Directory
          ev_obj_key  = lv_key               " Artifact table key
      ).

      create data lr_data type standard table of (lv_tabname) with non-unique default key.

      deserialize_table(
        exporting
          is_file    = ls_files
          iv_tabname = lv_tabname
*          iv_key     = lv_key
          ir_data    = lr_data ).

      ls_table_content-tabname = lv_tabname.
      ls_table_content-table_content = lr_data.
      append ls_table_content to lt_table_content.
      clear ls_table_content.

    endloop.

    if lt_table_content is not initial.

      lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = me->ms_item-obj_type ).

      lo_artifact->set_table_content(
        exporting
          iv_key1                 = lv_key
          it_insert_table_content = lt_table_content
      ).

    endif.

  endmethod.


  method ZIF_ABAPGIT_OBJECT~EXISTS.
    rv_bool = abap_true.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~GET_COMPARATOR.
    return.
  endmethod.


method zif_abapgit_object~get_deserialize_order.
  return.
endmethod.


  method ZIF_ABAPGIT_OBJECT~GET_DESERIALIZE_STEPS.
    append zif_abapgit_object=>gc_step_id-late to rt_steps.
  endmethod.


  method zif_abapgit_object~get_metadata.
    return.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~IS_ACTIVE.
    rv_active = abap_true.
  endmethod.


  method zif_abapgit_object~is_locked.
    return.
  endmethod.


  method zif_abapgit_object~jump.
    return.
  endmethod.


method zif_abapgit_object~map_filename_to_object.
  return.
endmethod.


method zif_abapgit_object~map_object_to_filename.
  return.
endmethod.


  method ZIF_ABAPGIT_OBJECT~SERIALIZE.

    data: lo_artifact      type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    field-symbols: <lt_standard_table> type standard table.

**********************************************************************

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = me->ms_item-obj_type ).

    lv_key = me->ms_item-obj_name.

    lo_artifact->get_table_content(
      exporting iv_key1          = lv_key
      importing et_table_content = lt_table_content ).

* set fields that will be skipped in the serialization process
    set_skip_fields( ).

* serialize
    loop at lt_table_content into ls_table_content.

      assign ls_table_content-table_content->* to <lt_standard_table>.

      check <lt_standard_table> is not initial.

      me->serialize_table(
        exporting
          iv_tabname = ls_table_content-tabname
          it_table   = <lt_standard_table> ).

    endloop.

  endmethod.
ENDCLASS.
