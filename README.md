cgit_auth_docker
=================


*simple cgit docker with authentication*

---

 * https://git.zx2c4.com/cgit/about/
 * https://github.com/KunoiSayami/cgit-simple-authentication

---

## Run with:

```bash

docker run                                 \
       --detach                            \
       --publish "{{port_ui}}:80/tcp"      \
       --publish "{{port}}:22"             \
       --name "{{docker_name}}"            \
       --restart unless-stopped            \
       --volume "{{conf_dir}}:/config"     \
       --volume "{{repos_dir}}:/cgit"      \
       --env "SSH_KEY={{ssh-public-key}}"  \
       --env "CGIT_TITLE={{title}}"        \
       --env "CGIT_DESC={{description}}"   \
       --env "DEFAULT_USER={{username}}"   \
       --env "DEFAULT_PASS={{password}}"   \
 			 --env "CGIT_CACHE=0"                \
 			 --env "CGIT_AUTH=0"                 \
       --env "AUTH_TTL=600"                \
       "mikescher/cgit_auth"

 # Then navigate to http://{{domain}}:{{port}} for the cgit website

```

## Env variable

| Environment Variable           | Description                |
|--------------------------------|----------------------------|
| `CGIT_TITLE`                   | CGit HTML Title            |
| `CGIT_DESC`                    | CGit HTML Subtitle         |
| `CGIT_VROOT`                   |                            |
| `CGIT_SECTION_FROM_STARTPATH`  |                            |
| `CGIT_LOG_PAGESIZE`            | Pagesize for commit-list   |
| `CGIT_REPO_PAGESIZE`           | Pagesize for repo-list     |
| `CGIT_CACHE`                   | Set to 0 to disable cache  |
| `CGIT_AUTH`                    | Set to 1 to enable auth    |
| `DEFAULT_USER`                 | Username for auth          |
| `DEFAULT_PASS`                 | Password for auth          |
| `AUTH_TTL`                     |                            |
| `DOMAIN`                       | Domain (for clone urls)    |
| `SSHPORT`                      | SSH-Port (for clone urls)  |

## Create repo

```bash
  $> ssh "git@{{domain}}" -p "{{port}}"
  $> cd /cgit
  $> git init "{{repo_name}}" --bare
  $> /opt/cgit-simple-authentication repo add "{{repo_name}}" "{{username}}"
```

## Push

```bash
  $> git remote add origin "ssh://git@{{domain}}:{{port}}/cgit/{{repo_name}}"
  $> git push
```
