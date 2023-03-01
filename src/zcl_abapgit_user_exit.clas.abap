class ZCL_ABAPGIT_USER_EXIT definition
  public
  final
  create public .

public section.

  interfaces ZIF_ABAPGIT_EXIT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ABAPGIT_USER_EXIT IMPLEMENTATION.


method zif_abapgit_exit~change_tadir.

*  data: ls_tadir like line of ct_tadir.
  field-symbols: <fs_tadir> like line of ct_tadir.

  if sy-uname eq 'ANDREC'.
    BREAK-POINT.
    if iv_package cs '$NEPTUNE_GIT_TESTING'.
*      append value #(
*        pgmid    = 'R3TR'
*        object   = 'ZN01'"some_logic( something )
*        obj_name = 'ANDRE_GIT_TESTES' "something-name
*        devclass = iv_package
*        path     = '/src/'
*        ) to ct_tadir.


      append initial line to ct_tadir assigning <fs_tadir>.
      if sy-subrc eq 0.
        <fs_tadir>-pgmid    = 'R3TR'.
        <fs_tadir>-object   = 'ZN01' ."some_logic( something ).
        <fs_tadir>-obj_name = 'ANDRE_GIT_TESTES' . "something-name.
        <fs_tadir>-devclass = iv_package.
        <fs_tadir>-path     = '/src/' .
      endif.
    endif.
  endif.
endmethod.
ENDCLASS.
