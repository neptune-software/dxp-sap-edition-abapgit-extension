class ZCL_ABAPGIT_OBJECT_ZN03 definition
  public
  inheriting from ZCL_ABAPGIT_OBJECTS_SUPER
  final
  create public .

public section.

  interfaces ZIF_ABAPGIT_OBJECT .
protected section.
private section.

  methods SERIALIZE_TABLE
    importing
      !IV_TABNAME type TABNAME
      !IT_TABLE type ANY
    raising
      ZCX_ABAPGIT_EXCEPTION .
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN03 IMPLEMENTATION.


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
*      it_skip_paths = get_skip_fields( ).
*      if it_skip_paths is not initial.
*        lo_ajson = zcl_abapgit_ajson=>create_from(
*          ii_source_json = lo_ajson
*          ii_filter = zcl_abapgit_ajson_filter_lib=>create_path_filter(
*                                                      it_skip_paths     = it_skip_paths
*                                                      iv_pattern_search = abap_true ) ).
*      endif.

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


method ZIF_ABAPGIT_OBJECT~CHANGED_BY.
endmethod.


method ZIF_ABAPGIT_OBJECT~DELETE.
endmethod.


method ZIF_ABAPGIT_OBJECT~DESERIALIZE.
endmethod.


method ZIF_ABAPGIT_OBJECT~EXISTS.
  rv_bool = abap_true.
endmethod.


method zif_abapgit_object~get_comparator.
  return.
endmethod.


method zif_abapgit_object~get_deserialize_steps.
  append zif_abapgit_object=>gc_step_id-late to rt_steps.
endmethod.


method ZIF_ABAPGIT_OBJECT~GET_METADATA.
endmethod.


method zif_abapgit_object~is_active.
  rv_active = abap_true.
endmethod.


method ZIF_ABAPGIT_OBJECT~IS_LOCKED.
endmethod.


method ZIF_ABAPGIT_OBJECT~JUMP.
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
*  set_skip_fields( ).

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
