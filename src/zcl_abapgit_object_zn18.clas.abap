class zcl_abapgit_object_zn18 definition
  public
  inheriting from zcl_abapgit_objects_super
  final
  create public .

  public section.

    interfaces zif_abapgit_object .
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
      ty_t_mime_t type standard table of /neptune/mime_t with non-unique default key .
    types:
      begin of ty_lcl_mime.
            include type /neptune/mime.
    types: file_name      type string,
      end of ty_lcl_mime .
    types:
      ty_tt_lcl_mime type standard table of ty_lcl_mime .

    constants:
      gc_name_separator(1) type c value '@'.                "#EC NOTEXT
    constants gc_mime_table type tabname value '/NEPTUNE/MIME'. "#EC NOTEXT
    constants gc_mime_t_table type tabname value '/NEPTUNE/MIME_T'. "#EC NOTEXT
    data gt_skip_paths type string_table .
    class-data gt_mapping type ty_mapping_tt .

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
    methods deserialize_mime_table
      importing
        !is_file type zif_abapgit_git_definitions=>ty_file
        !ir_data type ref to data
        !it_files type zif_abapgit_git_definitions=>ty_files_tt
      raising
        zcx_abapgit_exception .
    methods deserialize_table
      importing
        !is_file type zif_abapgit_git_definitions=>ty_file
        !ir_data type ref to data
        !iv_tabname type tadir-obj_name
      raising
        zcx_abapgit_exception .
    methods get_values_from_filename
      importing
        !is_filename type string
      exporting
        !ev_tabname type tadir-obj_name
        !ev_name type /neptune/artifact_name .
    methods get_full_file_path
      importing
        !iv_parent type /neptune/mime_t-parent
        !it_mime_t type ty_t_mime_t
      returning
        value(rv_path) type string .
    interface /neptune/if_artifact_type load .
    methods serialize_mime_table
      importing
        !iv_key type /neptune/artifact_key
        !is_table_content type /neptune/if_artifact_type=>ty_table_content
        !it_mime_t type ty_t_mime_t optional .
endclass.



class zcl_abapgit_object_zn18 implementation.


  method deserialize_mime_table.

    data lt_lcl_mime type ty_tt_lcl_mime.
    data ls_lcl_mime like line of lt_lcl_mime.

    data lt_mime type standard table of /neptune/mime with default key.
    data ls_mime like line of lt_mime.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data ls_file like line of it_files.

    field-symbols <lt_tab> type any table.

    assign ir_data->* to <lt_tab>.
    check sy-subrc = 0.

    try.
        lo_ajson = zcl_abapgit_ajson=>parse( zcl_abapgit_convert=>xstring_to_string_utf8( is_file-data ) ).
        lo_ajson->zif_abapgit_ajson~to_abap( importing ev_container = lt_lcl_mime ).
      catch zcx_abapgit_ajson_error into lx_ajson.
        zcx_abapgit_exception=>raise( lx_ajson->get_text( ) ).
    endtry.

    loop at lt_lcl_mime into ls_lcl_mime.

      move-corresponding ls_lcl_mime to ls_mime.

      read table it_files into ls_file with key filename = ls_lcl_mime-file_name.
      if sy-subrc = 0.

        ls_mime-data = ls_file-data.

      endif.
      append ls_mime to lt_mime.
    endloop.
*
    <lt_tab> = lt_mime.

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


  method get_full_file_path.

    data lv_parent type /neptune/mime_t-parent.

    field-symbols <ls_mime_t> like line of it_mime_t.

    lv_parent = iv_parent.

    while lv_parent is not initial.
      read table it_mime_t assigning <ls_mime_t> with key guid = lv_parent.
      if sy-subrc = 0.
        concatenate <ls_mime_t>-name rv_path into rv_path separated by '_'.
        if <ls_mime_t>-parent is initial and <ls_mime_t>-guid <> /neptune/cl_nad_cockpit=>media_folder-media_pack.
          concatenate 'Media Library' rv_path into rv_path separated by '_'.
        endif.
        lv_parent = <ls_mime_t>-parent.
      else.
        clear lv_parent.
      endif.
    endwhile.

  endmethod.


  method get_skip_fields.

    rt_skip_paths = gt_skip_paths.

  endmethod.


  method get_values_from_filename.

    data lt_comp type standard table of string with default key.
    data ls_comp like line of lt_comp.

    split is_filename at '.' into table lt_comp.

    read table lt_comp into ls_comp index 1.
    if sy-subrc = 0.
      translate ls_comp to upper case.
      ev_name = ls_comp.
    endif.

    read table lt_comp into ls_comp index 3.
    if sy-subrc = 0.
      replace all occurrences of '#' in ls_comp with '/'.
      translate ls_comp to upper case.
      ev_tabname = ls_comp.
    endif.

  endmethod.


  method serialize_mime_table.

    data lt_lcl_mime type ty_tt_lcl_mime.
    data ls_lcl_mime like line of lt_lcl_mime.

    data lt_mime type standard table of /neptune/mime with default key.
    data ls_mime like line of lt_mime.

    data: ls_file          type zif_abapgit_git_definitions=>ty_file,
          lv_path          type string,
          lv_guid          type string,
          lv_name          type string,
          lv_ext           type char10.

    field-symbols: <lt_standard_table> type standard table.

    assign is_table_content-table_content->* to <lt_standard_table>.
    check sy-subrc = 0 and <lt_standard_table> is not initial.

    lt_mime = <lt_standard_table>.

    loop at lt_mime into ls_mime.
      move-corresponding ls_mime to ls_lcl_mime.
      " clear the image from this field because the image will be its own file
      clear ls_lcl_mime-data.

