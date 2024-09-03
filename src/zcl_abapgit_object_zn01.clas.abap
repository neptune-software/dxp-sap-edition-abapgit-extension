class zcl_abapgit_object_zn01 definition
  public
  inheriting from zcl_abapgit_objects_super
  final
  create public .

  public section.

    interfaces zif_abapgit_object .
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

    data mv_artifact_type type /neptune/artifact_type .

    interface /neptune/if_artifact_type load .
    methods serialize_html
      importing
        !it_obj type /neptune/_obj_tt
        !is_table_content type /neptune/if_artifact_type=>ty_table_content
      raising
        zcx_abapgit_exception .
    methods serialize_evtscr
      importing
        !it_obj type /neptune/_obj_tt
        !is_table_content type /neptune/if_artifact_type=>ty_table_content
      raising
        zcx_abapgit_exception .
    methods serialize_script
      importing
        !it_obj type /neptune/_obj_tt
        !is_table_content type /neptune/if_artifact_type=>ty_table_content
      raising
        zcx_abapgit_exception .
    methods serialize__script
      importing
        !it_obj type /neptune/_obj_tt
        !is_table_content type /neptune/if_artifact_type=>ty_table_content
      raising
        zcx_abapgit_exception .
    methods serialize__html
      importing
        !it_obj type /neptune/_obj_tt
        !is_table_content type /neptune/if_artifact_type=>ty_table_content
      raising
        zcx_abapgit_exception .
    methods serialize__evtscr
      importing
        !it_obj type /neptune/_obj_tt
        !is_table_content type /neptune/if_artifact_type=>ty_table_content
      raising
        zcx_abapgit_exception .
    methods serialize_table
      importing
        !iv_tabname type tabname
        !it_table type any
      raising
        zcx_abapgit_exception .
    methods serialize_css
      importing
        !is_table_content type /neptune/if_artifact_type=>ty_table_content
      raising
        zcx_abapgit_exception .
    methods serialize__css
      importing
        !is_table_content type /neptune/if_artifact_type=>ty_table_content
      raising
        zcx_abapgit_exception .
    interface zif_abapgit_git_definitions load .
    methods deserialize_table
      importing
        !is_file type zif_abapgit_git_definitions=>ty_file
        !ir_data type ref to data
        !iv_tabname type tadir-obj_name
        !iv_key type /neptune/artifact_key
        !iv_devclass type devclass
      raising
        zcx_abapgit_exception .
    methods get_values_from_filename
      importing
        !is_filename type string
      exporting
        !ev_tabname type tadir-obj_name .
    methods deserialize_script
      importing
        !is_file type zif_abapgit_git_definitions=>ty_file
        !it_files type zif_abapgit_git_definitions=>ty_files_tt
        !ir_data type ref to data
        !iv_key type /neptune/artifact_key
      raising
        zcx_abapgit_exception .
    methods deserialize_html
      importing
        !is_file type zif_abapgit_git_definitions=>ty_file
        !it_files type zif_abapgit_git_definitions=>ty_files_tt
        !ir_data type ref to data
        !iv_key type /neptune/artifact_key
      raising
        zcx_abapgit_exception .
    methods deserialize_evtscr
      importing
        !is_file type zif_abapgit_git_definitions=>ty_file
        !it_files type zif_abapgit_git_definitions=>ty_files_tt
        !ir_data type ref to data
        !iv_key type /neptune/artifact_key
      raising
        zcx_abapgit_exception .
    methods deserialize__script
      importing
        !is_file type zif_abapgit_git_definitions=>ty_file
        !it_files type zif_abapgit_git_definitions=>ty_files_tt
        !ir_data type ref to data
        !iv_key type /neptune/artifact_key
      raising
        zcx_abapgit_exception .
    methods deserialize__html
      importing
        !is_file type zif_abapgit_git_definitions=>ty_file
        !it_files type zif_abapgit_git_definitions=>ty_files_tt
        !ir_data type ref to data
        !iv_key type /neptune/artifact_key
      raising
        zcx_abapgit_exception .
    methods deserialize__evtscr
      importing
        !is_file type zif_abapgit_git_definitions=>ty_file
        !it_files type zif_abapgit_git_definitions=>ty_files_tt
        !ir_data type ref to data
        !iv_key type /neptune/artifact_key
      raising
        zcx_abapgit_exception .
    methods deserialize_css
      importing
        !is_file type zif_abapgit_git_definitions=>ty_file
        !it_files type zif_abapgit_git_definitions=>ty_files_tt
        !ir_data type ref to data
        !iv_key type /neptune/artifact_key
      raising
        zcx_abapgit_exception .
    methods deserialize__css
      importing
        !is_file type zif_abapgit_git_definitions=>ty_file
        !it_files type zif_abapgit_git_definitions=>ty_files_tt
        !ir_data type ref to data
        !iv_key type /neptune/artifact_key
      raising
        zcx_abapgit_exception .
    methods insert_to_transport
      importing
        !io_artifact type ref to /neptune/if_artifact_type
        !iv_transport type trkorr
        !iv_package type devclass
        !iv_key1 type any
        !iv_artifact_type type /neptune/aty-artifact_type .
    methods serialize_i18n
      importing
        it_table_content type /neptune/if_artifact_type=>ty_t_table_content
      raising
        zcx_abapgit_exception.
    methods serialize__i18n
      importing
        it_table_content type /neptune/if_artifact_type=>ty_t_table_content
      raising
        zcx_abapgit_exception.
    methods deserialize_i18n
      importing
        iv_key           type /neptune/artifact_key
        it_files         type zif_abapgit_git_definitions=>ty_files_tt
        it_table_content type /neptune/if_artifact_type=>ty_t_table_content
        ir_attributes    type ref to data
        ir_contents      type ref to data
        ir_locales       type ref to data
      raising
        zcx_abapgit_exception.
    methods deserialize__i18n
      importing
        iv_key           type /neptune/artifact_key
        it_files         type zif_abapgit_git_definitions=>ty_files_tt
        it_table_content type /neptune/if_artifact_type=>ty_t_table_content
        ir_attributes    type ref to data
        ir_contents      type ref to data
        ir_locales       type ref to data
      raising
        zcx_abapgit_exception.

