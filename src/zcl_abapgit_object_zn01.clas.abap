class zcl_abapgit_object_zn01 definition
  public
  inheriting from zcl_abapgit_objects_super
  final
  create public .

  public section.

    interfaces zif_abapgit_object .

    constants gc_crlf type abap_cr_lf value cl_abap_char_utilities=>cr_lf. "#EC NOTEXT
  protected section.
private section.

  types:
    begin of ty_lcl_evtscr,
                    applid    type /neptune/applid,
                    field_id  type /neptune/field_id,
                    event     type /neptune/event_id,
                    file_name type string,
                   end of ty_lcl_evtscr .
  types:
    ty_tt_lcl_evtscr type standard table of ty_lcl_evtscr .
  types:
    begin of ty_lcl_css,
                    applid    type /neptune/applid,
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
  types:
    begin of ty_lcl_script,
                    applid    type /neptune/applid,
                    field_id  type /neptune/field_id,
                    file_name type string,
                   end of ty_lcl_script .
  types:
    ty_tt_lcl_script type standard table of ty_lcl_script .

  data MT_SKIP_PATHS type STRING_TABLE .

  interface /NEPTUNE/IF_ARTIFACT_TYPE load .
  methods SERIALIZE_HTML
    importing
      !IT_OBJ type /NEPTUNE/OBJ_TT
      !IS_TABLE_CONTENT type /NEPTUNE/IF_ARTIFACT_TYPE=>TY_TABLE_CONTENT .
  methods SERIALIZE_EVTSCR
    importing
      !IT_OBJ type /NEPTUNE/OBJ_TT
      !IS_TABLE_CONTENT type /NEPTUNE/IF_ARTIFACT_TYPE=>TY_TABLE_CONTENT .
  methods SERIALIZE_SCRIPT
    importing
      !IT_OBJ type /NEPTUNE/OBJ_TT
      !IS_TABLE_CONTENT type /NEPTUNE/IF_ARTIFACT_TYPE=>TY_TABLE_CONTENT .
  methods SERIALIZE__SCRIPT
    importing
      !IT_OBJ type /NEPTUNE/OBJ_TT
      !IS_TABLE_CONTENT type /NEPTUNE/IF_ARTIFACT_TYPE=>TY_TABLE_CONTENT .
  methods SERIALIZE__HTML
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
      !IV_DEVCLASS type DEVCLASS
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods GET_VALUES_FROM_FILENAME
    importing
      !IS_FILENAME type STRING
    exporting
      !EV_TABNAME type TADIR-OBJ_NAME .
  methods SET_SKIP_FIELDS .
  methods GET_SKIP_FIELDS
    returning
      value(RT_SKIP_PATHS) type STRING_TABLE .
  methods DESERIALIZE_SCRIPT
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
      !IR_DATA type ref to DATA
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods DESERIALIZE_HTML
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
      !IR_DATA type ref to DATA
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods DESERIALIZE_EVTSCR
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
      !IR_DATA type ref to DATA
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods DESERIALIZE__SCRIPT
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
      !IR_DATA type ref to DATA
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
    exceptions
      ZCX_ABAPGIT_EXCEPTION .
  methods DESERIALIZE__HTML
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
      !IR_DATA type ref to DATA
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
    exceptions
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
  methods INSERT_TO_TRANSPORT
    importing
      !IO_ARTIFACT type ref to /NEPTUNE/IF_ARTIFACT_TYPE
      !IV_TRANSPORT type TRKORR
      !IV_PACKAGE type DEVCLASS
      !IV_KEY1 type ANY
      !IV_ARTIFACT_TYPE type /NEPTUNE/ATY-ARTIFACT_TYPE .
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN01 IMPLEMENTATION.


  method deserialize_css.

    data lt_lcl_css type ty_tt_lcl_css.
    data ls_lcl_css like line of lt_lcl_css.

    data lt_css type standard table of /neptune/css with default key.
    data ls_css like line of lt_css.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data ls_file like line of it_files.

    data lt_code type string_table.
    data lv_code type string.

    field-symbols <lt_tab> type any table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_css ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    loop at lt_lcl_css into ls_lcl_css.

      move-corresponding ls_lcl_css to ls_css.

      read table it_files into ls_file with key filename = ls_lcl_css-file_name.
      if sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

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

    data lt_evtscr type standard table of /neptune/evtscr with default key.
    data ls_evtscr like line of lt_evtscr.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data ls_file like line of it_files.

    data lt_code type string_table.
    data lv_code type string.

    field-symbols <lt_tab> type any table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_evtscr ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    loop at lt_lcl_evtscr into ls_lcl_evtscr.

      move-corresponding ls_lcl_evtscr to ls_evtscr.

      read table it_files into ls_file with key filename = ls_lcl_evtscr-file_name.
      if sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

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


  method DESERIALIZE_HTML.

    data lt_lcl_script type ty_tt_lcl_script.
    data ls_lcl_script like line of lt_lcl_script.

    data lt_html type standard table of /neptune/html with default key.
    data ls_html like line of lt_html.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data ls_file like line of it_files.

    data lt_code type string_table.
    data lv_code type string.

    field-symbols <lt_tab> type any table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_script ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    loop at lt_lcl_script into ls_lcl_script.

      move-corresponding ls_lcl_script to ls_html.

      read table it_files into ls_file with key filename = ls_lcl_script-file_name.
      if sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

        split lv_code at gc_crlf into table lt_code.
        loop at lt_code into lv_code.
          ls_html-applid = iv_key.
          ls_html-seqnr  = sy-tabix.
          ls_html-text   = lv_code.
          append ls_html to lt_html.
        endloop.


      endif.
    endloop.

    <lt_tab> = lt_html.

  endmethod.


  method DESERIALIZE_SCRIPT.

    data lt_lcl_script type ty_tt_lcl_script.
    data ls_lcl_script like line of lt_lcl_script.

    data lt_script type standard table of /neptune/script with default key.
    data ls_script like line of lt_script.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data ls_file like line of it_files.

    data lt_code type string_table.
    data lv_code type string.

    field-symbols <lt_tab> type any table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_script ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    loop at lt_lcl_script into ls_lcl_script.

      move-corresponding ls_lcl_script to ls_script.

      read table it_files into ls_file with key filename = ls_lcl_script-file_name.
      if sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

        split lv_code at gc_crlf into table lt_code.
        loop at lt_code into lv_code.
          ls_script-applid = iv_key.
          ls_script-seqnr  = sy-tabix.
          ls_script-text   = lv_code.
          append ls_script to lt_script.
        endloop.


      endif.
    endloop.

    <lt_tab> = lt_script.

  endmethod.


  method deserialize_table.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data lt_table_content type ref to data.

    field-symbols <lt_tab> type any table.
    field-symbols <ls_line> type any.
    field-symbols <lv_field> type any.
    field-symbols <lt_standard_table> type standard table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    create data lt_table_content type standard table of (iv_tabname) with non-unique default key.
    assign lt_table_content->* to <lt_standard_table>.
    check sy-subrc = 0.

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

      assign component 'DEVCLASS' of structure <ls_line> to <lv_field>.
      if <lv_field> is assigned.
        <lv_field> = iv_devclass.
        unassign <lv_field>.
      endif.

    endloop.

    <lt_tab> = <lt_standard_table>.

  endmethod.


  method deserialize__css.

    data lt_lcl_css type ty_tt_lcl_css.
    data ls_lcl_css like line of lt_lcl_css.

    data lt_css type standard table of /neptune/_css_d with default key.
    data ls_css like line of lt_css.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data ls_file like line of it_files.

    data lt_code type string_table.
    data lv_code type string.

    field-symbols <lt_tab> type any table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_css ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    loop at lt_lcl_css into ls_lcl_css.

      move-corresponding ls_lcl_css to ls_css.

      read table it_files into ls_file with key filename = ls_lcl_css-file_name.
      if sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

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

    data lt_evtscr type standard table of /neptune/_evtscr with default key.
    data ls_evtscr like line of lt_evtscr.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data ls_file like line of it_files.

    data lt_code type string_table.
    data lv_code type string.

    field-symbols <lt_tab> type any table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_evtscr ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
      catch zcx_abapgit_exception.
    endtry.

    loop at lt_lcl_evtscr into ls_lcl_evtscr.

      move-corresponding ls_lcl_evtscr to ls_evtscr.

      read table it_files into ls_file with key filename = ls_lcl_evtscr-file_name.
      if sy-subrc = 0.
        try.
            lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).
          catch zcx_abapgit_exception.
        endtry.

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


  method DESERIALIZE__HTML.

    data lt_lcl_script type ty_tt_lcl_script.
    data ls_lcl_script like line of lt_lcl_script.

    data lt_html type standard table of /neptune/_html with default key.
    data ls_html like line of lt_html.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data ls_file like line of it_files.

    data lt_code type string_table.
    data lv_code type string.

    field-symbols <lt_tab> type any table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_script ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
      catch zcx_abapgit_exception.
    endtry.

    loop at lt_lcl_script into ls_lcl_script.

      move-corresponding ls_lcl_script to ls_html.

      read table it_files into ls_file with key filename = ls_lcl_script-file_name.
      if sy-subrc = 0.
        try.
            lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).
          catch zcx_abapgit_exception.
        endtry.

        split lv_code at gc_crlf into table lt_code.
        loop at lt_code into lv_code.
          ls_html-applid = iv_key.
          ls_html-version = 1.
          ls_html-seqnr  = sy-tabix.
          ls_html-text   = lv_code.
          append ls_html to lt_html.
        endloop.

      endif.
    endloop.

    <lt_tab> = lt_html.

  endmethod.


  method DESERIALIZE__SCRIPT.

    data lt_lcl_script type ty_tt_lcl_script.
    data ls_lcl_script like line of lt_lcl_script.

    data lt_script type standard table of /neptune/_script with default key.
    data ls_script like line of lt_script.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data ls_file like line of it_files.

    data lt_code type string_table.
    data lv_code type string.

    field-symbols <lt_tab> type any table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_script ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
      catch zcx_abapgit_exception.
    endtry.

    loop at lt_lcl_script into ls_lcl_script.

      move-corresponding ls_lcl_script to ls_script.

      read table it_files into ls_file with key filename = ls_lcl_script-file_name.
      if sy-subrc = 0.
        try.
            lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).
          catch zcx_abapgit_exception.
        endtry.

        split lv_code at gc_crlf into table lt_code.
        loop at lt_code into lv_code.
          ls_script-applid = iv_key.
          ls_script-version = 1.
          ls_script-seqnr  = sy-tabix.
          ls_script-text   = lv_code.
          append ls_script to lt_script.
        endloop.

      endif.
    endloop.

    <lt_tab> = lt_script.

  endmethod.


  method get_skip_fields.
    rt_skip_paths = mt_skip_paths.
  endmethod.


  method get_values_from_filename.

    data lt_comp type standard table of string with default key.
    data ls_comp like line of lt_comp.

    split is_filename at '.' into table lt_comp.

    read table lt_comp into ls_comp index 3.
    if sy-subrc = 0.
      replace all occurrences of '#' in ls_comp with '/'.
      translate ls_comp to upper case.
      ev_tabname = ls_comp.
    endif.

  endmethod.


  method insert_to_transport.

    data ls_message type /neptune/message.
    data lv_task type trkorr.

    /neptune/cl_nad_transport=>transport_task_find(
      exporting
        transport = iv_transport
      importing
        task      = lv_task ).

    io_artifact->insert_to_transport(
      exporting
        iv_korrnum = lv_task
        iv_key1    = iv_key1
      importing
        ev_message = ls_message ).

    try.
        call method ('/NEPTUNE/CL_TADIR')=>('INSERT_TO_TRANSPORT')