**********************************************************************
*            lv_path = get_full_file_path(
*                          iv_parent = ls_mime-parent
*                          it_mime_t = <lt_mime_t> ).
*
*            concatenate lv_path ls_mime-name into lv_path.
*
*            lv_guid = ls_mime-guid.
*
*            concatenate lv_guid
*                        ms_item-obj_type
*                        IS_TABLE_CONTENT-tabname
*                        lv_path into ls_file-filename separated by '.'.
*
*            replace all occurrences of '/' in ls_file-filename with '#'.
**********************************************************************

      lv_guid = ls_mime-guid.

      concatenate iv_key
                  ms_item-obj_type
*                  is_table_content-tabname into ls_file-filename separated by '.'.
                  is_table_content-tabname
                  lv_guid into ls_file-filename separated by '.'.

      replace all occurrences of '/' in ls_file-filename with '#'.

      split ls_mime-name at '.' into lv_name lv_ext.

      concatenate lv_name ls_file-filename into ls_file-filename separated by gc_name_separator.
      concatenate ls_file-filename lv_ext into ls_file-filename separated by '.'.

      translate ls_file-filename to lower case.

      ls_file-path = '/'.
      ls_file-data = ls_mime-data.

      zif_abapgit_object~mo_files->add( ls_file ).

      ls_lcl_mime-file_name = ls_file-filename.

      append ls_lcl_mime to lt_lcl_mime.
    endloop.

    serialize_table(
      iv_tabname = is_table_content-tabname
      it_table   = lt_lcl_mime ).


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
    append lv_skip to gt_skip_paths.
    lv_skip = '*APPLID' ##NO_TEXT.
    append lv_skip to gt_skip_paths.
    lv_skip = '*CREDAT' ##NO_TEXT.
    append lv_skip to gt_skip_paths.
    lv_skip = '*CRETIM' ##NO_TEXT.
    append lv_skip to gt_skip_paths.
    lv_skip = '*CRENAM' ##NO_TEXT.
    append lv_skip to gt_skip_paths.
    lv_skip = '*UPDDAT' ##NO_TEXT.
    append lv_skip to gt_skip_paths.
    lv_skip = '*UPDTIM' ##NO_TEXT.
    append lv_skip to gt_skip_paths.
    lv_skip = '*UPDNAM' ##NO_TEXT.
    append lv_skip to gt_skip_paths.


  endmethod.


  method zif_abapgit_object~changed_by.
    return.
  endmethod.


  method zif_abapgit_object~delete.
    return.
  endmethod.


  method zif_abapgit_object~deserialize.

** pick up logic from CLASS ZCL_ABAPGIT_DATA_DESERIALIZER

    data lo_artifact type ref to /neptune/if_artifact_type.

    data: lt_files type zif_abapgit_git_definitions=>ty_files_tt,
          ls_files like line of lt_files.

    data: lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content.

    data lr_data    type ref to data.
    data lv_tabname type tadir-obj_name.
    data lv_key     type /neptune/artifact_key.
    data lv_name    type /neptune/artifact_name.

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
          ev_tabname  = lv_tabname
          ev_name     = lv_name ).

      create data lr_data type standard table of (lv_tabname) with non-unique default key.

      case lv_tabname.
        when gc_mime_table.
          deserialize_mime_table(
            is_file  = ls_files
            ir_data  = lr_data
            it_files = lt_files ).

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

      lo_artifact->set_table_content(
        iv_key1                 = lv_key
        it_insert_table_content = lt_table_content ).

      lo_artifact->update_tadir_entry(
          iv_key1          = lv_key
          iv_devclass      = ms_item-devclass
          iv_artifact_name = lv_name ).

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

    split iv_filename at gc_name_separator into lv_artifact_name lv_filename.
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
            iv_artifact_type = /neptune/if_artifact_type=>gc_artifact_type-mime_folder
          receiving
            rs_tadir    = ls_tadir          ##called.

      catch cx_sy_dyn_call_illegal_class
            cx_sy_dyn_call_illegal_method.

        return.

    endtry.

    if ls_tadir is not initial.
      concatenate ls_tadir-artifact_name cv_filename into cv_filename separated by gc_name_separator.
    else.
      read table gt_mapping into ls_mapping with key key = is_item-obj_name.
      if sy-subrc = 0.
        concatenate ls_mapping-name cv_filename into cv_filename separated by gc_name_separator.
      endif.
    endif.

  endmethod.


  method zif_abapgit_object~serialize.

    data: lo_artifact      type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key,
          ls_file          type zif_abapgit_git_definitions=>ty_file,
          lv_path          type string,
          lv_guid          type string.

    field-symbols: <lt_standard_table> type standard table,
                   <ls_line>           type any,
                   <lv_data>           type any,
                   <lv_name>           type any,
                   <lv_parent>         type any,
                   <lv_guid>           type any.

    field-symbols <lt_mime_t> type ty_t_mime_t.

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


* get folders table
    read table lt_table_content into ls_table_content with key tabname = gc_mime_t_table.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_mime_t>.
    endif.

    check <lt_mime_t> is assigned.
    
* serialize
    loop at lt_table_content into ls_table_content.

      assign ls_table_content-table_content->* to <lt_standard_table>.

      check sy-subrc = 0 and <lt_standard_table> is not initial.

      case ls_table_content-tabname.
        when gc_mime_table.
          serialize_mime_table(
            iv_key           = lv_key
            is_table_content = ls_table_content
            it_mime_t        = <lt_mime_t> ).

        when others.
          serialize_table(
            iv_tabname = ls_table_content-tabname
            it_table   = <lt_standard_table> ).
      endcase.

    endloop.

  endmethod.
endclass.
