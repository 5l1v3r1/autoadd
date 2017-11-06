#!/usr/bin/python

import os, smtplib, getpass, sys, fileinput

if (len(sys.argv) < 4):
    print "\nUsage: python newaccountmail.py <new_user> <new_password> <to_email>"
    sys.exit()

new_usr = sys.argv[1]
new_passwd = sys.argv[2]
to = sys.argv[3]

user = 'mail@example.nl'
passwd = getpass.getpass('Password: ')
#passwd = '<Your_Password>'

body = '''
Dear %s,

Your account was created.
You'll find your user credentials below.

Username: %s
Password: %s

Do not share these details with anyone else.
We recommand you to change your password the first time you login.

If you have any questions, please send them to mail@leonvoerman.nl.

Kind regards,

Administrator
Leon V.

--------------------------------------------------------------------

Please note:
This message was send with a beta python script.
If you received invalid information, please contact us so we send you the correct details manually.
''' % (new_usr, new_usr, new_passwd)

try:
    server = smtplib.SMTP('smtp02.hostnet.nl','587')
    server.ehlo()
    server.starttls()
    server.login(user,passwd)

    subject = 'Welcome: your account details'
    msg = 'From: ' + user + '\nSubject: ' + subject + '\n' + body
    server.sendmail(user,to,msg) # Send message
    server.quit()
except KeyboardInterrupt:
   print '[ - ] Canceled'
   sys.exit()

except smtplib.SMTPAuthenticationError:
   print '[ ! ] Failed to login: The username or password you entered is incorrect.'
   sys.exit()
