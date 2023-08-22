class zcl_abapgit_object_zn00 definition
  public
  inheriting from zcl_abapgit_objects_super
  final
  create public .

  public section.

    interfaces zif_abapgit_object .
  protected section.
  private section.
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN00 IMPLEMENTATION.


  method zif_abapgit_object~changed_by.
  endmethod.


  method zif_abapgit_object~delete.
  endmethod.


  method zif_abapgit_object~deserialize.

    data ls_lib_002 type /neptune/lib_002.

    try.
        io_xml->read(
          exporting
            iv_name = 'meta'
          changing
            cg_data = ls_lib_002 ).
      catch zcx_abapgit_exception.
    endtry.

  endmethod.


  method zif_abapgit_object~exists.
    rv_bool = abap_true.
  endmethod.


  method zif_abapgit_object~get_comparator.
  endmethod.


  method zif_abapgit_object~get_deserialize_order.
  endmethod.


  method zif_abapgit_object~get_deserialize_steps.
  endmethod.


  method zif_abapgit_object~get_metadata.
  endmethod.


  method zif_abapgit_object~is_active.
    rv_active = abap_true.
  endmethod.


  method zif_abapgit_object~is_locked.
  endmethod.


  method zif_abapgit_object~jump.
  endmethod.


  method zif_abapgit_object~map_filename_to_object.
  endmethod.


  method zif_abapgit_object~map_object_to_filename.
  endmethod.


  method zif_abapgit_object~serialize.

    data ls_lib_002 type /neptune/lib_002.

    select single * from /neptune/lib_002
      into ls_lib_002.

    try.
        io_xml->add(
          iv_name = 'meta'
          ig_data = ls_lib_002 ).
      catch zcx_abapgit_exception.
    endtry.

  endmethod.
ENDCLASS.