*            call method /neptune/cl_tadir=>insert_to_transport
            exporting
              iv_korrnum       = lv_task
              iv_devclass      = iv_package
              iv_artifact_key  = iv_key1
              iv_artifact_type = iv_artifact_type
            importing
              ev_message      = ls_message.
      catch cx_sy_dyn_call_illegal_class
            cx_sy_dyn_call_illegal_method.
    endtry.

  endmethod.


  method serialize_css.

    data ls_file type zif_abapgit_git_definitions=>ty_file.
    data lv_code type string.

    data lt_lcl_css type ty_tt_lcl_css.
    data ls_lcl_css like line of lt_lcl_css.

    data lt_css type standard table of /neptune/css with default key.
    data ls_css like line of lt_css.

    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_css = <lt_standard_table>.

    sort lt_css.

    read table lt_css into ls_css index 1.
    check sy-subrc = 0.

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

    try.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_css ).

** loop at code table to add each entry as a file
        ls_file-path = '/'.

        ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
      catch zcx_abapgit_exception.
    endtry.

    ls_file-filename = ls_lcl_css-file_name.

    zif_abapgit_object~mo_files->add( ls_file ).

  endmethod.


  method serialize_evtscr.

    data ls_file type zif_abapgit_git_definitions=>ty_file.

    data lt_lcl_evtscr type ty_tt_lcl_evtscr.
    data ls_lcl_evtscr like line of lt_lcl_evtscr.

    data lt_evtscr type standard table of /neptune/evtscr with default key.
    data ls_evtscr like line of lt_evtscr.

    data: lt_code type ty_tt_code,
          ls_code like line of lt_code.

    data ls_obj like line of it_obj.

    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

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
        if sy-subrc = 0.
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

    try.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_evtscr ).

