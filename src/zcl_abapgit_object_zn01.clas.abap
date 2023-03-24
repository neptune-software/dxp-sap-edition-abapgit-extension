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
*          version   type /neptune/version,
          event     type /neptune/event_id,
          file_name type string,
         end of ty_lcl_evtscr .
  types:
    ty_tt_lcl_evtscr type standard table of ty_lcl_evtscr .
  types:
    begin of ty_lcl_css,
          applid    type /neptune/applid,
*          version   type /neptune/version,
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
      !IR_DATA type ref to DATA
      !IV_TABNAME type TADIR-OBJ_NAME
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods GET_VALUES_FROM_FILENAME
    importing
      !IS_FILENAME type STRING
    exporting
      !EV_TABNAME type TADIR-OBJ_NAME
      !EV_OBJ_KEY type /NEPTUNE/ARTIFACT_KEY .
  methods SET_SKIP_FIELDS .
  methods GET_SKIP_FIELDS
    returning
      value(RT_SKIP_PATHS) type STRING_TABLE .
  methods DESERIALIZE_EVTSCR
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
      !IR_DATA type ref to DATA
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods DESERIALIZE__EVTSCR
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
      !IR_DATA type ref to DATA
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
    exceptions
      ZCX_ABAPGIT_EXCEPTION .
  methods DESERIALIZE_CSS
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
      !IR_DATA type ref to DATA
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods DESERIALIZE__CSS
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
      !IR_DATA type ref to DATA
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
    raising
      ZCX_ABAPGIT_EXCEPTION .
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN01 IMPLEMENTATION.


method DESERIALIZE_CSS.

  data lt_lcl_css type ty_tt_lcl_css.
  data ls_lcl_css like line of lt_lcl_css.

  data lt_css type standard table of /neptune/css.
  data ls_css like line of lt_css.

  data lo_ajson type ref to zcl_abapgit_ajson.
  data lx_ajson type ref to zcx_abapgit_ajson_error.

  data ls_file like line of it_files.

  data lt_code type string_table.
  data lv_code type string.

  field-symbols <lt_tab> type any table.

  assign ir_data->* to <lt_tab>.

  try.
      lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
      lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_css ).
    catch zcx_abapgit_ajson_error into lx_ajson.
      zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
  endtry.

  loop at lt_lcl_css into ls_lcl_css.

    move-corresponding ls_lcl_css to ls_css.

    read table it_files into ls_file with key filename = ls_lcl_css-file_name.
    if sy-subrc eq 0.

      lv_code =  zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ) .

      split lv_code at gc_crlf into table lt_code.
      loop at lt_code into lv_code.
        ls_css-applid = iv_key.
        ls_css-seqnr  = sy-tabix.
        ls_css-text   = lv_code.
        append ls_css to lt_css.
      endloop.


    endif.
  endloop.

  <lt_tab> = lt_css.

endmethod.


method deserialize_evtscr.

  data lt_lcl_evtscr type ty_tt_lcl_evtscr.
  data ls_lcl_evtscr like line of lt_lcl_evtscr.

  data lt_evtscr type standard table of /neptune/evtscr.
  data ls_evtscr like line of lt_evtscr.

  data lo_ajson type ref to zcl_abapgit_ajson.
  data lx_ajson type ref to zcx_abapgit_ajson_error.

  data ls_file like line of it_files.

  data lt_code type string_table.
  data lv_code type string.

  field-symbols <lt_tab> type any table.

  assign ir_data->* to <lt_tab>.

  try.
      lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
      lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_evtscr ).
    catch zcx_abapgit_ajson_error into lx_ajson.
      zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
  endtry.

  loop at lt_lcl_evtscr into ls_lcl_evtscr.

    move-corresponding ls_lcl_evtscr to ls_evtscr.

    read table it_files into ls_file with key filename = ls_lcl_evtscr-file_name.
    if sy-subrc eq 0.

      lv_code =  zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ) .

      split lv_code at gc_crlf into table lt_code.
      loop at lt_code into lv_code.
        ls_evtscr-applid = iv_key.
        ls_evtscr-seqnr  = sy-tabix.
        ls_evtscr-text   = lv_code.
        append ls_evtscr to lt_evtscr.
      endloop.


    endif.
  endloop.

  <lt_tab> = lt_evtscr.

