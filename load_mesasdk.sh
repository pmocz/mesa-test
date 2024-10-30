# MESA::

# set MESA_DIR to be the directory to which you downloaded MESA
# The directory shown is only an example and must be modified for your particular system.
#export MESA_DIR=/mnt/home/pmocz/Projects/Mesa/mesa

# set OMP_NUM_THREADS to be the number of cores on your machine
#export OMP_NUM_THREADS=16

# you should have done this when you set up the MESA SDK
# The directory shown is only an example and must be modified for your particular system.
export MESASDK_ROOT=/mnt/home/pmocz/Projects/Mesa/mesasdk
source $MESASDK_ROOT/bin/mesasdk_init.sh

# add shmesa (the MESA command line tool) to your PATH
#export PATH=$PATH:$MESA_DIR/scripts/shmesa
