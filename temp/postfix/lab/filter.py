# Author: Miroslav Houdek <miroslav.houdek@gmail.com>
# License is, do whatever you wanna do with it (at least I think that that is what LGPL v3 says)

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
            data_string = Parser().parsestr(data.decode("utf-8"))

            result = MailMessage(data).check()
            print(result)

            if result["probability"] >= 0.9:
                return  # Discard
            elif result["probability"] >= 0.8:
                status = "Probable"
            elif result["probability"] >= 0.6:
                status = "Potential"
            elif result["probability"] >= 0:
                status = "Unlikely"
            else:
                status = "Error"

            data_string.add_header("X-RCP-Spam-Status", status)
            data_string.add_header("X-RCP-Spam-Reason", str(result["reason"]))
            data_string.add_header("X-RCP-Spam-Description", str(result["description"]))

            raw = status + str(result["reason"]) + str(result["description"])

            data_string.add_header("X-RCP-Spam-Hash", self.hash(raw, "iy9Rd@CG!MemBt"))

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

    def hash(self, data, salt):
        return hashlib.sha256((data + salt).encode("utf-8")).hexdigest()


server = CustomSMTPServer(("127.0.0.1", 10025), None)

asyncore.loop()
