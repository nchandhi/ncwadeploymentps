// ========== main.bicep ========== //
targetScope = 'resourceGroup'

@minLength(3)
@maxLength(6)
@description('Prefix Name')
param solutionPrefix string

@description('CosmosDB Location')
param cosmosLocation string

var resourceGroupLocation = resourceGroup().location
var resourceGroupName = resourceGroup().name

var solutionLocation = resourceGroupLocation
// var baseUrl = 'https://raw.githubusercontent.com/microsoft/Build-your-own-copilot-Solution-Accelerator/main/ClientAdvisor/'
var baseUrl = 'https://raw.githubusercontent.com/nchandhi/ncwadeploymentps/main/ClientAdvisor/'

// ========== Managed Identity ========== //
module managedIdentityModule 'deploy_managed_identity.bicep' = {
  name: 'deploy_managed_identity'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
  }
  scope: resourceGroup(resourceGroup().name)
}

// module cosmosDBModule 'deploy_cosmos_db.bicep' = {
//   name: 'deploy_cosmos_db'
//   params: {
//     solutionName: solutionPrefix
//     solutionLocation: cosmosLocation
//     identity:managedIdentityModule.outputs.managedIdentityOutput.objectId
//   }
//   scope: resourceGroup(resourceGroup().name)
// }


// ========== Storage Account Module ========== //
module storageAccountModule 'deploy_storage_account.bicep' = {
  name: 'deploy_storage_account'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
    managedIdentityObjectId:managedIdentityModule.outputs.managedIdentityOutput.objectId
  }
  scope: resourceGroup(resourceGroup().name)
}

// //========== SQL DB Module ========== //
// module sqlDBModule 'deploy_sql_db.bicep' = {
//   name: 'deploy_sql_db'
//   params: {
//     solutionName: solutionPrefix
//     solutionLocation: solutionLocation
//     managedIdentityObjectId:managedIdentityModule.outputs.managedIdentityOutput.objectId
//   }
//   scope: resourceGroup(resourceGroup().name)
// }

//========== SQL DB Module ========== //
module PostgreSQLDBModule 'deploy_postgres_sql.bicep' = {
  name: 'deploy_postgres_sql'
  params: {
    solutionName: solutionPrefix
    solutionLocation: cosmosLocation
    managedIdentityObjectId:managedIdentityModule.outputs.managedIdentityOutput.objectId
  }
  scope: resourceGroup(resourceGroup().name)
}

// ========== Azure AI services multi-service account ========== //
module azAIMultiServiceAccount 'deploy_azure_ai_service.bicep' = {
  name: 'deploy_azure_ai_service'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
  }
} 

// // ========== Search service ========== //
// module azSearchService 'deploy_ai_search_service.bicep' = {
//   name: 'deploy_ai_search_service'
//   params: {
//     solutionName: solutionPrefix
//     solutionLocation: solutionLocation
//   }
// } 

// ========== Azure OpenAI ========== //
module azOpenAI 'deploy_azure_open_ai.bicep' = {
  name: 'deploy_azure_open_ai'
  params: {
    solutionName: solutionPrefix
    solutionLocation: cosmosLocation
  }
}

module uploadFiles 'deploy_upload_files_script.bicep' = {
  name : 'deploy_upload_files_script'
  params:{
    storageAccountName:storageAccountModule.outputs.storageAccountOutput.name
    solutionLocation: solutionLocation
    containerName:storageAccountModule.outputs.storageAccountOutput.dataContainer
    identity:managedIdentityModule.outputs.managedIdentityOutput.id
    storageAccountKey:storageAccountModule.outputs.storageAccountOutput.key
    baseUrl:baseUrl
  }
  dependsOn:[storageAccountModule]
}

