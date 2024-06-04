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
            dkim = message.checkDkim()
            print(spam, virus, dkim)

            status, backup = self.parseSpamStatus(spam["prob"])
            raw = f"{status}{spam['reason']}{spam['descr']}{virus['status']}{virus['descr']}{dkim}"

            if backup or virus["status"] == "Failed":
                message.backup(rcpttos, status, virus["status"])

            data_string = Parser().parsestr(data.decode("utf-8"))
            data_string.add_header("X-RCP-Spam-Status", status)
            data_string.add_header("X-RCP-Spam-Reason", spam["reason"])
            data_string.add_header("X-RCP-Spam-Description", spam["descr"])
            data_string.add_header("X-RCP-Virus-Status", virus["status"])
            data_string.add_header("X-RCP-Virus-Description", virus["descr"])
            data_string.add_header("X-RCP-DKIM-Status", dkim)
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
            return "Certain", False
        if p >= 0.8:
            return "Probable", True
        elif p >= 0.6:
            return "Potential", True
        elif p >= 0:
            return "Unlikely", False
        else:
            return "Error", False

    def hash(self, data):
        return hashlib.sha256(data.encode("utf-8")).hexdigest()


server = CustomSMTPServer(("127.0.0.1", 10025), None)

asyncore.loop()
