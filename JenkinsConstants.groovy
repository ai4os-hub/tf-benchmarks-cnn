import groovy.transform.Field
// This file defines variables to be used in the AI4OS-Hub Upstream Jenkins pipeline
// base_cpu_tag : base docker image for Dockerfile, CPU version
// base_gpu_tag : base docker image tag for Dockerfile, GPU version
// dockerfile : what Dockerfile to use for building, can include path, e.g. docker/Dockerfile

//@Field
//def base_cpu_tag = '20.06-tf2-py3'

//@Field
//def base_gpu_tag = '20.06-tf2-py3'

@Field
def dockerfile = 'Dockerfile'

return this;
