#!/bin/bash

#SBATCH --job-name=star
#SBATCH --nodes=1
#SBATCH --export=ALL
#SBATCH --time=4:00:00
#SBATCH --mail-type=FAIL
#SBATCH --requeue

./load_mesasdk.sh

if [ -n "${USE_MESA_TEST}" ]; then
    mesa_test test ${SLURM_ARRAY_TASK_ID} --module=star ${MESA_TEST_OPTIONS}
else
    cd ${MESA_DIR}/star/test_suite
    ./each_test_run ${SLURM_ARRAY_TASK_ID}
fi
