## TensorFlow Benchmark Example

This example runs the TensorFlow benchmarks (for V1.8) on the Spartan GPGPU partition. By default, it uses ResNet, a batch size of 64, and a whole node (4 GPUS and 24 CPUs), but this can be varied as needed.

As of 18 July 2018, this particular configuration was achieving about 730 images/second across 4 GPUs.

Benchmark: https://www.tensorflow.org/performance/benchmarks

Source: https://github.com/tensorflow/benchmarks/
