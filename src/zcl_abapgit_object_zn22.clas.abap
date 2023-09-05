class ZCL_ABAPGIT_OBJECT_ZN22 definition
  public
  inheriting from ZCL_ABAPGIT_OBJECTS_SUPER
  final
  create public .

public section.

  interfaces ZIF_ABAPGIT_OBJECT .

  constants GC_CRLF type ABAP_CR_LF value CL_ABAP_CHAR_UTILITIES=>CR_LF. "#EC NOTEXT
  protected section.
private section.

  types:
    begin of ty_lcl_cushead,
              configuration type /neptune/cushead-configuration,
              file_name     type string,
             end of ty_lcl_cushead .
  types:
    ty_tt_lcl_cushead type standard table of ty_lcl_cushead .
  types:
    begin of ty_lcl_cuslogi,
              configuration type /neptune/cuslogi-configuration,
              file_name     type string,
             end of ty_lcl_cuslogi .
  types:
    ty_tt_lcl_cuslogi type standard table of ty_lcl_cuslogi .
  types:
    begin of ty_lcl_confxml,
              configuration type /neptune/confxml-configuration,
              file_name     type string,
             end of ty_lcl_confxml .
  types:
    ty_tt_lcl_confxml type standard table of ty_lcl_confxml .

  data MT_SKIP_PATHS type STRING_TABLE .

  methods SERIALIZE_CUSHEAD
    importing
      !IS_TABLE_CONTENT type /NEPTUNE/IF_ARTIFACT_TYPE=>TY_TABLE_CONTENT .
  methods SERIALIZE_CONFXML
    importing
      !IS_TABLE_CONTENT type /NEPTUNE/IF_ARTIFACT_TYPE=>TY_TABLE_CONTENT .
  methods SERIALIZE_APPCACH
    importing
      !IS_TABLE_CONTENT type /NEPTUNE/IF_ARTIFACT_TYPE=>TY_TABLE_CONTENT .
  methods SERIALIZE_CUSLOGI
    importing
      !IS_TABLE_CONTENT type /NEPTUNE/IF_ARTIFACT_TYPE=>TY_TABLE_CONTENT .
  methods SERIALIZE_TABLE
    importing
      !IV_TABNAME type TABNAME
      !IT_TABLE type ANY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods SET_SKIP_FIELDS .
  methods GET_SKIP_FIELDS
    returning
      value(RT_SKIP_PATHS) type STRING_TABLE .
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
      !EV_TABNAME type TADIR-OBJ_NAME .
  methods DESERIALIZE_CUSHEAD
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
      !IR_DATA type ref to DATA
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods DESERIALIZE_CONFXML
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
      !IR_DATA type ref to DATA
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods DESERIALIZE_APPCACH
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
      !IR_DATA type ref to DATA
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods DESERIALIZE_CUSLOGI
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
      !IR_DATA type ref to DATA
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
    raising
      ZCX_ABAPGIT_EXCEPTION .
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN22 IMPLEMENTATION.


  method DESERIALIZE_APPCACH.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data lt_table_content type ref to data.

    data ls_file like line of it_files.

    field-symbols <lt_tab> type any table.
    field-symbols <ls_line> type any.
    field-symbols <lv_code> type any.
    field-symbols <lv_field> type any.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = <lt_tab> ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    loop at <lt_tab> assigning <ls_line>.

      assign component 'CONFIGURATION' of structure <ls_line> to <lv_field>.
      if <lv_field> is assigned.
        <lv_field> = iv_key.
        translate <lv_field> to upper case.
        unassign <lv_field>.
      endif.

      assign component 'GLOBAL_STYLE' of structure <ls_line> to <lv_code>.
      check <lv_code> is assigned and <lv_code> is not initial.

      read table it_files into ls_file with key filename = <lv_code>.
      if sy-subrc = 0.
        <lv_code> = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).
      endif.
    endloop.
  endmethod.


  method DESERIALIZE_CONFXML.

    data lt_lcl_confxml type ty_tt_lcl_confxml.
    data ls_lcl_confxml like line of lt_lcl_confxml.

    data lt_confxml type standard table of /neptune/confxml with default key.
    data ls_confxml like line of lt_confxml.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data ls_file like line of it_files.

    data lt_code type string_table.
    data lv_code type string.

    data lv_seqnr type /neptune/confxml-seqnr value 0.

    field-symbols <lt_tab> type any table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_confxml ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    loop at lt_lcl_confxml into ls_lcl_confxml.

      move-corresponding ls_lcl_confxml to ls_confxml.

      read table it_files into ls_file with key filename = ls_lcl_confxml-file_name.
      if sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

        split lv_code at gc_crlf into table lt_code.
        loop at lt_code into lv_code.
          lv_seqnr = lv_seqnr + 1.

          ls_confxml-configuration = iv_key.
          ls_confxml-seqnr         = lv_seqnr.
          ls_confxml-value         = lv_code.

          append ls_confxml to lt_confxml.
        endloop.
