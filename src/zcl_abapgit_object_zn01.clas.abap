CLASS zcl_abapgit_object_zn01 DEFINITION
  PUBLIC
  INHERITING FROM zcl_abapgit_objects_super
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abapgit_object .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_abapgit_object_zn01 IMPLEMENTATION.


  METHOD zif_abapgit_object~changed_by.
  ENDMETHOD.


  METHOD zif_abapgit_object~delete.
  ENDMETHOD.


  METHOD zif_abapgit_object~deserialize.
  ENDMETHOD.


  METHOD zif_abapgit_object~exists.
    rv_bool = abap_true.
  ENDMETHOD.


  METHOD zif_abapgit_object~get_comparator.
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
  ENDMETHOD.
ENDCLASS.
