class ZCL_ABAPGIT_OBJECT_ZN18 definition
  public
  inheriting from ZCL_ABAPGIT_OBJECTS_SUPER
  final
  create public .

public section.

  interfaces ZIF_ABAPGIT_OBJECT .
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
    begin of ty_lcl_mime,
               name           type /neptune/mime-name          ,
               parent         type /neptune/mime-parent        ,
               type           type /neptune/mime-type          ,
               descr          type /neptune/mime-descr         ,
               credat         type /neptune/mime-credat        ,
               cretim         type /neptune/mime-cretim        ,
               crenam         type /neptune/mime-crenam        ,
               file_kb        type /neptune/mime-file_kb       ,
               configuration  type /neptune/mime-configuration ,
               guid           type /neptune/mime-guid          ,
               file_name      type string,
         end of ty_lcl_mime .
  types:
    ty_tt_lcl_mime type standard table of ty_lcl_mime .

  constants:
    mc_name_separator(1) type c value '@'. "#EC NOTEXT
  data GT_SKIP_PATHS type STRING_TABLE .
  class-data GT_MAPPING type TY_MAPPING_TT .

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
  interface ZIF_ABAPGIT_GIT_DEFINITIONS load .
  methods DESERIALIZE_TABLE
    importing
      !IS_FILE type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILE
      !IR_DATA type ref to DATA
      !IV_KEY type /NEPTUNE/ARTIFACT_KEY
      !IV_TABNAME type TADIR-OBJ_NAME
      !IT_FILES type ZIF_ABAPGIT_GIT_DEFINITIONS=>TY_FILES_TT
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods GET_VALUES_FROM_FILENAME
    importing
      !IS_FILENAME type STRING
    exporting
      !EV_TABNAME type TADIR-OBJ_NAME
      !EV_NAME type /NEPTUNE/ARTIFACT_NAME .
  methods GET_FULL_FILE_PATH
    importing
      !IV_PARENT type /NEPTUNE/MIME_T-PARENT
      !IT_MIME_T type TY_T_MIME_T
    returning
      value(RV_PATH) type STRING .
  interface /NEPTUNE/IF_ARTIFACT_TYPE load .
  methods SERIALIZE_MIME_TABLE
    importing
      !IV_TABNAME type TABNAME
      !IS_TABLE_CONTENT type /NEPTUNE/IF_ARTIFACT_TYPE=>TY_TABLE_CONTENT .
  methods DESERIALIZE_MIME_TABLE .
ENDCLASS.



CLASS ZCL_ABAPGIT_OBJECT_ZN18 IMPLEMENTATION.


method DESERIALIZE_MIME_TABLE.
endmethod.


  method DESERIALIZE_TABLE.

    data lo_ajson type ref to zcl_abapgit_ajson.
    data lx_ajson type ref to zcx_abapgit_ajson_error.

    data lt_table_content type ref to data.
    data ls_file like line of it_files.

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

      if iv_tabname = '/NEPTUNE/DOC_H' ##NO_TEXT.
        assign component 'DOC_TEXT' of structure <ls_line> to <lv_field> ##NO_TEXT.
        check sy-subrc = 0 and <lv_field> is not initial.

        read table it_files into ls_file with key filename = <lv_field>.
        check sy-subrc = 0.

        <lv_field> = zcl_abapgit_convert=>xstring_to_string_utf8( ls_file-data ).
      endif.
    endloop.



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
      if <ls_mime_t>-parent is initial and <ls_mime_t>-guid ne /neptune/cl_nad_cockpit=>media_folder-media_pack.
        concatenate 'Media Library' rv_path into rv_path separated by '_'.
      endif.
      lv_parent = <ls_mime_t>-parent.
    else.
      clear lv_parent.
    endif.
  endwhile.

