FROM alpine:3.4

# "--no-cache" is new in Alpine 3.3 and it avoid using
# "--update + rm -rf /var/cache/apk/*" (to remove cache)
RUN apk add --no-cache \
# openssh=7.2_p2-r1 \
  openssh \
# git=2.8.3-r0
  git

# Key generation on the server
RUN ssh-keygen -A

# SSH autorun
# RUN rc-update add sshd


# -D flag avoids password generation
# -s flag changes user's shell
RUN mkdir -p /git-server/keys \
  && adduser -D -s /usr/bin/git-shell git \
  && echo git:12345 | chpasswd \
  && mkdir /home/git/.ssh

# This is a login shell for SSH accounts to provide restricted Git access.
# It permits execution only of server-side Git commands implementing the
# pull/push functionality, plus custom commands present in a subdirectory
# named git-shell-commands in the user’s home directory.
# More info: https://git-scm.com/docs/git-shell
COPY src/git-shell-commands /home/git/git-shell-commands

# sshd_config file is edited for enable access key and disable access password
COPY src/sshd_config /etc/ssh/sshd_config
COPY src/start.sh /git-server/start.sh

EXPOSE 22

WORKDIR /repos

CMD ["sh", "/git-server/start.sh"]
