# Serverless Contact Form

A production-ready serverless contact form solution built with React, AWS Lambda, API Gateway, DynamoDB, and SES. Infrastructure is managed with Terraform and deployed via GitHub Actions.

## Architecture

```
Frontend (React) → API Gateway → Lambda → DynamoDB
                                    ↓
                                   SES (Email)
```

### Components

- **Frontend**: React application with beautiful UI and form validation
- **API Gateway**: RESTful endpoint with CORS support
- **Lambda**: Serverless function for processing form submissions
- **DynamoDB**: NoSQL database for storing submissions
- **SES**: Email service for notifications
- **Terraform**: Infrastructure as Code
- **GitHub Actions**: CI/CD pipeline

## Features

- ✅ Beautiful, responsive contact form
- ✅ Real-time form validation
- ✅ Serverless architecture (pay-per-use)
- ✅ Email notifications with HTML templates
- ✅ Data persistence in DynamoDB
- ✅ CORS support for cross-origin requests
- ✅ Input sanitization and security
- ✅ Infrastructure as Code with Terraform
- ✅ Automated deployment with GitHub Actions
- ✅ Comprehensive error handling
- ✅ Request logging and monitoring

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0
- Node.js >= 18
- Git

## Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd serverless-contact-form
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start development server**
   ```bash
   npm run dev
   ```

## Infrastructure Deployment

### Manual Deployment

1. **Configure AWS credentials**
   ```bash
   aws configure
   ```

2. **Create Terraform variables file**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit terraform.tfvars**
   ```hcl
   aws_region = "ap-south-1"
   project_name = "serverless-contact-form"
   environment = "prod"
   notification_email = "your-email@example.com"
   ```

4. **Deploy infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. **Get API endpoint**
   ```bash
   terraform output frontend_api_endpoint
   ```

### Automated Deployment with GitHub Actions

1. **Set up repository secrets**
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `NOTIFICATION_EMAIL`

2. **Push to main branch**
   ```bash
   git push origin main
   ```

The GitHub Actions workflow will:
- Validate Terraform configuration
- Deploy infrastructure
- Build and prepare frontend
- Output the API endpoint

## SES Configuration

1. **Verify email address**
   - Go to AWS SES Console
   - Verify your notification email address
   - Check your email for verification link

2. **Request production access** (if needed)
   - By default, SES is in sandbox mode
   - Request production access to send emails to any address

## Configuration

### Environment Variables

Create `.env.production` for production:
```env
VITE_API_ENDPOINT=https://your-api-gateway-url.amazonaws.com/prod/contact
```

### Terraform Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `ap-south-1` |
| `project_name` | Project name | `serverless-contact-form` |
| `environment` | Environment | `dev` |
| `notification_email` | Email for notifications | Required |
| `lambda_timeout` | Lambda timeout (seconds) | `30` |
| `lambda_memory_size` | Lambda memory (MB) | `128` |

## Monitoring

### CloudWatch Logs
- Lambda function logs: `/aws/lambda/{function-name}`
- API Gateway logs: Available in CloudWatch

### DynamoDB
- Monitor read/write capacity
- Check for throttling
- Review item count and size

### SES
- Monitor send statistics
- Check bounce and complaint rates
- Review reputation metrics

## Security Features

- Input validation and sanitization
- CORS configuration
- IAM roles with least privilege
- DynamoDB encryption at rest
- SES TLS enforcement
- Request rate limiting (API Gateway)

## Cost Optimization

- **Lambda**: Pay per request (free tier: 1M requests/month)
- **API Gateway**: Pay per request (free tier: 1M requests/month)
- **DynamoDB**: Pay per request (free tier: 25GB storage)
- **SES**: Pay per email (free tier: 62,000 emails/month)

## Testing

### Local Testing
```bash
npm run test
```

### API Testing
```bash
curl -X POST https://your-api-endpoint.com/prod/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "subject": "Test Subject",
    "message": "This is a test message"
  }'
```

##  Troubleshooting

### Common Issues

1. **SES Email Not Sending**
   - Verify email address in SES console
   - Check SES sending limits
   - Review CloudWatch logs

2. **CORS Errors**
   - Verify API Gateway CORS configuration
   - Check allowed origins and methods

3. **Lambda Timeout**
   - Increase timeout in Terraform variables
   - Check function performance metrics

4. **DynamoDB Access Denied**
   - Verify IAM role permissions
   - Check resource ARNs in policies

### Logs and Debugging

```bash
# View Lambda logs
aws logs tail /aws/lambda/your-function-name --follow

# Check API Gateway logs
aws logs describe-log-groups --log-group-name-prefix API-Gateway-Execution-Logs
```

## Updates and Maintenance

### Updating Infrastructure
```bash
cd terraform
terraform plan
terraform apply
```

### Updating Lambda Function
1. Modify code in `terraform/modules/lambda/src/`
2. Run `terraform apply`
3. Terraform will detect changes and redeploy

### Frontend Updates
1. Make changes to React components
2. Build: `npm run build`
3. Deploy to your hosting service

## API Documentation

### POST /contact

**Request Body:**
```json
{
  "name": "string (required)",
  "email": "string (required, valid email)",
  "subject": "string (required)",
  "message": "string (required, min 10 chars)"
}
```

**Response (Success):**
```json
{
  "message": "Contact form submitted successfully",
  "id": "uuid",
  "timestamp": "ISO 8601 timestamp"
}
```

**Response (Error):**
```json
{
  "error": "Error message",
  "details": ["validation errors"]
}
```


**Built with ❤️ using AWS Serverless Technologies**