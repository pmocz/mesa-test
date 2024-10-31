# mesa-test

Josiah Schwab,
Philip Mocz
(2024)

SLURM scripts for running the MESA test_suite on rusty at Flatiron.

These scripts submit a set of jobs that run the [[http://mesastar.org][MESA]] test_suite on a cluster.
It is written for the [[https://slurm.schedmd.com/documentation.html][SLURM]] job scheduler.

The scripts assumes you have a [[http://user.astro.wisc.edu/~townsend/static.php?ref=mesasdk][MESA SDK]] installed,
as well as [[https://github.com/MESAHub/mesa_test][mesa_test]]


## mesa-test.sh

This is the script that you should run. It needs network access to
fetch the latest MESA version, so on my cluster, that means it needs
to run on a login node. It exits after checking out a new copy of
MESA and spawning the other jobs.
```console
./test-mesa.sh [SHA]
```

You should edit this script to customize various values for your
system. Look for comments beginning `# set`.


## star.sh

This runs the star test_suite. It uses SLURM job arrays to run a separate job for
each test case.


## binary.sh

This runs the binary test_suite. It uses SLURM job arrays to run a separate job for
each test case.


## astero.sh

This runs the astero test_suite. It uses SLURM job arrays to run a separate job for
each test case.


## git-hook.sh

This is an example post-receive hook that can start the tests when a
git repo receives a push on a branch. This script will need to be
customized to your system. My system layout is:

There is a bare MESA git repository. (Its location is specified as
`$MESA_GIT_DIR` in the hook.) This file (`git_hook.sh`) is symlinked
to `hooks/post-receive`.

The hook does a checkout of the branch that was pushed to in the
directory `$MESA_TEST_DIR`. This directory is what will be specified
as `$MESA_DIR` in `test_mesa.sh`.
