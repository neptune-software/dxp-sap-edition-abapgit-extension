CLASS zcl_abapgit_object_zn01 DEFINITION
  PUBLIC
  INHERITING FROM zcl_abapgit_objects_super
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abapgit_object .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES: BEGIN OF ty_model,
             field TYPE string,
           END OF ty_model.
ENDCLASS.



CLASS zcl_abapgit_object_zn01 IMPLEMENTATION.


  METHOD zif_abapgit_object~changed_by.
  ENDMETHOD.


  METHOD zif_abapgit_object~delete.
  ENDMETHOD.


  METHOD zif_abapgit_object~deserialize.

    DATA lo_json_handler TYPE REF TO zcl_abapgit_json_handler.
    DATA lv_xjson        TYPE xstring.
    DATA ls_data         TYPE ty_model.

    lv_xjson = zif_abapgit_object~mo_files->read_raw( iv_ext = 'json' ).

    CREATE OBJECT lo_json_handler.
    lo_json_handler->deserialize(
      EXPORTING
        iv_content = lv_xjson
      IMPORTING
        ev_data    = ls_data ).

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


  METHOD zif_abapgit_object~serialize.

    DATA ls_data         TYPE ty_model.
    DATA lv_xjson        TYPE xstring.
    DATA lo_json_handler TYPE REF TO zcl_abapgit_json_handler.

    ls_data-field = 'sdf'.

    CREATE OBJECT lo_json_handler.
    lv_xjson = lo_json_handler->serialize( ls_data ).

    zif_abapgit_object~mo_files->add_raw(
      iv_ext  = 'json'
      iv_data = lv_xjson ).

  ENDMETHOD.
ENDCLASS.
