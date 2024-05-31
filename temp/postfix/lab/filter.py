# Author: Miroslav Houdek <miroslav.houdek@gmail.com>
# License is, do whatever you wanna do with it (at least I think that that is what LGPL v3 says)

import os
import smtpd
import hashlib
import asyncore
import smtplib
import traceback
from email.parser import Parser
from mailmsg import MailMessage
from dotenv import load_dotenv


class CustomSMTPServer(smtpd.SMTPServer):

    def process_message(self, peer, mailfrom, rcpttos, data, **kwargs):
        mailfrom.replace("'", "")
        mailfrom.replace('"', "")

        for recipient in rcpttos:
            recipient.replace("'", "")
            recipient.replace('"', "")

        try:
            message = MailMessage(data)
            spam = message.checkSpam()
            virus = message.checkVirus()
            print(spam, virus)

            status = self.parseSpamStatus(spam["prob"])
            raw = f"{status}{spam['reason']}{spam['descr']}{virus['status']}{virus['descr']}"

            data_string = Parser().parsestr(data.decode("utf-8"))
            data_string.add_header("X-RCP-Spam-Status", status)
            data_string.add_header("X-RCP-Spam-Reason", spam["reason"])
            data_string.add_header("X-RCP-Spam-Description", spam["descr"])
            data_string.add_header("X-RCP-Virus-Status", virus["status"])
            data_string.add_header("X-RCP-Virus-Description", virus["descr"])
            data_string.add_header("X-RCP-Hash", self.hash(raw))
            data = data_string.as_string().encode("utf-8")

            server = smtplib.SMTP("127.0.0.1", 10026)
            server.sendmail(mailfrom, rcpttos, data)
            server.quit()
            print("Sent Successfully")
        except smtplib.SMTPException:
            print("Exception SMTPException")
            pass
        except smtplib.SMTPServerDisconnected:
            print("Exception SMTPServerDisconnected")
            pass
        except smtplib.SMTPResponseException:
            print("Exception SMTPResponseException")
            pass
        except smtplib.SMTPSenderRefused:
            print("Exception SMTPSenderRefused")
            pass
        except smtplib.SMTPRecipientsRefused:
            print("Exception SMTPRecipientsRefused")
            pass
        except smtplib.SMTPDataError:
            print("Exception SMTPDataError")
            pass
        except smtplib.SMTPConnectError:
            print("Exception SMTPConnectError")
            pass
        except smtplib.SMTPHeloError:
            print("Exception SMTPHeloError")
            pass
        except smtplib.SMTPAuthenticationError:
            print("Exception SMTPAuthenticationError")
            pass
        except:
            print("Undefined exception")
            print(traceback.format_exc())
        return

    def parseSpamStatus(self, p):
        if p >= 0.9:
            return "Certain"
        if p >= 0.8:
            return "Probable"
        elif p >= 0.6:
            return "Potential"
        elif p >= 0:
            return "Unlikely"
        else:
            return "Error"

    def hash(self, data):
        salt = os.environ.get("HASH_SALT")
        return hashlib.sha256((data + salt).encode("utf-8")).hexdigest()


server = CustomSMTPServer(("127.0.0.1", 10025), None)

asyncore.loop()
