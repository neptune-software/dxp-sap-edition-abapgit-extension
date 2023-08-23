class zcl_abapgit_object_zn00 definition
  public
  inheriting from zcl_abapgit_objects_super
  final
  create public .

  public section.

    interfaces zif_abapgit_object .
  protected section.
  private section.
endclass.



class zcl_abapgit_object_zn00 implementation.


  method zif_abapgit_object~changed_by.
    return.
  endmethod.


  method zif_abapgit_object~delete.
    return.
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
    return.
  endmethod.


  method zif_abapgit_object~get_deserialize_order.
    return.
  endmethod.


  method zif_abapgit_object~get_deserialize_steps.
    return.
  endmethod.


  method zif_abapgit_object~get_metadata.
    return.
  endmethod.


  method zif_abapgit_object~is_active.
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


  method zif_abapgit_object~serialize.

    data ls_lib_002 type /neptune/lib_002.

    select single * from /neptune/lib_002
      into ls_lib_002.

    check sy-subrc = 0.

    try.
        io_xml->add(
          iv_name = 'meta'
          ig_data = ls_lib_002 ).
      catch zcx_abapgit_exception.
    endtry.

  endmethod.
endclass.