** loop at code table to add each entry as a file
        loop at lt_code into ls_code.

          ls_file-path = '/'.

          ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( ls_code-code ).

          ls_file-filename = ls_code-file_name.

          zif_abapgit_object~mo_files->add( ls_file ).

        endloop.
      catch zcx_abapgit_exception.
    endtry.

  endmethod.


  method serialize_html.

    data ls_file type zif_abapgit_git_definitions=>ty_file.

    data lt_lcl_script type ty_tt_lcl_script.
    data ls_lcl_script like line of lt_lcl_script.

    data lt_html type standard table of /neptune/html with default key.
    data ls_html like line of lt_html.

    data: lt_code type ty_tt_code,
          ls_code like line of lt_code.

    data ls_obj like line of it_obj.

    data lv_ext type char10.

    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_html = <lt_standard_table>.

    loop at lt_html into ls_html.
      at new field_id.
        move-corresponding ls_html to ls_lcl_script.
        clear ls_code.
      endat.

      if ls_code-code is initial.
        ls_code-code = ls_html-text.
      else.
        concatenate ls_code-code ls_html-text into ls_code-code separated by gc_crlf.
      endif.

      at end of field_id.
        read table it_obj into ls_obj with key applid = ls_html-applid
                                               field_id = ls_html-field_id.
        if sy-subrc = 0.
          case ls_obj-field_type.
            when 'SCRIPT'.
              lv_ext = 'js'.
            when 'TYPESCRIPT'.
              lv_ext = 'ts'.
            when 'HTML'.
              lv_ext = 'html'.
          endcase.

          concatenate me->ms_item-obj_name
                      me->ms_item-obj_type
                      is_table_content-tabname into ls_lcl_script-file_name separated by '.'.

          replace all occurrences of '/' in ls_lcl_script-file_name with '#'.

          translate ls_lcl_script-file_name to lower case.

          concatenate ls_lcl_script-file_name
                      ls_obj-field_name
                      lv_ext into ls_lcl_script-file_name separated by '.'.

          append ls_lcl_script to lt_lcl_script.

          ls_code-file_name = ls_lcl_script-file_name.
          append ls_code to lt_code.
        endif.

      endat.
    endloop.

    try.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_script ).

