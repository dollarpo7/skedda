param webAppName string = 'mywebapp'
param sqlServerName string = 'mydatabase'
param sqlAdminLogin string = 'adminlogin'

@secure()
@minLength(7)
param sqlAdminPwd string
param rgLocation string
param WebAppKind string
@description('The Runtime stack of current web app')
param linuxFxVersion string

var url = environment().suffixes.sqlServerHostname

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: '${webAppName}-plan'
  location: rgLocation
  sku: {
    name: 'S2'
    tier: 'Standard'
  }
  kind: WebAppKind
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: rgLocation
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion:linuxFxVersion
      connectionStrings: [
        {
          name: 'DbConnectionString'
          connectionString: 'Server=tcp:${sqlServer.name}.${url},1433;Initial Catalog=${sqlDatabase.name};Persist Security Info=False;User ID=${sqlServer.properties.administratorLogin};Password=${sqlAdminPwd};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
          type: 'SQLAzure'
        }
      ]
      appSettings: [
        {
          name: 'DbConnectionString'
          value: 'Server=tcp:${sqlServer.name}.${url},1433;Initial Catalog=${sqlDatabase.name};Persist Security Info=False;User ID=${sqlServer.properties.administratorLogin};Password=${sqlAdminPwd};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
        }
      ]
    }
  }
}


resource sqlServer 'Microsoft.Sql/servers@2022-11-01-preview' = {
  name: sqlServerName
  location: rgLocation
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPwd
    version: '12.0'
    publicNetworkAccess: 'Enabled'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-11-01-preview' = {
  parent:sqlServer
  name: '${sqlServerName}-${webAppName}-db'
  location: rgLocation
  sku: {
    name: 'S0'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    
  }
}

