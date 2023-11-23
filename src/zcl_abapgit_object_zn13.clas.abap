class zcl_abapgit_object_zn13 definition
  public
  inheriting from zcl_abapgit_objects_super
  final
  create public .

  public section.

    interfaces zif_abapgit_object .

  protected section.
private section.

  types:
    begin of ty_mapping,
                  key type tadir-obj_name,
                  name type string,
                 end of ty_mapping .
  types:
    ty_mapping_tt type standard table of ty_mapping with key key .

  constants:
    mc_name_separator(1)  type c value '@'. "#EC NOTEXT
  constants:
    mc_colorset_cammel(8) type c value 'ColorSet'. "#EC NOTEXT
  constants:
    mc_colorset_lower(8)  type c value 'colorset'. "#EC NOTEXT
  class-data GT_MAPPING type TY_MAPPING_TT .
  data MT_SKIP_PATHS type STRING_TABLE .
  data MV_ARTIFACT_TYPE type /NEPTUNE/ARTIFACT_TYPE .

  methods SERIALIZE_TABLE
    importing
      !IV_TABNAME type TABNAME
      !IT_TABLE type ANY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  interface ZIF_ABAPGIT_GIT_DEFINITIONS load .
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
  methods INSERT_TO_TRANSPORT
    importing
      !IO_ARTIFACT type ref to /NEPTUNE/IF_ARTIFACT_TYPE
      !IV_TRANSPORT type TRKORR
      !IV_PACKAGE type DEVCLASS
      !IV_KEY1 type ANY
      !IV_ARTIFACT_TYPE type /NEPTUNE/ATY-ARTIFACT_TYPE .
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN13 IMPLEMENTATION.


  method deserialize_table.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data lt_table_content type ref to data.

    field-symbols <lt_tab> type any table.
    field-symbols <lt_standard_table> type standard table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    create data lt_table_content type standard table of (iv_tabname) with non-unique default key.
    assign lt_table_content->* to <lt_standard_table>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).

        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = <lt_standard_table> ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    <lt_tab> = <lt_standard_table>.

  endmethod.


  method get_values_from_filename.

    data lt_comp type standard table of string with default key.
    data ls_comp like line of lt_comp.
    data lv_key type /neptune/artifact_key.
    data lv_name type string.

    split is_filename at '.' into table lt_comp.

    read table lt_comp into ls_comp index 1.
    if sy-subrc = 0.
      split ls_comp at mc_name_separator into lv_name lv_key.
      translate lv_name to upper case.
      ev_name = lv_name.
    endif.

    read table lt_comp into ls_comp index 3.
    if sy-subrc = 0.
      replace all occurrences of '#' in ls_comp with '/'.
      translate ls_comp to upper case.
      ev_tabname = ls_comp.
    endif.

  endmethod.


  method insert_to_transport.

    data ls_message type /neptune/message.
    data lv_task type trkorr.

    /neptune/cl_nad_transport=>transport_task_find(
      exporting
        transport = iv_transport
      importing
        task      = lv_task ).

    io_artifact->insert_to_transport(
      exporting
        iv_korrnum = lv_task
        iv_key1    = iv_key1
      importing
        ev_message = ls_message ).

    try.
        call method ('/NEPTUNE/CL_TADIR')=>('INSERT_TO_TRANSPORT')