** loop at code table to add each entry as a file
        loop at lt_code into ls_code.

          ls_file-path = '/'.

          ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( ls_code-code ).

          ls_file-filename = ls_code-file_name.

          zif_abapgit_object~mo_files->add( ls_file ).

        endloop.
      catch zcx_abapgit_exception.
    endtry.

  endmethod.


  method serialize_script.

    data ls_file type zif_abapgit_git_definitions=>ty_file.

    data lt_lcl_script type ty_tt_lcl_script.
    data ls_lcl_script like line of lt_lcl_script.

    data lt_script type standard table of /neptune/script with default key.
    data ls_script like line of lt_script.

    data: lt_code type ty_tt_code,
          ls_code like line of lt_code.

    data ls_obj like line of it_obj.

    data lv_ext type char10.

    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_script = <lt_standard_table>.

    loop at lt_script into ls_script.
      at new field_id.
        move-corresponding ls_script to ls_lcl_script.
        clear ls_code.
      endat.

      if ls_code-code is initial.
        ls_code-code = ls_script-text.
      else.
        concatenate ls_code-code ls_script-text into ls_code-code separated by gc_crlf.
      endif.

      at end of field_id.
        read table it_obj into ls_obj with key applid = ls_script-applid
                                               field_id = ls_script-field_id.
        if sy-subrc = 0.
          case ls_obj-field_type.
            when 'SCRIPT'.
              lv_ext = 'js'.
            when 'TYPESCRIPT'.
              lv_ext = 'ts'.
            when 'HTML'.
              lv_ext = 'html'.
          endcase.

          concatenate me->ms_item-obj_name
                      me->ms_item-obj_type
                      is_table_content-tabname into ls_lcl_script-file_name separated by '.'.

          replace all occurrences of '/' in ls_lcl_script-file_name with '#'.

          translate ls_lcl_script-file_name to lower case.

          concatenate ls_lcl_script-file_name
                      ls_obj-field_name
                      lv_ext into ls_lcl_script-file_name separated by '.'.

          append ls_lcl_script to lt_lcl_script.

          ls_code-file_name = ls_lcl_script-file_name.
          append ls_code to lt_code.
        endif.

      endat.
    endloop.

    try.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_script ).

