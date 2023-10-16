class ZCL_ABAPGIT_UTILITIES definition
  public
  final
  create public .

public section.

  class-methods GET_PACKAGE_PATH
    importing
      !IV_DEVCLASS type DEVCLASS
      !IV_SUB_DEVCLASS type DEVCLASS
    returning
      value(RV_PATH) type STRING .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ABAPGIT_UTILITIES IMPLEMENTATION.


method get_package_path.

  data: lo_repo type ref to zif_abapgit_repo,
        lo_dot  type ref to zcl_abapgit_dot_abapgit,
        lo_folder_logic type ref to zcl_abapgit_folder_logic.

  try.

      zcl_abapgit_repo_srv=>get_instance( )->get_repo_from_package(
        exporting
          iv_package = iv_devclass
        importing
          ei_repo    = lo_repo ).

      create object lo_dot
        exporting
          is_data = lo_repo->ms_data-dot_abapgit.

      lo_folder_logic = zcl_abapgit_folder_logic=>get_instance( ).

      rv_path = lo_folder_logic->package_to_path(
        iv_top     = iv_devclass
        io_dot     = lo_dot
        iv_package = iv_sub_devclass ).

    catch zcx_abapgit_exception.
  endtry.
endmethod.
ENDCLASS.
