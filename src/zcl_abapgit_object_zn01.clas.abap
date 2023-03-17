class zcl_abapgit_object_zn01 definition
  public
  inheriting from zcl_abapgit_objects_super
  final
  create public .

  public section.

    interfaces zif_abapgit_object .

    constants: gc_crlf type ABAP_CR_LF value cl_abap_char_utilities=>cr_lf.
protected section.
private section.

  types:
    begin of ty_lcl_evtscr,
          applid    type /neptune/applid,
          field_id  type /neptune/field_id,
          version   type /neptune/version,
          event     type /neptune/event_id,
          file_name type string,
         end of ty_lcl_evtscr .
  types:
    ty_tt_lcl_evtscr type standard table of ty_lcl_evtscr .
  types:
    begin of ty_lcl_css,
          applid    type /neptune/applid,
          version   type /neptune/version,
          file_name type string,
         end of ty_lcl_css .
  types:
    ty_tt_lcl_css type standard table of ty_lcl_css .
  types:
    begin of ty_code,
          file_name type string,
          code      type string,
         end of ty_code .
  types:
    ty_tt_code type standard table of ty_code with non-unique key file_name .

  data GT_SKIP_PATHS type STRING_TABLE .

  interface /NEPTUNE/IF_ARTIFACT_TYPE load .
  methods SERIALIZE_EVTSCR
    importing
      !IT_OBJ type /NEPTUNE/OBJ_TT
      !IS_TABLE_CONTENT type /NEPTUNE/IF_ARTIFACT_TYPE=>TY_TABLE_CONTENT .
  methods SERIALIZE__EVTSCR
    importing
      !IT_OBJ type /NEPTUNE/OBJ_TT
      !IS_TABLE_CONTENT type /NEPTUNE/IF_ARTIFACT_TYPE=>TY_TABLE_CONTENT .
  methods SERIALIZE_TABLE
    importing
      !IV_TABNAME type TABNAME
      !IT_TABLE type ANY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods SERIALIZE_CSS
    importing
      !IS_TABLE_CONTENT type /NEPTUNE/IF_ARTIFACT_TYPE=>TY_TABLE_CONTENT .
  methods SERIALIZE__CSS
    importing
      !IS_TABLE_CONTENT type /NEPTUNE/IF_ARTIFACT_TYPE=>TY_TABLE_CONTENT .
  interface ZIF_ABAPGIT_GIT_DEFINITIONS load .
  methods DESERIALIZE_TABLE
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IR_DATA type ref to DATA .
  methods GET_TABNAME_FROM_FILE
    importing
      !IS_FILENAME type STRING
    returning
      value(EV_TABNAME) type TADIR-OBJ_NAME .
  methods SET_SKIP_FIELDS .
  methods GET_SKIP_FIELDS
    returning
      value(RT_SKIP_PATHS) type STRING_TABLE .
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN01 IMPLEMENTATION.


method deserialize_table.

  data lo_ajson type ref to zcl_abapgit_ajson.
  data lx_ajson type ref to zcx_abapgit_ajson_error.

  field-symbols <lg_tab> type any table.

  assign ir_data->* to <lg_tab>.

  try.
      lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
      lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = <lg_tab> ).
    catch zcx_abapgit_ajson_error into lx_ajson.
      zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
  endtry.

endmethod.


method get_skip_fields.

  rt_skip_paths = gt_skip_paths.

endmethod.


method get_tabname_from_file.

  data lt_comp type standard table of string.
  data ls_comp like line of lt_comp.

  split is_filename at '.' into table lt_comp.

  read table lt_comp into ls_comp index 3.
  if sy-subrc eq 0.
    replace all occurrences of '#' in ls_comp with '/'.
    translate ls_comp to upper case.
    ev_tabname = ls_comp.
  endif.

endmethod.


method serialize_css.

  data ls_file type zif_abapgit_git_definitions=>ty_file.
  data lv_code type string.