** loop at code table to add each entry as a file
        loop at lt_code into ls_code.

          ls_file-path = '/'.

          ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( ls_code-code ).

          ls_file-filename = ls_code-file_name.

          zif_abapgit_object~mo_files->add( ls_file ).

        endloop.
      catch zcx_abapgit_exception.
    endtry.

  endmethod.


  method serialize_table.

    data: lo_ajson         type ref to zcl_abapgit_ajson,
          lx_ajson         type ref to zcx_abapgit_ajson_error,
          lv_json          type string,
          ls_file          type zif_abapgit_git_definitions=>ty_file.

    data lt_skip_paths type string_table.

    check it_table is not initial.

    try.
        lo_ajson = zcl_abapgit_ajson=>create_empty( ).
        lo_ajson->keep_item_order( ).
        lo_ajson->set(
          iv_path = '/'
          iv_val  = it_table ).

* Remove fields that have initial value
        lo_ajson = zcl_abapgit_ajson=>create_from(
          ii_source_json = lo_ajson
          ii_filter      = zcl_abapgit_ajson_filter_lib=>create_empty_filter( ) ).

* Remove unwanted fields
        lt_skip_paths = get_skip_fields( ).
        if lt_skip_paths is not initial.
          lo_ajson = zcl_abapgit_ajson=>create_from(
            ii_source_json = lo_ajson
            ii_filter      = zcl_abapgit_ajson_filter_lib=>create_path_filter(
                                                             it_skip_paths     = lt_skip_paths
                                                             iv_pattern_search = abap_true ) ).
        endif.

        lv_json = lo_ajson->stringify( 2 ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    ls_file-path = '/'.
    try.
        ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_json ).
      catch zcx_abapgit_exception.
    endtry.
    ls_file-filename = zcl_abapgit_filename_logic=>object_to_file(
                           is_item  = ms_item
                           iv_extra = iv_tabname
                           iv_ext   = 'json' ).

    zif_abapgit_object~mo_files->add( ls_file ).

  endmethod.


  method serialize__css.

    data ls_file type zif_abapgit_git_definitions=>ty_file.
    data lv_code type string.

    data lt_lcl_css type ty_tt_lcl_css.
    data ls_lcl_css like line of lt_lcl_css.

    data lt_css type standard table of /neptune/_css_d with default key.
    data ls_css like line of lt_css.

    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_css = <lt_standard_table>.

    sort lt_css.

    read table lt_css into ls_css index 1.
    check sy-subrc = 0.

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
    try.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_css ).

** loop at code table to add each entry as a file
        ls_file-path = '/'.

        ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
      catch zcx_abapgit_exception.
    endtry.
    ls_file-filename = ls_lcl_css-file_name.

    zif_abapgit_object~mo_files->add( ls_file ).

  endmethod.


  method serialize__evtscr.

    data ls_file type zif_abapgit_git_definitions=>ty_file.

    data lt_lcl_evtscr type ty_tt_lcl_evtscr.
    data ls_lcl_evtscr like line of lt_lcl_evtscr.

    data lt_evtscr type standard table of /neptune/_evtscr with default key.
    data ls_evtscr like line of lt_evtscr.

    data: lt_code type ty_tt_code,
          ls_code like line of lt_code.

    data ls_obj like line of it_obj.

    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

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
        if sy-subrc = 0.
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

    try.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_evtscr ).