endmethod.


  method GET_SKIP_FIELDS.

    rt_skip_paths = gt_skip_paths.

  endmethod.


  method GET_VALUES_FROM_FILENAME.

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
        lv_guid          type string.

  field-symbols: <lt_standard_table> type standard table,
                 <ls_line>           type any,
                 <lv_data>           type any,
                 <lv_name>           type any,
                 <lv_parent>         type any,
                 <lv_guid>           type any.

  assign is_table_content-table_content->* to <lt_standard_table>.
  check sy-subrc = 0 and <lt_standard_table> is not initial.

  lt_mime = <lt_standard_table>.


  loop at lt_mime into ls_mime.
    move-corresponding ls_mime to ls_lcl_mime.

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

    lv_guid = <lv_guid>.

    concatenate lv_guid
                ms_item-obj_type
                is_table_content-tabname into ls_file-filename separated by '.'.

    replace all occurrences of '/' in ls_file-filename with '#'.
    concatenate ls_mime-name ls_file-filename into ls_file-filename separated by mc_name_separator.

    translate ls_file-filename to lower case.

    ls_file-path = '/'.
    ls_file-data = <lv_data>.

    zif_abapgit_object~mo_files->add( ls_file ).


    ls_lcl_mime-file_name = ls_file-filename.

    append ls_lcl_mime to lt_lcl_mime.
  endloop.


*  loop at <lt_standard_table> assigning <ls_line>.
*
*    assign component 'DATA' of structure <ls_line> to <lv_data> casting type /neptune/mime-data.
*    if sy-subrc = 0 and <lv_data> is not initial.
*
*      assign component 'NAME' of structure <ls_line> to <lv_name> casting type /neptune/mime-name.
*      check sy-subrc = 0.
*      assign component 'GUID' of structure <ls_line> to <lv_guid> casting type /neptune/mime-guid.
*      check sy-subrc = 0.
*      assign component 'PARENT' of structure <ls_line> to <lv_parent> casting type /neptune/mime-parent.
*      check sy-subrc = 0.
*
**            lv_path = get_full_file_path(
**                          iv_parent = <lv_parent>
**                          it_mime_t = <lt_mime_t> ).
**
**            concatenate lv_path <lv_name> into lv_path.
**
**            lv_guid = <lv_guid>.
**
**            concatenate lv_guid
**                        ms_item-obj_type
**                        ls_table_content-tabname
**                        lv_path into ls_file-filename separated by '.'.
**
**            replace all occurrences of '/' in ls_file-filename with '#'.
*
*      lv_guid = <lv_guid>.
*
*      concatenate lv_guid
*                  ms_item-obj_type
*                  is_table_content-tabname into ls_file-filename separated by '.'.
*
*      replace all occurrences of '/' in ls_file-filename with '#'.
*      concatenate <lv_name> ls_file-filename into ls_file-filename separated by mc_name_separator.
*
*      translate ls_file-filename to lower case.
*
*      ls_file-path = '/'.
*      ls_file-data = <lv_data>.
*
*      zif_abapgit_object~mo_files->add( ls_file ).
**            <lv_data> = ls_file-filename.
*
*      cl_bcs_convert=>string_to_xstring(
*        exporting
*          iv_string     = ls_file-filename    " Input data
**    iv_convert_cp = 'X'    " Run Code Page Conversion
**    iv_codepage   =     " Target Code Page in SAP Form  (Default = SAPconnect Setting)
**    iv_add_bom    =     " Add Byte-Order Mark
*        receiving
*          ev_xstring    = <lv_data>    " Output data
*      ).
**  catch cx_bcs.    " BCS: General Exceptions
*
*
*    endif.
*
*  endloop.

  serialize_table(
    iv_tabname = is_table_content-tabname
    it_table   = lt_lcl_mime ).


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


  method ZIF_ABAPGIT_OBJECT~CHANGED_BY.

    data: lo_artifact type ref to /neptune/if_artifact_type,
          lt_table_content type /neptune/if_artifact_type=>ty_t_table_content,
          ls_table_content like line of lt_table_content,
          lv_key           type /neptune/artifact_key.

    data ls_doc type /neptune/doc.

    field-symbols <lt_standard_table> type standard table.

    lo_artifact = /neptune/cl_artifact_type=>get_instance( iv_object_type = ms_item-obj_type ).

    lv_key = ms_item-obj_name.

    lo_artifact->get_table_content(
      exporting iv_key1          = lv_key
      importing et_table_content = lt_table_content ).

    read table lt_table_content into ls_table_content with table key tabname = '/NEPTUNE/DOC'.
    if sy-subrc = 0.
      assign ls_table_content-table_content->* to <lt_standard_table>.
      check sy-subrc = 0.
      read table <lt_standard_table> into ls_doc index 1.
      if sy-subrc = 0 and ls_doc-updnam is not initial.
        rv_user = ls_doc-updnam.
      else.
        rv_user = ls_doc-crenam.
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

      deserialize_table(
        is_file    = ls_files
        iv_key     = lv_key
        iv_tabname = lv_tabname
        ir_data    = lr_data
        it_files   = lt_files ).

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
            iv_artifact_type = /neptune/if_artifact_type=>gc_artifact_type-mime_folder
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
    read table lt_table_content into ls_table_content with key tabname = '/NEPTUNE/MIME_T'.
    if sy-subrc eq 0.
      assign ls_table_content-table_content->* to <lt_mime_t>.
    endif.

