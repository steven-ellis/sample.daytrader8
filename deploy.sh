#!/bin/bash

# Deployment wrapper for the Legacy Day Trader application
#
# The Keycloak REST automation is based on guides from
#  - https://dev.to/rounakcodes/keycloak-rest-api-for-realm-role-5hgp
#  - https://suedbroecker.net/2021/07/16/upload-an-user-to-keycloak-using-curl/

AUTH_REALM=stocktrader
PROJECT_HOME=`pwd`
OCP_NAMESPACE=daytrader

# oc_wait_for 
#
# $1 = [pod|node]
# $2 = app-name
# $3 = [app|name|role] - defaults to app
# $4 = namespace - defailts to ${OCP_NAMESPACE}
#
# EG
#    oc_wait_for pod rook-ceph-mon
#
oc_wait_for ()
{
    TYPE=${3:-app}
    NAMESPACE=${4:-$OCP_NAMESPACE}

    echo "Waiting for the ${1}s tagged ${2} = ready"
    oc wait --for condition=ready ${1} -l ${TYPE}=${2} -n ${NAMESPACE} --timeout=400s
}


# check_oc_login
#
# Make sure we're logged into OCP and grab our API endpoint
#
check_oc_login ()
{
    #OC_TOKEN=`oc whoami -t`
    OCP_USER=`oc whoami | sed "s/://"`

    OCP_ENDPOINT=`oc whoami --show-server`

    if [ "${OCP_USER}" == "" ]; then
      echo "You aren't logged into OpenShift at ${OCP_ENDPOINT}"
      exit 1
    else

      echo "You are logged into OpenShift as $OCP_USER at ${OCP_ENDPOINT}"
    fi
}


deploy_kafka ()
{

    oc apply -k k8s/kafka/prod
}


# We need to update the entries in the file


deploy_database ()
{
    
    
    oc apply -k k8s/db/prod


    # Need to implement a delay here while we wait for mysql to load
    oc_wait_for  pod mysql  app 

}

deploy_apps ()
{
    

    oc apply -k k8s/sampledaytrader8/prod

    oc_wait_for pod sampledaytrader8   app 
    
    echo "20s delay while we wait for the service to come up"

}

# confirm_app_running
#
# Uses CURL to query that a webapp is running correctly
#
# $i = URL 
#
confirm_app_running ()
{

   CHECK_URL=${1}

   for i in {1..12}
   do
      echo "checking for 200 status webapp $1 attempt $i"
      status=`curl -o /dev/null -k -s -w "%{http_code}\n" ${CHECK_URL}`
      if [ "${status}" == "200" ] ; then
         echo "Application now available at at ${CHECK_URL}" >&2
         return;
      else
         echo "got status ${status}"
      fi
      sleep 10s
   done
   echo "ERROR: Application at ${CHECK_URL} not in Running state" >&2
   exit
}


populate_db ()
{
    export DAYTRADER_ROUTE="https://$(oc get route -n daytrader sampledaytrader8 -o jsonpath='{.spec.host}')"

    echo "you can access the console via the following URL"
    echo $DAYTRADER_ROUTE/io.openliberty.sample.daytrader8/


    confirm_app_running "$DAYTRADER_ROUTE/io.openliberty.sample.daytrader8/"

    curl -k -X GET "$DAYTRADER_ROUTE/io.openliberty.sample.daytrader8/config?action=buildDBTables" | 


    oc scale -n daytrader --replicas=0 deploy/sampledaytrader8
    oc scale -n daytrader --replicas=1 deploy/sampledaytrader8
    sleep 5s

    oc_wait_for pod sampledaytrader8   app 

    confirm_app_running "$DAYTRADER_ROUTE/io.openliberty.sample.daytrader8/"
    
    echo "Now populate the Database"
    curl -k -X GET "$DAYTRADER_ROUTE/io.openliberty.sample.daytrader8/config?action=buildDB"

    echo "If the populate DB phase fails we recommend you use the following URL"
    echo $DAYTRADER_ROUTE/io.openliberty.sample.daytrader8/

}


deploy_debezium ()
{

    oc apply -k k8s/debezium/prod
    
    oc_wait_for pod daytrader-debezium-connect   strimzi.io/name


}

check_status ()
{
    export DAYTRADER_ROUTE="https://$(oc get route -n daytrader sampledaytrader8 -o jsonpath='{.spec.host}')"

    echo "KafkaConnect should return Ready as True"
    status=$(oc get KafkaConnect  -n daytrader daytrader-debezium -ojsonpath='{.status.conditions[?(@.type=="Ready")].status}')
 
    if [ "${status}" == "True" ] ; then
       echo "KafkaConnect is Ready" 
    else
       echo "got status ${status} for KafkaConnect"
       exit 1
    fi

    echo "Check the status of the mysql-daytrader-connector"
    status=$(oc get KafkaConnector -n daytrader mysql-daytrader-connector -ojsonpath='{.status.conditions[?(@.type=="Ready")].status}')

    if [ "${status}" == "True" ] ; then
       echo "KafkaConnect mysql-daytrader-connector is Ready" 
    else
       echo "got status ${status} for KafkaConnect mysql-daytrader-connector"
       exit 1
    fi


    echo ""
    echo "List Kafka Topics"

    ./scripts/kafka-list-topics.sh daytrader

    echo ""
    echo "You should now be able to access the application on"
    echo $DAYTRADER_ROUTE/io.openliberty.sample.daytrader8/
}




check_oc_login

case "$1" in
  deploy)
        deploy_database
        deploy_apps

        populate_db 

        deploy_kafka
        deploy_debezium
        ;;
  status)
        check_status
        ;;
  delete|cleanup|remove)
        remove_apps
        ;;
  *)
        echo "Usage: $N {setup|status|remove|cleanup}" >&2
        exit 1
        ;;
esac

