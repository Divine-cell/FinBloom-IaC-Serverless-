## FinBloom Serverless Infrastructure as Code (IaC)

The primary goal was to improve the 3-tier web app I had previously built by introducing automation, scalability, and a serverless architecture. 
The entire infrastructure is provisioned, managed, and maintained solely through Terraform configuration files.

##Architectural Diagram

The application follows a standard serverless 3-Tier model, ensuring high availability (across 2 Availability Zones), security, and fast content delivery.
<img width="1114" height="778" alt="finbloom" src="https://github.com/user-attachments/assets/cb5dfad3-733e-43bd-bba2-81deb1bba8ad" />

##Architecture Breakdown

**1. Frontend
The frontend is designed for speed and security, utilizing global AWS edge services:
S3 Bucket: Static file hosting for the frontend application.

CloudFront: Global Content Delivery Network (CDN) that caches frontend files and accelerates delivery. it also acts as the primary public entry point.
ACM (AWS Certificate Manager): Provisions and manages the SSL certificate for secure HTTPS communication.
freedomain.one: An external DNS that resolve to the CloudFront distribution endpoint

**2. Backend
The backend is fully serverless, scaling automatically with user demand:
API Gateway (HTTP): Frontend access and routing. It exposes a secure, custom domain endpoint (https://transactions.finbloom.work.gd) that triggers the backend logic.
AWS Lambda: This is triggered by API Gateway requests. Lambda execution code is stored in a separate S3 bucket and accessed during runtime due to large file size, ensuring efficient deployment. it is also pplaced in the private subnet so it can communicate securely with db
IAM Role: Grants the Lambda function necessary execution permissions and access to both the Backend S3 bucket (to fetch code/files) and the RDS instance (VPC access).

**3. Database
RDS PostgreSQL: Placed exclusively in the Private Subnets. Communication with Lambda is secured via VPC Security Groups, ensuring it is never publicly accessible.
EC2 Jumphost: Database Management Access. It Used as a Jumphost (Bastion Host) in the Public Subnet to securely SSH into the VPC and access the private RDS instance for schema setup.

##Deployment and Technology
This project is built on the following core technologies:
Terraform: Used to provision, manage, and tear down all AWS resources defined in the architecture.
AWS: All services (S3, CloudFront, Lambda, RDS, etc.) are hosted on Amazon Web Services.
PostgreSQL: Relational database hosted on AWS RDS.
Scripting: JavaScript/Node.js, HTML, CSS

Used for the Lambda function runtime.

🧠 Challenges and Lessons Learned

Building this serverless infrastructure provided valuable insights into production-grade cloud development:

Challenge / Lesson Learned

Detail

Lambda Handler Function

Initially struggled with Lambda correctly executing the application logic. Learned the absolute necessity of defining a specific handler function in the application code (server.handler) for Lambda to properly bootstrap and execute the backend files.

RDS Security & VPC

Confirmed the best practice of placing RDS in a Private Subnet and configuring Lambda with a VPC connection for secure, internal network communication.

SSL/Data-in-Transit

Recognized that while Lambda-to-RDS communication is secure over the private network, SSL is required for encryption of data in transit (e.g., between the application and the database) for production standards.

DB Migration vs. Manual Setup

Faced issues with automating the initial DB migration. Opted for the pragmatic solution of using the EC2 Jumphost to manually create the database and schema using psql. Future state must involve automated database migration.

CORS Policy

Overcame a critical CORS policy error by ensuring the API Gateway explicitly allowed the frontend domain (https://www.finbloom.work.gd) in the cors_configuration block of the Terraform resource.

🚀 Future Improvements

This project serves as a strong foundation. Future development efforts will focus on achieving full automation and enhancing production readiness:

CI/CD Pipeline: Implement a Continuous Integration/Continuous Delivery pipeline using GitHub Actions to automate the build, test, and deployment of both the Terraform infrastructure and the Lambda code.

Database Migration Automation: Replace the manual Jumphost setup by integrating a proper database migration tool (e.g., Flyway or Liquibase) into the Terraform or CI/CD workflow.

Database Secrets Management: Implement AWS Secrets Manager to securely store and retrieve RDS credentials, removing hardcoded values from the Lambda environment.

Remove Jumphost: For production, the Jumphost should be replaced with a managed service like AWS Systems Manager (SSM) Session Manager for secure shell access without needing open SSH ports.