** loop at code table to add each entry as a file
        loop at lt_code into ls_code.

          ls_file-path = '/'.

          ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( ls_code-code ).

          ls_file-filename = ls_code-file_name.

          zif_abapgit_object~mo_files->add( ls_file ).

        endloop.

      catch zcx_abapgit_exception.
    endtry.

  endmethod.


  method SERIALIZE__HTML.

    data ls_file type zif_abapgit_git_definitions=>ty_file.

    data lt_lcl_script type ty_tt_lcl_script.
    data ls_lcl_script like line of lt_lcl_script.

    data lt_html type standard table of /neptune/_html with default key.
    data ls_html like line of lt_html.

    data: lt_code type ty_tt_code,
          ls_code like line of lt_code.

    data ls_obj like line of it_obj.

    data lv_ext type char10.

    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_html = <lt_standard_table>.

    loop at lt_html into ls_html.
      at new field_id.
        move-corresponding ls_html to ls_lcl_script.
        clear ls_code.
      endat.

      if ls_code-code is initial.
        ls_code-code = ls_html-text.
      else.
        concatenate ls_code-code ls_html-text into ls_code-code separated by gc_crlf.
      endif.

      at end of field_id.
        read table it_obj into ls_obj with key applid = ls_html-applid
                                               field_id = ls_html-field_id.
        if sy-subrc = 0.
          case ls_obj-field_type.
            when 'SCRIPT'.
              lv_ext = 'js'.
            when 'TYPESCRIPT'.
              lv_ext = 'ts'.
            when 'HTML'.
              lv_ext = 'html'.
          endcase.

          concatenate me->ms_item-obj_name
                      me->ms_item-obj_type
                      is_table_content-tabname into ls_lcl_script-file_name separated by '.'.

          replace all occurrences of '/' in ls_lcl_script-file_name with '#'.

          translate ls_lcl_script-file_name to lower case.

          concatenate ls_lcl_script-file_name
                      ls_obj-field_name
                      lv_ext into ls_lcl_script-file_name separated by '.'.

          append ls_lcl_script to lt_lcl_script.

          ls_code-file_name = ls_lcl_script-file_name.
          append ls_code to lt_code.
        endif.

      endat.
    endloop.

    try.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_script ).

** loop at code table to add each entry as a file
        loop at lt_code into ls_code.

          ls_file-path = '/'.

          ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( ls_code-code ).

          ls_file-filename = ls_code-file_name.

          zif_abapgit_object~mo_files->add( ls_file ).

        endloop.
      catch zcx_abapgit_exception.
    endtry.

  endmethod.


  method serialize__script.

    data ls_file type zif_abapgit_git_definitions=>ty_file.

    data lt_lcl_script type ty_tt_lcl_script.
    data ls_lcl_script like line of lt_lcl_script.

    data lt_script type standard table of /neptune/_script with default key.
    data ls_script like line of lt_script.

    data: lt_code type ty_tt_code,
          ls_code like line of lt_code.

    data ls_obj like line of it_obj.

    data lv_ext type char10.

    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_script = <lt_standard_table>.

    loop at lt_script into ls_script.
      at new field_id.
        move-corresponding ls_script to ls_lcl_script.
        clear ls_code.
      endat.

      if ls_code-code is initial.
        ls_code-code = ls_script-text.
      else.
        concatenate ls_code-code ls_script-text into ls_code-code separated by gc_crlf.
      endif.

      at end of field_id.
        read table it_obj into ls_obj with key applid = ls_script-applid
                                               field_id = ls_script-field_id.
        if sy-subrc = 0.
          case ls_obj-field_type.
            when 'SCRIPT'.
              lv_ext = 'js'.
            when 'TYPESCRIPT'.
              lv_ext = 'ts'.
            when 'HTML'.
              lv_ext = 'html'.
          endcase.

          concatenate me->ms_item-obj_name
                      me->ms_item-obj_type
                      is_table_content-tabname into ls_lcl_script-file_name separated by '.'.

          replace all occurrences of '/' in ls_lcl_script-file_name with '#'.

          translate ls_lcl_script-file_name to lower case.

          concatenate ls_lcl_script-file_name
                      ls_obj-field_name
                      lv_ext into ls_lcl_script-file_name separated by '.'.

          append ls_lcl_script to lt_lcl_script.

          ls_code-file_name = ls_lcl_script-file_name.
          append ls_code to lt_code.
        endif.

      endat.
    endloop.

    try.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_script ).