endclass.



class zcl_abapgit_object_zn01 implementation.


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

        lt_code = zcl_neptune_abapgit_utilities=>string_to_code_lines( iv_string = lv_code ).
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

        lt_code = zcl_neptune_abapgit_utilities=>string_to_code_lines( iv_string = lv_code ).
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


  method deserialize_html.

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

        lt_code = zcl_neptune_abapgit_utilities=>string_to_code_lines( iv_string = lv_code ).
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


  method deserialize_script.

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

        lt_code = zcl_neptune_abapgit_utilities=>string_to_code_lines( iv_string = lv_code ).
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

        lo_ajson->zif_abapgit_ajson~to_abap( exporting iv_corresponding = abap_true
                                             importing ev_container     = <lt_standard_table> ).
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

        lt_code = zcl_neptune_abapgit_utilities=>string_to_code_lines( iv_string = lv_code ).
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

        lt_code = zcl_neptune_abapgit_utilities=>string_to_code_lines( iv_string = lv_code ).
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


  method deserialize__html.

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

        lt_code = zcl_neptune_abapgit_utilities=>string_to_code_lines( iv_string = lv_code ).
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


  method deserialize__script.

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

        lt_code = zcl_neptune_abapgit_utilities=>string_to_code_lines( iv_string = lv_code ).

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

    data lt_code_lines type string_table.

    data lv_message type string.

    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.
    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_css = <lt_standard_table>.

    sort lt_css.

    read table lt_css into ls_css index 1.
    check sy-subrc = 0.

    move-corresponding ls_css to ls_lcl_css.

    loop at lt_css into ls_css.

      append ls_css-text to lt_code_lines.

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

        lv_code = zcl_neptune_abapgit_utilities=>code_lines_to_string( it_code_lines = lt_code_lines ).

        ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
      catch zcx_abapgit_exception.
        concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
    endtry.

    ls_file-filename = ls_lcl_css-file_name.

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*    zif_abapgit_object~mo_files->add( ls_file ).
    " for version 1.125.0
    assign ('ZIF_ABAPGIT_OBJECT~MO_FILES') to <lr_object_files>.
    if <lr_object_files> is not assigned.
      " for version 1.126.0
      assign ('MO_FILES') to <lr_object_files>.
    endif.

    if <lr_object_files> is assigned.
      call method <lr_object_files>->add
        exporting
          is_file = ls_file.
    else.
      concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
      zcx_abapgit_exception=>raise( lv_message ).
    endif.

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

    data lt_code_lines type string_table.

    data lv_message type string.

    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.
    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_evtscr = <lt_standard_table>.

    loop at lt_evtscr into ls_evtscr.
      at new event.
        move-corresponding ls_evtscr to ls_lcl_evtscr.
        clear ls_code.
      endat.

      append ls_evtscr-text to lt_code_lines.

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
                      ls_obj-field_id
                      ls_lcl_evtscr-event
                      'js' into ls_lcl_evtscr-file_name separated by '.'.

          append ls_lcl_evtscr to lt_lcl_evtscr.

          ls_code-file_name = ls_lcl_evtscr-file_name.
          ls_code-code = zcl_neptune_abapgit_utilities=>code_lines_to_string( it_code_lines = lt_code_lines ).
          clear: lt_code_lines.
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

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*    zif_abapgit_object~mo_files->add( ls_file ).
          " for version 1.125.0
          assign ('ZIF_ABAPGIT_OBJECT~MO_FILES') to <lr_object_files>.
          if <lr_object_files> is not assigned.
            " for version 1.126.0
            assign ('MO_FILES') to <lr_object_files>.
          endif.

          if <lr_object_files> is assigned.
            call method <lr_object_files>->add
              exporting
                is_file = ls_file.
          else.
            concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
            zcx_abapgit_exception=>raise( lv_message ).
          endif.

        endloop.
      catch zcx_abapgit_exception.
        concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
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

    data lt_code_lines type string_table.

    data lv_message type string.

    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.
    field-symbols <lt_standard_table> type standard table.

    constants lc_ext(4) type c value 'html'.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_html = <lt_standard_table>.

    loop at lt_html into ls_html.
      at new field_id.
        move-corresponding ls_html to ls_lcl_script.
        clear ls_code.
      endat.

      append ls_html-text to lt_code_lines.

      at end of field_id.
        read table it_obj into ls_obj with key applid = ls_html-applid
                                               field_id = ls_html-field_id.
        if sy-subrc = 0 or ( sy-subrc <> 0 and ls_html-field_id is initial ).

          concatenate me->ms_item-obj_name
                      me->ms_item-obj_type
                      is_table_content-tabname into ls_lcl_script-file_name separated by '.'.

          replace all occurrences of '/' in ls_lcl_script-file_name with '#'.

          translate ls_lcl_script-file_name to lower case.

          if ls_obj-field_id is initial.
