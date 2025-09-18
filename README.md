# Projeto_Wordpress_Alta_Disponibilidade-AWS

## 1. Crie uma VPC

   - 2 sub-redes públicas para EC2 e o Load Balancer
   - 4 sub-redes privadas para RDS e o EFS

## 2. Criar e configurar os grupos de segurança

   - SG do Load Balancer(ALB)
     - Regras de entrada:
       todo o tráfego => 0.0.0.0/0
     - Regras de saída:
       vazio
       
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
![Logo da Minha Empresa](/imagens/Conectividade (escolha SG).png)
## 4. Criar o sistema de arquivos EFS
## 5. Criar o launch template
## 6. Criar o load balancer
## 7. Criar o auto scaling group
