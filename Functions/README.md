# Hi-Tech Pantry (Google Cloud Functions)

## Description

Cloud functions used by the project to send push notifications to the users.

## Functionality

`newProductNotification` - sends a notification to the user whenever a new product has been added to the inventory

`expiredProductsNotification` (runs once a day) - sends a notification to the user with all the expired products that are currently in the pantry

`productsExpiringSoonNotification` (runs once a day) - sends a notification to the user with all the products that are to expire in the next 3 days

`productsRunningLowNotification` (runs once a day) - sends a notification to the user with all the products that have `quantity <= 3`

`checkExpiredProducts` (runs once a day) - checks whether products have expired or not and updates the `isExpired` field accordingly

`productQuantityUpdatedNotification` - sends notifications to users whenever they deposit or withdraw products