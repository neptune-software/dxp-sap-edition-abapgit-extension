class zcl_abapgit_object_zn09 definition
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
      begin of ty_mapping,
                  key type tadir-obj_name,
                  name type string,
                 end of ty_mapping .
    types:
      ty_mapping_tt type standard table of ty_mapping with key key .
    types:
      begin of ty_lcl_enhtext,
              enhancement type /neptune/enhancement,
              spot        type /neptune/enhancement_spot,
              file_name   type string,
             end of ty_lcl_enhtext .
    types:
      ty_tt_lcl_enhtext type standard table of ty_lcl_enhtext .

    constants:
      mc_name_separator(1) type c value '@'.                "#EC NOTEXT
    class-data gt_mapping type ty_mapping_tt .
    data mt_skip_paths type string_table .

    methods serialize_table
      importing
        !iv_tabname type tabname
        !it_table type any
      raising
        zcx_abapgit_exception .
    methods set_skip_fields .
    methods get_skip_fields
      returning
        value(rt_skip_paths) type string_table .
    interface zif_abapgit_git_definitions load .
    methods deserialize_table
      importing
        !is_file type zif_abapgit_git_definitions=>ty_file
        !ir_data type ref to data
        !iv_tabname type tadir-obj_name
      raising
        zcx_abapgit_exception .
    methods serialize_enhtext
      importing
        !iv_name type /neptune/enhance-descr
        !is_table_content type /neptune/if_artifact_type=>ty_table_content .
    methods get_values_from_filename
      importing
        !is_filename type string
      exporting
        !ev_tabname type tadir-obj_name
        !ev_name type /neptune/artifact_name .
    methods deserialize_enhtext
      importing
        !is_file type zif_abapgit_git_definitions=>ty_file
        !it_files type zif_abapgit_git_definitions=>ty_files_tt
        !ir_data type ref to data
      raising
        zcx_abapgit_exception .
    methods insert_to_transport
      importing
        !io_artifact type ref to /neptune/if_artifact_type
        !iv_transport type trkorr
        !iv_package type devclass
        !iv_key1 type any
        !iv_artifact_type type /neptune/aty-artifact_type .
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN09 IMPLEMENTATION.


  method deserialize_enhtext.

    data lt_lcl_enhtext type ty_tt_lcl_enhtext.
    data ls_lcl_enhtext like line of lt_lcl_enhtext.

    data lt_enhtext type standard table of /neptune/enhtext with default key.
    data ls_enhtext like line of lt_enhtext.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data ls_file like line of it_files.

    data lt_code type string_table.
    data lv_code type string.

    data lv_seqnr type /neptune/enhtext-seqnr value 0.

    field-symbols <lt_tab> type any table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_enhtext ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    loop at lt_lcl_enhtext into ls_lcl_enhtext.

      move-corresponding ls_lcl_enhtext to ls_enhtext.

      read table it_files into ls_file with key filename = ls_lcl_enhtext-file_name.
      if sy-subrc = 0.

        lv_code = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).

        split lv_code at gc_crlf into table lt_code.
        loop at lt_code into lv_code.
          lv_seqnr = lv_seqnr + 1.

          ls_enhtext-seqnr  = lv_seqnr.
          ls_enhtext-text   = lv_code.
          append ls_enhtext to lt_enhtext.
        endloop.
*
*
      endif.
    endloop.
*
    <lt_tab> = lt_enhtext.
*
  endmethod.


  method deserialize_table.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data lt_table_content type ref to data.

    field-symbols <lt_tab> type any table.
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

    <lt_tab> = <lt_standard_table>.

  endmethod.


  method get_skip_fields.

    rt_skip_paths = mt_skip_paths.

  endmethod.


  method get_values_from_filename.

    data lt_comp type standard table of string with default key.
    data ls_comp like line of lt_comp.
    data lv_key type /neptune/artifact_key.
    data lv_name type string.

    split is_filename at '.' into table lt_comp.

    read table lt_comp into ls_comp index 1.
    if sy-subrc = 0.
      split ls_comp at mc_name_separator into lv_name lv_key.
      translate lv_name to upper case.
      ev_name = lv_name.
    endif.

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


  method serialize_enhtext.

    data ls_file type zif_abapgit_git_definitions=>ty_file.
    data lv_code type string.

    data lt_lcl_enhtext type ty_tt_lcl_enhtext.
    data ls_lcl_enhtext like line of lt_lcl_enhtext.

    data lt_enhtext type standard table of /neptune/enhtext with default key.
    data ls_enhtext like line of lt_enhtext.

    field-symbols <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_enhtext = <lt_standard_table>.

    sort lt_enhtext.

    loop at lt_enhtext into ls_enhtext.
      at new spot.
        clear lv_code.
        move-corresponding ls_enhtext to ls_lcl_enhtext.
      endat.
      if lv_code is initial.
        lv_code = ls_enhtext-text.
      else.
        concatenate lv_code ls_enhtext-text into lv_code separated by gc_crlf.
      endif.

      at end of spot.

        concatenate me->ms_item-obj_name
                    me->ms_item-obj_type
                    is_table_content-tabname
                    ls_enhtext-spot
                    'js' into ls_lcl_enhtext-file_name separated by '.'.

        replace all occurrences of '/' in ls_lcl_enhtext-file_name with '#'.
        concatenate iv_name ls_lcl_enhtext-file_name into ls_lcl_enhtext-file_name separated by mc_name_separator.
        translate ls_lcl_enhtext-file_name to lower case.
        append ls_lcl_enhtext to lt_lcl_enhtext.

        try.