endmethod.


method deserialize_table.

  data lo_ajson type ref to zcl_abapgit_ajson.
  data lx_ajson type ref to zcx_abapgit_ajson_error.

  data lt_table_content type ref to data.

  field-symbols <lt_tab> type any table.
  field-symbols <ls_line> type any.
  field-symbols <lv_field> type any.
  field-symbols: <lt_standard_table> type standard table.
**********************************************************************

  assign ir_data->* to <lt_tab>.

  create data lt_table_content type standard table of (iv_tabname) with non-unique default key.
  assign lt_table_content->* to <lt_standard_table>.

  try.
      lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).

      lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = <lt_standard_table> ).
    catch zcx_abapgit_ajson_error into lx_ajson.
      zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
  endtry.


  loop at <lt_standard_table> assigning <ls_line>.
    assign component 'APPLID' of structure <ls_line> to <lv_field>.
    if <lv_field> is assigned.
      <lv_field> = iv_key.
      unassign <lv_field>.
    endif.

    assign component 'VERSION' of structure <ls_line> to <lv_field>.
    if <lv_field> is assigned.
      <lv_field> = 1.
      unassign <lv_field>.
    endif.

  endloop.

  <lt_tab> = <lt_standard_table>.

endmethod.


method deserialize__css.

  data lt_lcl_css type ty_tt_lcl_css.
  data ls_lcl_css like line of lt_lcl_css.

  data lt_css type standard table of /neptune/_css_d.
  data ls_css like line of lt_css.

  data lo_ajson type ref to zcl_abapgit_ajson.
  data lx_ajson type ref to zcx_abapgit_ajson_error.

  data ls_file like line of it_files.

  data lt_code type string_table.
  data lv_code type string.

  field-symbols <lt_tab> type any table.

  assign ir_data->* to <lt_tab>.

  try.
      lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
      lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_css ).
    catch zcx_abapgit_ajson_error into lx_ajson.
      zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
  endtry.

  loop at lt_lcl_css into ls_lcl_css.

    move-corresponding ls_lcl_css to ls_css.

    read table it_files into ls_file with key filename = ls_lcl_css-file_name.
    if sy-subrc eq 0.

      lv_code =  zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ) .

      split lv_code at gc_crlf into table lt_code.
      loop at lt_code into lv_code.
        ls_css-applid  = iv_key.
        ls_css-version = 1.
        ls_css-seqnr   = sy-tabix.
        ls_css-text    = lv_code.
        append ls_css to lt_css.
      endloop.


    endif.
  endloop.

  <lt_tab> = lt_css.

endmethod.


method deserialize__evtscr.

  data lt_lcl_evtscr type ty_tt_lcl_evtscr.
  data ls_lcl_evtscr like line of lt_lcl_evtscr.

  data lt_evtscr type standard table of /neptune/_evtscr.
  data ls_evtscr like line of lt_evtscr.

  data lo_ajson type ref to zcl_abapgit_ajson.
  data lx_ajson type ref to zcx_abapgit_ajson_error.

  data ls_file like line of it_files.

  data lt_code type string_table.
  data lv_code type string.

  field-symbols <lt_tab> type any table.

  assign ir_data->* to <lt_tab>.

  try.
      lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
      lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_evtscr ).
    catch zcx_abapgit_ajson_error into lx_ajson.
      zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
  endtry.

  loop at lt_lcl_evtscr into ls_lcl_evtscr.

    move-corresponding ls_lcl_evtscr to ls_evtscr.

    read table it_files into ls_file with key filename = ls_lcl_evtscr-file_name.
    if sy-subrc eq 0.

      lv_code =  zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ) .

      split lv_code at gc_crlf into table lt_code.
      loop at lt_code into lv_code.
        ls_evtscr-applid = iv_key.
        ls_evtscr-version = 1.
        ls_evtscr-seqnr  = sy-tabix.
        ls_evtscr-text   = lv_code.
        append ls_evtscr to lt_evtscr.
      endloop.

    endif.
  endloop.

  <lt_tab> = lt_evtscr.