module azureFunctions 'deploy_azure_function_script.bicep' = {
  name : 'deploy_azure_function_script'
  params:{
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
    resourceGroupName:resourceGroupName
    azureOpenAIApiKey:azOpenAI.outputs.openAIOutput.openAPIKey
    azureOpenAIApiVersion:'2024-02-15-preview'
    azureOpenAIEndpoint:azOpenAI.outputs.openAIOutput.openAPIEndpoint
    // azureSearchAdminKey:azSearchService.outputs.searchServiceOutput.searchServiceAdminKey
    // azureSearchServiceEndpoint:azSearchService.outputs.searchServiceOutput.searchServiceEndpoint
    // azureSearchIndex:'transcripts_index'
    // sqlServerName:sqlDBModule.outputs.sqlDbOutput.sqlServerName
    // sqlDbName:sqlDBModule.outputs.sqlDbOutput.sqlDbName
    // sqlDbUser:sqlDBModule.outputs.sqlDbOutput.sqlDbUser
    // sqlDbPwd:sqlDBModule.outputs.sqlDbOutput.sqlDbPwd
    postgresqlServerName:PostgreSQLDBModule.outputs.postgreSQLDbOutput.postgresqlServerName
    postgresqlDbName:PostgreSQLDBModule.outputs.postgreSQLDbOutput.postgreSQLDatabaseName
    postgresqlDbUser:PostgreSQLDBModule.outputs.postgreSQLDbOutput.postgresqlDbUser
    postgresqlDbPwd:PostgreSQLDBModule.outputs.postgreSQLDbOutput.postgresqlDbPwd
    sslMode:'Require'
    identity:managedIdentityModule.outputs.managedIdentityOutput.id
    baseUrl:baseUrl
  }
  dependsOn:[storageAccountModule]
}

module azureFunctionURL 'deploy_azure_function_script_url.bicep' = {
  name : 'deploy_azure_function_script_url'
  params:{
    solutionName: solutionPrefix
    identity:managedIdentityModule.outputs.managedIdentityOutput.id
  }
  dependsOn:[azureFunctions]
}


// ========== Key Vault ========== //

module keyvaultModule 'deploy_keyvault.bicep' = {
  name: 'deploy_keyvault'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
    objectId: managedIdentityModule.outputs.managedIdentityOutput.objectId
    tenantId: subscription().tenantId
    managedIdentityObjectId:managedIdentityModule.outputs.managedIdentityOutput.objectId
    adlsAccountName:storageAccountModule.outputs.storageAccountOutput.storageAccountName
    adlsAccountKey:storageAccountModule.outputs.storageAccountOutput.key
    azureOpenAIApiKey:azOpenAI.outputs.openAIOutput.openAPIKey
    azureOpenAIApiVersion:'2024-02-15-preview'
    azureOpenAIEndpoint:azOpenAI.outputs.openAIOutput.openAPIEndpoint
    // azureSearchAdminKey:azSearchService.outputs.searchServiceOutput.searchServiceAdminKey
    // azureSearchServiceEndpoint:azSearchService.outputs.searchServiceOutput.searchServiceEndpoint
    // azureSearchServiceName:azSearchService.outputs.searchServiceOutput.searchServiceName
    // azureSearchIndex:'transcripts_index'
    cogServiceEndpoint:azAIMultiServiceAccount.outputs.cogSearchOutput.cogServiceEndpoint
    cogServiceName:azAIMultiServiceAccount.outputs.cogSearchOutput.cogServiceName
    cogServiceKey:azAIMultiServiceAccount.outputs.cogSearchOutput.cogServiceKey
    // sqlServerName:sqlDBModule.outputs.sqlDbOutput.sqlServerName
    // sqlDbName:sqlDBModule.outputs.sqlDbOutput.sqlDbName
    // sqlDbUser:sqlDBModule.outputs.sqlDbOutput.sqlDbUser
    // sqlDbPwd:sqlDBModule.outputs.sqlDbOutput.sqlDbPwd
    postgresqlServerName:PostgreSQLDBModule.outputs.postgreSQLDbOutput.postgresqlServerName
    postgresqlDbName:PostgreSQLDBModule.outputs.postgreSQLDbOutput.postgreSQLDatabaseName
    postgresqlDbUser:PostgreSQLDBModule.outputs.postgreSQLDbOutput.postgresqlDbUser
    postgresqlDbPwd:PostgreSQLDBModule.outputs.postgreSQLDbOutput.postgresqlDbPwd
    sslMode:'Require'
    enableSoftDelete:false
  }
  scope: resourceGroup(resourceGroup().name)
  dependsOn:[storageAccountModule,azOpenAI,PostgreSQLDBModule]
  // dependsOn:[storageAccountModule,azOpenAI,azSearchService,PostgreSQLDBModule]
}

module createData 'deploy_data_scripts.bicep' = {
  name : 'deploy_data_scripts'
  params:{
    solutionLocation: solutionLocation
    identity:managedIdentityModule.outputs.managedIdentityOutput.id
    baseUrl:baseUrl
    keyVaultName:keyvaultModule.outputs.keyvaultOutput.name
  }
  dependsOn:[keyvaultModule]
}

