#!/usr/bin/python
# Recommended to use a dummy mail account that redirects the Email because the password must be given in plain-text.

import os, smtplib, getpass, sys, fileinput

if (len(sys.argv) < 4):
    print "\nUsage: python newaccountmail.py <new_user> <new_password> <to_email>"
    sys.exit()

new_usr = sys.argv[1]
new_passwd = sys.argv[2]
to = sys.argv[3]

user = 'mail@example.nl'
passwd = getpass.getpass('Password: ')
#passwd = '<YOUR PASSWORD>'

body = '''
Dear %s,

Your account was created.
You'll find your user credentials below.

Username: %s
Password: %s

Do not share these details with anyone else.
We recommand you to change your password the first time you login.

If you have any questions, please send them to mail@example.com.

Kind regards,

Administrator
Leon V.

--------------------------------------------------------------------

Please note:
This message was send with a beta python script.
If you received invalid information, please contact us so we send you the correct details manually.
''' % (new_usr, new_usr, new_passwd)

# REMOVE "<>" AND INSERT SMTP DETAILS
try:
    server = smtplib.SMTP('<SMTP_SERVER>','<SMTP_PORT>')
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
