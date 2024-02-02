class ZCL_NEPTUNE_ABAPGIT_UTILITIES definition
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
  class-methods FIX_STRING_SERIALIZE
    changing
      !CV_STRING type STRING ##NEEDED. 
  class-methods FIX_STRING_DESERIALIZE
    changing
      !CV_STRING type STRING ##NEEDED. 
  class-methods GET_SKIP_FIELDS_FOR_ARTIFACT
    importing
      !IV_ARTIFACT_TYPE type /NEPTUNE/ARTIFACT_TYPE
      !IV_SERIALIZE type BOOLE_D optional
      !IV_TABNAME type TABNAME optional
    returning
      value(RT_FIELDS) type STRING_TABLE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_NEPTUNE_ABAPGIT_UTILITIES IMPLEMENTATION.


method CODE_LINES_TO_STRING.

  concatenate lines of it_code_lines into rv_string separated by gc_eol respecting blanks.
* when editing files via eg. GitHub web interface it adds a newline at end of file
  rv_string = rv_string && cl_abap_char_utilities=>newline.

endmethod.


method FIX_STRING_DESERIALIZE.
* in the future when we swapp ace editor for monaco in all artifacts like Global Style in Launchpad
* we will probablly need to replace NEWLINE with CR_LF.
endmethod.


method FIX_STRING_SERIALIZE.
* in the future when we swapp ace editor for monaco in all artifacts like Global Style in Launchpad
* we will probablly need to replace CR_LF with NEWLINE
endmethod.


method GET_PACKAGE_PATH.
**********************************************************************
* this method is used in /neptune/cl_abapgit_user_exit=>change_tadir
**********************************************************************

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


method get_skip_fields_for_artifact.

  data: lo_artifact_type   type ref to /neptune/if_artifact_type,
        lt_artifact_fields type /neptune/if_artifact_type=>ty_t_artifact_fields,
        ls_field           like line of rt_fields.

  field-symbols: <ls_artifact_field> like line of lt_artifact_fields.

  lo_artifact_type = /neptune/cl_artifact_type=>get_instance( iv_artifact_type = iv_artifact_type ).
  lt_artifact_fields = lo_artifact_type->get_artifact_fields( iv_tabname = iv_tabname ).

  loop at lt_artifact_fields assigning <ls_artifact_field>.
    if iv_serialize eq abap_true.
      concatenate '*' <ls_artifact_field>-fieldname into ls_field.
    else.
      ls_field = <ls_artifact_field>-fieldname.
    endif.
    insert ls_field into table rt_fields.
  endloop.

endmethod.


method STRING_TO_CODE_LINES.

  split iv_string at gc_eol into table rt_code_lines.

endmethod.
ENDCLASS.
