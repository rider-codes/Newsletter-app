# Newsletter Application

A modern, full-stack newsletter management system built with React, TypeScript, and AWS services. This application allows you to manage and send newsletters to your subscribers with a beautiful UI and robust backend infrastructure.

## 🚀 Features

- Modern React-based frontend with TypeScript
- Responsive and intuitive user interface
- AWS Lambda-powered backend
- Email sending capabilities via AWS SES
- S3 storage for subscriber lists and templates
- Comprehensive monitoring with CloudWatch
- CORS-enabled API Gateway integration
- Automated deployment scripts

## 🛠 Tech Stack

### Frontend
- React
- TypeScript
- TailwindCSS
- Framer Motion

### Backend
- AWS Lambda
- Python
- AWS SES (Simple Email Service)
- AWS S3
- AWS API Gateway

### Monitoring
- AWS CloudWatch
- Custom Dashboards
- Automated Alarms

## 📋 Prerequisites

- Node.js (v14 or higher)
- Python 3.8+
- AWS CLI configured with appropriate credentials
- AWS Account with access to:
  - Lambda
  - S3
  - SES
  - API Gateway
  - CloudWatch

## 🔧 Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd newsletter-app
```

2. Install frontend dependencies:
```bash
npm install
```

3. Install Python dependencies:
```bash
pip install -r requirements.txt
```

4. Configure AWS services:
```bash
# Run the setup scripts
./setup-api.ps1
./setup-s3.ps1
./setup-monitoring.ps1
```

## 🚀 Development

1. Start the development server:
```bash
npm start
```

2. Build for production:
```bash
npm run build
```

## 📊 Monitoring

The application comes with pre-configured CloudWatch dashboards and alarms:

- API Gateway metrics
- Lambda function performance
- SES email statistics
- S3 bucket metrics

To view the dashboards:
1. Navigate to AWS CloudWatch
2. Select "Dashboards"
3. Open "NewsletterServicesDashboard"

## 🔐 Security

- AWS IAM roles and policies are configured for least privilege
- CORS policies are implemented
- API Gateway authentication ready
- SES email sending limits enforced

## 📝 API Documentation

### Send Newsletter Endpoint
- **URL**: `/send-newsletter`
- **Method**: `POST`
- **Auth**: None (configurable)
- **Request Body**:
```json
{
  "subject": "Newsletter Subject",
  "content": "Newsletter Content"
}
```

## 📁 Project Structure

```
newsletter-app/
├── src/
│   ├── components/
│   │   └── NewsletterForm.tsx
│   ├── App.tsx
│   ├── index.tsx
│   └── index.css
├── public/
│   └── index.html
├── aws/
│   ├── lambda_function.py
│   └── email_template.html
├── scripts/
│   ├── setup-api.ps1
│   ├── setup-s3.ps1
│   └── setup-monitoring.ps1
└── config/
    ├── dashboard.json
    └── lambda-role-policy.json
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- AWS Documentation
- React Community
- TailwindCSS Team

## 🔧 Troubleshooting

Common issues and their solutions:

1. **CORS Issues**
   - Verify CORS configuration in API Gateway
   - Check browser console for specific errors

2. **Email Sending Failures**
   - Verify SES configuration
   - Check email verification status
   - Review CloudWatch logs

3. **Monitoring Issues**
   - Ensure IAM roles have correct permissions
   - Verify CloudWatch dashboard configuration

## 📞 Support

For support, please:
1. Check the documentation
2. Review CloudWatch logs
3. Open an issue in the repository

---

Rahul Srivastava
