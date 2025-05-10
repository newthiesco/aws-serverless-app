# 🌐 AWS Serverless Application Deployment

This project demonstrates how to build and deploy a modern serverless web application on AWS. It leverages key AWS services to serve static content, handle API requests, and persist data securely — all without managing any servers.

---

## 🚀 Tech Stack

- **Frontend:** HTML, CSS, JavaScript hosted on **Amazon S3**
- **Backend:** **AWS Lambda** (Python)
- **API Management:** **Amazon API Gateway**
- **Database:** **Amazon DynamoDB**
- **Content Delivery & Security:** **Amazon CloudFront** (HTTPS + caching)

---

## 🏗️ Architecture Overview

[User] --> [CloudFront CDN] --> [S3 Bucket (Static Site)]
↘
→ [API Gateway] → [Lambda (Python)] → [DynamoDB]


---

## 📦 Features

- 🗂️ Serve static website via **S3**
- 🔐 Secure the site and APIs using **CloudFront + HTTPS**
- ⚙️ Trigger **Python Lambda functions** via **API Gateway**
- 🧠 Persist and retrieve data with **DynamoDB**
- ✅ Fully serverless and scalable architecture

---

## 📁 Project Structure

.
├── frontend/
│ ├── index.html
│ ├── styles.css
│ └── app.js
├── lambda/
│ ├── handler.py
│ └── requirements.txt
├── templates/
│ └── cloudformation.yml
└── README.md


---

## ⚙️ Deployment Steps

### 1. 🧾 Deploy DynamoDB Table

```bash
aws dynamodb create-table \
  --table-name YourTableName \
  --attribute-definitions AttributeName=pk,AttributeType=S \
  --key-schema AttributeName=pk,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

2. 🐍 Deploy Lambda Functions

cd lambda
zip function.zip handler.py
aws lambda create-function \
  --function-name YourFunctionName \
  --runtime python3.11 \
  --handler handler.lambda_handler \
  --zip-file fileb://function.zip \
  --role arn:aws:iam::123456789012:role/your-lambda-exec-role

3. 🧩 Set Up API Gateway

Configure REST endpoints to trigger your Lambda:

    You can use the AWS Console, AWS CLI, or a CloudFormation template to create a REST API with a resource and method integrated with your Lambda function.

4. 🪣 Upload Static Website to S3

aws s3 mb s3://your-bucket-name
aws s3 sync ./frontend s3://your-bucket-name --acl public-read

aws s3 mb s3://your-bucket-name
aws s3 sync ./frontend s3://your-bucket-name --acl public-read

Enable static website hosting in the S3 bucket properties.
5. 🛡️ Configure CloudFront for CDN + HTTPS

Create a CloudFront distribution:

    Origin Domain Name: Your S3 bucket endpoint

    Viewer Protocol Policy: Redirect HTTP to HTTPS

    Alternate Domain Name (CNAME): Optional

    SSL Certificate: Use ACM for a custom domain

    Use AWS Console or CloudFormation for advanced setup.

🔐 Security Best Practices

    ✅ Enforce HTTPS via CloudFront

    🚫 Disable public access to the S3 bucket (use OAI/OAC)

    🔐 Use IAM roles with least privilege for Lambda

    🌐 Enable proper CORS in API Gateway

    🔒 Store secrets securely using AWS Secrets Manager or environment variables

📚 Useful Resources

## 📚 Useful Resources

## 📚 Useful Resources

## 📚 Useful Resources

## 📚 Useful Resources

- 📘 [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- 📘 [API Gateway + Lambda Integration](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-getting-started-with-rest-apis.html)
- 📘 [Amazon CloudFront Docs](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html)
- 📘 [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)


📌 TODO

Add CI/CD pipeline with GitHub Actions or AWS CodePipeline

Add unit tests for Lambda functions

Add monitoring with AWS CloudWatch

Add authentication via Amazon Cognito or IAM

📬 Feedback

Have suggestions or found a bug? Feel free to open an issue or submit a PR!

📝 License

This project is licensed under the MIT License.

---
Credit to Youtube Video
https://www.youtube.com/watch?v=pK52mfm69i0
