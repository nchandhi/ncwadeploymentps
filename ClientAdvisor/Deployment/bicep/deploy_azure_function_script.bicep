@description('Specifies the location for resources.')
param solutionName string 
param solutionLocation string
param resourceGroupName string
param identity string
param baseUrl string
@secure()
param azureOpenAIApiKey string
param azureOpenAIApiVersion string
param azureOpenAIEndpoint string
@secure()
param azureSearchAdminKey string
param azureSearchServiceEndpoint string
param azureSearchIndex string
param postgresqlServerName string
param postgresqlDbName string
param postgresqlDbUser string
@secure()
param postgresqlDbPwd string
param sslMode string = 'require'
resource deploy_azure_function 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind:'AzureCLI'
  name: 'deploy_azure_function'
  location: solutionLocation // Replace with your desired location
  identity:{
    type:'UserAssigned'
    userAssignedIdentities: {
      '${identity}' : {}
    }
  }
  properties: {
    azCliVersion: '2.50.0'
    primaryScriptUri: '${baseUrl}Deployment/scripts/create_azure_functions.sh' // deploy-azure-synapse-pipelines.sh
    arguments: '${solutionName} ${solutionLocation} ${resourceGroupName} ${baseUrl} ${azureOpenAIApiKey} ${azureOpenAIApiVersion} ${azureOpenAIEndpoint} ${azureSearchAdminKey} ${azureSearchServiceEndpoint} ${azureSearchIndex} ${postgresqlServerName} ${postgresqlDbName} ${postgresqlDbUser} ${postgresqlDbPwd} ${sslMode}' // Specify any arguments for the script
    timeout: 'PT1H' // Specify the desired timeout duration
    retentionInterval: 'PT1H' // Specify the desired retention interval
    cleanupPreference:'OnSuccess'
  }
}


