#!/bin/bash
echo ">>>>> Destroy all"
~/ci/destroyContainer.sh
echo ">>>>> Create all"
~/ci/run.sh