*
*
      endif.
    endloop.
*
    <lt_tab> = lt_confxml.
*
  endmethod.


  method DESERIALIZE_CUSHEAD.

    data lt_lcl_cushead type ty_tt_lcl_cushead.
    data ls_lcl_cushead like line of lt_lcl_cushead.

    data lt_cushead type standard table of /neptune/cushead with default key.
    data ls_cushead like line of lt_cushead.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data ls_file like line of it_files.

    data lt_code type string_table.
    data lv_code type string.

    data lv_seqnr type /neptune/cushead-seqnr value 0.

    field-symbols <lt_tab> type any table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_cushead ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    loop at lt_lcl_cushead into ls_lcl_cushead.

      move-corresponding ls_lcl_cushead to ls_cushead.

      read table it_files into ls_file with key filename = ls_lcl_cushead-file_name.
      if sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

        split lv_code at gc_crlf into table lt_code.
        loop at lt_code into lv_code.
          lv_seqnr = lv_seqnr + 1.

          ls_cushead-configuration = iv_key.
          ls_cushead-seqnr         = lv_seqnr.
          ls_cushead-text          = lv_code.

          append ls_cushead to lt_cushead.
        endloop.

      endif.
    endloop.

    <lt_tab> = lt_cushead.

  endmethod.


  method DESERIALIZE_CUSLOGI.

    data lt_lcl_cuslogi type ty_tt_lcl_cuslogi.
    data ls_lcl_cuslogi like line of lt_lcl_cuslogi.

    data lt_cuslogi type standard table of /neptune/cuslogi with default key.
    data ls_cuslogi like line of lt_cuslogi.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data ls_file like line of it_files.

    data lt_code type string_table.
    data lv_code type string.

    data lv_seqnr type /neptune/cuslogi-seqnr value 0.

    field-symbols <lt_tab> type any table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_cuslogi ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    loop at lt_lcl_cuslogi into ls_lcl_cuslogi.

      move-corresponding ls_lcl_cuslogi to ls_cuslogi.

      read table it_files into ls_file with key filename = ls_lcl_cuslogi-file_name.
      if sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

        split lv_code at gc_crlf into table lt_code.
        loop at lt_code into lv_code.
          lv_seqnr = lv_seqnr + 1.

          ls_cuslogi-configuration = iv_key.
          ls_cuslogi-seqnr         = lv_seqnr.
          ls_cuslogi-text          = lv_code.

          append ls_cuslogi to lt_cuslogi.
        endloop.
*
*
      endif.
    endloop.
*
    <lt_tab> = lt_cuslogi.
