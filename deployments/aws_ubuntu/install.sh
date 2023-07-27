#!/bin/bash

terraform init

export auto=yes

make apply.vpc
make apply.eip
make apply.vpc-data
make apply.efs
make apply.bbb
make bbb
make apply.rds
make apply.cache
make apply.sl
make sl
make apply.gl
make gl