*            call method /neptune/cl_tadir=>insert_to_transport
            exporting
              iv_korrnum       = lv_task
              iv_devclass      = iv_package
              iv_artifact_key  = iv_key1
              iv_artifact_type = iv_artifact_type
            importing
              ev_message      = ls_message.
      catch cx_sy_dyn_call_illegal_class
            cx_sy_dyn_call_illegal_method.
    endtry.

  endmethod.


  method serialize_table.

    data: lo_ajson         type ref to zcl_abapgit_ajson,
          lx_ajson         type ref to zcx_abapgit_ajson_error,
          lv_json          type string,
          ls_file          type zif_abapgit_git_definitions=>ty_file.

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
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    ls_file-path = '/'.
    ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_json ).
    ls_file-filename = zcl_abapgit_filename_logic=>object_to_file(
                           is_item  = ms_item
                           iv_extra = iv_tabname
                           iv_ext   = 'json' ).

    zif_abapgit_object~mo_files->add( ls_file ).

  endmethod.


  method zif_abapgit_object~changed_by.

    data: lo_artifact type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    data ls_cusclrs type /neptune/cusclrs.

    field-symbols <lt_standard_table> type standard table.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

    lv_key = ms_item-obj_name.
    translate lv_key to lower case.
    replace mc_colorset_lower in lv_key with mc_colorset_cammel.

    lo_artifact->get_table_content(
      exporting iv_key1                 = lv_key
                iv_only_sys_independent = abap_true
      importing et_table_content        = lt_table_content ).

    read table lt_table_content into ls_table_content with table key tabname = '/NEPTUNE/CUSCLRS'.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_standard_table>.
      check sy-subrc = 0.
      read table <lt_standard_table> into ls_cusclrs index 1.
      if sy-subrc = 0 and ls_cusclrs-updnam is not initial.
        rv_user = ls_cusclrs-updnam.
      else.
        rv_user = ls_cusclrs-crenam.
      endif.
    endif.

  endmethod.


  method zif_abapgit_object~delete.

    data: lo_artifact type ref to /neptune/if_artifact_type,
          ls_settings type /neptune/aty,
          lv_key1     type /neptune/artifact_key.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    ls_settings = lo_artifact->get_settings( ).

    lv_key1 = ms_item-obj_name.
    translate lv_key1 to lower case.
    replace mc_colorset_lower in lv_key1 with mc_colorset_cammel.

    lo_artifact->delete_artifact(
      iv_key1     = lv_key1
      iv_devclass = iv_package ).

    lo_artifact->delete_tadir_entry( iv_key1 = lv_key1 ).

    if ls_settings-transportable is not initial and iv_transport is not initial.

      insert_to_transport(
        io_artifact      = lo_artifact
        iv_transport     = iv_transport
        iv_package       = iv_package
        iv_key1          = lv_key1
        iv_artifact_type = ls_settings-artifact_type ).

    endif.

  endmethod.


  method zif_abapgit_object~deserialize.

