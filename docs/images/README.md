# Wiki screenshots

Drop screenshot files in this folder to fill the placeholders referenced by
the wiki pages. Naming convention: `<page-slug>-<NN>-<short-name>.png`, e.g.

```
build-guide-01-create-project.png       (New Project wizard: project name/location)
build-guide-01b-project-type.png        (New Project wizard: project type)
build-guide-01c-wizard-add-sources.png  (New Project wizard: Add Sources page, left empty)
build-guide-02-add-sources.png          (Add Source Files dialog: selecting files, incl. top.sv)
build-guide-02b-sources-list.png        (confirmed source list with locations)
build-guide-02c-add-sources-wizard.png  (post-creation Add Sources dialog)
build-guide-02d-add-board-wrapper.png   (adding top_kr260_riscv.sv from board/)
build-guide-02e-sources-verified.png    (final Sources panel, hierarchy confirmed)
build-guide-03-add-constraints.png      (Add Constraint Files dialog)
build-guide-03b-default-part.png        (Default Part wizard page: Boards tab, KR260)
build-guide-sim-01-add-memory-file.png  (adding machine_code.mem as a simulation source)
build-guide-sim-01b-add-testbench.png   (adding sim/test_bench.sv as a simulation source)
build-guide-sim-01c-set-testbench-top.png  (test_bench set as simulation top, hierarchy confirmed)
build-guide-sim-01d-exclude-board-wrapper.png  (USED_IN property: removing "simulation")
build-guide-sim-01e-exclude-verified.png   (Sources panel mid-simulation:
                                             top_kr260_riscv gone from sim_1,
                                             vio_0 + test_bench/dut remain)
build-guide-sim-02-run-simulation.png   (Run Behavioral Simulation)
build-guide-sim-03-waveform.png         (simulation waveform)
build-guide-04a-ip-catalog-vio.png      (IP Catalog: searching "vio")
build-guide-04b-customize-vio.png       (Customize IP: input count set to 0)
build-guide-04c-generate-output-products.png  (Generate Output Products dialog)
build-guide-04d-vio-synth-complete.png  (Design Runs: vio_0_synth_1 complete)
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
4. Run a behavioral simulation
5. Create/customize the `vio_0` IP
6. Run Synthesis (6a) and the Set Up Debug wizard (6b)
7. Program the device
8. Run it (ILA/VIO dashboards with the core running)

**Note on filename numbers vs. step numbers:** step 4 (behavioral
simulation) was inserted after the VIO/synthesis/program-device/run-it
screenshots were already captured and named, so those keep their original
`04a`–`04d` / `05a`–`05b` / `06` / `07` filenames even though they now
illustrate steps 5–8. The filename prefix is just an identifier — the step
each image belongs to is whatever `docs/Build-Guide.md` says, not the
number in the filename. The simulation step's own images use a `sim-NN`
prefix instead of `04-*` to avoid colliding with the already-named VIO
screenshots.

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
