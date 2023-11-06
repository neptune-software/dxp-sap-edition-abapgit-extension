class zcl_abapgit_object_zn00 definition
  public
  inheriting from zcl_abapgit_objects_super
  final
  create public .

  public section.

    interfaces zif_abapgit_object .
  protected section.
  private section.

    types:
      begin of ty_metadata,
        version        type /neptune/lib_002-version,
        patchversion   type /neptune/lib_002-patchversion,
        sapui5_version type /neptune/global-sapui5_version,
      end of ty_metadata.
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN00 IMPLEMENTATION.


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

    data ls_metadata type ty_metadata.

    select single version patchversion from /neptune/lib_002
      into (ls_metadata-version, ls_metadata-patchversion). "#EC CI_NOWHERE
    if sy-subrc = 0.

      select single sapui5_version
        from /neptune/global
        into ls_metadata-sapui5_version.                "#EC CI_NOWHERE
      if sy-subrc = 0 and ls_metadata-sapui5_version is initial.
        ls_metadata-sapui5_version = /neptune/cl_nad_server=>version-ui5.
      endif.

      try.
          io_xml->add(
            iv_name = 'meta'
            ig_data = ls_metadata ).
        catch zcx_abapgit_exception.
      endtry.

    endif.
  endmethod.
ENDCLASS.
