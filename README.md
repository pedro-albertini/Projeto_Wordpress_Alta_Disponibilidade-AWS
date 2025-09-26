<h1 align="center">Projeto_Wordpress_Alta_Disponibilidade-AWS</h1>

<br>

<p align="center">
  <img src="https://skillicons.dev/icons?i=docker" alt="Docker" width="100"/>
  <img src="https://skillicons.dev/icons?i=aws" alt="AWS" width="100"/>
  <img src="https://skillicons.dev/icons?i=wordpress" alt="WordPress" width="100"/>
  <img src="https://skillicons.dev/icons?i=linux" alt="Linux" width="100"/>
</p>

<br><br>

## 🔍 Funcionalidades

- Ambiente escalável utilizando Auto Scaling Group
- Persistência de arquivos com Amazon EFS
- Banco de dados gerenciado com Amazon RDS (MySQL)
- Balanceamento de carga com Elastic Load Balancer
- Implantação automática via script de inicialização (User Data)
- Segurança reforçada por meio de Security Groups bem configurados

## 📁 Arquitetura e Serviços Utilizados

- VPC personalizada
- Sub-redes:
  - 2 públicas (EC2 + Load Balancer)
  - 4 privadas (EFS + RDS)
- Amazon EC2
  - Execução do Docker Compose com WordPress
  - Utilização de Launch Template para instâncias do Auto Scaling
- Amazon RDS (MySQL)
  - Banco de dados gerenciado para o WordPress
- Amazon EFS
  - Armazenamento de arquivos persistentes e compartilhados
- Elastic Load Balancer
  - Distribuição de tráfego e acesso externo ao WordPress
- Auto Scaling Group
  - 2 instâncias em execução (com ajuste automático entre 1 e 3)

<br>

## ⚙️ Configuração
## 1. Crie uma VPC

   - 2 sub-redes públicas para EC2 e o Load Balancer
   - 4 sub-redes privadas para RDS e o EFS

## 2. Criar e configurar os grupos de segurança

   - SG do Load Balancer(ALB)
     - Regras de entrada:
       todo o tráfego => 0.0.0.0/0
     - Regras de saída:
       todo o tráfego => 0.0.0.0/0
       
   - SG da EC2:
     - Regras de entrada:
       HTTP => TCP => 22 => My IP  
       SSH => TCP => 80 => SG-ALB  
       NFS => TCP => 2049 => SG-EFS
     - Regras de saída:
       todo o tráfego => 0.0.0.0/0
       
- SG do RDS
     - Regras de entrada:
       MYSQL/Aurora => TCP => 3306 => SG-EC2
     - Regras de saída:
       todo o tráfego => 0.0.0.0/0

- SG do EFS:
  - Regras de entrada:
    NFS => TCP => 2049 => SG-EC2
  - Regras de saída:
    todo o tráfego => 0.0.0.0/0



## 3. Criar o banco de dados RDS (MYSQL)

- Método de criação: padrão
- Nas opções de mecanismo: MYSQL  

