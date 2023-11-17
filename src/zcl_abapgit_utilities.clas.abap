class ZCL_ABAPGIT_UTILITIES definition
  public
  final
  create public .

public section.

  class CL_ABAP_CHAR_UTILITIES definition load .
  constants GC_EOL type C value CL_ABAP_CHAR_UTILITIES=>NEWLINE. "#EC NOTEXT

  class-methods GET_PACKAGE_PATH
    importing
      !IV_DEVCLASS type DEVCLASS
      !IV_SUB_DEVCLASS type DEVCLASS
    returning
      value(RV_PATH) type STRING .
  class-methods CODE_LINES_TO_STRING
    importing
      !IT_CODE_LINES type STRING_TABLE
    returning
      value(RV_STRING) type STRING .
  class-methods STRING_TO_CODE_LINES
    importing
      !IV_STRING type STRING
    returning
      value(RT_CODE_LINES) type STRING_TABLE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ABAPGIT_UTILITIES IMPLEMENTATION.


method code_lines_to_string.

  concatenate lines of it_code_lines into rv_string separated by gc_eol.
* when editing files via eg. GitHub web interface it adds a newline at end of file
  rv_string = rv_string && cl_abap_char_utilities=>newline.

endmethod.


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


method string_to_code_lines.

  split iv_string at gc_eol into table rt_code_lines.

endmethod.
ENDCLASS.
