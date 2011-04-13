#!/bin/sh
# Copyright (c) 2011 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed by the Apache license that can be
# found in the LICENSE file.

ROOT=$(dirname $0)
cd $ROOT
../landslide silent_data_corruption.md --theme mine --embed -d silent_data_corruption.html
../landslide maruel_git.md --theme mine --embed -d maruel_git.html