** loop at code table to add each entry as a file
        loop at lt_code into ls_code.

          ls_file-path = '/'.

          ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( ls_code-code ).

          ls_file-filename = ls_code-file_name.

          zif_abapgit_object~mo_files->add( ls_file ).

        endloop.
      catch zcx_abapgit_exception.
    endtry.

  endmethod.


  method set_skip_fields.

    data lv_skip type string.

    lv_skip = '*APPLID'.
    append lv_skip to mt_skip_paths.
    lv_skip = '*DEVCLASS'.
    append lv_skip to mt_skip_paths.
    lv_skip = '*CREDAT'.
    append lv_skip to mt_skip_paths.
    lv_skip = '*CRETIM'.
    append lv_skip to mt_skip_paths.
    lv_skip = '*CRENAM'.
    append lv_skip to mt_skip_paths.
    lv_skip = '*UPDDAT'.
    append lv_skip to mt_skip_paths.
    lv_skip = '*UPDTIM'.
    append lv_skip to mt_skip_paths.
    lv_skip = '*UPDNAM'.
    append lv_skip to mt_skip_paths.
    lv_skip = 'TR_ORDER'.
    append lv_skip to mt_skip_paths.


  endmethod.


  method zif_abapgit_object~changed_by.

    data: lo_artifact type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    data ls_app type /neptune/app.

    field-symbols <lt_standard_table> type standard table.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

    lv_key = me->ms_item-obj_name.

    lo_artifact->get_table_content(
      exporting iv_key1          = lv_key
      importing et_table_content = lt_table_content ).

    read table lt_table_content into ls_table_content with table key tabname = '/NEPTUNE/APP'.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_standard_table>.
      check sy-subrc = 0.
      read table <lt_standard_table> into ls_app index 1.
      check sy-subrc = 0.
      if ls_app-updnam is not initial.
        rv_user = ls_app-updnam.
      else.
        rv_user = ls_app-crenam.
      endif.
    endif.

  endmethod.


  method zif_abapgit_object~delete.

    data: lo_artifact type ref to /neptune/if_artifact_type,
          ls_settings type /neptune/aty,
          lv_key1     type /neptune/artifact_key.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    ls_settings = lo_artifact->get_settings( ).

    lv_key1 = ms_item-obj_name.

    lo_artifact->delete_artifact(
      iv_key1     = lv_key1
      iv_devclass = iv_package ).

    lo_artifact->delete_tadir_entry( iv_key1 = lv_key1 ).

    if ls_settings-transportable is not initial and iv_transport is not initial.

      insert_to_transport(
        io_artifact      = lo_artifact
        iv_transport     = iv_transport
        iv_package       = iv_package
        iv_key1          = lv_key1
        iv_artifact_type = ls_settings-artifact_type ).

    endif.

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
    data ls_settings type /neptune/aty.

    try.
        io_xml->read(
          exporting
            iv_name = 'key'
          changing
            cg_data = lv_key ).
      catch zcx_abapgit_exception.
    endtry.

    lt_files = zif_abapgit_object~mo_files->get_files( ).

    loop at lt_files into ls_files where filename cs '.json'.

      get_values_from_filename(
        exporting
          is_filename = ls_files-filename
        importing
          ev_tabname  = lv_tabname ).

      create data lr_data type standard table of (lv_tabname) with non-unique default key.

      case lv_tabname.
        when '/NEPTUNE/EVTSCR'.

          deserialize_evtscr(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).


        when '/NEPTUNE/_EVTSCR'.

          deserialize__evtscr(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        when '/NEPTUNE/_SCRIPT'.

          deserialize_script(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        when '/NEPTUNE/__SCRIPT'.

          deserialize__script(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        when '/NEPTUNE/_HTML'.

          deserialize_html(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        when '/NEPTUNE/__HTML'.

          deserialize__html(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        when '/NEPTUNE/CSS'.

          deserialize_css(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        when '/NEPTUNE/_CSS_D' or
             '/NEPTUNE/_CSS_P' or
             '/NEPTUNE/_CSS_T'.

          deserialize__css(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        when others.

          deserialize_table(
            is_file     = ls_files
            iv_tabname  = lv_tabname
            iv_key      = lv_key
            iv_devclass = iv_package
            ir_data     = lr_data ).

      endcase.

      ls_table_content-tabname = lv_tabname.
      ls_table_content-table_content = lr_data.
      append ls_table_content to lt_table_content.
      clear ls_table_content.

    endloop.

    if lt_table_content is not initial.

      lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
      ls_settings = lo_artifact->get_settings( ).

      lo_artifact->set_table_content(
        iv_key1                 = lv_key
        it_insert_table_content = lt_table_content ).

      lo_artifact->update_tadir_entry(
          iv_key1     = lv_key
          iv_devclass = iv_package ).

      if ls_settings-transportable is not initial and iv_transport is not initial.

        insert_to_transport(
          io_artifact      = lo_artifact
          iv_transport     = iv_transport
          iv_package       = iv_package
          iv_key1          = lv_key
          iv_artifact_type = ls_settings-artifact_type ).

      endif.

    endif.

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
    append zif_abapgit_object=>gc_step_id-late to rt_steps.
  endmethod.


  method zif_abapgit_object~get_metadata.
    return.
  endmethod.


  method zif_abapgit_object~is_active.
    rv_active = abap_true.
  endmethod.


  method zif_abapgit_object~is_locked.

    data lo_artifact type ref to /neptune/if_artifact_type.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    rv_is_locked = lo_artifact->check_artifact_is_locked( iv_key = ms_item-obj_name ).

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

    data: lo_artifact      type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    data lt_obj type standard table of /neptune/obj with default key.

    field-symbols <lt_standard_table> type standard table.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

    try.
        io_xml->add(
          iv_name = 'key'
          ig_data = ms_item-obj_name ).
      catch zcx_abapgit_exception.
    endtry.

    lv_key = ms_item-obj_name.

    lo_artifact->get_table_content(
      exporting iv_key1          = lv_key
      importing et_table_content = lt_table_content ).

* Save OBJ Table so we can read the name of objects with the FIELD_ID
    read table lt_table_content into ls_table_content with key tabname = '/NEPTUNE/OBJ'.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_standard_table>.
      check sy-subrc = 0.
      lt_obj = <lt_standard_table>.
    endif.

* set fields that will be skipped in the serialization process
    set_skip_fields( ).

* serialize
    loop at lt_table_content into ls_table_content.

      case ls_table_content-tabname.
        when '/NEPTUNE/EVTSCR'.

          serialize_evtscr(
            it_obj           = lt_obj
            is_table_content = ls_table_content ).

        when '/NEPTUNE/_EVTSCR'.

          serialize__evtscr(
            it_obj           = lt_obj
            is_table_content = ls_table_content ).

        when '/NEPTUNE/SCRIPT'.

          serialize_script(
            it_obj           = lt_obj
            is_table_content = ls_table_content ).

        when '/NEPTUNE/_SCRIPT'.

          serialize__script(
            it_obj           = lt_obj
            is_table_content = ls_table_content ).

        when '/NEPTUNE/HTML'.

          serialize_html(
            it_obj           = lt_obj
            is_table_content = ls_table_content ).

        when '/NEPTUNE/_HTML'.

          serialize__html(
            it_obj           = lt_obj
            is_table_content = ls_table_content ).

        when '/NEPTUNE/CSS'.

          serialize_css( is_table_content = ls_table_content ).

        when '/NEPTUNE/_CSS_D' or
             '/NEPTUNE/_CSS_P' or
             '/NEPTUNE/_CSS_T'.

          serialize__css( is_table_content = ls_table_content ).

        when others.

          assign ls_table_content-table_content->* to <lt_standard_table>.

          check sy-subrc = 0 and <lt_standard_table> is not initial.

          serialize_table(
            iv_tabname = ls_table_content-tabname
            it_table   = <lt_standard_table> ).

      endcase.

    endloop.

  endmethod.
ENDCLASS.
