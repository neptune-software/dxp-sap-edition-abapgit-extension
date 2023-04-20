class ZCL_ABAPGIT_OBJECT_ZN02 definition
  public
  inheriting from ZCL_ABAPGIT_OBJECTS_SUPER
  final
  create public .

public section.

  interfaces ZIF_ABAPGIT_OBJECT .
  protected section.
  private section.

    types:
      begin of ty_lcl_evtscr,
            applid    type /neptune/applid,
            field_id  type /neptune/field_id,
            version   type /neptune/version,
            event     type /neptune/event_id,
            file_name type string,
           end of ty_lcl_evtscr .
    types:
      ty_tt_lcl_evtscr type standard table of ty_lcl_evtscr .
    types:
      begin of ty_lcl_css,
            applid    type /neptune/applid,
            version   type /neptune/version,
            file_name type string,
           end of ty_lcl_css .
    types:
      ty_tt_lcl_css type standard table of ty_lcl_css .
    types:
      begin of ty_code,
            file_name type string,
            code      type string,
           end of ty_code .
    types:
      ty_tt_code type standard table of ty_code with non-unique key file_name .

    data gt_skip_paths type string_table .

    methods serialize_table
      importing
        !iv_tabname type tabname
        !it_table type any
      raising
        zcx_abapgit_exception .
    methods set_skip_fields .
    methods get_skip_fields
      returning
        value(rt_skip_paths) type string_table .
    methods deserialize_table
      importing
        !is_file type zif_abapgit_git_definitions=>ty_file
        !ir_data type ref to data
        !iv_tabname type tadir-obj_name
        !iv_key type /neptune/artifact_key
      raising
        zcx_abapgit_exception .
    methods get_values_from_filename
      importing
        !is_filename type string
      exporting
        !ev_tabname type tadir-obj_name
        !ev_obj_key type /neptune/artifact_key .
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN02 IMPLEMENTATION.


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
*      assign component 'APIID' of structure <ls_line> to <lv_field>.
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
    if sy-subrc eq 0.
*    translate ls_comp to upper case.
      ev_obj_key = ls_comp.
    endif.

    read table lt_comp into ls_comp index 3.
    if sy-subrc eq 0.
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

*    lv_skip = '*APIID'.
*    append lv_skip to gt_skip_paths.
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


  method zif_abapgit_object~changed_by.

    data: lo_artifact type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    data ls_api type /neptune/api.

    data lo_mapping type ref to zif_abapgit_key_mapping.
    data ls_mapping type zif_abapgit_key_mapping=>ty_mapping.
    data lv_artifact_name type /neptune/artifact_name.

    field-symbols <lt_standard_table> type standard table.

**********************************************************************

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = me->ms_item-obj_type ).

    lo_mapping = zcl_abapgit_key_mapping=>get_instance( ).

    lv_artifact_name =  me->ms_item-obj_name.

    lo_mapping->get_key(
      exporting
        iv_object_type   = me->ms_item-obj_type     " Neptune Artifact Type
        iv_artifact_name = lv_artifact_name     " Artifact Name
      receiving
        rv_key           = lv_key     " Artifact table key
    ).

    check lv_key is not initial.

*    lv_key = me->ms_item-obj_name.

    lo_artifact->get_table_content(
      exporting iv_key1          = lv_key
      importing et_table_content = lt_table_content ).

    read table lt_table_content into ls_table_content with table key tabname = '/NEPTUNE/API'.
    if sy-subrc eq 0.
      assign ls_table_content-table_content->* to <lt_standard_table>.
      read table <lt_standard_table> into ls_api index 1.
      if ls_api-updnam is not initial.
        rv_user = ls_api-updnam.
      else.
        rv_user = ls_api-crenam.
      endif.
    endif.

  endmethod.


  method ZIF_ABAPGIT_OBJECT~DELETE.
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

    loop at lt_files into ls_files where filename cs '.json'.

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
          iv_key     = lv_key
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
          iv_key1                 = lv_key    " Char 80
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


  method ZIF_ABAPGIT_OBJECT~GET_DESERIALIZE_STEPS.
    append zif_abapgit_object=>gc_step_id-late to rt_steps.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~GET_METADATA.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~IS_ACTIVE.
    rv_active = abap_true.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~IS_LOCKED.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~JUMP.
  endmethod.


  method zif_abapgit_object~serialize.

    data: lo_artifact      type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    data lo_mapping type ref to zif_abapgit_key_mapping.
    data ls_mapping type zif_abapgit_key_mapping=>ty_mapping.
    data lv_artifact_name type /neptune/artifact_name.

    field-symbols: <lt_standard_table> type standard table.

**********************************************************************

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = me->ms_item-obj_type ).

    lo_mapping = zcl_abapgit_key_mapping=>get_instance( ).

    lv_artifact_name =  me->ms_item-obj_name.

    lo_mapping->get_key(
      exporting
        iv_object_type   = me->ms_item-obj_type     " Neptune Artifact Type
        iv_artifact_name = lv_artifact_name     " Artifact Name
      receiving
        rv_key           = lv_key     " Artifact table key
    ).

    check lv_key is not initial.

*    lv_key = me->ms_item-obj_name.

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
