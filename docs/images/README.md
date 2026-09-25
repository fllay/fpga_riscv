# Wiki screenshots

Drop screenshot files in this folder to fill the placeholders referenced by
the wiki pages. Naming convention: `<page-slug>-<NN>-<short-name>.png`, e.g.

```
build-guide-01-create-project.png       (New Project wizard: project name/location)
build-guide-01b-project-type.png        (New Project wizard: project type)
build-guide-01c-wizard-add-sources.png  (New Project wizard: Add Sources page, left empty)
build-guide-02-add-sources.png          (Add Source Files dialog: selecting files)
build-guide-02b-sources-list.png        (confirmed source list with locations)
build-guide-03-add-constraints.png      (Add Constraint Files dialog)
build-guide-03b-default-part.png        (Default Part wizard page: Boards tab, KR260)
build-guide-04-create-vio.png
build-guide-05a-synthesis.png
build-guide-05b-set-up-debug.png
build-guide-06-program-device.png
build-guide-07-run-it.png
```

`docs/Build-Guide.md` currently has one placeholder per numbered step, in
that order — matching Vivado's actual flow:

1. Create a new project (target part `xck26-sfvc784-2LV-c`)
2. Add design sources
3. Add constraints
4. Create/customize the `vio_0` IP
5. Run Synthesis (5a) and the Set Up Debug wizard (5b)
6. Program the device
7. Run it (ILA/VIO dashboards with the core running)

Once an image is dropped in with the matching filename, it renders
automatically wherever `docs/Build-Guide.md` references it — no other edits
needed. When a single step spans more than one Vivado screen (like the New
Project wizard in step 1), extra screens get a letter suffix (`01b`, `01c`,
...) rather than their own step number.

Other pages ([Debug Workflow](../Debug-Workflow.md),
[Loading Programs](../Loading-Programs.md),
[Troubleshooting](../Troubleshooting.md)) don't have placeholders yet; say
the word and the same pattern (`<page-slug>-NN-name.png`) can be added to
any of them.
