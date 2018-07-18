## TensorFlow Example

This is a very simple example which shows how to use TensorFlow with the Spartan GPGPU partition. It requests a single CPU and NVidia P100 GPU,  multiplies together two small matrices on the GPU, and prints the result. It will also print a little debug info showing that the calculation is being performed on the GPU (rather than CPU).

It can be submitted with the command `sbatch tensor_flow.slurm`.

You'll need access to the GPGPU partition before this example will work, see https://dashboard.hpc.unimelb.edu.au/gpu/ for details.

N.B. If you belong to multiple projects, and the default one doesn't have access to the gpgpu partition, you might have to explictly specify the project with `sbatch -A <project name> tensor_flow.slurm`.

This example is based on: https://www.tensorflow.org/guide/using_gpu