** loop at code table to add each entry as a file
            ls_file-path = '/'.

            ls_file-data = zcl_abapgit_convert=>string_to_xstring_utf8( lv_code ).
          catch zcx_abapgit_exception.
        endtry.

        ls_file-filename = ls_lcl_enhtext-file_name.

        zif_abapgit_object~mo_files->add( ls_file ).

      endat.
    endloop.

    if lt_lcl_enhtext is not initial.
      try.
** Add adjusted table to files
          serialize_table(
            iv_tabname = is_table_content-tabname
            it_table   = lt_lcl_enhtext ).

        catch zcx_abapgit_exception.
      endtry.
    endif.
  endmethod.


  method serialize_table.

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


  method set_skip_fields.

    data lv_skip type string.

    lv_skip = '*MANDT' ##NO_TEXT.
    append lv_skip to mt_skip_paths.
    lv_skip = '*CREDAT' ##NO_TEXT.
    append lv_skip to mt_skip_paths.
    lv_skip = '*CRETIM' ##NO_TEXT.
    append lv_skip to mt_skip_paths.
    lv_skip = '*CRENAM' ##NO_TEXT.
    append lv_skip to mt_skip_paths.
    lv_skip = '*UPDDAT' ##NO_TEXT.
    append lv_skip to mt_skip_paths.
    lv_skip = '*UPDTIM' ##NO_TEXT.
    append lv_skip to mt_skip_paths.
    lv_skip = '*UPDNAM' ##NO_TEXT.
    append lv_skip to mt_skip_paths.


  endmethod.


  method zif_abapgit_object~changed_by.

    data: lo_artifact type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    data ls_enhance type /neptune/enhance.

    field-symbols <lt_standard_table> type standard table.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

    lv_key = ms_item-obj_name.

    lo_artifact->get_table_content(
      exporting iv_key1          = lv_key
      importing et_table_content = lt_table_content ).

    read table lt_table_content into ls_table_content with table key tabname = '/NEPTUNE/ENHANCE'.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_standard_table>.
      check sy-subrc = 0.
      read table <lt_standard_table> into ls_enhance index 1.
      if sy-subrc = 0 and ls_enhance-updnam is not initial.
        rv_user = ls_enhance-updnam.
      else.
        rv_user = ls_enhance-crenam.
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
      iv_key1      = lv_key1
      iv_devclass  = iv_package ).

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
        when '/NEPTUNE/ENHTEXT'.

          deserialize_enhtext(
            is_file  = ls_files
            it_files = lt_files
            ir_data  = lr_data ).

        when others.

          deserialize_table(
            is_file    = ls_files
            iv_tabname = lv_tabname
            ir_data    = lr_data ).

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
          iv_devclass = ms_item-devclass ).

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
    return.
  endmethod.


  method zif_abapgit_object~jump.
    return.
  endmethod.


  method zif_abapgit_object~map_filename_to_object.

    data lt_parts type standard table of string with default key.
    data: lv_artifact_name type string,
          lv_key type string,
          lv_filename type string.
    data ls_mapping like line of gt_mapping.

    split iv_filename at mc_name_separator into lv_artifact_name lv_filename.
    split lv_filename at '.' into table lt_parts.
    read table lt_parts into lv_key index 1.
    check sy-subrc = 0.

    if lv_artifact_name is not initial.
      translate lv_key to upper case.
      cs_item-obj_name = lv_key.

      read table gt_mapping transporting no fields with key key = lv_key.
      check sy-subrc <> 0.

      ls_mapping-key = lv_key.
      ls_mapping-name = lv_artifact_name.
      append ls_mapping to gt_mapping.

    endif.

  endmethod.


  method zif_abapgit_object~map_object_to_filename.

    data ls_mapping like line of gt_mapping.
    data ls_tadir type /neptune/if_artifact_type=>ty_lcl_tadir.
    data lv_key type /neptune/artifact_key.

    check is_item-devclass is not initial.

    lv_key = is_item-obj_name.

    try.
        " Ongoing from DXP 23 fetch wie tadir framework (all artifacts can be assigned to a devclass)
        call method ('/NEPTUNE/CL_TADIR')=>('GET_ARTIFACT_ENTRY')
*          call method  /neptune/cl_tadir=>get_artifact_entry
          exporting
            iv_key           = lv_key
            iv_devclass      = is_item-devclass
            iv_artifact_type = /neptune/if_artifact_type=>gc_artifact_type-enhancement
          receiving
            rs_tadir    = ls_tadir          ##called.

      catch cx_sy_dyn_call_illegal_class
            cx_sy_dyn_call_illegal_method.

        return.

    endtry.

    if ls_tadir is not initial.
      concatenate ls_tadir-artifact_name cv_filename into cv_filename separated by mc_name_separator.
    else.
      read table gt_mapping into ls_mapping with key key = is_item-obj_name.
      if sy-subrc = 0.
        concatenate ls_mapping-name cv_filename into cv_filename separated by mc_name_separator.
      endif.
    endif.

  endmethod.


  method zif_abapgit_object~serialize.

    data: lo_artifact      type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    field-symbols: <lt_standard_table> type standard table,
                   <ls_line>           type any,
                   <lv_field_value>    type any.

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

    read table lt_table_content into ls_table_content with key tabname = '/NEPTUNE/ENHANCE'.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_standard_table>.
      check sy-subrc = 0 and <lt_standard_table> is not initial.
      read table <lt_standard_table> assigning <ls_line> index 1.
      check sy-subrc = 0.
      assign component 'DESCR' of structure <ls_line> to <lv_field_value> casting type /neptune/enhance-descr.
      check sy-subrc = 0 and <lv_field_value> is not initial.
    endif.


* serialize
    loop at lt_table_content into ls_table_content.

      case ls_table_content-tabname.
        when '/NEPTUNE/ENHTEXT'.

          serialize_enhtext(
            iv_name          = <lv_field_value>
            is_table_content = ls_table_content ).

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
