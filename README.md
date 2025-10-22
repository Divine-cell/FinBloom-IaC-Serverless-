## FinBloom Serverless Infrastructure as Code (IaC)

The primary goal was to improve the 3-tier web app I had previously built by introducing automation, scalability, and a serverless architecture. 

**check out the initial infrastructure:** https://github.com/Divine-cell/FinBloom

The entire infrastructure is provisioned, managed, and maintained solely through Terraform configuration files.

<img width="1325" height="646" alt="Screenshot 2025-10-20 024300" src="https://github.com/user-attachments/assets/27b7e508-f5ac-4508-a1b8-e3598b85a5d7" />


## Architectural Diagram

The application follows a standard serverless 3-Tier model, ensuring high availability (across 2 Availability Zones), security, and fast content delivery.
<img width="1114" height="778" alt="finbloom" src="https://github.com/user-attachments/assets/cb5dfad3-733e-43bd-bba2-81deb1bba8ad" />

## Architecture Breakdown

### 1. Frontend
The frontend is designed for speed and security, utilizing global AWS edge services: 

**S3 Bucket:** Static file hosting for the frontend application.
<img width="1354" height="508" alt="Screenshot 2025-10-20 024120" src="https://github.com/user-attachments/assets/4e60506c-b171-4e49-b6b7-e454d049015c" /> 

**ACM (AWS Certificate Manager):** Provisions and manages the SSL certificate for secure HTTPS communication (www.Finbloom.work.gd)
<img width="1366" height="297" alt="Screenshot 2025-10-20 024606" src="https://github.com/user-attachments/assets/f9829a41-3749-4b08-a087-c06b01ad68f5" />
<img width="1051" height="457" alt="Screenshot 2025-10-20 024627" src="https://github.com/user-attachments/assets/ddb2c42a-d834-40d7-9439-314b78d33d5a" />


**CloudFront:** Global Content Delivery Network (CDN) that caches frontend files and accelerates delivery. it also acts as the primary public entry point.
<img width="1355" height="325" alt="Screenshot 2025-10-20 024409" src="https://github.com/user-attachments/assets/7b5de68d-735a-4148-9394-823047aab40e" />

**freedomain.one:** An external DNS that resolve to the CloudFront distribution endpoint

### 2. Backend
The backend is fully serverless, scaling automatically with user demand:

**API Gateway (HTTP):** Frontend access and routing. It exposes a secure, custom domain endpoint (https://transactions.finbloom.work.gd) that triggers the backend logic.
<img width="1082" height="284" alt="Screenshot 2025-10-20 023611" src="https://github.com/user-attachments/assets/3ca352e6-7566-48d0-9e8c-0f1d0eabaa51" />

**ACM (AWS Certificate Manager):** Provisions and manages the SSL certificate for secure HTTPS communication for custom domain for api gatway (transactions.Finbloom.work.gd)

<img width="1026" height="461" alt="Screenshot 2025-10-20 024535" src="https://github.com/user-attachments/assets/7322dcfb-30fe-4bfe-bb7b-89b13adb62b9" />


**AWS Lambda:** This is triggered by API Gateway requests. it is also placed in the private subnet so it can communicate securely with db

<img width="1366" height="459" alt="Screenshot 2025-10-20 023657" src="https://github.com/user-attachments/assets/f7fecc7b-233e-4eb0-a58a-6328d9ae1027" />
<img width="1342" height="517" alt="Screenshot 2025-10-20 023919" src="https://github.com/user-attachments/assets/09c2343a-b7f3-43bb-9ec1-80a22a917747" />

**IAM Role:** Grants the Lambda function necessary execution permissions and access to both the Backend S3 bucket (to fetch code/files) and the RDS instance (VPC access).

**S3:** Lambda execution code is stored in a separate S3 bucket and accessed during ru
ntime due to large file size, ensuring efficient deployment.

<img width="1064" height="388" alt="lams3" src="https://github.com/user-attachments/assets/2b3a26d9-b909-44ac-952a-34752be39229" />

### 3. Database
**RDS PostgreSQL:** Placed exclusively in the Private Subnets. Communication with Lambda is secured via VPC Security Groups, ensuring it is never publicly accessible.

<img width="1348" height="511" alt="Screenshot 2025-10-20 022849" src="https://github.com/user-attachments/assets/ad5f0b75-19a2-4f48-9533-7fa912e6d6a2" /> 

**EC2 Jumphost:** Database Management Access. It Used as a Jumphost (Bastion Host) in the Public Subnet to securely SSH into the VPC and access the private RDS instance for schema setup.
**Note:** Using a jump box is not best practice for production environments. A better approach is to use AWS Systems Manager Session Manager, database migration services, and encrypted connections.

<img width="1365" height="715" alt="Screenshot 2025-10-20 022658" src="https://github.com/user-attachments/assets/3d58bb01-62ec-4077-94ac-b556f260e695" />

### Networking
VPC:
Subnet: 
<img width="1105" height="308" alt="Screenshot 2025-10-20 023232" src="https://github.com/user-attachments/assets/44e32456-586e-436c-9aab-cdb67440d4b9" />

Route Table: 
<img width="1126" height="246" alt="Screenshot 2025-10-20 023420" src="https://github.com/user-attachments/assets/77229699-2991-438e-82a4-b4df0449bd9a" /> 

Internet GateWay: 
<img width="1107" height="243" alt="Screenshot 2025-10-20 023446" src="https://github.com/user-attachments/assets/7300fd60-caf4-4887-9b5e-e8b38de465ca" />

## Deployment and Technology
This project is built on the following core technologies:

**Terraform:** Used to provision, manage, and tear down all AWS resources defined in the architecture.

**AWS:** All services (S3, CloudFront, Lambda, RDS, etc.) are hosted on Amazon Web Services.

**PostgreSQL:** Relational database hosted on AWS RDS.

**Freedomain.io:** Domain Name Service

**Scripting:** JavaScript/Node.js, HTML, CSS


## Challenges and Lessons Learned
Building this serverless infrastructure provided valuable insights into production-grade cloud development

**CORS Issues:**
Initially, API Gateway responses didn’t include proper CORS headers, breaking frontend requests. I resolved this by adding explicit CORS configurations and headers in Lambda responses.

**Lambda Handler Error:**
My first Lambda deployments failed because the function handler path wasn’t correctly defined in Terraform (handler = "app.lambda_handler"). Once corrected and zipped properly, it executed smoothly.

**Database Connectivity:**
The Lambda function couldn’t initially connect to RDS. After troubleshooting, I found missing VPC and security group configurations. Proper subnet mapping and security group rules fixed the issue.

**Parameter Group / pg_hba.conf Issues:**
I faced PostgreSQL host authentication problems (no pg_hba.conf entry for host). The fix involved proper RDS parameter group configuration and ensuring SSL communication where required.

## Future Improvements
This project serves as a strong foundation. Future development efforts will focus on achieving full automation and enhancing production readiness:

**- CI/CD Pipeline:** Implement a Continuous Integration/Continuous Delivery pipeline using GitHub Actions to automate the build, test, and deployment of both the Terraform infrastructure and the Lambda code.

**- Database Migration Automation:** Replace the manual Jumphost setup by integrating a proper database migration tool into the Terraform or CI/CD workflow.

**- Database Secrets Management:** Implement AWS Secrets Manager to securely store and retrieve RDS credentials, removing hardcoded values from the Lambda environment.

**- Remove Jumphost:** For production, the Jumphost should be replaced with a managed service like AWS Systems Manager (SSM) Session Manager for secure shell access without needing open SSH ports.
