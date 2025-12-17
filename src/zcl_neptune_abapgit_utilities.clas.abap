CLASS zcl_neptune_abapgit_utilities DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_mapping,
                  key TYPE tadir-obj_name,
                  name TYPE string,
                 END OF ty_mapping .
    TYPES:
      ty_mapping_tt TYPE STANDARD TABLE OF ty_mapping WITH KEY key .

    CLASS cl_abap_char_utilities DEFINITION LOAD .
    CONSTANTS gc_eol TYPE c VALUE cl_abap_char_utilities=>newline. "#EC NOTEXT
    CONSTANTS:
      mc_name_separator(1) TYPE c VALUE '@'. "#EC NOTEXT

    CLASS-METHODS get_package_path
      IMPORTING
      !iv_devclass TYPE devclass
      !iv_sub_devclass TYPE devclass
      RETURNING
      VALUE(rv_path) TYPE string .
    CLASS-METHODS code_lines_to_string
      IMPORTING
      !it_code_lines TYPE string_table
      RETURNING
      VALUE(rv_string) TYPE string .
    CLASS-METHODS string_to_code_lines
      IMPORTING
      !iv_string TYPE string
      RETURNING
      VALUE(rt_code_lines) TYPE string_table .
    CLASS-METHODS fix_string_serialize
      CHANGING
      !cv_string TYPE string . "#EC NEEDED
    CLASS-METHODS fix_string_deserialize
      CHANGING
      !cv_string TYPE string . "#EC NEEDED
    CLASS-METHODS get_skip_fields_for_artifact
      IMPORTING
      !iv_artifact_type TYPE /neptune/artifact_type
      !iv_serialize TYPE boole_d OPTIONAL
      !iv_tabname TYPE tabname OPTIONAL
      RETURNING
      VALUE(rt_fields) TYPE string_table .
    INTERFACE zif_abapgit_definitions LOAD .
    CLASS-METHODS map_filename_to_object
      IMPORTING
      !iv_item_part_of_filename TYPE clike
      CHANGING
      !cs_item TYPE zif_abapgit_definitions=>ty_item
      !ct_mapping TYPE ty_mapping_tt
      RAISING
      zcx_abapgit_exception .

    CLASS-METHODS map_object_to_filename
      IMPORTING
      !is_item TYPE zif_abapgit_definitions=>ty_item
      !it_mapping TYPE ty_mapping_tt
      !iv_artifact_key TYPE /neptune/artifact_key
      !iv_artifact_type TYPE /neptune/artifact_type
      !iv_ext TYPE clike
      !iv_extra TYPE clike
      !iv_modular_file_parts TYPE abap_bool
      CHANGING
      !cv_item_part_of_filename TYPE string
      RAISING
      zcx_abapgit_exception . "#EC NEEDED
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_neptune_abapgit_utilities IMPLEMENTATION.


  METHOD code_lines_to_string.

    CONCATENATE LINES OF it_code_lines INTO rv_string SEPARATED BY gc_eol RESPECTING BLANKS.
* when editing files via eg. GitHub web interface it adds a newline at end of file
    rv_string = rv_string && cl_abap_char_utilities=>newline.

  ENDMETHOD.


  METHOD fix_string_deserialize.
* in the future when we swapp ace editor for monaco in all artifacts like Global Style in Launchpad
* we will probablly need to replace NEWLINE with CR_LF.
  ENDMETHOD.


  METHOD fix_string_serialize.
* in the future when we swapp ace editor for monaco in all artifacts like Global Style in Launchpad
* we will probablly need to replace CR_LF with NEWLINE
  ENDMETHOD.


  METHOD get_package_path.