*  data lv_file_name type string.

  data lt_lcl_css type ty_tt_lcl_css.
  data ls_lcl_css like line of lt_lcl_css.

  data lt_css type standard table of /neptune/css.
  data ls_css like line of lt_css.

  field-symbols: <lt_standard_table> type standard table.

**********************************************************************\\

  assign is_table_content-table_content->* to <lt_standard_table>.

  lt_css = <lt_standard_table>.

  sort lt_css.

  read table lt_css into ls_css index 1.
  check sy-subrc eq 0.

  move-corresponding ls_css to ls_lcl_css.

  loop at lt_css into ls_css.
    if lv_code is initial.
      lv_code = ls_css-text.
    else.
      concatenate lv_code ls_css-text into lv_code separated by gc_crlf.
    endif.
  endloop.

  concatenate me->ms_item-obj_name
              me->ms_item-obj_type
              is_table_content-tabname
              'css' into ls_lcl_css-file_name separated by '.'.

  replace all occurrences of '/' in ls_lcl_css-file_name with '#'.

  translate ls_lcl_css-file_name to lower case.
  append ls_lcl_css to lt_lcl_css.

** Add adjusted table to files
  me->serialize_table(
    exporting
      iv_tabname = is_table_content-tabname
      it_table   = lt_lcl_css ).

** loop at code table to add each entry as a file
  ls_file-path = '/'.
  ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
  ls_file-filename = ls_lcl_css-file_name.

  zif_abapgit_object~mo_files->add( ls_file ).

endmethod.


method serialize_evtscr.

  data ls_file type zif_abapgit_git_definitions=>ty_file.

  data lt_lcl_evtscr type ty_tt_lcl_evtscr.
  data ls_lcl_evtscr like line of lt_lcl_evtscr.

  data lt_evtscr type standard table of /neptune/evtscr.
  data ls_evtscr like line of lt_evtscr.

  data: lt_code type ty_tt_code,
        ls_code like line of lt_code.

  data ls_obj like line of it_obj.

  field-symbols: <lt_standard_table> type standard table.

**********************************************************************\\

  assign is_table_content-table_content->* to <lt_standard_table>.

  lt_evtscr = <lt_standard_table>.
  loop at lt_evtscr into ls_evtscr.
    at new event.
      move-corresponding ls_evtscr to ls_lcl_evtscr.
      clear ls_code.
    endat.

    if ls_code-code is initial.
      ls_code-code = ls_evtscr-text.
    else.
      concatenate ls_code-code ls_evtscr-text into ls_code-code separated by gc_crlf.
    endif.

    at end of event.
      read table it_obj into ls_obj with key applid = ls_evtscr-applid
                                             field_id = ls_evtscr-field_id.
      if sy-subrc eq 0.
        concatenate me->ms_item-obj_name
                    me->ms_item-obj_type
                    is_table_content-tabname into ls_lcl_evtscr-file_name separated by '.'.

        replace all occurrences of '/' in ls_lcl_evtscr-file_name with '#'.

        translate ls_lcl_evtscr-file_name to lower case.

        concatenate ls_lcl_evtscr-file_name
                    ls_obj-field_name
                    ls_lcl_evtscr-event
                    'js' into ls_lcl_evtscr-file_name separated by '.'.

        append ls_lcl_evtscr to lt_lcl_evtscr.

        ls_code-file_name = ls_lcl_evtscr-file_name.
        append ls_code to lt_code.
      endif.

    endat.
  endloop.

** Add adjusted table to files
  me->serialize_table(
    exporting
      iv_tabname = is_table_content-tabname
      it_table   = lt_lcl_evtscr ).

** loop at code table to add each entry as a file
  loop at lt_code into ls_code.

    ls_file-path = '/'.
    ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( ls_code-code ).
    ls_file-filename = ls_code-file_name.

    zif_abapgit_object~mo_files->add( ls_file ).

  endloop.

endmethod.


