class ZCL_ABAPGIT_OBJECT_ZN02 definition
  public
  inheriting from ZCL_ABAPGIT_OBJECTS_SUPER
  final
  create public .

public section.

  interfaces ZIF_ABAPGIT_OBJECT .

  constants GC_CRLF type ABAP_CR_LF value CL_ABAP_CHAR_UTILITIES=>CR_LF. "#EC NOTEXT
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
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN02 IMPLEMENTATION.


method GET_SKIP_FIELDS.

  rt_skip_paths = gt_skip_paths.

endmethod.


method serialize_table.

  data: lo_artifact      type ref to /neptune/if_artifact_type,
        lo_ajson         type ref to zcl_abapgit_ajson,
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

  lv_skip = '*APIID'.
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
        lv_json          type string,
        lv_key           type /neptune/artifact_key.

  field-symbols <lt_standard_table> type standard table.

**********************************************************************
*    break andrec.

  lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = me->ms_item-obj_type ).

  lv_key = me->ms_item-obj_name.

  lo_artifact->get_table_content(
    exporting iv_key1          = lv_key
    importing et_table_content = lt_table_content ).

  loop at lt_table_content into ls_table_content.
    assign ls_table_content-table_content->* to <lt_standard_table>.
  endloop.

endmethod.


method ZIF_ABAPGIT_OBJECT~DELETE.
endmethod.


method ZIF_ABAPGIT_OBJECT~DESERIALIZE.
** pick up logic from CLASS ZCL_ABAPGIT_DATA_DESERIALIZER

  data lt_files type zif_abapgit_git_definitions=>ty_files_tt.

  lt_files = zif_abapgit_object~mo_files->get_files( ).

endmethod.


method ZIF_ABAPGIT_OBJECT~EXISTS.
  rv_bool = abap_true.
endmethod.


method ZIF_ABAPGIT_OBJECT~GET_COMPARATOR.
  RETURN.
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
        lo_ajson         type ref to zcl_abapgit_ajson,
        lx_ajson         type ref to zcx_abapgit_ajson_error,
        lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
        ls_table_content like line of lt_table_content,
        lv_json          type string,
        lv_key           type /neptune/artifact_key,
        ls_file          type zif_abapgit_git_definitions=>ty_file.

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

    me->serialize_table(
      exporting
        iv_tabname = ls_table_content-tabname
        it_table   = <lt_standard_table> ).

  endloop.

endmethod.
ENDCLASS.
