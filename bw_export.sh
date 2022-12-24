#!/bin/bash

echo "Starting export script..."
bw login --quit --apikey $BW_EMAIL

if [[ $(bw status | jq -r .status) == "unauthenticated" ]]
then 
    echo "ERROR: Failed to authenticate."
    echo
    exit 1
fi

#Unlock the vault
session_key=$(bw unlock --raw --passwordenv BW_MASTER_PASSWORD)

#Verify that unlock succeeded
if [[ $session_key == "" ]]
then 
    echo "ERROR: Failed to authenticate."
    echo
    exit 1
else
    echo "Login successful."
    echo
fi

#Export the session key as an env variable (needed by BW CLI)
export BW_SESSION="$session_key" 

echo "Performing vault exports..."
echo
echo "Exporting personal vault to an unencrypted file..."
bw export --format json --output $SAVE_FOLDER


# 3. Download all attachments (file backup)
#First download attachments in vault
if [[ $(bw list items | jq -r '.[] | select(.attachments != null)') != "" ]]
then
    echo
    echo "Saving attachments..."
    bash <(bw list items | jq -r '.[] 
    | select(.attachments != null) 
    | "bw get attachment \"\(.attachments[].fileName)\" --itemid \(.id) --output \"'$SAVE_FOLDER_ATTACHMENTS'\(.name)/\""' )
else
    echo
    echo "No attachments exist, so nothing to export."
fi 

echo
echo "Vault export complete."

echo
bw lock 
echo
