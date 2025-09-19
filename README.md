Reorganizar isso


Novas variáveis de ambiente
Entrypoint agora gera alguns arquivos de configuração.
Novas variáveis de ambiente
Entrypoint agora pode gerar automaticamente `server.properties`, `whitelist.json` e `ops.json` com valores baseados em variáveis de ambiente.
As variáveis de ambiente
Ambas são necessárias para a configuração do servidor.
# Minecraft Forge Server (1.20.1) - Docker

Este repositório contém um Dockerfile e um `docker-compose.yml` para subir um servidor Minecraft Forge 1.20.1 localmente usando o instalador que você já tem em `./data/` (ou `./Forge_Version/`).

Pré-requisitos
- Docker e Docker Compose (v2) instalados
- O instalador do Forge colocado em `Forge_Version/` (por exemplo `forge-1.20.1-47.4.0-installer.jar`)

Como funciona
- O `docker-compose.yml` foi modificado para construir a imagem localmente.
- `./data` (ou alternativamente `./Forge_Version`) é montado dentro do container em `/opt/forge` (somente leitura).
- Na primeira execução, o entrypoint procura por um arquivo `*installer*.jar` dentro de `/opt/forge` e roda `java -jar installer.jar --installServer /data` para instalar os arquivos do servidor no volume `./minecraft-data`.
- O script também escreve `eula.txt` automaticamente se `EULA` estiver definido como `TRUE` no compose.

Instruções rápidas
1. Verifique que `data/forge-1.20.1-47.4.0-installer.jar` (ou `Forge_Version/forge-1.20.1-47.4.0-installer.jar`) existe.
2. Suba o serviço (buildará a imagem localmente):

```bash
docker compose up --build -d
```

3. Veja os logs para acompanhar a instalação e o startup:

```bash
docker compose logs -f
```

Observações
- O script procura por jars que contenham `installer` no nome. Se o seu instalador tiver outro nome, renomeie-o ou coloque um link simbólico em `./data/` (ou `./Forge_Version/`).
- Se preferir usar a imagem oficial `itzg/minecraft-server`, volte a `docker-compose.yml` para apontar para `image: itzg/minecraft-server`.

Problemas conhecidos e sugestões
- Se o container não conseguir baixar dependências, verifique a conectividade de rede e as permissões do volume `./minecraft-data` no host.
- Para ajustar memória, altere `MAX_MEMORY` e `INIT_MEMORY` no `docker-compose.yml`.

Troubleshooting: permissões e erros comuns

- Aviso do `docker compose` sobre `version` obsoleto: a linha `version: '3.8'` foi removida do `docker-compose.yml` para evitar o aviso.

- Erro: "permission denied while trying to connect to the Docker daemon socket" ou "connect: permission denied"
	- Causa: seu usuário não tem permissão para acessar o socket do Docker (`/var/run/docker.sock`).
	- Soluções possíveis (escolha uma):
		- Executar com sudo:

```bash
sudo docker compose up --build -d
```

		- Ou adicionar seu usuário ao grupo `docker` (necessário logout/login):

```bash
sudo usermod -aG docker $USER
# depois faça logout/login ou: newgrp docker
```

		- Verifique permissões do socket:

```bash
ls -l /var/run/docker.sock
# normalmente o grupo deve ser 'docker' e o socket ter permissão de grupo rw
```

- Erro: "mkdir: cannot create directory '/data': Permission denied"
	- Causa: o processo dentro do container está tentando criar ou escrever em `/data`, mas o volume montado no host (`./minecraft-data`) tem permissões que impedem escrita pelo UID usado no container.
	- Soluções: garantir que o diretório no host existe e tem dono/permissões apropriadas. Exemplo:

```bash
# crie o diretório se não existir
mkdir -p ./minecraft-data
# ajuste dono para seu usuário (se for executar docker com seu UID dentro do container, ou use root do container)
sudo chown -R $(id -u):$(id -g) ./minecraft-data
```

	- Observação: o `Dockerfile` configura o processo para rodar como usuário `mc` dentro do container. Se preferir, você pode alterar o Dockerfile para rodar como root (não recomendado por segurança) ou ajustar as permissões no host de modo que o UID do usuário `mc` dentro do container possa escrever (isto requer mapeamento de UID/GID).

Se precisar, posso sugerir o comando exato para ajustar as permissões do diretório no host com base no UID do usuário `mc` dentro da imagem.


