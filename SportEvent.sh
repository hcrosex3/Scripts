#!/bin/sh
#
# Original Author: Nicole Green
#
# Program Name: Sport Event Container Restart
#
# Purpose: Reset Database connections
#
# Dated Revisions: see RCS
#----------------------------------------------------------------------------------------------------------------


eval kill -9 `ps aux|grep java|grep dmENGQA.ctesbSdrSportEvent| awk '{ print $2 }'`
/sonic/qa/01/sonic85/espn_runtime/Containers/dmENGQA.ctesbSdrSportEvent1/launchcontainer.sh &
