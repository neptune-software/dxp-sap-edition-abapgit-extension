# Neptune DXP SAP Edition abapGit Extension Objects.

Leveraging the already well-known open-source software [abapGit](https://github.com/abapGit/abapGit), we now provide an interface to integrate all Neptune DXP artifacts with GitHub.

This will allow you to have side-by-side your ABAP artifacts with your Neptune DXP artifacts, making it possible to store, version, and deploy full solutions across systems using GitHub.


## Documentation and Guides
Check out our full documentation about this extension [here.](https://docs.neptune-software.com/neptune-sap-edition/23/resources-help/abapGit-integration.html)

## Post-installation activities
If this is the first time implementing abapGit user exits, you will need to create a class named ZCL_ABAPGIT_USER_EXIT with interface ZIF_ABAPGIT_EXIT, then it is necessary to implement the code showned below in the mentioned methods. The full user exit guide for abapGit can be found [here.](https://docs.abapgit.org/user-guide/reference/exits.html)

If you already have the abapGit user exit class implemented, please add and adjust the code shown below to the mentioned methods.

#### CHANGE_SUPPORTED_OBJECT_TYPES:

```abap
// Change supported object types to recognize Neptune DXP Artifacts
  method zif_abapgit_exit~change_supported_object_types.

    data: lt_neptune_types type /neptune/cl_abapgit_user_exit=>ty_object_types_tt,
              ls_neptune_types like line of lt_neptune_types.

    data ls_types like line of ct_types.

    lt_neptune_types = /neptune/cl_abapgit_user_exit=>change_supported_object_types( ).
    loop at lt_neptune_types into ls_neptune_types.
      ls_types = ls_neptune_types.
      append ls_types to ct_types.
    endloop.

  endmethod.
```

#### CHANGE_TADIR:

> [!NOTE]
> Parameter _iv_ignore_subpackages_ is available from Neptune SAP Edition DXP23.10.0003 and abapGit V1.127

```abap
// Include Neptune DXP Artifacts in the internal tadir table
  method zif_abapgit_exit~change_tadir.

    data: lt_neptune_tadir type /neptune/cl_abapgit_user_exit=>ty_tadir_tt,
              ls_neptune_tadir like line of lt_neptune_tadir.

    data ls_tadir like line of ct_tadir.

    lt_neptune_tadir = /neptune/cl_abapgit_user_exit=>change_tadir( 
                                                        iv_package            = iv_package 
                                                        iv_ignore_subpackages = iv_ignore_subpackages ).

    loop at lt_neptune_tadir into ls_neptune_tadir.
      move-corresponding ls_neptune_tadir to ls_tadir.
      append ls_tadir to ct_tadir.
    endloop.

  endmethod.
```

## Bug Reports

A bug is a _demonstrable problem_ that is caused by the code in the repository. Good bug reports are extremely helpful - thank you!

Guidelines for bug reports:

1. **Use the GitHub issue search** &mdash; check if the issue has already been reported.

2. **Check if the issue has been fixed** &mdash; try to reproduce it using the latest version or development branch in the repository.

3. **Demonstrate the problem** &mdash; provide clear steps that can be reproduced.

A good bug report should not leave others needing to chase you up for more information. Please try to be as detailed as possible in your report. What is your environment? What steps will reproduce the issue? What would you expect to be the outcome? All these details will help to fix any potential bugs.
