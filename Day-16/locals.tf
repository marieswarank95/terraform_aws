locals {
    users = csvdecode(file("users.csv"))  #It returns list of map data type values.
}