method serialize_table.

  data: lo_artifact      type ref to /neptune/if_artifact_type,
        lo_ajson         type ref to zcl_abapgit_ajson,
        lx_ajson         type ref to zcx_abapgit_ajson_error,
        lv_json          type string,
        ls_file          type zif_abapgit_git_definitions=>ty_file.

  data it_skip_paths type string_table.

  try.
      lo_ajson = zcl_abapgit_ajson=>create_empty( ).
      lo_ajson->keep_item_order( ).
      lo_ajson->set(
        iv_path = '/'
        iv_val = it_table ).

* Remove fields that have initial value
      lo_ajson = zcl_abapgit_ajson=>create_from(
        ii_source_json = lo_ajson
        ii_filter = zcl_abapgit_ajson_filter_lib=>create_empty_filter( ) ).

* Remove unwanted fields
      it_skip_paths = get_skip_fields( ).
      if it_skip_paths is not initial.
        lo_ajson = zcl_abapgit_ajson=>create_from(
          ii_source_json = lo_ajson
          ii_filter = zcl_abapgit_ajson_filter_lib=>create_path_filter(
                                                      it_skip_paths     = it_skip_paths
                                                      iv_pattern_search = abap_true ) ).
      endif.

      lv_json = lo_ajson->stringify( 2 ).
    catch zcx_abapgit_ajson_error into lx_ajson.
      zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
  endtry.

  ls_file-path = '/'.
  ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_json ).
  ls_file-filename = zcl_abapgit_filename_logic=>object_to_file(
                         is_item  = me->ms_item
                         iv_extra = iv_tabname
                         iv_ext   = 'json' ).

  zif_abapgit_object~mo_files->add( ls_file ).

endmethod.


method SERIALIZE__CSS.

  data ls_file type zif_abapgit_git_definitions=>ty_file.
  data lv_code type string.
*  data lv_file_name type string.

  data lt_lcl_css type ty_tt_lcl_css.
  data ls_lcl_css like line of lt_lcl_css.

  data lt_css type standard table of /neptune/_css_d.
  data ls_css like line of lt_css.

  field-symbols: <lt_standard_table> type standard table.

**********************************************************************\\

  assign is_table_content-table_content->* to <lt_standard_table>.

  lt_css = <lt_standard_table>.

  sort lt_css.

  read table lt_css into ls_css index 1.
  check sy-subrc eq 0.

  move-corresponding ls_css to ls_lcl_css.

  loop at lt_css into ls_css.
    if lv_code is initial.
      lv_code = ls_css-text.
    else.
      concatenate lv_code ls_css-text into lv_code separated by gc_crlf.
    endif.
  endloop.

  concatenate me->ms_item-obj_name
              me->ms_item-obj_type
              is_table_content-tabname
              'css' into ls_lcl_css-file_name separated by '.'.

  replace all occurrences of '/' in ls_lcl_css-file_name with '#'.

  translate ls_lcl_css-file_name to lower case.
  append ls_lcl_css to lt_lcl_css.

** Add adjusted table to files
  me->serialize_table(
    exporting
      iv_tabname = is_table_content-tabname
      it_table   = lt_lcl_css ).

** loop at code table to add each entry as a file
  ls_file-path = '/'.
  ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
  ls_file-filename = ls_lcl_css-file_name.

  zif_abapgit_object~mo_files->add( ls_file ).

endmethod.


method serialize__evtscr.

  data ls_file type zif_abapgit_git_definitions=>ty_file.

  data lt_lcl_evtscr type ty_tt_lcl_evtscr.
  data ls_lcl_evtscr like line of lt_lcl_evtscr.

  data lt__evtscr type standard table of /neptune/_evtscr.
  data ls__evtscr like line of lt__evtscr.

  data: lt_code type ty_tt_code,
        ls_code like line of lt_code.

  data ls_obj like line of it_obj.

  field-symbols: <lt_standard_table> type standard table.

