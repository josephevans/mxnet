#!/usr/bin/env python3

import json
import yaml


DRONE_WORKSPACE_DIR="/drone"



def generate_drone_config():
    with open("pipelines.yaml", "r") as fh:
        pl_conf = yaml.load(fh.read(), Loader=yaml.SafeLoader)
    config = []
    for pipeline_name in pl_conf['pipelines'].keys():
        pl = pl_conf['pipelines'][pipeline_name]
        print("Generating config for pipeline {}".format(pipeline_name))
        clone_cmds = [
            "/ci/get_source.sh",
            "/ci/setup_ccache.sh",
            "du -hs $DRONE_WORKSPACE_BASE/*"
        ]
        pipeline = {
            'kind': 'pipeline',
            'type': 'docker',
            'name': pipeline_name,
            'platform': { 'os': pl['os'], 'arch': pl['arch'] },
            'node': { 'hw': pl['instance-type'] },
            #'node': { 'hw': 'cpu' },
            'clone': { 'disable': True },
            'image_pull_secrets': [ 'dockerconfigjson' ],
            'workspace': {
                'base': '/drone',
                'path': 'mxnet'
            },
            'steps': [
                {
                    'name': 'clone-src',
                    #'image': 'drone/git',
                    'image': '187885003319.dkr.ecr.us-west-2.amazonaws.com/mxnetci/buildtools',
                    'commands': clone_cmds
                }
            ]
        }
        if 'depends-on' in pl.keys():
            pipeline['depends_on'] = pl['depends-on']

        # compile steps
        build_commands = [
            '. /ci/setup_build_env.sh',
            'ls -liaF /work /drone',
            'cd $FLAVOR_BUILD_DIR',
            'ccache --zero-stats',
            'if [ -e /usr/bin/nvidia-smi ]; then /usr/bin/nvidia-smi; fi',
            'set'
        ]
        build_commands += pl['compile']
        build_commands += ["ccache -s"]
        build_commands += ["pwd && find $DRONE_WORKSPACE_BASE -name libmxnet.so"]
        #build_commands += ["ldd $(find $DRONE_WORKSPACE_BASE -name libmxnet.so) || true"]

        #flavor_build_dir = "{}/{}".format(DRONE_WORKSPACE_DIR, pipeline_name)
        flavor_build_dir = "{}/{}".format(DRONE_WORKSPACE_DIR, "mxnet")
        compile_image = pl['image']
        pipeline['steps'].append({
            'name': "compile",
            'image': compile_image,
            'commands': build_commands,
            'depends_on': ['clone-src'],
            'environment': {
                'FLAVOR_BUILD_DIR': flavor_build_dir,
                'NUMPROC': 3
            }
        })

        # test steps
        if 'tests' in pl.keys() and type(pl['tests']) is dict:
            for testname in pl['tests'].keys():
                test = pl['tests'][testname]

                test_commands = [
                    '. /ci/setup_test_env.sh',
                    'cd $FLAVOR_BUILD_DIR',
                    'set',
                    'if [ -e /usr/bin/nvidia-smi ]; then /usr/bin/nvidia-smi; fi'
                ]
                img = pl['image']
                if 'image' in test.keys():
                    img = test['image']

                dependency = "compile"
                if 'depends-on' in test.keys():
                    dependency = "test-{}".format(test['depends-on'])

                pipeline['steps'].append({
                    'name': "test-{}".format(testname),
                    'image': img,
                    'commands': test_commands + test['commands'],
                    'depends_on': [ dependency ],
                    'environment': {
                        'FLAVOR_BUILD_DIR': flavor_build_dir,
                        'NUMPROC': 3
                    }
                })
        build_cleanup_commands = []
        if 'stash-libs' in pl.keys():
            build_cleanup_commands.append("/ci/stash_libs.sh {}".format(pl['stash-libs']))
        build_cleanup_commands += [
            "ls -liaF $DRONE_WORKSPACE_BASE && du -hs $DRONE_WORKSPACE_BASE/* && df -h",
            "/ci/cleanup_ccache.sh"
        ]
        pipeline['steps'].append({
            'name': "build-cleanup",
            'image': '187885003319.dkr.ecr.us-west-2.amazonaws.com/mxnetci/buildtools',
            #'detach': True,
            'when': { 'status': [ 'failure', 'success' ] },
            'commands': build_cleanup_commands,
            'depends_on': [ 'compile' ]
        })
        config.append(pipeline)
    return config


conf = generate_drone_config()
#print(yaml.dump_all(conf))
with open("../../.drone.yml", "w") as fh:
    fh.write(yaml.dump_all(conf))

