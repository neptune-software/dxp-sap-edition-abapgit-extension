class ZCL_ABAPGIT_OBJECT_ZN01 definition
  public
  inheriting from ZCL_ABAPGIT_OBJECTS_SUPER
  final
  create public .

public section.

  interfaces ZIF_ABAPGIT_OBJECT .
protected section.
private section.

  types:
    BEGIN OF ty_model,
             field TYPE string,
           END OF ty_model .
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN01 IMPLEMENTATION.


  method zif_abapgit_object~changed_by.
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


  METHOD ZIF_ABAPGIT_OBJECT~DELETE.
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_OBJECT~DESERIALIZE.

** pick up logic from CLASS ZCL_ABAPGIT_DATA_DESERIALIZER

  ENDMETHOD.


  METHOD ZIF_ABAPGIT_OBJECT~EXISTS.
    rv_bool = abap_true.
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_OBJECT~GET_COMPARATOR.
    RETURN.
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_OBJECT~GET_DESERIALIZE_STEPS.
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_OBJECT~GET_METADATA.
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_OBJECT~IS_ACTIVE.
    rv_active = abap_true.
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_OBJECT~IS_LOCKED.
  ENDMETHOD.


  METHOD ZIF_ABAPGIT_OBJECT~JUMP.
  ENDMETHOD.


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

*    break andrec.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = me->ms_item-obj_type ).

    lv_key = me->ms_item-obj_name.

    lo_artifact->get_table_content(
      exporting iv_key1          = lv_key
      importing et_table_content = lt_table_content ).

    loop at lt_table_content into ls_table_content.

      assign ls_table_content-table_content->* to <lt_standard_table>.


      try.
          lo_ajson = zcl_abapgit_ajson=>create_empty( ).
          lo_ajson->keep_item_order( ).
          lo_ajson->set(
            iv_path = '/'
            iv_val = <lt_standard_table> ).

*          if iv_skip_initial = abap_true.
*            lo_ajson = zcl_abapgit_ajson=>create_from(
*              ii_source_json = lo_ajson
*              ii_filter = zcl_abapgit_ajson_filter_lib=>create_empty_filter( ) ).
*          endif.

          lv_json = lo_ajson->stringify( 2 ).
        catch zcx_abapgit_ajson_error into lx_ajson.
          zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
      endtry.

      ls_file-path = '/'.
      ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_json ).
      ls_file-filename = zcl_abapgit_filename_logic=>object_to_file(
                             is_item  = me->ms_item
                             iv_extra = ls_table_content-tabname
                             iv_ext   = 'json' ).

      zif_abapgit_object~mo_files->add( ls_file ).

      free: lo_ajson.
      clear: lv_json, ls_file.

    endloop.

  endmethod.
ENDCLASS.
