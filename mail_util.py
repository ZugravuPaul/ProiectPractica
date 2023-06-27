import smtplib
import sys
from email.mime.text import MIMEText
from dotenv import dotenv_values
from datetime import date

config = dotenv_values(".env")

def send_email(sender_email, recipient_email, subject, message, sender_password):
    try:
        #MIMEText object 
        msg = MIMEText(message)
        msg["Subject"] = subject
        msg["From"] = sender_email
        msg["To"] = recipient_email

        # SMTP server
        with smtplib.SMTP("smtp.gmail.com", 587) as server:
            server.starttls()

            server.login(sender_email, sender_password)

            server.send_message(msg)


    except Exception as e:
        print("Error sending email:", str(e))

# email details
sender_email = "zugravupaul14@gmail.com"
sender_password = config["pass"]
recipient_email = sys.argv[3]
subject = sys.argv[1] 
message = sys.argv[2]

send_email(sender_email, recipient_email, subject, message, sender_password)