endmethod.


method get_skip_fields.

  rt_skip_paths = gt_skip_paths.

endmethod.


method get_values_from_filename.

  data lt_comp type standard table of string.
  data ls_comp like line of lt_comp.

  split is_filename at '.' into table lt_comp.

  read table lt_comp into ls_comp index 1.
  if sy-subrc eq 0.
    translate ls_comp to upper case.
    ev_obj_key = ls_comp.
  endif.

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

  data: lo_ajson         type ref to zcl_abapgit_ajson,
        lx_ajson         type ref to zcx_abapgit_ajson_error,
        lv_json          type string,
        ls_file          type zif_abapgit_git_definitions=>ty_file.

  data it_skip_paths type string_table.

  check it_table is not initial.

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

  data lt_evtscr type standard table of /neptune/_evtscr.
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
        lv_key           type /neptune/artifact_key.

  data ls_app type /neptune/app.

  field-symbols <lt_standard_table> type standard table.

**********************************************************************

  lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = me->ms_item-obj_type ).

  lv_key = me->ms_item-obj_name.

  lo_artifact->get_table_content(
    exporting iv_key1          = lv_key
    importing et_table_content = lt_table_content ).

  read table lt_table_content into ls_table_content with table key tabname = '/NEPTUNE/APP'.
  if sy-subrc eq 0.
    assign ls_table_content-table_content->* to <lt_standard_table>.
    read table <lt_standard_table> into ls_app index 1.
    if ls_app-updnam is not initial.
      rv_user = ls_app-updnam.
    else.
      rv_user = ls_app-crenam.
    endif.
  endif.

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
  data lv_key     type /neptune/artifact_key.

  data lo_artifact type ref to /neptune/if_artifact_type.

**********************************************************************

  lt_files = zif_abapgit_object~mo_files->get_files( ).

  loop at lt_files into ls_files where filename cs '.json'.

    get_values_from_filename(
      exporting
        is_filename = ls_files-filename    " File Name
      importing
        ev_tabname  = lv_tabname           " Object Name in Object Directory
        ev_obj_key  = lv_key               " Artifact table key
    ).

    create data lr_data type standard table of (lv_tabname) with non-unique default key.

    case lv_tabname.
      when '/NEPTUNE/EVTSCR'.

        deserialize_evtscr(
          exporting
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key
        ).


      when '/NEPTUNE/_EVTSCR'.

        deserialize__evtscr(
          exporting
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key
        ).

      when '/NEPTUNE/CSS'.

        deserialize_css(
          exporting
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key
        ).

      when '/NEPTUNE/_CSS_D' or
           '/NEPTUNE/_CSS_P' or
           '/NEPTUNE/_CSS_T'.

        deserialize__css(
          exporting
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key
        ).

      when others.

        deserialize_table(
          exporting
            is_file    = ls_files
            iv_tabname = lv_tabname
            iv_key     = lv_key
            ir_data    = lr_data ).

    endcase.

    ls_table_content-tabname = lv_tabname.
    ls_table_content-table_content = lr_data.
    append ls_table_content to lt_table_content.
    clear ls_table_content.


  endloop.

  if lt_table_content is not initial.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = me->ms_item-obj_type ).

    lo_artifact->set_table_content(
      exporting
*        iv_mandt                =     " Client
        iv_key1                 = lv_key    " Char 80
        it_insert_table_content = lt_table_content
        io_artifact             = lo_artifact
    ).

  endif.

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
        lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
        ls_table_content like line of lt_table_content,
        lv_key           type /neptune/artifact_key.

  data: lt_obj type standard table of /neptune/obj.

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
