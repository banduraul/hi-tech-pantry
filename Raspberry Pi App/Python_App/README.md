# Hi-Tech Pantry (Python)

## Description

A command line based Python application that makes use of the [EAN-Search API](https://www.ean-search.org/) to add products in a user's inventory for tracking through the mobile app.

## Functionality

The first time the application runs the user needs to scan the **QR Code** from the **Profile** page of the **Mobile** application in order to connect to their pantry. After this, the credentials are saved in a file for easier connection if the application is reopened.

After the users have connected successfully, they can deposit items in their pantry by scanning the product barcodes by using the **USB Barcode Scanner** connected to the Raspberry Pi.