*
  endmethod.


  method DESERIALIZE_TABLE.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    field-symbols <lt_tab> type any table.
    field-symbols <ls_line> type any.
    field-symbols <lv_field> type any.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = <lt_tab> ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.


    loop at <lt_tab> assigning <ls_line>.
      assign component 'CONFIGURATION' of structure <ls_line> to <lv_field>.
      if <lv_field> is assigned.
        <lv_field> = iv_key.
        translate <lv_field> to upper case.
        unassign <lv_field>.
      endif.
    endloop.

  endmethod.


  method GET_SKIP_FIELDS.

    rt_skip_paths = mt_skip_paths.

  endmethod.


  method GET_VALUES_FROM_FILENAME.

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


  method SERIALIZE_APPCACH.

    data ls_file type zif_abapgit_git_definitions=>ty_file.

*    data lt_lcl_cuslogi type ty_tt_lcl_cuslogi.
*    data ls_lcl_cuslogi like line of lt_lcl_cuslogi.

    data lt_appcach type standard table of /neptune/appcach with default key.
    data ls_appcach like line of lt_appcach.

    data lv_code type string.

    field-symbols <lt_standard_table> type standard table.
    field-symbols <ls_line> type any.
    field-symbols <lv_code> type any.
    field-symbols <ls_appcach> like line of lt_appcach.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_appcach = <lt_standard_table>.

    loop at <lt_standard_table> assigning <ls_line>.

      assign component 'GLOBAL_STYLE' of structure <ls_line> to <lv_code>.
      check <lv_code> is assigned and <lv_code> is not initial.

      concatenate me->ms_item-obj_name
                  me->ms_item-obj_type
                  is_table_content-tabname into ls_file-filename separated by '.'.

      replace all occurrences of '/' in ls_file-filename with '#'.

      concatenate ls_file-filename
                  'css' into ls_file-filename separated by '.'.

      translate ls_file-filename to lower case.

      try.
          ls_file-path = '/'.
          ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( <lv_code> ).
          zif_abapgit_object~mo_files->add( ls_file ).
        catch zcx_abapgit_exception.
      endtry.

      <lv_code> = ls_file-filename.

    endloop.

    try.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = <lt_standard_table> ).

      catch zcx_abapgit_exception.
    endtry.

  endmethod.


  method SERIALIZE_CONFXML.

    data ls_file type zif_abapgit_git_definitions=>ty_file.

    data lt_lcl_confxml type ty_tt_lcl_confxml.
    data ls_lcl_confxml like line of lt_lcl_confxml.

    data lt_confxml type standard table of /neptune/confxml with default key.
    data ls_confxml like line of lt_confxml.

    data lv_code type string.

    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_confxml = <lt_standard_table>.

    loop at lt_confxml into ls_confxml.
      if sy-tabix eq 1.
        move-corresponding ls_confxml to ls_lcl_confxml.
        clear lv_code.
      endif.

      if lv_code is initial.
        lv_code = ls_confxml-value.
      else.
        concatenate lv_code ls_confxml-value into lv_code separated by gc_crlf.
      endif.

    endloop.

    concatenate me->ms_item-obj_name
                me->ms_item-obj_type
                is_table_content-tabname into ls_lcl_confxml-file_name separated by '.'.

    replace all occurrences of '/' in ls_lcl_confxml-file_name with '#'.

    translate ls_lcl_confxml-file_name to lower case.

    concatenate ls_lcl_confxml-file_name
                'xml' into ls_lcl_confxml-file_name separated by '.'.

    append ls_lcl_confxml to lt_lcl_confxml.

    try.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_confxml ).

        ls_file-path = '/'.
        ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
        ls_file-filename = ls_lcl_confxml-file_name.
        zif_abapgit_object~mo_files->add( ls_file ).

      catch zcx_abapgit_exception.
    endtry.

  endmethod.


  method SERIALIZE_CUSHEAD.

    data ls_file type zif_abapgit_git_definitions=>ty_file.

    data lt_lcl_cushead type ty_tt_lcl_cushead.
    data ls_lcl_cushead like line of lt_lcl_cushead.

    data lt_cushead type standard table of /neptune/cushead with default key.
    data ls_cushead like line of lt_cushead.

    data lv_code type string.

    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_cushead = <lt_standard_table>.

    loop at lt_cushead into ls_cushead.
      if sy-tabix eq 1.
        move-corresponding ls_cushead to ls_lcl_cushead.
        clear lv_code.
      endif.

      if lv_code is initial.
        lv_code = ls_cushead-text.
      else.
        concatenate lv_code ls_cushead-text into lv_code separated by gc_crlf.
      endif.

    endloop.

    concatenate me->ms_item-obj_name
                me->ms_item-obj_type
                is_table_content-tabname into ls_lcl_cushead-file_name separated by '.'.

    replace all occurrences of '/' in ls_lcl_cushead-file_name with '#'.

    translate ls_lcl_cushead-file_name to lower case.

    concatenate ls_lcl_cushead-file_name
                'html' into ls_lcl_cushead-file_name separated by '.'.

    append ls_lcl_cushead to lt_lcl_cushead.

    try.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_cushead ).

          ls_file-path = '/'.
          ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
          ls_file-filename = ls_lcl_cushead-file_name.
          zif_abapgit_object~mo_files->add( ls_file ).

      catch zcx_abapgit_exception.
    endtry.

  endmethod.


  method SERIALIZE_CUSLOGI.

    data ls_file type zif_abapgit_git_definitions=>ty_file.

    data lt_lcl_cuslogi type ty_tt_lcl_cuslogi.
    data ls_lcl_cuslogi like line of lt_lcl_cuslogi.

    data lt_cuslogi type standard table of /neptune/cuslogi with default key.
    data ls_cuslogi like line of lt_cuslogi.

    data lv_code type string.

    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_cuslogi = <lt_standard_table>.

    loop at lt_cuslogi into ls_cuslogi.
      if sy-tabix eq 1.
        move-corresponding ls_cuslogi to ls_lcl_cuslogi.
        clear lv_code.
      endif.

      if lv_code is initial.
        lv_code = ls_cuslogi-text.
      else.
        concatenate lv_code ls_cuslogi-text into lv_code separated by gc_crlf.
      endif.

    endloop.

    concatenate me->ms_item-obj_name
                me->ms_item-obj_type
                is_table_content-tabname into ls_lcl_cuslogi-file_name separated by '.'.

    replace all occurrences of '/' in ls_lcl_cuslogi-file_name with '#'.

    translate ls_lcl_cuslogi-file_name to lower case.

    concatenate ls_lcl_cuslogi-file_name
                'js' into ls_lcl_cuslogi-file_name separated by '.'.

    append ls_lcl_cuslogi to lt_lcl_cuslogi.

    try.