| ![Opções de mecanismo (escolha mysql)](https://github.com/user-attachments/assets/25b97ab9-50ba-4aff-8790-e1c08ec9a760) |
|-------------------------------------------------------------------------------------------------------------------------|
| *Figura - Opções de mecanismo (escolha mysql)* |

- Modelos: gratuito
- Configurações:
  - Coloque um ID para o banco de dados
  - Coloque no modo autogerenciamento e crie suas credenciais
- Escolha a configuração da sua instancia:  

| ![Configurações de instancias (t3 micro)](https://github.com/user-attachments/assets/ea8a281c-792f-4d57-acb9-903282572978) |
|----------------------------------------------------------------------------------------------------------------------------|
| *Figura - Configuração de instâncias (t3 micro)* |

- Selecione sua VPC:  

| ![Conectividade (escolha de vpc)](https://github.com/user-attachments/assets/5957e377-2693-453f-926f-a6370f2f7eca) |
|--------------------------------------------------------------------------------------------------------------------|
| *Figura - Conectividade (escolha de VPC)* |

- Selecione seu security groups (SG-RDS):  

| ![Conectividade (escolha SG)](https://github.com/user-attachments/assets/99bf7326-8970-4cb1-99f6-4f9599c1d59d) |
|----------------------------------------------------------------------------------------------------------------|
| *Figura - Conectividade (escolha SG)* |

- Deixe o RDS com autenticação por senha  
- Nas configurações adicionais, coloque o nome do banco de dados:  

| ![Configuração adicional (nome do banco)](https://github.com/user-attachments/assets/09e0d423-b432-4ab8-a3d7-1bb1793c1e80) |
|----------------------------------------------------------------------------------------------------------------------------|
| *Figura - Configuração adicional (nome do banco)* |

- Ele será usado posteriormente no user_data, o restante deixe como padrão


## 4. Criar o sistema de arquivos EFS

- Coloque um nome para seu EFS:  

| ![Geral (nome efs)](https://github.com/user-attachments/assets/ecaf2a69-4bc3-481b-a9c2-fc4fc7354981) |
|-------------------------------------------------------------------------------------------------------|
| *Figura - Geral (nome do EFS)* |

- Em redes, selecione sua VPC e certifique-se que as subnets que estão selecionadas são privadas e os grupos de segurança estão como SG-EFS:  

| ![Rede (vpc e subnet)](https://github.com/user-attachments/assets/157fe57b-52b1-4f53-b222-c4d3a5a458d0) |
|----------------------------------------------------------------------------------------------------------|
| *Figura - Rede (VPC e Subnet)* |

- O restante pode deixar como padrão

## 5. Criar instância EC2 base com user data

- Utilizar AMI Ubuntu
- Adicionar script no User Data para:
  - Instalar Docker ou containerd
  - Montar EFS
  - Rodar container do WordPress com variáveis de ambiente do RDS
- User data utilizado: [`userdata`](./userdata.sh)
- Conecte-se via SSH e verifique se o Docker está funcionando e se nosso projeto foi lançado.
```
  ssh -i suachave.pem ubuntu@ip_publico 
```
  
## 6. Criar o launch template

- Baseado na instância feita anteriormente
- Deve conter:
  - AMI Ubuntu
  - Par de chaves (opcional caso precise conectar via SSH)
  - Grupo de Segurança da EC2 (SG-EC2)
  - Não selecionar sub-redes (Será selecionado no Auto Sacaling)
  - Deixar IP público das instâncias ativadas
  - Script do UserData

## 7. Criar o target group

- Para criar um grupo alvo escolha as seguintes opções:  

| ![Configuração inicial (instancia)](https://github.com/user-attachments/assets/cd8ca9ff-a462-47ca-8ed9-88d37a812601) |
|----------------------------------------------------------------------------------------------------------------------|
| *Figura - Configuração inicial (instância)* |

| ![Escolha VPC](https://github.com/user-attachments/assets/7963ee9e-d940-4ed7-9421-ebfb0a937701) |
|--------------------------------------------------------------------------------------------------|
| *Figura - Escolha VPC* |


## 8. Criar o load balancer

- Tipo: application load balancer
- Coloque um nome para seu ALB:  

| ![Config basica (nome)](https://github.com/user-attachments/assets/dadce59b-c357-4c77-98f2-cf8dd88d36a0) |
|----------------------------------------------------------------------------------------------------------|
| *Figura - Configuração básica (nome)* |

- Escolha sua VPC, escolha as duas zonas de disponibilidade com as sub-redes públicas  

| ![VPC e AZs](https://github.com/user-attachments/assets/9d7f8288-20ef-4cd1-957c-05848da968c7) |
|------------------------------------------------------------------------------------------------|
| *Figura - VPC e AZs* |

- Escolha seu grupo de segurança SG-ALB:  

| ![Grupo de segurança](https://github.com/user-attachments/assets/1bb751d3-7aaa-416d-9a6a-1b3ee810edf1) |
|---------------------------------------------------------------------------------------------------------|
| *Figura - Grupo de segurança* |

- E para o listeners selecione essas opções escolhendo o target group criado anteriormente:  

| ![roteamento (tg)](https://github.com/user-attachments/assets/94e851a4-6733-42dd-95a5-097cdb57622a) |
|-----------------------------------------------------------------------------------------------------|
| *Figura - Roteamento (TG)* |


## 9. Criar o auto scaling group

- Coloque um nome e escolha o launch template criado anteriormente:  

| ![modelo de execução (nome)](https://github.com/user-attachments/assets/b831370e-21fd-4f5e-bd40-cce4f5af4068) |
|---------------------------------------------------------------------------------------------------------------|
| *Figura - Modelo de execução (nome)* |

- Em rede:
  - Escolha a sua VPC e as sub-redes públicas  

| ![Rede (VPC)](https://github.com/user-attachments/assets/d5c31d21-ab07-4d77-a4a2-7622bd532f7d) |
|--------------------------------------------------------------------------------------------------|
| *Figura - Rede (VPC)* |

- Selecione o load balancer criado anteriormente  
- Configurações:
  - Mínimo: 1 instância
  - Desejado: 2 instâncias
  - Máximo: 3 instâncias
  - O resto deixe como padrão

<br>

## 🚀 Conclusão

Este projeto demonstrou a implementação de um ambiente de **alta disponibilidade** para o WordPress utilizando os principais serviços da **AWS** (EC2, RDS, EFS, ALB e Auto Scaling Group), aliado à **containerização com Docker** para garantir portabilidade e padronização do ambiente.  

A solução permite escalabilidade, persistência de dados e maior resiliência da aplicação, seguindo boas práticas de arquitetura em nuvem e segurança com o uso de Security Groups.  

✅ **Principais aprendizados**:  
- Infraestrutura como código (User Data para automação do ambiente)  
- Uso de containers (Docker e Docker Compose) em conjunto com serviços gerenciados da AWS  
- Criação de um ambiente altamente disponível e escalável  

---

🔗 Desenvolvido com foco em aprendizado e aplicação prática de **DevOps e Cloud Computing**.