** pick up logic from CLASS ZCL_ABAPGIT_DATA_DESERIALIZER

    data: lt_files type zif_abapgit_git_definitions=>ty_files_tt,
          ls_files like line of lt_files.

    data: lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content.

    data lr_data    type ref to data.
    data lv_tabname type tadir-obj_name.
    data lv_key     type /neptune/artifact_key.
    data lv_name    type /neptune/artifact_name.

    data lo_artifact type ref to /neptune/if_artifact_type.
    data ls_settings type /neptune/aty.

    try.
        io_xml->read(
          exporting
            iv_name = 'key'
          changing
            cg_data = lv_key ).
      catch zcx_abapgit_exception.
    endtry.

    lt_files = zif_abapgit_object~mo_files->get_files( ).

    loop at lt_files into ls_files where filename cs '.json'.

      get_values_from_filename(
        exporting
          is_filename = ls_files-filename
        importing
          ev_tabname  = lv_tabname
          ev_name     = lv_name ).

      create data lr_data type standard table of (lv_tabname) with non-unique default key.

      deserialize_table(
        is_file    = ls_files
        iv_tabname = lv_tabname
        ir_data    = lr_data ).

      ls_table_content-tabname = lv_tabname.
      ls_table_content-table_content = lr_data.
      append ls_table_content to lt_table_content.
      clear ls_table_content.

    endloop.

    if lt_table_content is not initial.

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

      if ls_settings-transportable is not initial and iv_transport is not initial.

        insert_to_transport(
          io_artifact      = lo_artifact
          iv_transport     = iv_transport
          iv_package       = iv_package
          iv_key1          = lv_key
          iv_artifact_type = ls_settings-artifact_type ).

      endif.

    endif.

  endmethod.


  method zif_abapgit_object~exists.
    rv_bool = abap_true.
  endmethod.


  method zif_abapgit_object~get_comparator.
    return.
  endmethod.


  method zif_abapgit_object~get_deserialize_order.
    return.
  endmethod.


  method zif_abapgit_object~get_deserialize_steps.
    append zif_abapgit_object=>gc_step_id-late to rt_steps.
  endmethod.


  method zif_abapgit_object~get_metadata.
    return.
  endmethod.


  method zif_abapgit_object~is_active.
    rv_active = abap_true.
  endmethod.


  method zif_abapgit_object~is_locked.

    data lo_artifact type ref to /neptune/if_artifact_type.
    data lv_key type /neptune/artifact_key.

    lv_key = ms_item-obj_name.
    translate lv_key to lower case.
    replace mc_colorset_lower in lv_key with mc_colorset_cammel.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    rv_is_locked = lo_artifact->check_artifact_is_locked( iv_key = lv_key ).

  endmethod.


  method zif_abapgit_object~jump.
    return.
  endmethod.


  method zif_abapgit_object~map_filename_to_object.

    data lt_parts type standard table of string with default key.
    data: lv_artifact_name type string,
          lv_key type string,
          lv_filename type string.
    data ls_mapping like line of gt_mapping.

    split iv_filename at mc_name_separator into lv_artifact_name lv_filename.
    split lv_filename at '.' into table lt_parts.
    read table lt_parts into lv_key index 1.
    check sy-subrc = 0.

    if lv_artifact_name is not initial.
      translate lv_key to upper case.
      cs_item-obj_name = lv_key.

      read table gt_mapping transporting no fields with key key = lv_key.
      check sy-subrc <> 0.

      ls_mapping-key = lv_key.
      ls_mapping-name = lv_artifact_name.
      append ls_mapping to gt_mapping.

    endif.

  endmethod.


  method zif_abapgit_object~map_object_to_filename.

    data ls_mapping like line of gt_mapping.
    data ls_tadir type /neptune/if_artifact_type=>ty_lcl_tadir.
    data lv_key type /neptune/artifact_key.

    check is_item-devclass is not initial.

    lv_key = is_item-obj_name.
    translate lv_key to lower case.
    replace mc_colorset_lower in lv_key with mc_colorset_cammel.

    try.
        " Ongoing from DXP 23 fetch wie tadir framework (all artifacts can be assigned to a devclass)
        call method ('/NEPTUNE/CL_TADIR')=>('GET_ARTIFACT_ENTRY')
*          call method  /neptune/cl_tadir=>get_artifact_entry
          exporting
            iv_key           = lv_key
            iv_devclass      = is_item-devclass
            iv_artifact_type = /neptune/if_artifact_type=>gc_artifact_type-colorset
          receiving
            rs_tadir    = ls_tadir          ##called.

      catch cx_sy_dyn_call_illegal_class
            cx_sy_dyn_call_illegal_method.

        return.

    endtry.

    if ls_tadir is not initial.
      concatenate ls_tadir-artifact_name cv_filename into cv_filename separated by mc_name_separator.
    else.
      read table gt_mapping into ls_mapping with key key = is_item-obj_name.
      if sy-subrc = 0.
        concatenate ls_mapping-name cv_filename into cv_filename separated by mc_name_separator.
      endif.
    endif.

  endmethod.


  method zif_abapgit_object~serialize.

    data: lo_artifact      type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    field-symbols <lt_standard_table> type standard table.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    mv_artifact_type = lo_artifact->artifact_type.

    lv_key = ms_item-obj_name.
    translate lv_key to lower case.

    replace mc_colorset_lower in lv_key with mc_colorset_cammel.

    try.
        io_xml->add(
          iv_name = 'key'
          ig_data = lv_key ).
      catch zcx_abapgit_exception.
    endtry.

    lo_artifact->get_table_content(
      exporting iv_key1                 = lv_key
                iv_only_sys_independent = abap_true
      importing et_table_content        = lt_table_content ).

* serialize
    loop at lt_table_content into ls_table_content.
      assign ls_table_content-table_content->* to <lt_standard_table>.

      check sy-subrc = 0 and <lt_standard_table> is not initial.

      serialize_table(
        iv_tabname = ls_table_content-tabname
        it_table   = <lt_standard_table> ).
    endloop.

  endmethod.
ENDCLASS.
