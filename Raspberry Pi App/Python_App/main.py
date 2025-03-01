import os
import time
import pyfiglet
import firebase_admin
from termcolor import colored
from eansearch import EANSearch
from product_info import ProductInfo
from firebase_admin import credentials, auth, firestore
from google.cloud.firestore_v1.base_query import FieldFilter

cred = credentials.Certificate('/home/hi-tech-pantry/Desktop/Project/hi-tech-pantry/Raspberry Pi App/Python_App/service_account.json')
app = firebase_admin.initialize_app(cred)

def get_uid_by_email(email):
    try:
        user = auth.get_user_by_email(email)
        return user.uid
    except firebase_admin.auth.UserNotFoundError:
        print(colored('Wrong QR Code scanned. Please try again', color = 'red'))
        with open('/home/hi-tech-pantry/Desktop/Project/hi-tech-pantry/Raspberry Pi App/Python_App/saved_account.txt', 'w') as file:
            file.write('')
        return ''

def on_snapshot(doc_snapshot, changes, read_time):
    global email, uid, mode
    for change in changes:
        if change.type.name == 'MODIFIED':
            if change.document.to_dict()['connectedToPantry'] == False:
                email = ''
                uid = ''
                print('\n')
                with open('/home/hi-tech-pantry/Desktop/Project/hi-tech-pantry/Raspberry Pi App/Python_App/saved_account.txt', 'w') as file:
                    file.write('')
                ascii_art = pyfiglet.figlet_format('DISCONNECTED FROM PANTRY')
                print(colored(ascii_art, color = 'red'))
                os.system('echo 0 | sudo tee /sys/class/leds/ACT/brightness > /dev/null') # Turn off green LED to mark disconnection
                os.system('echo timer | sudo tee /sys/class/leds/PWR/trigger > /dev/null') # Turn on blinking red LED

                time.sleep(2)
                os._exit(0) # Close program if user disconnected

def addProduct(eancode):
    global db, tokenAPI
    products_ref = db.collection('users').document(uid).collection('products')
    query = products_ref.where(filter = FieldFilter('eancode', '==', eancode)).stream()
    results = [doc for doc in query]
    if results: # Product already in the pantry, just increase its quantity
        doc_ref = results[0].reference
        doc_ref.update({ 'quantity': firestore.Increment(1) })
        print(colored('You have successfully deposited {}'.format(results[0]._data['name']), color = 'green'))
    else: # Product not in the pantry
        # Make a call to the EAN-Search API to get the product name
        name = lookup.barcodeLookup(eancode)
        if name is not None:
            db.collection('users').document(uid).collection('products').add(ProductInfo(eancode = eancode, name = name).toFirestore())
            print(colored(f'You have successfully deposited {name}', color = 'green'))
        else:
            db.collection('users').document(uid).collection('products').add(ProductInfo(eancode = eancode, name = '').toFirestore())
            print(colored('The product info has not been found using the API. The product has been added to the pantry as an Unknown Product. Please add a name to the product using the Mobile Application.', color = 'yellow'))

email = ''
uid = ''
mode = 'Deposit'
doc_watch = None
tokenAPI = ''
with open('/home/hi-tech-pantry/Desktop/Project/hi-tech-pantry/Raspberry Pi App/Python_App/token_api.txt', 'r') as file:
    tokenAPI = file.read()
lookup = EANSearch(tokenAPI)

ascii_art = pyfiglet.figlet_format('HI-TECH PANTRY')
print(colored(ascii_art, color = 'blue'))

os.system('echo none | sudo tee /sys/class/leds/PWR/trigger > /dev/null') # Turn off blinking red LED
os.system('echo timer | sudo tee /sys/class/leds/ACT/trigger > /dev/null') # Turn on blinking green LED to mark ready for connection

while True:
    if uid == '':
        if doc_watch:
            doc_watch.unsubscribe()
            doc_watch = None
        try:
            with open('/home/hi-tech-pantry/Desktop/Project/hi-tech-pantry/Raspberry Pi App/Python_App/saved_account.txt', 'r') as file:
                email = file.read()
        except FileNotFoundError:
            email = ''
        if email == '':
            email = input('Scan QR Code to connect to pantry: ')
            with open('/home/hi-tech-pantry/Desktop/Project/hi-tech-pantry/Raspberry Pi App/Python_App/saved_account.txt', 'w') as file:
                file.write(email)
        uid = get_uid_by_email(email)
        if uid != '':
            db = firestore.client()

            doc_ref = db.collection('users').document(uid)

            doc_ref.update({ 'connectedToPantry': True })

            ascii_art = pyfiglet.figlet_format('CONNECTED TO PANTRY')
            print(colored(ascii_art, color = 'green'))

            doc_watch = doc_ref.on_snapshot(on_snapshot)

            os.system('echo none | sudo tee /sys/class/leds/ACT/trigger > /dev/null')
            os.system('echo 1 | sudo tee /sys/class/leds/ACT/brightness > /dev/null') # Let the green LED on to mark Hi-Tech Pantry Application connected successfully

            while True and uid != '':
                ascii_art = pyfiglet.figlet_format(mode.upper())
                print(colored(ascii_art, color = 'blue'))
                eancode = input('Scan product barcode: ')
                if eancode.isdigit():
                    os.system('echo heartbeat | sudo tee /sys/class/leds/ACT/trigger > /dev/null') # Turn on blinking green LED in heartbeat mode to mark processing the barcode
                    addProduct(eancode) # Add the scanned product to the pantry
                    os.system('echo none | sudo tee /sys/class/leds/ACT/trigger > /dev/null')
                    os.system('echo 1 | sudo tee /sys/class/leds/ACT/brightness > /dev/null') # Let the green LED on to mark processing finished
                else:
                    print(colored('Please scan a valid barcode', color = 'red'))