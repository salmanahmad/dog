#!/bin/sh
#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#


# resolve links - $0 may be a soft-link
PRG="$0"

while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
        PRG="$link"
    else
        PRG=`dirname "$PRG"`/"$link"
    fi
done

# TODO - I need to switch over to the jar-with-dependencies at some point.
DIR_NAME=`dirname "$PRG"`
DEP_PATH="$DIR_NAME/../lib/dependency/*"


JAR_NAME="dog.jar"
JAR_PATH="$DIR_NAME/../lib/$JAR_NAME"

CLASSPATH="$JAR_PATH:$DEP_PATH"
COMMAND_NAME="dog.commands.Main"

exec java -classpath "$CLASSPATH" "$COMMAND_NAME"  "$@"

echo $CLASSPATH