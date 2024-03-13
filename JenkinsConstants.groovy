import groovy.transform.Field
// This file defines variables to be used in the AI4OS-Hub Upstream Jenkins pipeline
// base_image   : base docker image for Dockerfile
// base_gpu_tag : base docker image tag
// dockerfile : what Dockerfile to use for building, can include path, e.g. docker/Dockerfile

@Field
def base_image = ''

@Field
def base_tag = ''

@Field
def dockerfile = 'Dockerfile'

return this;