** Add adjusted table to files
        serialize_table(
          iv_tabname = is_table_content-tabname
          it_table   = lt_lcl_cuslogi ).

          ls_file-path = '/'.
          ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
          ls_file-filename = ls_lcl_cuslogi-file_name.
          zif_abapgit_object~mo_files->add( ls_file ).

      catch zcx_abapgit_exception.
    endtry.

  endmethod.


  method SERIALIZE_TABLE.

    data: lo_ajson         type ref to zcl_abapgit_ajson,
          lx_ajson         type ref to zcx_abapgit_ajson_error,
          lv_json          type string,
          ls_file          type zif_abapgit_git_definitions=>ty_file.

    data lt_skip_paths type string_table.

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
    ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_json ).
    ls_file-filename = zcl_abapgit_filename_logic=>object_to_file(
                           is_item  = ms_item
                           iv_extra = iv_tabname
                           iv_ext   = 'json' ).

    zif_abapgit_object~mo_files->add( ls_file ).

  endmethod.


  method SET_SKIP_FIELDS.

    data lv_skip type string.

    lv_skip = '*MANDT'.
    append lv_skip to mt_skip_paths.
    lv_skip = '*CONFIGURATION'.
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


  endmethod.


  method ZIF_ABAPGIT_OBJECT~CHANGED_BY.

    data: lo_artifact type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    data ls_appcach type /neptune/appcach.

    field-symbols <lt_standard_table> type standard table.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

    lv_key = ms_item-obj_name.

    lo_artifact->get_table_content(
      exporting iv_key1          = lv_key
      importing et_table_content = lt_table_content ).

    read table lt_table_content into ls_table_content with table key tabname = '/NEPTUNE/APPCACH'.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_standard_table>.
      check sy-subrc = 0.
      read table <lt_standard_table> into ls_appcach index 1.
      if sy-subrc = 0 and ls_appcach-updnam is not initial.
        rv_user = ls_appcach-updnam.
      else.
        rv_user = ls_appcach-crenam.
      endif.
    endif.

  endmethod.


  method ZIF_ABAPGIT_OBJECT~DELETE.
    return.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~DESERIALIZE.

