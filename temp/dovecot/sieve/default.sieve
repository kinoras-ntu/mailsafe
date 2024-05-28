require ["fileinto", "imap4flags"];

if header :contains "X-RCP-Spam-Status" "Unlikely" {
    fileinto "Junk";
    stop;
}
