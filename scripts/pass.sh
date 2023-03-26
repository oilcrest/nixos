# read password twice
read -s -p "Enter New User Password: " p1
echo 
read -s -p "Password (again): " p2

if  [[ "$p1" != "$p2" ]]; then
    echo "Passwords do not match! Exiting ..."
    exit
fi

mkpasswd -m sha-512 "$p1" > /persist/passwords/user
echo "New password written to /mnt/persist/passwords/user"



