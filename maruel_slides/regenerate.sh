#!/bin/sh
# Copyright (c) 2011 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

ROOT=$(dirname $0)
$ROOT/../landslide $ROOT/silent_data_corruption.md --theme mine --embed -d $ROOT/silent_data_corruption.html
