#!/bin/bash
set -euxo pipefail

#SBATCH --job-name=test_mesa
#SBATCH --nodes=1
#SBATCH --export=ALL
#SBATCH --time=1:00:00
#SBATCH --mail-type=FAIL
#SBATCH --requeue

# load the MESA sdk
./load_mesasdk.sh


# set email address for SLURM and for cleanup output
export MY_EMAIL_ADDRESS=pmocz@flatironinstitute.org

# set SLURM options (used for all sbatch calls)
export MY_SLURM_OPTIONS="--partition=gen"

# set how many threads; this will also be sent to SLURM as --ntasks-per-node
export OMP_NUM_THREADS=64


# set other relevant MESA options
#export MESA_SKIP_OPTIONAL=t
#export MESA_FPE_CHECKS_ON=1
export MESA_GIT_LFS_SLEEP=30
export MESA_FORCE_PGSTAR_FLAG=false

# if USE_MESA_TEST is set, use mesa_test gem; pick its options via MESA_TEST_OPTIONS
# otherwise, use built-in each_test_run script
export USE_MESA_TEST=t
export MESA_TEST_OPTIONS="--force"


# first argument to script is SHA
case "${USE_MESA_TEST}" in

    # test with mesa_test
    t)

    if [ "$#" -eq 0 ]; then
        echo "mesa_test on main"
        mesa_test install
    else
        echo "mesa_test on $1"
        mesa_test install $1   # [SHA]
    fi
	mesa_test submit --empty
	export MESA_WORK=/mnt/home/pmocz/.mesa_test/work

	if ! grep "MESA installation was successful" "${MESA_WORK}/build.log"; then
	    echo "MESA installation failed"
	    exit
	fi

	;;

    # test internally
    *)
        #git --git-dir ${MESA_DIR}/.git describe --all --long > ${MESA_DIR}/test.version
	echo "not implemented"
	exit
        ;;
esac


# function to clean caches; executed at start of each job
clean_caches(){
    # clean up cache dir if needed
    if [ -n "${MESA_CACHES_DIR}" ]; then
        rm -rf ${MESA_CACHES_DIR}
        mkdir -p ${MESA_CACHES_DIR}
    fi
}

export -f clean_caches

# run the star test suite
# this part is parallelized, so get the number of tests
cd ${MESA_WORK}/star/test_suite
export NTESTS=$(./count_tests)
cd -

export STAR_JOBID=$(sbatch --parsable \
                           --ntasks-per-node=${OMP_NUM_THREADS} \
                           --array=1-${NTESTS} \
                           --output="${MESA_WORK}/star.log-%a" \
                           --mail-user=${MY_EMAIL_ADDRESS} \
                           ${MY_SLURM_OPTIONS} \
                           star.sh)


# run the binary test suite
# this part is parallelized, so get the number of tests
cd ${MESA_WORK}/binary/test_suite
export NTESTS=$(./count_tests)
cd -

export BINARY_JOBID=$(sbatch --parsable \
                             --ntasks-per-node=${OMP_NUM_THREADS} \
                             --array=1-${NTESTS} \
                             --output="${MESA_WORK}/binary.log-%a" \
                             --mail-user=${MY_EMAIL_ADDRESS} \
                             ${MY_SLURM_OPTIONS} \
                             binary.sh)


# run the astero test suite
# this part is parallelized, so get the number of tests
cd ${MESA_WORK}/astero/test_suite
export NTESTS=$(./count_tests)
cd -

export ASTERO_JOBID=$(sbatch --parsable \
                             --ntasks-per-node=${OMP_NUM_THREADS} \
                             --array=1-${NTESTS} \
                             --output="${MESA_WORK}/astero.log-%a" \
                             --mail-user=${MY_EMAIL_ADDRESS} \
                             ${MY_SLURM_OPTIONS} \
                             astero.sh)
