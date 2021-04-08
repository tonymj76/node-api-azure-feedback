param location string
param name_prefix string
param postgres_adminPassword string {
  secure: true
}
param webapi_node_env string

var unique_name_prefix = concat(name_prefix, uniqueString(resourceGroup().id))

module monitoring './monitoring.bicep' = {
  name: 'monitoring_deploy'
  params:{
    location: location
    name_prefix: unique_name_prefix
  }
}

module postgres './postgres.bicep' = {
  name: 'postgres_deploy'
  params:{
    location: location
    name_prefix: unique_name_prefix
    workspace_id: monitoring.outputs.workspace_id
    administratorLoginPassword: postgres_adminPassword
  }
}

module webapi './webapp.bicep' = {
  name: 'webapp_deploy'
  params:{
    location: location
    name_prefix: unique_name_prefix
    workspace_id: monitoring.outputs.workspace_id
    appSettings_pghost: postgres.outputs.pg_host
    appSettings_pguser: postgres.outputs.pg_user
    appSettings_pgdb: postgres.outputs.pg_db
    appSettings_node_env: webapi_node_env
    appSettings_pgpassword: postgres_adminPassword
    appSettings_insights_key: monitoring.outputs.instrumentation_key
  }
}

output webapi_id string = webapi.outputs.webapi_id
output webapi_hostname string = webapi.outputs.webapi_hostname
output postgres_host string = postgres.outputs.pg_host
output postgres_user string = postgres.outputs.pg_user
output postgres_db string = postgres.outputs.pg_db