az group create --location westus3 --resource-group lazar

az deployment group what-if \
  --resource-group lazar \
  --template-file main.bicep \
  --parameters main.bicepparam

az deployment group create \
  --resource-group lazar \
  --template-file main.bicep \
  --parameters main.bicepparam 


#Delete all resources deployed in the Resource Group
az group delete --resource-group lazar --yes --no-wait