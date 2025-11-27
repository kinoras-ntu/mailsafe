# 🚀 Setup & Deployment

> **Note:**  
> Most cloud platforms block outgoing traffic on port 25 to prevent spam, making it difficult to host this project on those platforms without special arrangements.

> **Remarks:**  
> This project was developed in an NTU dorm room environment, where each person is provided with a dedicated IP address with unrestricted port access.

## Prerequisites

- **A machine with an internet connection:**
  - Must have a dedicated IP address
  - Must allow external access to the following ports:  
    25, 80, 110, 143, 465, 587, 993, 995
- **Docker:**
  - Used to build and run the containerised mail service.
  - Manual installation on a VM is possible but not recommended.
- **Make:**
  - Simplifies build and deployment with predefined commands.
  - You can also run Docker commands directly if preferred.

## Environment Setup

1. **Copy the environment template:**  
   Copy `/.env.defaults` and rename it to `/.env`.

2. **Configure environment variables in `.env`:**

   - **Application settings** (all are required):

     - `DOMAIN`: Your mail server domain (e.g., `example.com`).
     - `MYSQL_USERNAME`: Database username for Roundcube.
     - `MYSQL_PASSWORD`: Database password for Roundcube.
     - `OPENAI_KEY`: OpenAI API key for email filtering with LLM.
     - `ADMIN_USERNAME`: Admin panel login username.
     - `ADMIN_PASSWORD`: Admin panel login password.

   - **Docker settings** (all are optional):

     - `IMAGE`: Docker image tag.
     - `CONTAINER`: Container name.
     - `PORTS`: Port mappings in format `HOST:CONTAINER`.

## Network Setup

### Port Access

Ensure your firewall allows public access to the following ports:

- **Port 25**: SMTP
- **Port 587**: SMTP Submission with STARTTLS
- **Port 465**: SMTPS (SSL/TLS)
- **Port 110**: POP3
- **Port 995**: POP3S (SSL/TLS)
- **Port 143**: IMAP
- **Port 993**: IMAPS (SSL/TLS)
- **Port 80**: HTTP (for Roundcube)

If you configured custom port mappings in `.env`, ensure they are properly mapped to the conventional port numbers listed above. This allows external requests to reach the services running inside the Docker container through your machine's public IP address.

### DNS Configuration

Configure your domain's DNS records with the following settings:

| Type | Name | Value                  | Priority | TTL  |
| ---- | ---- | ---------------------- | -------- | ---- |
| A    | @    | _`ip`_                 | N/A      | 1800 |
| A    | mx   | _`ip`_                 | N/A      | 1800 |
| TXT  | @    | v=spf1 ip4:_`ip`_ -all | N/A      | 1800 |
| MX   | @    | mx._`example.com`_     | 10       | 1800 |

Replace _`ip`_ with your actual public IP address and _`example.com`_ with your domain name.

## Commands

### Container Management

The following commands are available to manage the container, typically used in this order:

- `make build` - Build the Docker image with all required components.
- `make start` - Start the container and filtering services.
- `make shell` - Open a shell session in the container.
- `make stop` - Stop and remove the container.
- `make clean` - Remove the Docker image.
- `make help` - Display all available commands.

### User Management

Once inside the container shell, you can use the following commands:

- **Create a user:** Creates a new user with the specified username.  
   `useradd -m -G mail USERNAME`

- **Set user password:** Assigns a password to the specified user.  
   `passwd USERNAME`

### Log Inspection

View the following logs for debugging:

- **Postfix and Dovecot logs**: `cat /var/log/mail.log`
- **Python filter logs**: `cat /etc/postfix/filter/filter.log`

## Access

You can access the application at the following endpoints (replace _`example.com`_ with your domain name):

- **Roundcube:** `http://example.com:80`
- **Admin Panel:** `http://example.com/admin`
