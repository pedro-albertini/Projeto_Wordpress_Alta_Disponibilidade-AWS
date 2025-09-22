# Projeto_Wordpress_Alta_Disponibilidade-AWS

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
<img width="1818" height="607" alt="Opções de mecanismo (escolha mysql)" src="https://github.com/user-attachments/assets/25b97ab9-50ba-4aff-8790-e1c08ec9a760" />

- Modelos: gratuito
- Configurações:
  - Coloque um ID para o banco de dados
  - Coloque no modo autogerenciamento e crie suas credenciais
- Escolha a configuração da sua instancia:
  
  <img width="1821" height="600" alt="Configurações de instancias (t3 micro)" src="https://github.com/user-attachments/assets/ea8a281c-792f-4d57-acb9-903282572978" />
  
- Selecione sua VPC:
  
  <img width="1821" height="600" alt="Conectividade (escolha de vpc)" src="https://github.com/user-attachments/assets/5957e377-2693-453f-926f-a6370f2f7eca" />
  
- Selecione seu security groups (SG-RDS):
   
  <img width="1821" height="600" alt="Conectividade (escolha SG)" src="https://github.com/user-attachments/assets/99bf7326-8970-4cb1-99f6-4f9599c1d59d" />  

- Deixe o RDS com autenticação por senha  

- Nas configurações adicionais, coloque o nome do banco de dados:
  
  <img width="1821" height="600" alt="Configuração adicional (nome do banco)" src="https://github.com/user-attachments/assets/09e0d423-b432-4ab8-a3d7-1bb1793c1e80" />  

- Ele será usado posteriormente no user_data, o restante deixe como padrão


## 4. Criar o sistema de arquivos EFS

- Coloque um nome para seu EFS:
  
  <img width="1278" height="510" alt="Geral (nome efs)" src="https://github.com/user-attachments/assets/ecaf2a69-4bc3-481b-a9c2-fc4fc7354981" />
  
- Em redes, selecione sua VPC e certifique-se que as subnets que estão selecionadas são privadas e os grupos de segurança estão como SG-EFS:
  
  <img width="1470" height="687" alt="Rede (vpc e subnet)" src="https://github.com/user-attachments/assets/157fe57b-52b1-4f53-b222-c4d3a5a458d0" />
  
- O restante pode deixar como padrão

## 5. Criar o launch template

- Deve conter:
  - AMI Ubuntu
  - Par de chaves (opcional caso precise conectar via SSH)
  - Grupo de Segurança da EC2 (SG-EC2)
  - Não selecionar sub-redes (Será selecionado no Auto Sacaling)
  - Deixar IP público das instâncias ativadas
  - Script do UserData

## 6. Criar o target group

- Para criar um grupo alvo escolha as seguintes opções:

<img width="1425" height="648" alt="Configuração inicial (instancia)" src="https://github.com/user-attachments/assets/cd8ca9ff-a462-47ca-8ed9-88d37a812601" />
<img width="1212" height="687" alt="Escolha VPC" src="https://github.com/user-attachments/assets/7963ee9e-d940-4ed7-9421-ebfb0a937701" />


## 7. Criar o load balancer

- Tipo: application load balancer
- Coloque um nome para seu ALB:
  
<img width="1308" height="590" alt="Config basica (nome)" src="https://github.com/user-attachments/assets/dadce59b-c357-4c77-98f2-cf8dd88d36a0" />

- Escolha sua VPC, escolha as duas zonas de disponibilidade com as sub-redes públicas

<img width="1796" height="677" alt="VPC e AZs" src="https://github.com/user-attachments/assets/9d7f8288-20ef-4cd1-957c-05848da968c7" />

- Escolha seu grupo de segurança SG-ALB:

<img width="1577" height="237" alt="Grupo de segurança" src="https://github.com/user-attachments/assets/1bb751d3-7aaa-416d-9a6a-1b3ee810edf1" />

- E para o listeners selecione essas opções escolhendo o target group criado anteriormente:

<img width="1801" height="622" alt="roteamento (tg)" src="https://github.com/user-attachments/assets/94e851a4-6733-42dd-95a5-097cdb57622a" />


## 8. Criar o auto scaling group