* this is the " Header " section of the app
            ls_obj-field_name = 'Header'.
          endif.

          concatenate ls_lcl_script-file_name
                      ls_obj-field_name
                      ls_obj-field_id
                      lc_ext into ls_lcl_script-file_name separated by '.'.

          append ls_lcl_script to lt_lcl_script.

          ls_code-file_name = ls_lcl_script-file_name.

          ls_code-code = zcl_neptune_abapgit_utilities=>code_lines_to_string( it_code_lines = lt_code_lines ).
          clear: lt_code_lines.

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

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*    zif_abapgit_object~mo_files->add( ls_file ).
          " for version 1.125.0
          assign ('ZIF_ABAPGIT_OBJECT~MO_FILES') to <lr_object_files>.
          if <lr_object_files> is not assigned.
            " for version 1.126.0
            assign ('MO_FILES') to <lr_object_files>.
          endif.

          if <lr_object_files> is assigned.
            call method <lr_object_files>->add
              exporting
                is_file = ls_file.
          else.
            concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
            zcx_abapgit_exception=>raise( lv_message ).
          endif.

        endloop.
      catch zcx_abapgit_exception.
        concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
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

    data lt_code_lines type string_table.

    data lv_message type string.

    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.
    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_script = <lt_standard_table>.

    loop at lt_script into ls_script.
      at new field_id.
        move-corresponding ls_script to ls_lcl_script.
        clear ls_code.
      endat.

      append ls_script-text to lt_code_lines.

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
                      ls_obj-field_id
                      lv_ext into ls_lcl_script-file_name separated by '.'.

          append ls_lcl_script to lt_lcl_script.

          ls_code-file_name = ls_lcl_script-file_name.

          ls_code-code = zcl_neptune_abapgit_utilities=>code_lines_to_string( it_code_lines = lt_code_lines ).
          clear: lt_code_lines.

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

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*    zif_abapgit_object~mo_files->add( ls_file ).
          " for version 1.125.0
          assign ('ZIF_ABAPGIT_OBJECT~MO_FILES') to <lr_object_files>.
          if <lr_object_files> is not assigned.
            " for version 1.126.0
            assign ('MO_FILES') to <lr_object_files>.
          endif.

          if <lr_object_files> is assigned.
            call method <lr_object_files>->add
              exporting
                is_file = ls_file.
          else.
            concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
            zcx_abapgit_exception=>raise( lv_message ).
          endif.

        endloop.
      catch zcx_abapgit_exception.
        concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
    endtry.

  endmethod.


  method serialize_table.

    data: lo_ajson         type ref to zcl_abapgit_ajson,
          lx_ajson         type ref to zcx_abapgit_ajson_error,
          lv_json          type string,
          ls_file          type zif_abapgit_git_definitions=>ty_file.

    data lt_skip_paths type string_table.

    data lv_message type string.

    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.

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
        lt_skip_paths = zcl_neptune_abapgit_utilities=>get_skip_fields_for_artifact(
                                                          iv_artifact_type = mv_artifact_type
                                                          iv_serialize     = abap_true ).
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
        concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name iv_tabname into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
    endtry.
    ls_file-filename = zcl_abapgit_filename_logic=>object_to_file(
                           is_item  = ms_item
                           iv_extra = iv_tabname
                           iv_ext   = 'json' ).

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*    zif_abapgit_object~mo_files->add( ls_file ).
    " for version 1.125.0
    assign ('ZIF_ABAPGIT_OBJECT~MO_FILES') to <lr_object_files>.
    if <lr_object_files> is not assigned.
      " for version 1.126.0
      assign ('MO_FILES') to <lr_object_files>.
    endif.

    if <lr_object_files> is assigned.
      call method <lr_object_files>->add
        exporting
          is_file = ls_file.
    else.
      concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name iv_tabname into lv_message separated by space.
      zcx_abapgit_exception=>raise( lv_message ).
    endif.

  endmethod.


  method serialize__css.

    data ls_file type zif_abapgit_git_definitions=>ty_file.
    data lv_code type string.

    data lt_lcl_css type ty_tt_lcl_css.
    data ls_lcl_css like line of lt_lcl_css.

    data lt_css type standard table of /neptune/_css_d with default key.
    data ls_css like line of lt_css.

    data lt_code_lines type string_table.

    data lv_message type string.

    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.
    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_css = <lt_standard_table>.

    sort lt_css.

    read table lt_css into ls_css index 1.
    check sy-subrc = 0.

    move-corresponding ls_css to ls_lcl_css.

    loop at lt_css into ls_css.

      append ls_css-text to lt_code_lines.

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

        lv_code = zcl_neptune_abapgit_utilities=>code_lines_to_string( it_code_lines = lt_code_lines ).

        ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
      catch zcx_abapgit_exception.
        concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
    endtry.
    ls_file-filename = ls_lcl_css-file_name.

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*    zif_abapgit_object~mo_files->add( ls_file ).
    " for version 1.125.0
    assign ('ZIF_ABAPGIT_OBJECT~MO_FILES') to <lr_object_files>.
    if <lr_object_files> is not assigned.
      " for version 1.126.0
      assign ('MO_FILES') to <lr_object_files>.
    endif.

    if <lr_object_files> is assigned.
      call method <lr_object_files>->add
        exporting
          is_file = ls_file.
    else.
      concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
      zcx_abapgit_exception=>raise( lv_message ).
    endif.

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

    data lt_code_lines type string_table.

    data lv_ext type char10.

    data lv_message type string.

    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.
    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_evtscr = <lt_standard_table>.

    loop at lt_evtscr into ls_evtscr.
      at new event.
        move-corresponding ls_evtscr to ls_lcl_evtscr.
        clear ls_code.
      endat.

      append ls_evtscr-text to lt_code_lines.

      at end of event.
        read table it_obj into ls_obj with key applid = ls_evtscr-applid
                                               field_id = ls_evtscr-field_id.
        if sy-subrc = 0.
          concatenate me->ms_item-obj_name
                      me->ms_item-obj_type
                      is_table_content-tabname into ls_lcl_evtscr-file_name separated by '.'.

          replace all occurrences of '/' in ls_lcl_evtscr-file_name with '#'.

          translate ls_lcl_evtscr-file_name to lower case.

          case is_table_content-tabname.
            when '/NEPTUNE/_EVTTSC'.
              lv_ext = 'ts'.
            when '/NEPTUNE/_EVTSCR'.
              lv_ext = 'js'.
          endcase.

          concatenate ls_lcl_evtscr-file_name
                      ls_obj-field_name
                      ls_obj-field_id
                      ls_lcl_evtscr-event
                      lv_ext into ls_lcl_evtscr-file_name separated by '.'.

          append ls_lcl_evtscr to lt_lcl_evtscr.

          ls_code-file_name = ls_lcl_evtscr-file_name.
          ls_code-code = zcl_neptune_abapgit_utilities=>code_lines_to_string( it_code_lines = lt_code_lines ).
          clear: lt_code_lines.
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

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*    zif_abapgit_object~mo_files->add( ls_file ).
          " for version 1.125.0
          assign ('ZIF_ABAPGIT_OBJECT~MO_FILES') to <lr_object_files>.
          if <lr_object_files> is not assigned.
            " for version 1.126.0
            assign ('MO_FILES') to <lr_object_files>.
          endif.

          if <lr_object_files> is assigned.
            call method <lr_object_files>->add
              exporting
                is_file = ls_file.
          else.
            concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
            zcx_abapgit_exception=>raise( lv_message ).
          endif.

        endloop.

      catch zcx_abapgit_exception.
        concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
    endtry.

  endmethod.


  method serialize__html.

    data ls_file type zif_abapgit_git_definitions=>ty_file.

    data lt_lcl_script type ty_tt_lcl_script.
    data ls_lcl_script like line of lt_lcl_script.

    data lt_html type standard table of /neptune/_html with default key.
    data ls_html like line of lt_html.

    data: lt_code type ty_tt_code,
          ls_code like line of lt_code.

    data ls_obj like line of it_obj.

    data lt_code_lines type string_table.

    data lv_message type string.

    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.
    field-symbols <lt_standard_table> type standard table.

    constants lc_ext(4) type c value 'html'.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_html = <lt_standard_table>.

    loop at lt_html into ls_html.
      at new field_id.
        move-corresponding ls_html to ls_lcl_script.
        clear ls_code.
      endat.

      append ls_html-text to lt_code_lines.

      at end of field_id.
        read table it_obj into ls_obj with key applid = ls_html-applid
                                               field_id = ls_html-field_id.
        if sy-subrc = 0 or ( sy-subrc <> 0 and ls_html-field_id is initial ).

          concatenate me->ms_item-obj_name
                      me->ms_item-obj_type
                      is_table_content-tabname into ls_lcl_script-file_name separated by '.'.

          replace all occurrences of '/' in ls_lcl_script-file_name with '#'.

          translate ls_lcl_script-file_name to lower case.

          if ls_obj-field_id is initial.
