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
    <img width="1252" height="505" alt="Configurações de instancias (t3 micro)" src="https://github.com/user-attachments/assets/ea8a281c-792f-4d57-acb9-903282572978" />
  - Selecione sua VPC:
    <img width="1821" height="520" alt="Conectividade (escolha de vpc)" src="https://github.com/user-attachments/assets/5957e377-2693-453f-926f-a6370f2f7eca" />
  - Selecione seu security groups (SG-RDS):
    <img width="1821" height="610" alt="Conectividade (escolha SG)" src="https://github.com/user-attachments/assets/99bf7326-8970-4cb1-99f6-4f9599c1d59d" />
  - Deixe o RDS com autenticação por senha
  - Nas configurações adicionais coloque o nome do banco de dados
    <img width="1765" height="423" alt="Configuração adicional (nome do banco)" src="https://github.com/user-attachments/assets/09e0d423-b432-4ab8-a3d7-1bb1793c1e80" />
  - Ele será usado posteriormente no user_data, o restante deixe como padrão




<img width="1821" height="520" alt="Conectividade (escolha de vpc)" src="https://github.com/user-attachments/assets/9e1619c3-ab2d-4a58-b61c-19e593e16f33" />

## 4. Criar o sistema de arquivos EFS
## 5. Criar o launch template
## 6. Criar o load balancer
## 7. Criar o auto scaling group