**********************************************************************\\

  assign is_table_content-table_content->* to <lt_standard_table>.

  lt__evtscr = <lt_standard_table>.
  loop at lt__evtscr into ls__evtscr.
    at new event.
      move-corresponding ls__evtscr to ls_lcl_evtscr.
      clear ls_code.
    endat.

    if ls_code-code is initial.
      ls_code-code = ls__evtscr-text.
    else.
      concatenate ls_code-code ls__evtscr-text into ls_code-code separated by gc_crlf.
    endif.

    at end of event.
      read table it_obj into ls_obj with key applid = ls__evtscr-applid
                                             field_id = ls__evtscr-field_id.
      if sy-subrc eq 0.
        concatenate me->ms_item-obj_name
                    me->ms_item-obj_type
                    is_table_content-tabname into ls_lcl_evtscr-file_name separated by '.'.

        replace all occurrences of '/' in ls_lcl_evtscr-file_name with '#'.

        translate ls_lcl_evtscr-file_name to lower case.

        concatenate ls_lcl_evtscr-file_name
                    ls_obj-field_name
                    ls_lcl_evtscr-event
                    'js' into ls_lcl_evtscr-file_name separated by '.'.

        append ls_lcl_evtscr to lt_lcl_evtscr.

        ls_code-file_name = ls_lcl_evtscr-file_name.
        append ls_code to lt_code.
      endif.

    endat.
  endloop.

** Add adjusted table to files
  me->serialize_table(
    exporting
      iv_tabname = is_table_content-tabname
      it_table   = lt_lcl_evtscr ).

** loop at code table to add each entry as a file
  loop at lt_code into ls_code.

    ls_file-path = '/'.
    ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( ls_code-code ).
    ls_file-filename = ls_code-file_name.

    zif_abapgit_object~mo_files->add( ls_file ).

  endloop.

endmethod.


method set_skip_fields.

  data: lv_skip type string.

  lv_skip = '*APPLID'.
  append lv_skip to gt_skip_paths.
  lv_skip = '*CREDAT'.
  append lv_skip to gt_skip_paths.
  lv_skip = '*CRETIM'.
  append lv_skip to gt_skip_paths.
  lv_skip = '*CRENAM'.
  append lv_skip to gt_skip_paths.
  lv_skip = '*UPDDAT'.
  append lv_skip to gt_skip_paths.
  lv_skip = '*UPDTIM'.
  append lv_skip to gt_skip_paths.
  lv_skip = '*UPDNAM'.
  append lv_skip to gt_skip_paths.


endmethod.


method zif_abapgit_object~changed_by.

  data: lo_artifact type ref to /neptune/if_artifact_type,
        lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
        ls_table_content like line of lt_table_content,
        lv_json          type string,
        lv_key           type /neptune/artifact_key.

  field-symbols <lt_standard_table> type standard table.

**********************************************************************
*    break andrec.

  lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = me->ms_item-obj_type ).

  lv_key = me->ms_item-obj_name.

  lo_artifact->get_table_content(
    exporting iv_key1          = lv_key
    importing et_table_content = lt_table_content ).

  loop at lt_table_content into ls_table_content.
    assign ls_table_content-table_content->* to <lt_standard_table>.
  endloop.

endmethod.


method ZIF_ABAPGIT_OBJECT~DELETE.
endmethod.


method zif_abapgit_object~deserialize.
** pick up logic from CLASS ZCL_ABAPGIT_DATA_DESERIALIZER

  data: lt_files type zif_abapgit_git_definitions=>ty_files_tt,
        ls_files like line of lt_files.

  data: lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
        ls_table_content like line of lt_table_content.

  data lr_data    type ref to data.
  data lv_tabname type tadir-obj_name.

**********************************************************************

  lt_files = zif_abapgit_object~mo_files->get_files( ).

  loop at lt_files into ls_files where filename cs '.json'.

    lv_tabname = get_tabname_from_file( ls_files-filename ).

    lr_data = zcl_abapgit_data_utils=>build_table_itab( lv_tabname ).

    case lv_tabname.
      when '/NEPTUNE/EVTSCR'.

