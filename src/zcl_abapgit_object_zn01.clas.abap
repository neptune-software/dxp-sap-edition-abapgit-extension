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
          lv_key           type /neptune/tadir-key1.

    field-symbols <lt_standard_table> type standard table.

**********************************************************************
    break andrec.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = me->ms_item-obj_type ).

    lv_key = me->ms_item-obj_name.

    lo_artifact->get_table_content(
      exporting iv_key1          = lv_key
      importing et_table_content = lt_table_content ).

    loop at lt_table_content into ls_table_content.
      assign ls_table_content-table_content->* to <lt_standard_table>.
    endloop.



  endmethod.


  METHOD zif_abapgit_object~delete.
  ENDMETHOD.


  METHOD zif_abapgit_object~deserialize.

    DATA lo_json_handler TYPE REF TO zcl_abapgit_json_handler.
    DATA lv_xjson        TYPE xstring.
    DATA ls_data         TYPE ty_model.

IF sy-uname eq 'ANDREC'.
BREAK-POINT.
ENDIF.

*    lv_xjson = zif_abapgit_object~mo_files->read_raw( iv_ext = 'json' ).
*
*    CREATE OBJECT lo_json_handler.
*    lo_json_handler->deserialize(
*      EXPORTING
*        iv_content = lv_xjson
*      IMPORTING
*        ev_data    = ls_data ).

  ENDMETHOD.


  METHOD zif_abapgit_object~exists.
    rv_bool = abap_true.
  ENDMETHOD.


  METHOD zif_abapgit_object~get_comparator.
    RETURN.
  ENDMETHOD.


  METHOD zif_abapgit_object~get_deserialize_steps.
  ENDMETHOD.


  METHOD zif_abapgit_object~get_metadata.
  ENDMETHOD.


  METHOD zif_abapgit_object~is_active.
    rv_active = abap_true.
  ENDMETHOD.


  METHOD zif_abapgit_object~is_locked.
  ENDMETHOD.


  METHOD zif_abapgit_object~jump.
  ENDMETHOD.


  method zif_abapgit_object~serialize.

    data lv_xjson        type xstring.
    data lo_json_handler type ref to zcl_abapgit_json_handler.

    data: lo_artifact type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_json          type string.

    data: lv_key           type /neptune/artifact_key.

    field-symbols <lt_standard_table> type standard table.


    data: lv_enum_mappings  type zcl_abapgit_json_handler=>ty_enum_mappings,
          lv_skip_paths	type zcl_abapgit_json_handler=>ty_skip_paths.

**********************************************************************

    break andrec.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = me->ms_item-obj_type ).

    lv_key = me->ms_item-obj_name.

    lo_artifact->get_table_content(
      exporting iv_key1          = lv_key
      importing et_table_content = lt_table_content ).

    loop at lt_table_content into ls_table_content.
      assign ls_table_content-table_content->* to <lt_standard_table>.

      create object lo_json_handler.
      try.
          call method lo_json_handler->serialize
            exporting
              iv_data          = <lt_standard_table>
              iv_enum_mappings = lv_enum_mappings
              iv_skip_paths    = lv_skip_paths
            receiving
              rv_result        = lv_xjson.
        catch cx_static_check .
          break andrec.
      endtry.


    endloop.

*    ls_data-field = 'sdf'.
*
*    CREATE OBJECT lo_json_handler.
*    lv_xjson = lo_json_handler->serialize( IV_DATA = ls_data ).
*
*    zif_abapgit_object~mo_files->add_raw(
*      iv_ext  = 'json'
*      iv_data = lv_xjson ).

  endmethod.
ENDCLASS.
