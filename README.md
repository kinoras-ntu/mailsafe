# Mail Service with AI-Powered Filtering

## 🛠 Setup

1. Copy `/.env.defaults` and rename it into `/.env`.

2. Modify `/.env`:

   - **Setting secrets**: Replace the placeholders in the `replacements` section with in your config.

   - **Docker settings**: You can also check if you want to use your own image tag, container name, or port mapping.

## ⚙️ Usage

### Container management

The following commands are available in the Makefile:

- **build**: Build the Docker image (tag: `mailsafe`).

- **start**: Start the container (name: `mailsafe-instance`) and run the Python filter script.

- **shell**: Open an interactive Bash shell in the running container.

- **stop**: Stop and remove the running container.

- **clean**: Remove the Docker image.

- **help**: Display all available commands and their descriptions.

### In-container commands

Once you are inside the container's shell, here are some useful commands you can use:

- **Create a user**: Create a new user with the specified username.  
  `useradd -m -G mail USERNAME`

- **Change user password**: Assign a password to the specified user.  
  `passwd USERNAME`

- **Check logs**: Print the following logs to help debugging.  
  `cat /var/log/mail.log` - for Postfix and Dovecot logs  
  `cat /etc/postfix/filter/filter.log` - for the Python filter logs

## 📝 License

Permissively licensed under the MIT license.  
Special thanks to [Miroslav Houdek](https://github.com/MiroslavHoudek) for creating the foundation of the Python filter script.