*        me->serialize_evtscr(
*          exporting
*            it_obj    = lt_obj
*            is_table_content = ls_table_content ).

      when '/NEPTUNE/_EVTSCR'.

*        me->serialize__evtscr(
*          exporting
*            it_obj    = lt_obj
*            is_table_content = ls_table_content ).

      when '/NEPTUNE/CSS'.

*        me->serialize_css(
*          exporting
*            is_table_content = ls_table_content ).

      when '/NEPTUNE/_CSS_D' or
           '/NEPTUNE/_CSS_P' or
           '/NEPTUNE/_CSS_T'.

*        me->serialize__css(
*          exporting
*            is_table_content = ls_table_content ).

      when others.

        deserialize_table(
        exporting
          is_file = ls_files
          ir_data = lr_data
        ).

    endcase.

    ls_table_content-tabname = lv_tabname.
    ls_table_content-table_content = lr_data.
    append ls_table_content to lt_table_content.
    clear ls_table_content.


  endloop.

endmethod.


method zif_abapgit_object~exists.
  rv_bool = abap_true.
endmethod.


method ZIF_ABAPGIT_OBJECT~GET_COMPARATOR.
  RETURN.
endmethod.


method zif_abapgit_object~get_deserialize_steps.
  append zif_abapgit_object=>gc_step_id-late to rt_steps.
endmethod.


method ZIF_ABAPGIT_OBJECT~GET_METADATA.
endmethod.


method ZIF_ABAPGIT_OBJECT~IS_ACTIVE.
  rv_active = abap_true.
endmethod.


method ZIF_ABAPGIT_OBJECT~IS_LOCKED.
endmethod.


method ZIF_ABAPGIT_OBJECT~JUMP.
endmethod.


method zif_abapgit_object~serialize.

  data: lo_artifact      type ref to /neptune/if_artifact_type,
        lo_ajson         type ref to zcl_abapgit_ajson,
        lx_ajson         type ref to zcx_abapgit_ajson_error,
        lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
        ls_table_content like line of lt_table_content,
        lv_json          type string,
        lv_key           type /neptune/artifact_key,
        ls_file          type zif_abapgit_git_definitions=>ty_file.

  data: lt_obj type standard table of /neptune/obj,
        ls_obj like line of lt_obj.

  field-symbols: <lt_standard_table> type standard table.

**********************************************************************

  lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = me->ms_item-obj_type ).

  lv_key = me->ms_item-obj_name.

  lo_artifact->get_table_content(
    exporting iv_key1          = lv_key
    importing et_table_content = lt_table_content ).

* Save OBJ Table so we can read the name of objects with the FIELD_ID
  read table lt_table_content into ls_table_content with key tabname = '/NEPTUNE/OBJ'.
  if sy-subrc eq 0.
    assign ls_table_content-table_content->* to <lt_standard_table>.
    lt_obj = <lt_standard_table>.
  endif.

* set fields that will be skipped in the serialization process
  set_skip_fields( ).

* serialize
  loop at lt_table_content into ls_table_content.

    case ls_table_content-tabname.
      when '/NEPTUNE/EVTSCR'.

        me->serialize_evtscr(
          exporting
            it_obj    = lt_obj
            is_table_content = ls_table_content ).

      when '/NEPTUNE/_EVTSCR'.

        me->serialize__evtscr(
          exporting
            it_obj    = lt_obj
            is_table_content = ls_table_content ).

      when '/NEPTUNE/CSS'.

        me->serialize_css(
          exporting
            is_table_content = ls_table_content ).

      when '/NEPTUNE/_CSS_D' or
           '/NEPTUNE/_CSS_P' or
           '/NEPTUNE/_CSS_T'.

        me->serialize__css(
          exporting
            is_table_content = ls_table_content ).

      when others.

        assign ls_table_content-table_content->* to <lt_standard_table>.

        me->serialize_table(
          exporting
            iv_tabname = ls_table_content-tabname
            it_table   = <lt_standard_table> ).

    endcase.

  endloop.

endmethod.
ENDCLASS.
