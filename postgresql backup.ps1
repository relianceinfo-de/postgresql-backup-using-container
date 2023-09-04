# Create resource group
az group create `
  --name storage-resource-group `
  --location eastus;

# create a standard general-purpose v2 storage account with read-access geo-redundant storage
az storage account create `
  --name storeacc94 `
  --resource-group storage-resource-group `
  --location eastus `
  --sku Standard_RAGRS `
  --kind StorageV2;

az extension add --name storage-preview

#  create the account, specifying AzureDnsZone for the --dns-endpoint-type parameter.
az storage account create `
    --name storeacc94 `
    --resource-group storage-resource-group `
    --location eastus `
    --dns-endpoint-type Standard;

# After the account is created, you can return the service endpoints by getting the primaryEndpoints and secondaryEndpoints properties for the storage account
az storage account show `
    --resource-group storage-resource-group `
    --name storeacc94 `
    --query '[primaryEndpoints, secondaryEndpoints]';

# assigns the Storage Blob Data Contributor role, which includes the Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey action
# The role is scoped at the level of the storage account
az role assignment create `
    --role "Storage Blob Data Contributor" `
    --assignee promise@relianceinfosystems.com `
    --scope "/subscriptions/ca0aa86a-bcd6-4bef-b72c-45302a5515f6/resourceGroups/storage-resource-group/providers/Microsoft.Storage/storageAccounts/storeacc94";

# returns a user delegation SAS token for a container.
az storage container generate-sas `
    --account-name storeacc94 `
    --name storecont `
    --permissions acdlrw `
    --expiry 2023-08-27T00:00:00Z `
    --auth-mode login `
    --as-user;

# The user delegation SAS token returned
"se=2023-08-27T00%3A00%3A00Z&sp=racwdl&sv=2021-06-08&sr=c&skoid=6b0d6ab9-ac5e-4bc9-8e4d-f5e4000b7dcd&sktid=0b60fed4-5fc9-409d-95f2-271114f4c86f&skt=2023-08-23T19%3A55%3A17Z&ske=2023-08-27T00%3A00%3A00Z&sks=b&skv=2021-06-08&sig=too4d22gp2SeW6nWBorZGsyOye1IVZ9vRoY0JmaUyfQ%3D"

#  returns the blob URI with the SAS token appended
az storage blob generate-sas `
    --account-name storeacc94 `
    --container-name storecont `
    --name storeblob `
    --permissions acdrw `
    --expiry 2023-08-27T00:00:00Z `
    --auth-mode login `
    --as-user `
    --full-uri;

# The user delegation SAS URI returned
"https://storeacc94.blob.core.windows.net/storecont/storeblob?se=2023-08-27T00%3A00%3A00Z&sp=racwd&sv=2021-06-08&sr=b&skoid=6b0d6ab9-ac5e-4bc9-8e4d-f5e4000b7dcd&sktid=0b60fed4-5fc9-409d-95f2-271114f4c86f&skt=2023-08-23T19%3A57%3A49Z&ske=2023-08-27T00%3A00%3A00Z&sks=b&skv=2021-06-08&sig=2vdERyTfuZaWofFKIXxAD%2ByJWhi2n2KgzxViEpb6sJs%3D"

#clone the project
https://github.com/Laverlin/pg-az-backup.git
pg-az-backup

docker pull postgres
docker run --name my-postgres -e POSTGRES_PASSWORD=mysecretpassword -p 5432:5432 -d postgres

# Backup database
docker run `
    -e POSTGRES_HOST=pgautobckupserver.postgres.database.azure.com `
    -e POSTGRES_USER=adminuser `
    -e POSTGRES_PASSWORD=password@123 `
    -e POSTGRES_DATABASE=dvdrental `
    -e AZURE_STORAGE_ACCOUNT=straccdatastage `
    -e AZURE_SAS="si=bckaccess&spr=https&sv=2022-11-02&sr=c&sig=zauQFYHzZmWU18EqPPJXHMDZB9PtE3jy77WFWLj5z%2Bg%3D" `
    -e AZURE_CONTAINER_NAME=backup `
    --rm `
    ilaverlin/pg-az-backup;

# you may pass additional backup parameters by setting an environment variable
POSTGRES_EXTRA_OPTS

# Automatic periodic backup
#you'll need to pass SCHEDULE environment variable that should contain cron job schedule syntax, e. g. -e SCHEDULE="@daily" or -e SCHEDULE = "0 0 * * 0" (weekly).
docker run `
    -e POSTGRES_HOST=pgautobckupserver.postgres.database.azure.com `
    -e POSTGRES_USER=adminuser `
    -e POSTGRES_PASSWORD=password@123 `
    -e POSTGRES_DATABASE=dvdrental `
    -e AZURE_STORAGE_ACCOUNT=straccdatastage `
    -e AZURE_SAS="si=bckaccess&spr=https&sv=2022-11-02&sr=c&sig=zauQFYHzZmWU18EqPPJXHMDZB9PtE3jy77WFWLj5z%2Bg%3D" `
    -e AZURE_CONTAINER_NAME=backup `
    -e SCHEDULE="0 0 * * 0" `
    -d --name pg-scheduled-backup `
    ilaverlin/pg-az-backup;

# Restore database on the container
# By default the last backup will be restored
#  to restore specified backup you can set AZURE_BLOB_NAME environment variable with backp file name e.g. -e AZURE_BLOB_NAME="<database name>_2020-03-11T14:08:28Z.sql.gz"
docker run `
    -e POSTGRES_HOST=pgautobckupserver.postgres.database.azure.com `
    -e POSTGRES_USER=adminuser `
    -e POSTGRES_PASSWORD=password@123 `
    -e POSTGRES_DATABASE=dvdrental `
    -e AZURE_STORAGE_ACCOUNT=straccdatastage `
    -e AZURE_SAS="si=bckaccess&spr=https&sv=2022-11-02&sr=c&sig=zauQFYHzZmWU18EqPPJXHMDZB9PtE3jy77WFWLj5z%2Bg%3D" `
    -e AZURE_CONTAINER_NAME=backup `
    -e AZURE_BLOB_NAME=dvdrental `
    -e RESTORE=yes `
    -e DROP_PUBLIC=yes `
    --rm `
    ilaverlin/pg-az-backup;

##Since my db is backed up on docker container, i will copy to localhost 
docker cp <container_name>:<path_to_backup_file_inside_container> /path/on/your/host
#eg
docker cp my-postgres-container:/backup.sql /path/on/your/host
## Restore on your host machine
psql -h localhost -U postgres -d <database_name> -f <path_to_backup_file_on_host>
#eg
psql -h localhost -U postgres -d mydb -f /path/on/your/host/backup.sql


# OR
docker ps
#navigate to the directory where you want to save the database dump
cd /path/to/dump/directory
# to create the database dump.
docker exec -t your-db-container pg_dumpall -c -U postgres > dump_$(date +%d-%m-%Y"_"%H_%M_%S).sql
# Restore your databases
cat your_dump.sql | docker exec -i <your-db-container> psql -U postgres
#or
cat your_dump.sql | docker exec -i <my-postgres-container> psql -U postgres -d postgres

