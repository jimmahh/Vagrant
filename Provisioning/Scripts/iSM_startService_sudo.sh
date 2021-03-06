#!/bin/sh

unset CDPATH

echo "----------------------------------------------------------------"
echo "Start iWay Service Manager - 8.0.0.101"
echo "Copyright (C) 2003-2017, iWay Software/Information Builders, Inc."
echo "All Rights Reserved."
echo "----------------------------------------------------------------"

if [ $# -ne 1 -o "X$1" = 'X-h' -o "X$1" = 'X-help' ]; then
   echo "Usage: $0 <IWAYCONFIG>"
   exit 2
fi

IWAY8SM=/iway/iway8
IWAYUSER=vagrant
MOD=""

if [ `uname` = 'OS400' ]; then
   export COMMAND='chgjob job('$JOBNAME') runpty(20)'
   system $COMMAND
   export QIBM_MULTI_THREADED=y
   export QIBM_JAVA_PASE_STARTUP='/usr/lib/start64'
   LIBPATH=$LIBPATH:$IWAY8SM/lib
   export LIBPATH
   MOD=-s
fi

export $MOD IWAY8SM

DEFAULT_CP=`echo $IWAY8SM/config/$1/lib/*.jar $IWAY8SM/lib/*.jar $IWAY8SM/etc/manager/extensions/*.jar $IWAY8SM/etc/manager/console/*.jar $IWAY8SM/etc/manager/transformations/custom_functions/*.jar $IWAY8SM/etc/manager/transformations/custom_functions/ | tr ' ' ':'`
CP_AND_OPTIONS=`java -cp $DEFAULT_CP -DIWAY8=$IWAY8SM ISMParse -config $1 -srvr.cp $DEFAULT_CP`
echo ""
echo "----------------------------------------------------------------"
echo IWAY8SM home directory: $IWAY8SM
echo "iSM will start with classpath and JVM options: $CP_AND_OPTIONS"
echo "----------------------------------------------------------------"
echo ""
UNAME=`uname`
cd $IWAY8SM/config/$1
echo "Starting java"

if [ "$UNAME" != 'OS400' -a "$UNAME" != 'OS/390' -a "X$1" = 'Xbase' ]; then
   sudo -i -u $IWAYUSER java $CP_AND_OPTIONS -Diwaysoftware.af.idocument=com.ibi.edaqm.XDDocument -DIWAY8=$IWAY8SM edaqm -service -config $@ >> $IWAY8SM/bin/service.log &
else
   java $CP_AND_OPTIONS -Diwaysoftware.af.idocument=com.ibi.edaqm.XDDocument -DIWAY8=$IWAY8SM edaqm -service -config $@ >> $IWAY8SM/bin/service.log &
fi