* serialize
    loop at lt_table_content into ls_table_content.

      assign ls_table_content-table_content->* to <lt_standard_table>.

      check sy-subrc = 0 and <lt_standard_table> is not initial.

      case ls_table_content-tabname.
        when '/NEPTUNE/MIME'.
          serialize_mime_table(
            iv_tabname       = ls_table_content-tabname
            is_table_content = ls_table_content ).

        when others.

          serialize_table(
            iv_tabname = ls_table_content-tabname
            it_table   = <lt_standard_table> ).
      endcase.

*      if ls_table_content-tabname = '/NEPTUNE/MIME'.
*        loop at <lt_standard_table> assigning <ls_line>.
*
*          assign component 'DATA' of structure <ls_line> to <lv_data> casting type /neptune/mime-data.
*          if sy-subrc = 0 and <lv_data> is not initial.
*
*            assign component 'NAME' of structure <ls_line> to <lv_name> casting type /neptune/mime-name.
*            check sy-subrc = 0.
*            assign component 'GUID' of structure <ls_line> to <lv_guid> casting type /neptune/mime-guid.
*            check sy-subrc = 0.
*            assign component 'PARENT' of structure <ls_line> to <lv_parent> casting type /neptune/mime-parent.
*            check sy-subrc = 0.
*
**            lv_path = get_full_file_path(
**                          iv_parent = <lv_parent>
**                          it_mime_t = <lt_mime_t> ).
**
**            concatenate lv_path <lv_name> into lv_path.
**
**            lv_guid = <lv_guid>.
**
**            concatenate lv_guid
**                        ms_item-obj_type
**                        ls_table_content-tabname
**                        lv_path into ls_file-filename separated by '.'.
**
**            replace all occurrences of '/' in ls_file-filename with '#'.
*
*            lv_guid = <lv_guid>.
*
*            concatenate lv_guid
*                        ms_item-obj_type
*                        ls_table_content-tabname into ls_file-filename separated by '.'.
*
*            replace all occurrences of '/' in ls_file-filename with '#'.
*            concatenate <lv_name> ls_file-filename into ls_file-filename separated by mc_name_separator.
*
*            translate ls_file-filename to lower case.
*
*            ls_file-path = '/'.
*            ls_file-data = <lv_data>.
*
*            zif_abapgit_object~mo_files->add( ls_file ).
**            <lv_data> = ls_file-filename.
*
*            cl_bcs_convert=>string_to_xstring(
*              exporting
*                iv_string     = ls_file-filename    " Input data
**    iv_convert_cp = 'X'    " Run Code Page Conversion
**    iv_codepage   =     " Target Code Page in SAP Form  (Default = SAPconnect Setting)
**    iv_add_bom    =     " Add Byte-Order Mark
*              receiving
*                ev_xstring    = <lv_data>    " Output data
*            ).
**  catch cx_bcs.    " BCS: General Exceptions
*
*
*          endif.
*
*        endloop.
*
*
*        serialize_table(
*          iv_tabname = ls_table_content-tabname
*          it_table   = <lt_standard_table> ).
*
*        " to avoid serializing the actual /neptune/mime table
*        continue. " loop at lt_table_content into ls_table_content.
*      endif.

      serialize_table(
        iv_tabname = ls_table_content-tabname
        it_table   = <lt_standard_table> ).

    endloop.

  endmethod.
ENDCLASS.
