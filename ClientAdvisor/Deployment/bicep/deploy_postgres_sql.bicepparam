using './deploy_postgres_sql.bicep'

param solutionName = 'ncbyc12'
param solutionLocation = 'eastus2'
param managedIdentityObjectId = ''
param serverName = '${solutionName}-postgres'
param administratorLogin = 'admintest'
param administratorLoginPassword = 'Initial_0524'
param serverEdition = 'Burstable'
param skuSizeGB = 32
param dbInstanceType = 'Standard_B1ms'
param availabilityZone = '1'
param allowAllIPsFirewall = true
param version = '16'

