param solutionName string
param solutionLocation string
param managedIdentityObjectId string
@description('The name of the SQL logical server.')
param serverName string = '${ solutionName }.postgres.database.azure.com'

param administratorLogin string = 'admintest'
@secure()
param administratorLoginPassword string = 'Initial_0524'
param serverEdition string = 'Burstable'
param skuSizeGB int = 32
param dbInstanceType string = 'Standard_B1ms'
// param haMode string = 'ZoneRedundant'
param availabilityZone string = '1'
@description('PostgreSQL version')
@allowed([
  '11'
  '12'
  '13'
  '14'
  '15'
  '16'
])
param version string = '16'

var firewallrules = [
  {
    Name: 'rule1'
    StartIpAddress: '0.0.0.0'
    EndIpAddress: '255.255.255.255'
  }
]
resource serverName_resource 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: serverName
  location: solutionLocation
  sku: {
    name: dbInstanceType
    tier: serverEdition
  }
  properties: {
    version: version
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword

    highAvailability: {
      mode: 'Disabled'
    }
    storage: {
      storageSizeGB: skuSizeGB
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    availabilityZone: availabilityZone

  }
}

resource serverName_firewallrules 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2021-06-01' = [for rule in firewallrules: {
  parent: serverName_resource
  name: rule.Name
  properties: {
    startIpAddress: rule.StartIpAddress
    endIpAddress: rule.EndIpAddress
  }
}]


resource configurations 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2023-03-01-preview' = {
  name: 'azure.extensions'
  parent: serverName_resource
  properties: {
    value: 'vector'
    source: 'user-override'
  }
  dependsOn: [
    serverName_firewallrules
  ]
}


output postgreSQLDbOutput object = {
  postgreSQLServerName: serverName_resource.name
  postgreSQLDatabaseName: 'postgres'
  postgreSQLDbUser: administratorLogin
  postgreSQLDbPwd: administratorLoginPassword
  sslMode: 'Require'
}