// ========== Deploy App Service ========== //
module appserviceModule 'deploy_app_service.bicep' = {
  name: 'deploy_app_service'
  params: {
    identity:managedIdentityModule.outputs.managedIdentityOutput.id
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
    // AzureSearchService:azSearchService.outputs.searchServiceOutput.searchServiceName
    // AzureSearchIndex:'transcripts_index'
    // AzureSearchKey:azSearchService.outputs.searchServiceOutput.searchServiceAdminKey
    // AzureSearchUseSemanticSearch:'True'
    // AzureSearchSemanticSearchConfig:'my-semantic-config'
    // AzureSearchIndexIsPrechunked:'False'
    // AzureSearchTopK:'5'
    // AzureSearchContentColumns:'content'
    // AzureSearchFilenameColumn:'chunk_id'
    // AzureSearchTitleColumn:'client_id'
    // AzureSearchUrlColumn:'sourceurl'
    AzureOpenAIResource:azOpenAI.outputs.openAIOutput.openAPIEndpoint
    AzureOpenAIEndpoint:azOpenAI.outputs.openAIOutput.openAPIEndpoint
    AzureOpenAIModel:'gpt-4o'
    AzureOpenAIKey:azOpenAI.outputs.openAIOutput.openAPIKey
    AzureOpenAIModelName:'gpt-4o'
    AzureOpenAITemperature:'0'
    AzureOpenAITopP:'1'
    AzureOpenAIMaxTokens:'1000'
    AzureOpenAIStopSequence:''
    AzureOpenAISystemMessage:'''You are a helpful Wealth Advisor assistant''' 
    AzureOpenAIApiVersion:'2024-02-15-preview'
    AzureOpenAIStream:'True'
    // AzureSearchQueryType:'simple'
    // AzureSearchVectorFields:'contentVector'
    // AzureSearchPermittedGroupsField:''
    // AzureSearchStrictness:'3'
    AzureOpenAIEmbeddingName:'text-embedding-ada-002'
    AzureOpenAIEmbeddingkey:azOpenAI.outputs.openAIOutput.openAPIKey
    AzureOpenAIEmbeddingEndpoint:azOpenAI.outputs.openAIOutput.openAPIEndpoint
    USE_AZUREFUNCTION:'True'
    STREAMING_AZUREFUNCTION_ENDPOINT: azureFunctionURL.outputs.functionAppUrl
    // SQLDB_SERVER:sqlDBModule.outputs.sqlDbOutput.sqlServerName
    // SQLDB_DATABASE:sqlDBModule.outputs.sqlDbOutput.sqlDbName
    // SQLDB_USERNAME:sqlDBModule.outputs.sqlDbOutput.sqlDbUser
    // SQLDB_PASSWORD:sqlDBModule.outputs.sqlDbOutput.sqlDbPwd
    POSTGRESQL_SERVER:PostgreSQLDBModule.outputs.postgreSQLDbOutput.postgresqlServerName
    POSTGRESQL_DATABASE:PostgreSQLDBModule.outputs.postgreSQLDbOutput.postgreSQLDatabaseName
    POSTGRESQL_USERNAME:PostgreSQLDBModule.outputs.postgreSQLDbOutput.postgresqlDbUser
    POSTGRESQL_PASSWORD:PostgreSQLDBModule.outputs.postgreSQLDbOutput.postgresqlDbPwd
    // AZURE_COSMOSDB_ACCOUNT: cosmosDBModule.outputs.cosmosOutput.cosmosAccountName
    // AZURE_COSMOSDB_ACCOUNT_KEY: cosmosDBModule.outputs.cosmosOutput.cosmosAccountKey
    // AZURE_COSMOSDB_CONVERSATIONS_CONTAINER: cosmosDBModule.outputs.cosmosOutput.cosmosContainerName
    // AZURE_COSMOSDB_DATABASE: cosmosDBModule.outputs.cosmosOutput.cosmosDatabaseName
    // AZURE_COSMOSDB_ENABLE_FEEDBACK: 'True'
    VITE_POWERBI_EMBED_URL: 'TBD'
  }
  scope: resourceGroup(resourceGroup().name)
  dependsOn:[azOpenAI,azAIMultiServiceAccount,PostgreSQLDBModule,azureFunctionURL]
  // dependsOn:[azOpenAI,azAIMultiServiceAccount,azSearchService,PostgreSQLDBModule,azureFunctionURL,cosmosDBModule]
}