* this is the " Header " section of the app
            ls_obj-field_name = 'Header'.
          endif.

          concatenate ls_lcl_script-file_name
                      ls_obj-field_name
                      ls_obj-field_id
                      lc_ext into ls_lcl_script-file_name separated by '.'.

          append ls_lcl_script to lt_lcl_script.

          ls_code-file_name = ls_lcl_script-file_name.

          ls_code-code = zcl_neptune_abapgit_utilities=>code_lines_to_string( it_code_lines = lt_code_lines ).
          clear: lt_code_lines.

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

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*    zif_abapgit_object~mo_files->add( ls_file ).
          " for version 1.125.0
          assign ('ZIF_ABAPGIT_OBJECT~MO_FILES') to <lr_object_files>.
          if <lr_object_files> is not assigned.
            " for version 1.126.0
            assign ('MO_FILES') to <lr_object_files>.
          endif.

          if <lr_object_files> is assigned.
            call method <lr_object_files>->add
              exporting
                is_file = ls_file.
          else.
            concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
            zcx_abapgit_exception=>raise( lv_message ).
          endif.

        endloop.
      catch zcx_abapgit_exception.
        concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
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

    data lt_code_lines type string_table.

    data lv_message type string.

    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.
    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_script = <lt_standard_table>.

    loop at lt_script into ls_script.
      at new field_id.
        move-corresponding ls_script to ls_lcl_script.
        clear ls_code.
      endat.

      append ls_script-text to lt_code_lines.

      at end of field_id.
        read table it_obj into ls_obj with key applid = ls_script-applid
                                               field_id = ls_script-field_id.
        if sy-subrc = 0.
          case is_table_content-tabname.
            when '/NEPTUNE/_TSCRIP'.
              lv_ext = 'ts'.
            when others.
              case ls_obj-field_type.
                when 'SCRIPT'.
                  lv_ext = 'js'.
                when 'TYPESCRIPT'.
                  " this is a different table
                  " so this would be the transpiled verison of the typescript (js)
                  lv_ext = 'js'.
                when 'HTML'.
                  lv_ext = 'html'.
              endcase.
          endcase.



          concatenate me->ms_item-obj_name
                      me->ms_item-obj_type
                      is_table_content-tabname into ls_lcl_script-file_name separated by '.'.

          replace all occurrences of '/' in ls_lcl_script-file_name with '#'.

          translate ls_lcl_script-file_name to lower case.

          concatenate ls_lcl_script-file_name
                      ls_obj-field_name
                      ls_obj-field_id
                      lv_ext into ls_lcl_script-file_name separated by '.'.

          append ls_lcl_script to lt_lcl_script.

          ls_code-file_name = ls_lcl_script-file_name.
          ls_code-code = zcl_neptune_abapgit_utilities=>code_lines_to_string( it_code_lines = lt_code_lines ).
          clear: lt_code_lines.

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

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*    zif_abapgit_object~mo_files->add( ls_file ).
          " for version 1.125.0
          assign ('ZIF_ABAPGIT_OBJECT~MO_FILES') to <lr_object_files>.
          if <lr_object_files> is not assigned.
            " for version 1.126.0
            assign ('MO_FILES') to <lr_object_files>.
          endif.

          if <lr_object_files> is assigned.
            call method <lr_object_files>->add
              exporting
                is_file = ls_file.
          else.
            concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
            zcx_abapgit_exception=>raise( lv_message ).
          endif.

        endloop.
      catch zcx_abapgit_exception.
        concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name is_table_content-tabname into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
    endtry.

  endmethod.


  method zif_abapgit_object~changed_by.

    data: lo_artifact type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    data ls_app type /neptune/app.

    data: lv_crenam type /neptune/create_user,
          lv_credat type /neptune/create_date,
          lv_cretim type /neptune/create_time,
          lv_updnam type /neptune/update_user,
          lv_upddat type /neptune/update_date,
          lv_updtim type /neptune/update_time.

    field-symbols <lt_standard_table> type standard table.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

    lv_key = ms_item-obj_name.

    try.
        call method lo_artifact->('GET_METADATA')
          exporting
            iv_key1   = lv_key
          importing
            ev_crenam = lv_crenam
            ev_credat = lv_credat
            ev_cretim = lv_cretim
            ev_updnam = lv_updnam
            ev_upddat = lv_upddat
            ev_updtim = lv_updtim.

        if lv_upddat is not initial.
          rv_user = lv_updnam.
        else.
          rv_user = lv_crenam.
        endif.

      catch cx_sy_dyn_call_illegal_class
            cx_sy_dyn_call_illegal_method.

        lo_artifact->get_table_content(
          exporting iv_key1                 = lv_key
                    iv_only_sys_independent = abap_true
          importing et_table_content        = lt_table_content ).

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

    endtry.


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

    data lt_system_field_values type /neptune/if_artifact_type=>ty_t_system_field_values.

    data lr_data    type ref to data.
    data lv_tabname type tadir-obj_name.
    data lv_key     type /neptune/artifact_key.

    data lo_artifact type ref to /neptune/if_artifact_type.
    data ls_settings type /neptune/aty.

    data lv_message type string.

    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.

    try.
        io_xml->read(
          exporting
            iv_name = 'key'
          changing
            cg_data = lv_key ).
      catch zcx_abapgit_exception.
    endtry.

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->GET_FILES does not work anymore
*    lt_files = zif_abapgit_object~mo_files->get_files( ).
    " for version 1.125.0
    assign ('ZIF_ABAPGIT_OBJECT~MO_FILES') to <lr_object_files>.
    if <lr_object_files> is not assigned.
      " for version 1.126.0
      assign ('MO_FILES') to <lr_object_files>.
    endif.

    if <lr_object_files> is assigned.
      call method <lr_object_files>->get_files
        receiving
          rt_files = lt_files.
    else.
      concatenate 'Error deserializing' ms_item-obj_type  ms_item-obj_name lv_key into lv_message separated by space.
      zcx_abapgit_exception=>raise( lv_message ).
    endif.

    loop at lt_files into ls_files where filename cp '*.json'.

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


        when '/NEPTUNE/_EVTSCR' or '/NEPTUNE/_EVTTSC'.

          deserialize__evtscr(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        when '/NEPTUNE/SCRIPT'.

          deserialize_script(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        when '/NEPTUNE/_SCRIPT' or '/NEPTUNE/_TSCRIP'.

          deserialize__script(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        when '/NEPTUNE/HTML'.

          deserialize_html(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        when '/NEPTUNE/_HTML'.

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

    " I18n
    data lr_i18n_attributes type ref to data.
    data lr_i18n_contents   type ref to data.
    data lr_i18n_locales    type ref to data.

    " zn01.i18n*.properties files
    create data lr_i18n_attributes type ('/NEPTUNE/I18N_A_TT').
    create data lr_i18n_contents   type ('/NEPTUNE/I18N_C_TT').
    create data lr_i18n_locales    type ('/NEPTUNE/I18N_L_TT').

    deserialize_i18n(
      exporting
        iv_key           = lv_key
        it_files         = lt_files
        it_table_content = lt_table_content
        ir_attributes    = lr_i18n_attributes
        ir_contents      = lr_i18n_contents
        ir_locales       = lr_i18n_locales  ).

    ls_table_content-tabname = '/NEPTUNE/I18N_A'.
    ls_table_content-table_content = lr_i18n_attributes.
    append ls_table_content to lt_table_content.
    clear ls_table_content.

    ls_table_content-tabname = '/NEPTUNE/I18N_C'.
    ls_table_content-table_content = lr_i18n_contents.
    append ls_table_content to lt_table_content.
    clear ls_table_content.

    ls_table_content-tabname = '/NEPTUNE/I18N_L'.
    ls_table_content-table_content = lr_i18n_locales.
    append ls_table_content to lt_table_content.
    clear ls_table_content.

    " I18n zn01._i18n*.properties files
    create data lr_i18n_attributes type ('/NEPTUNE/_I18N_A_TT').
    create data lr_i18n_contents   type ('/NEPTUNE/_I18N_C_TT').
    create data lr_i18n_locales    type ('/NEPTUNE/_I18N_L_TT').

    deserialize__i18n(
      exporting
        iv_key           = lv_key
        it_files         = lt_files
        it_table_content = lt_table_content
        ir_attributes    = lr_i18n_attributes
        ir_contents      = lr_i18n_contents
        ir_locales       = lr_i18n_locales  ).

    ls_table_content-tabname = '/NEPTUNE/_I18N_A'.
    ls_table_content-table_content = lr_i18n_attributes.
    append ls_table_content to lt_table_content.
    clear ls_table_content.

    ls_table_content-tabname = '/NEPTUNE/_I18N_C'.
    ls_table_content-table_content = lr_i18n_contents.
    append ls_table_content to lt_table_content.
    clear ls_table_content.

    ls_table_content-tabname = '/NEPTUNE/_I18N_L'.
    ls_table_content-table_content = lr_i18n_locales.
    append ls_table_content to lt_table_content.
    clear ls_table_content.

    if lt_table_content is not initial.

      lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
      ls_settings = lo_artifact->get_settings( ).

      lo_artifact->delete_artifact(
        exporting
          iv_key1                = lv_key
          iv_devclass            = iv_package
        importing
          et_system_field_values = lt_system_field_values ).

      lo_artifact->set_table_content(
        iv_key1                 = lv_key
        iv_devclass             = iv_package
        it_insert_table_content = lt_table_content
        it_system_fields_values = lt_system_field_values ).

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

    data: lo_artifact        type ref to /neptune/if_artifact_type,
          lt_table_content   type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content   like line of lt_table_content,
          lv_key             type /neptune/artifact_key,
          lv_serialize_i18n  type abap_bool,
          lv_serialize__i18n type abap_bool.

    data lt_obj type /neptune/_obj_tt.

    field-symbols <lt_standard_table> type standard table.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).
    mv_artifact_type = lo_artifact->artifact_type.

    try.
        io_xml->add(
          iv_name = 'key'
          ig_data = ms_item-obj_name ).
      catch zcx_abapgit_exception.
    endtry.

    lv_key = ms_item-obj_name.

    lo_artifact->get_table_content(
      exporting iv_key1                 = lv_key
                iv_only_sys_independent = abap_true
      importing et_table_content        = lt_table_content ).

* Save OBJ Table so we can read the name of objects with the FIELD_ID
    read table lt_table_content into ls_table_content with key tabname = '/NEPTUNE/_OBJ'.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_standard_table>.
      check sy-subrc = 0.
      lt_obj = <lt_standard_table>.
    endif.

* serialize
    loop at lt_table_content into ls_table_content.

      case ls_table_content-tabname.
        when '/NEPTUNE/EVTSCR'.

          serialize_evtscr(
            it_obj           = lt_obj
            is_table_content = ls_table_content ).

        when '/NEPTUNE/_EVTSCR' or '/NEPTUNE/_EVTTSC'.

          serialize__evtscr(
            it_obj           = lt_obj
            is_table_content = ls_table_content ).

        when '/NEPTUNE/SCRIPT'.

          serialize_script(
            it_obj           = lt_obj
            is_table_content = ls_table_content ).

        when '/NEPTUNE/_SCRIPT' or '/NEPTUNE/_TSCRIP'.

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

        when '/NEPTUNE/I18N_A' or
             '/NEPTUNE/I18N_C' or
             '/NEPTUNE/I18N_L'.

          lv_serialize_i18n = abap_true.

        when '/NEPTUNE/_I18N_A' or
             '/NEPTUNE/_I18N_C' or
             '/NEPTUNE/_I18N_L'.

          lv_serialize__i18n = abap_true.

        when others.

          assign ls_table_content-table_content->* to <lt_standard_table>.

          check sy-subrc = 0 and <lt_standard_table> is not initial.

          serialize_table(
            iv_tabname = ls_table_content-tabname
            it_table   = <lt_standard_table> ).

      endcase.

    endloop.

    if lv_serialize_i18n = abap_true.
      serialize_i18n( it_table_content = lt_table_content ).
    endif.
    if lv_serialize__i18n = abap_true.
      serialize__i18n( it_table_content = lt_table_content ).
    endif.

  endmethod.

  method serialize_i18n.

    data ls_table_content like line of it_table_content.
    data lo_i18n          type ref to /neptune/cl_i18n.
    data lt_attributes    type lo_i18n->ty_t_i18n_attributes.
    data lt_contents      type lo_i18n->ty_t_i18n_contents.
    data lt_locales       type lo_i18n->ty_t_i18n_locales.
    data lt_i18n_bundle   type lo_i18n->ty_t_i18n_bundle.

    field-symbols <ls_attribute>     like line of lt_attributes.
    field-symbols <ls_content>       like line of lt_contents.
    field-symbols <ls_locale>        like line of lt_locales.
    field-symbols <lt_db_attributes> type /neptune/i18n_a_tt.
    field-symbols <ls_db_attribute>  like line of <lt_db_attributes>.
    field-symbols <lt_db_contents>   type /neptune/i18n_c_tt.
    field-symbols <ls_db_content>    like line of <lt_db_contents>.
    field-symbols <lt_db_locales>    type /neptune/i18n_l_tt.
    field-symbols <ls_db_locale>     like line of <lt_db_locales>.
    field-symbols <ls_i18n_bundle>   like line of lt_i18n_bundle.

    read table it_table_content with key tabname = '/NEPTUNE/I18N_A' into ls_table_content.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_db_attributes>.
      check sy-subrc = 0 and <lt_db_attributes> is not initial.
      loop at <lt_db_attributes> assigning <ls_db_attribute>.
        append initial line to lt_attributes assigning <ls_attribute>.
        move-corresponding <ls_db_attribute> to <ls_attribute>.
      endloop.
    endif.

    read table it_table_content with key tabname = '/NEPTUNE/I18N_C' into ls_table_content.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_db_contents>.
      check sy-subrc = 0 and <lt_db_contents> is not initial.
      loop at <lt_db_contents> assigning <ls_db_content>.
        append initial line to lt_contents assigning <ls_content>.
        move-corresponding <ls_db_content> to <ls_content>.
      endloop.
    endif.

    read table it_table_content with key tabname = '/NEPTUNE/I18N_L' into ls_table_content.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_db_locales>.
      check sy-subrc = 0 and <lt_db_locales> is not initial.
      loop at <lt_db_locales> assigning <ls_db_locale>.
        append initial line to lt_locales assigning <ls_locale>.
        move-corresponding <ls_db_locale> to <ls_locale>.
      endloop.
    endif.

    create object lo_i18n.
    lt_i18n_bundle = lo_i18n->serialize_i18n_bundle(
        attributes = lt_attributes
        contents   = lt_contents
        locales    = lt_locales
        annotated  = abap_true ).

    data ls_file type zif_abapgit_git_definitions=>ty_file.
    data lv_message type string.
    data lv_stripped_filename type string.
    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.

    loop at lt_i18n_bundle assigning <ls_i18n_bundle>.

      " Change newline sequence for git
      replace all occurrences of cl_abap_char_utilities=>cr_lf in <ls_i18n_bundle>-contents with cl_abap_char_utilities=>newline.

      ls_file-path = '/'.
      ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( <ls_i18n_bundle>-contents ).
      lv_stripped_filename = <ls_i18n_bundle>-filename.
      replace first occurrence of regex '\.properties$' in lv_stripped_filename with ''.
      ls_file-filename = zcl_abapgit_filename_logic=>object_to_file(
                             is_item  = ms_item
                             iv_extra = lv_stripped_filename
                             iv_ext   = 'properties' ).

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*    zif_abapgit_object~mo_files->add( ls_file ).
      " for version 1.125.0
      assign ('ZIF_ABAPGIT_OBJECT~MO_FILES') to <lr_object_files>.
      if <lr_object_files> is not assigned.
        " for version 1.126.0
        assign ('MO_FILES') to <lr_object_files>.
      endif.

      if <lr_object_files> is assigned.
        call method <lr_object_files>->add
          exporting
            is_file = ls_file.
      else.
        concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
      endif.

    endloop.

  endmethod.

  method serialize__i18n.

    data ls_table_content like line of it_table_content.
    data lo_i18n          type ref to /neptune/cl_i18n.
    data lt_attributes    type lo_i18n->ty_t_i18n_attributes.
    data lt_contents      type lo_i18n->ty_t_i18n_contents.
    data lt_locales       type lo_i18n->ty_t_i18n_locales.
    data lt_i18n_bundle   type lo_i18n->ty_t_i18n_bundle.

    field-symbols <ls_attribute>     like line of lt_attributes.
    field-symbols <ls_content>       like line of lt_contents.
    field-symbols <ls_locale>        like line of lt_locales.
    field-symbols <lt_db_attributes> type /neptune/_i18n_a_tt.
    field-symbols <ls_db_attribute>  like line of <lt_db_attributes>.
    field-symbols <lt_db_contents>   type /neptune/_i18n_c_tt.
    field-symbols <ls_db_content>    like line of <lt_db_contents>.
    field-symbols <lt_db_locales>    type /neptune/_i18n_l_tt.
    field-symbols <ls_db_locale>     like line of <lt_db_locales>.
    field-symbols <ls_i18n_bundle>   like line of lt_i18n_bundle.

    read table it_table_content with key tabname = '/NEPTUNE/_I18N_A' into ls_table_content.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_db_attributes>.
      check sy-subrc = 0 and <lt_db_attributes> is not initial.
      loop at <lt_db_attributes> assigning <ls_db_attribute>.
        append initial line to lt_attributes assigning <ls_attribute>.
        move-corresponding <ls_db_attribute> to <ls_attribute>.
      endloop.
    endif.

    read table it_table_content with key tabname = '/NEPTUNE/_I18N_C' into ls_table_content.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_db_contents>.
      check sy-subrc = 0 and <lt_db_contents> is not initial.
      loop at <lt_db_contents> assigning <ls_db_content>.
        append initial line to lt_contents assigning <ls_content>.
        move-corresponding <ls_db_content> to <ls_content>.
      endloop.
    endif.

    read table it_table_content with key tabname = '/NEPTUNE/_I18N_L' into ls_table_content.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_db_locales>.
      check sy-subrc = 0 and <lt_db_locales> is not initial.
      loop at <lt_db_locales> assigning <ls_db_locale>.
        append initial line to lt_locales assigning <ls_locale>.
        move-corresponding <ls_db_locale> to <ls_locale>.
      endloop.
    endif.

    create object lo_i18n.
    lt_i18n_bundle = lo_i18n->serialize_i18n_bundle(
        attributes = lt_attributes
        contents   = lt_contents
        locales    = lt_locales
        annotated  = abap_true ).

    data ls_file type zif_abapgit_git_definitions=>ty_file.
    data lv_message type string.
    data lv_stripped_filename type string.
    field-symbols <lr_object_files> type ref to zcl_abapgit_objects_files.

    loop at lt_i18n_bundle assigning <ls_i18n_bundle>.

      " Change newline sequence for git
      replace all occurrences of cl_abap_char_utilities=>cr_lf in <ls_i18n_bundle>-contents with cl_abap_char_utilities=>newline.

      ls_file-path = '/'.
      ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( <ls_i18n_bundle>-contents ).
      lv_stripped_filename = '_' && <ls_i18n_bundle>-filename.
      replace first occurrence of regex '\.properties$' in lv_stripped_filename with ''.
      ls_file-filename = zcl_abapgit_filename_logic=>object_to_file(
                             is_item  = ms_item
                             iv_extra = lv_stripped_filename
                             iv_ext   = 'properties' ).

* in 1.126.0 ZIF_ABAPGIT_OBJECT~MO_FILES->ADD does not work anymore
*    zif_abapgit_object~mo_files->add( ls_file ).
      " for version 1.125.0
      assign ('ZIF_ABAPGIT_OBJECT~MO_FILES') to <lr_object_files>.
      if <lr_object_files> is not assigned.
        " for version 1.126.0
        assign ('MO_FILES') to <lr_object_files>.
      endif.

      if <lr_object_files> is assigned.
        call method <lr_object_files>->add
          exporting
            is_file = ls_file.
      else.
        concatenate 'Error serializing' ms_item-obj_type ms_item-obj_name into lv_message separated by space.
        zcx_abapgit_exception=>raise( lv_message ).
      endif.

    endloop.

  endmethod.

  method deserialize_i18n.

    data ls_files           like line of it_files.
    data ls_table_content   like line of it_table_content.
    data lv_fallback_locale type string.

    data lo_i18n        type ref to /neptune/cl_i18n.
    data lt_i18n_bundle type lo_i18n->ty_t_i18n_bundle.

    field-symbols <ls_i18n_bundle> like line of lt_i18n_bundle.
    field-symbols <lt_app_header>  type /neptune/app_tt.
    field-symbols <ls_app_header>  type /neptune/app.

    " Properties
    loop at it_files into ls_files where filename cp '*.zn01.i18n*.properties'.

      append initial line to lt_i18n_bundle assigning <ls_i18n_bundle>.
      find first occurrence of regex '.zn01.(i18n.*\.properties)$' in ls_files-filename submatches <ls_i18n_bundle>-filename.
      <ls_i18n_bundle>-contents = zcl_abapgit_convert=>xstring_to_string_utf8( iv_data = ls_files-data ).

      " Change newline sequence from git
      replace all occurrences of cl_abap_char_utilities=>newline in <ls_i18n_bundle>-contents with cl_abap_char_utilities=>cr_lf.

    endloop.

    " Get fallback locale
    read table it_table_content with key tabname = '/NEPTUNE/APP' into ls_table_content.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_app_header>.
      if sy-subrc = 0.
        read table <lt_app_header> index 1 assigning <ls_app_header>.
        if sy-subrc = 0.
          lv_fallback_locale = <ls_app_header>-fallback_locale.
        endif.
      endif.
    endif.

    if lt_i18n_bundle is not initial.
      data lt_attributes type lo_i18n->ty_t_i18n_attributes.
      data lt_contents   type lo_i18n->ty_t_i18n_contents.
      data lt_locales    type lo_i18n->ty_t_i18n_locales.

      field-symbols <ls_attribute> like line of lt_attributes.
      field-symbols <ls_content>   like line of lt_contents.
      field-symbols <ls_locale>    like line of lt_locales.

      create object lo_i18n.
      lo_i18n->deserialize_i18n_bundle(
        exporting
          i18n_bundle = lt_i18n_bundle
        importing
          attributes  = lt_attributes
          contents    = lt_contents
          locales     = lt_locales ).

      data lt_db_attributes type /neptune/i18n_a_tt.
      data lt_db_contents   type /neptune/i18n_c_tt.
      data lt_db_locales    type /neptune/i18n_l_tt.

      field-symbols <ls_db_attribute> like line of lt_db_attributes.
      field-symbols <ls_db_content>   like line of lt_db_contents.
      field-symbols <ls_db_locale>    like line of lt_db_locales.
      field-symbols <lt_tab>          type any table.

      " Attributes
      loop at lt_attributes assigning <ls_attribute>.
        append initial line to lt_db_attributes assigning <ls_db_attribute>.
        move-corresponding <ls_attribute> to <ls_db_attribute>.
        <ls_db_attribute>-applid = iv_key.
      endloop.

      assign ir_attributes->* to <lt_tab>.
      check sy-subrc = 0.
      <lt_tab> = lt_db_attributes.

      " Contents
      loop at lt_contents assigning <ls_content>.
        append initial line to lt_db_contents assigning <ls_db_content>.
        move-corresponding <ls_content> to <ls_db_content>.
        <ls_db_content>-applid = iv_key.
      endloop.

      assign ir_contents->* to <lt_tab>.
      check sy-subrc = 0.
      <lt_tab> = lt_db_contents.

      " Locales
      loop at lt_locales assigning <ls_locale>.
        append initial line to lt_db_locales assigning <ls_db_locale>.
        move-corresponding <ls_locale> to <ls_db_locale>.
        <ls_db_locale>-applid = iv_key.
        if <ls_db_locale>-locale = lv_fallback_locale.
          <ls_db_locale>-fallback_locale = abap_true.
        endif.
      endloop.

      assign ir_locales->* to <lt_tab>.
      check sy-subrc = 0.
      <lt_tab> = lt_db_locales.

    endif.

  endmethod.

  method deserialize__i18n.

    data ls_files           like line of it_files.
    data ls_table_content   like line of it_table_content.
    data lv_fallback_locale type string.

    data lo_i18n        type ref to /neptune/cl_i18n.
    data lt_i18n_bundle type lo_i18n->ty_t_i18n_bundle.

    field-symbols <ls_i18n_bundle> like line of lt_i18n_bundle.
    field-symbols <lt_app_header>  type /neptune/_app_tt.
    field-symbols <ls_app_header>  type /neptune/_app.

    " Properties
    loop at it_files into ls_files where filename cp '*.zn01._i18n*.properties'.

      append initial line to lt_i18n_bundle assigning <ls_i18n_bundle>.
      find first occurrence of regex '.zn01._(i18n.*\.properties)$' in ls_files-filename submatches <ls_i18n_bundle>-filename.
      <ls_i18n_bundle>-contents = zcl_abapgit_convert=>xstring_to_string_utf8( iv_data = ls_files-data ).

      " Change newline sequence from git
      replace all occurrences of cl_abap_char_utilities=>newline in <ls_i18n_bundle>-contents with cl_abap_char_utilities=>cr_lf.

    endloop.

    " Get fallback locale
    read table it_table_content with key tabname = '/NEPTUNE/_APP' into ls_table_content.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_app_header>.
      if sy-subrc = 0.
        read table <lt_app_header> index 1 assigning <ls_app_header>.
        if sy-subrc = 0.
          lv_fallback_locale = <ls_app_header>-fallback_locale.
        endif.
      endif.
    endif.

    if lt_i18n_bundle is not initial.
      data lt_attributes type lo_i18n->ty_t_i18n_attributes.
      data lt_contents   type lo_i18n->ty_t_i18n_contents.
      data lt_locales    type lo_i18n->ty_t_i18n_locales.

      field-symbols <ls_attribute> like line of lt_attributes.
      field-symbols <ls_content>   like line of lt_contents.
      field-symbols <ls_locale>    like line of lt_locales.

      create object lo_i18n.
      lo_i18n->deserialize_i18n_bundle(
        exporting
          i18n_bundle = lt_i18n_bundle
        importing
          attributes  = lt_attributes
          contents    = lt_contents
          locales     = lt_locales ).

      data lt_db_attributes type /neptune/_i18n_a_tt.
      data lt_db_contents   type /neptune/_i18n_c_tt.
      data lt_db_locales    type /neptune/_i18n_l_tt.

      field-symbols <ls_db_attribute> like line of lt_db_attributes.
      field-symbols <ls_db_content>   like line of lt_db_contents.
      field-symbols <ls_db_locale>    like line of lt_db_locales.
      field-symbols <lt_tab>          type any table.

      " Attributes
      loop at lt_attributes assigning <ls_attribute>.
        append initial line to lt_db_attributes assigning <ls_db_attribute>.
        move-corresponding <ls_attribute> to <ls_db_attribute>.
        <ls_db_attribute>-applid  = iv_key.
        <ls_db_attribute>-version = 1.
      endloop.

      assign ir_attributes->* to <lt_tab>.
      check sy-subrc = 0.
      <lt_tab> = lt_db_attributes.

      " Contents
      loop at lt_contents assigning <ls_content>.
        append initial line to lt_db_contents assigning <ls_db_content>.
        move-corresponding <ls_content> to <ls_db_content>.
        <ls_db_content>-applid  = iv_key.
        <ls_db_content>-version = 1.
      endloop.

      assign ir_contents->* to <lt_tab>.
      check sy-subrc = 0.
      <lt_tab> = lt_db_contents.

      " Locales
      loop at lt_locales assigning <ls_locale>.
        append initial line to lt_db_locales assigning <ls_db_locale>.
        move-corresponding <ls_locale> to <ls_db_locale>.
        <ls_db_locale>-applid  = iv_key.
        <ls_db_locale>-version = 1.
        if <ls_db_locale>-locale = lv_fallback_locale.
          <ls_db_locale>-fallback_locale = abap_true.
        endif.
      endloop.

      assign ir_locales->* to <lt_tab>.
      check sy-subrc = 0.
      <lt_tab> = lt_db_locales.

    endif.

  endmethod.

endclass.