**********************************************************************
* this method is used in /neptune/cl_abapgit_user_exit=>change_tadir
**********************************************************************

    DATA: lo_repo TYPE REF TO zif_abapgit_repo,
        lo_dot  TYPE REF TO zcl_abapgit_dot_abapgit,
        lo_folder_logic TYPE REF TO zcl_abapgit_folder_logic.

    TRY.

        zcl_abapgit_repo_srv=>get_instance( )->get_repo_from_package(
          EXPORTING
          iv_package = iv_devclass
          IMPORTING
          ei_repo    = lo_repo ).

        CREATE OBJECT lo_dot
          EXPORTING
          is_data = lo_repo->ms_data-dot_abapgit.

        lo_folder_logic = zcl_abapgit_folder_logic=>get_instance( ).

        rv_path = lo_folder_logic->package_to_path(
          iv_top     = iv_devclass
          io_dot     = lo_dot
          iv_package = iv_sub_devclass ).

      CATCH zcx_abapgit_exception.
    ENDTRY.
  ENDMETHOD.


  METHOD get_skip_fields_for_artifact.

    DATA: lo_artifact_type   TYPE REF TO /neptune/if_artifact_type,
        lt_artifact_fields TYPE /neptune/if_artifact_type=>ty_t_artifact_fields,
        ls_field           LIKE LINE OF rt_fields.

    FIELD-SYMBOLS: <ls_artifact_field> LIKE LINE OF lt_artifact_fields.

    lo_artifact_type = /neptune/cl_artifact_type=>get_instance( iv_artifact_type = iv_artifact_type ).
    lt_artifact_fields = lo_artifact_type->get_artifact_fields( iv_tabname = iv_tabname ).

    LOOP AT lt_artifact_fields ASSIGNING <ls_artifact_field>.
      IF iv_serialize EQ abap_true.
        CONCATENATE '*' <ls_artifact_field>-fieldname INTO ls_field.
      ELSE.
        ls_field = <ls_artifact_field>-fieldname.
      ENDIF.
      INSERT ls_field INTO TABLE rt_fields.
    ENDLOOP.

  ENDMETHOD.


  METHOD map_filename_to_object.

    DATA lt_parts          TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA: lv_artifact_name TYPE string,
        lv_key           TYPE string,
        lv_filename      TYPE string.

    DATA ls_mapping LIKE LINE OF ct_mapping.

    SPLIT iv_item_part_of_filename AT mc_name_separator INTO lv_artifact_name lv_filename.
    SPLIT lv_filename AT '.' INTO TABLE lt_parts.
    READ TABLE lt_parts INTO lv_key INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF lv_artifact_name IS NOT INITIAL.
      TRANSLATE lv_key TO UPPER CASE.
      cs_item-obj_name = lv_key.

      READ TABLE ct_mapping TRANSPORTING NO FIELDS WITH KEY key = lv_key.
      IF sy-subrc = 0.
        RETURN.
      ENDIF.

      ls_mapping-key = lv_key.
      ls_mapping-name = lv_artifact_name.
      INSERT ls_mapping INTO TABLE ct_mapping.

    ENDIF.

  ENDMETHOD.


  METHOD map_object_to_filename.

    DATA ls_mapping LIKE LINE OF it_mapping.
    DATA ls_tadir TYPE /neptune/if_artifact_type=>ty_lcl_tadir.

    IF is_item-devclass IS INITIAL OR
        iv_artifact_key  IS INITIAL OR
        iv_artifact_type IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
      " Ongoing from DXP 23 fetch wie tadir framework (all artifacts can be assigned to a devclass)
        CALL METHOD ('/NEPTUNE/CL_TADIR')=>('GET_ARTIFACT_ENTRY')
*          call method  /neptune/cl_tadir=>get_artifact_entry
          EXPORTING
          iv_key           = iv_artifact_key
          iv_devclass      = is_item-devclass
          iv_artifact_type = iv_artifact_type
          RECEIVING
          rs_tadir    = ls_tadir          ##called.

      CATCH cx_sy_dyn_call_illegal_class
          cx_sy_dyn_call_illegal_method.

        RETURN.

    ENDTRY.

    IF ls_tadir IS NOT INITIAL.
      CONCATENATE ls_tadir-artifact_name cv_item_part_of_filename INTO cv_item_part_of_filename SEPARATED BY mc_name_separator.
    ELSE.
      READ TABLE it_mapping
         INTO ls_mapping
         TRANSPORTING name
         WITH KEY key = is_item-obj_name.
      IF sy-subrc = 0.
        CONCATENATE ls_mapping-name cv_item_part_of_filename INTO cv_item_part_of_filename SEPARATED BY mc_name_separator.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD string_to_code_lines.

    SPLIT iv_string AT gc_eol INTO TABLE rt_code_lines.

  ENDMETHOD.
ENDCLASS.