** pick up logic from CLASS ZCL_ABAPGIT_DATA_DESERIALIZER

    data lo_artifact type ref to /neptune/if_artifact_type.

    data: lt_files type zif_abapgit_git_definitions=>ty_files_tt,
          ls_files like line of lt_files.

    data: lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content.

    data lr_data    type ref to data.
    data lv_tabname type tadir-obj_name.
    data lv_key     type /neptune/artifact_key.

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
        when '/NEPTUNE/CUSHEAD'.
          deserialize_cushead(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        when '/NEPTUNE/CUSLOGI'.
          deserialize_cushead(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        when '/NEPTUNE/CONFXML'.
          deserialize_confxml(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        when '/NEPTUNE/APPCACH'.
          deserialize_appcach(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data
            iv_key   = lv_key ).

        when others.
          deserialize_table(
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

      lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

      lo_artifact->set_table_content(
        iv_key1                 = lv_key
        it_insert_table_content = lt_table_content ).

      lo_artifact->update_tadir_entry(
          iv_key1     = lv_key
          iv_devclass = ms_item-devclass ).

    endif.

  endmethod.


  method ZIF_ABAPGIT_OBJECT~EXISTS.
    rv_bool = abap_true.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~GET_COMPARATOR.
    return.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~GET_DESERIALIZE_ORDER.
    return.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~GET_DESERIALIZE_STEPS.
    append zif_abapgit_object=>gc_step_id-late to rt_steps.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~GET_METADATA.
    return.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~IS_ACTIVE.
    rv_active = abap_true.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~IS_LOCKED.
    return.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~JUMP.
    return.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~MAP_FILENAME_TO_OBJECT.
    return.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~MAP_OBJECT_TO_FILENAME.
    return.
  endmethod.


  method ZIF_ABAPGIT_OBJECT~SERIALIZE.

    data: lo_artifact      type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

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

* set fields that will be skipped in the serialization process
    set_skip_fields( ).

* serialize
    loop at lt_table_content into ls_table_content.

      assign ls_table_content-table_content->* to <lt_standard_table>.
      check sy-subrc = 0 and <lt_standard_table> is not initial.

      case ls_table_content-tabname.
        when '/NEPTUNE/CUSHEAD'.
          serialize_cushead(
            is_table_content = ls_table_content ).

        when '/NEPTUNE/CUSLOGI'.
          serialize_cuslogi(
            is_table_content = ls_table_content ).

        when '/NEPTUNE/CONFXML'.
          serialize_confxml(
            is_table_content = ls_table_content ).

        when '/NEPTUNE/APPCACH'.
          serialize_appcach(
            is_table_content = ls_table_content ).

        when others.
          serialize_table(
            iv_tabname = ls_table_content-tabname
            it_table   = <lt_standard_table> ).
      endcase.



    endloop.

  endmethod.
ENDCLASS.
