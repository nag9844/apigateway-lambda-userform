const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');

// Enable detailed logging
console.log('Lambda function starting...');
console.log('Environment variables:', {
    DYNAMODB_TABLE_NAME: process.env.DYNAMODB_TABLE_NAME,
    NOTIFICATION_EMAIL: process.env.NOTIFICATION_EMAIL,
    NODE_ENV: process.env.NODE_ENV,
    AWS_REGION: process.env.AWS_REGION
});

// Initialize AWS services
const dynamodb = new AWS.DynamoDB.DocumentClient({
    region: process.env.AWS_REGION || 'ap-south-1'
});
const ses = new AWS.SES({
    region: process.env.AWS_REGION || 'ap-south-1'
});

// Environment variables
const DYNAMODB_TABLE_NAME = process.env.DYNAMODB_TABLE_NAME;
const NOTIFICATION_EMAIL = process.env.NOTIFICATION_EMAIL;

// Validate environment variables
if (!DYNAMODB_TABLE_NAME) {
    console.error('❌ DYNAMODB_TABLE_NAME environment variable is not set');
}
if (!NOTIFICATION_EMAIL) {
    console.error('❌ NOTIFICATION_EMAIL environment variable is not set');
}

// CORS headers
const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
    'Access-Control-Allow-Methods': 'OPTIONS,POST',
    'Content-Type': 'application/json'
};

// Input validation function
function validateInput(data) {
    const errors = [];
    
    if (!data.name || typeof data.name !== 'string' || data.name.trim().length === 0) {
        errors.push('Name is required');
    }
    
    if (!data.email || typeof data.email !== 'string') {
        errors.push('Email is required');
    } else {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(data.email)) {
            errors.push('Invalid email format');
        }
    }
    
    if (!data.subject || typeof data.subject !== 'string' || data.subject.trim().length === 0) {
        errors.push('Subject is required');
    }
    
    if (!data.message || typeof data.message !== 'string' || data.message.trim().length < 10) {
        errors.push('Message must be at least 10 characters long');
    }
    
    return errors;
}

// Sanitize input to prevent XSS
function sanitizeInput(str) {
    return str.replace(/[<>]/g, '');
}

// Save to DynamoDB
async function saveToDatabase(data) {
    console.log('💾 Attempting to save to DynamoDB table:', DYNAMODB_TABLE_NAME);
    
    if (!DYNAMODB_TABLE_NAME) {
        throw new Error('DynamoDB table name not configured');
    }
    
    const item = {
        id: uuidv4(),
        name: sanitizeInput(data.name.trim()),
        email: data.email.toLowerCase().trim(),
        subject: sanitizeInput(data.subject.trim()),
        message: sanitizeInput(data.message.trim()),
        created_at: new Date().toISOString(),
        ip_address: data.sourceIp || 'unknown',
        user_agent: data.userAgent || 'unknown'
    };
    
    const params = {
        TableName: DYNAMODB_TABLE_NAME,
        Item: item
    };
    
    console.log('📝 DynamoDB put params:', JSON.stringify(params, null, 2));
    
    try {
        await dynamodb.put(params).promise();
        console.log('✅ Successfully saved to DynamoDB');
    } catch (error) {
        console.error('❌ DynamoDB error:', error);
        throw error;
    }
    
    return item;
}

// Send notification email
async function sendNotificationEmail(data) {
    console.log('📧 Attempting to send email via SES');
    console.log('📬 From email:', NOTIFICATION_EMAIL);
    console.log('📮 To email:', NOTIFICATION_EMAIL);
    
    if (!NOTIFICATION_EMAIL) {
        throw new Error('Notification email not configured');
    }
    
    const htmlBody = `
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>New Contact Form Submission</title>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px 8px 0 0; }
                .content { background: #f9f9f9; padding: 20px; border-radius: 0 0 8px 8px; }
                .field { margin-bottom: 15px; }
                .label { font-weight: bold; color: #555; }
                .value { margin-top: 5px; padding: 10px; background: white; border-radius: 4px; border-left: 4px solid #667eea; }
                .footer { margin-top: 20px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #666; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>📧 New Contact Form Submission</h1>
                </div>
                <div class="content">
                    <div class="field">
                        <div class="label">Name:</div>
                        <div class="value">${data.name}</div>
                    </div>
                    <div class="field">
                        <div class="label">Email:</div>
                        <div class="value">${data.email}</div>
                    </div>
                    <div class="field">
                        <div class="label">Subject:</div>
                        <div class="value">${data.subject}</div>
                    </div>
                    <div class="field">
                        <div class="label">Message:</div>
                        <div class="value">${data.message.replace(/\n/g, '<br>')}</div>
                    </div>
                    <div class="footer">
                        <p>Submitted on: ${new Date().toLocaleString()}</p>
                        <p>IP Address: ${data.sourceIp || 'unknown'}</p>
                    </div>
                </div>
            </div>
        </body>
        </html>
    `;
    
    const textBody = `
New Contact Form Submission

Name: ${data.name}
Email: ${data.email}
Subject: ${data.subject}

Message:
${data.message}

Submitted on: ${new Date().toLocaleString()}
IP Address: ${data.sourceIp || 'unknown'}
    `;
    
    const params = {
        Source: NOTIFICATION_EMAIL,
        Destination: {
            ToAddresses: [NOTIFICATION_EMAIL]
        },
        Message: {
            Subject: {
                Data: `New Contact: ${data.subject}`,
                Charset: 'UTF-8'
            },
            Body: {
                Html: {
                    Data: htmlBody,
                    Charset: 'UTF-8'
                },
                Text: {
                    Data: textBody,
                    Charset: 'UTF-8'
                }
            }
        },
        ReplyToAddresses: [data.email]
    };
    
    console.log('📧 SES email params prepared');
    
    try {
        const result = await ses.sendEmail(params).promise();
        console.log('✅ Email sent successfully:', result.MessageId);
    } catch (error) {
        console.error('❌ SES error:', error);
        throw error;
    }
}

// Main Lambda handler
exports.handler = async (event) => {
    console.log('📥 Received event:', JSON.stringify(event, null, 2));
    console.log('🔧 Environment check:', {
        tableName: DYNAMODB_TABLE_NAME,
        notificationEmail: NOTIFICATION_EMAIL ? 'SET' : 'NOT SET',
        region: process.env.AWS_REGION
    });
    
    try {
        // Handle CORS preflight
        if (event.httpMethod === 'OPTIONS') {
            console.log('✅ Handling OPTIONS request');
            return {
                statusCode: 200,
                headers: corsHeaders,
                body: ''
            };
        }
        
        // Only allow POST requests
        if (event.httpMethod !== 'POST') {
            console.log('❌ Method not allowed:', event.httpMethod);
            return {
                statusCode: 405,
                headers: corsHeaders,
                body: JSON.stringify({ error: 'Method not allowed' })
            };
        }
        
        // Parse request body
        let requestBody;
        try {
            console.log('📝 Parsing request body:', event.body);
            requestBody = JSON.parse(event.body);
            console.log('✅ Parsed body:', requestBody);
        } catch (error) {
            console.log('❌ JSON parse error:', error.message);
            return {
                statusCode: 400,
                headers: corsHeaders,
                body: JSON.stringify({ error: 'Invalid JSON in request body' })
            };
        }
        
        // Add request metadata
        requestBody.sourceIp = event.requestContext?.identity?.sourceIp;
        requestBody.userAgent = event.headers?.['User-Agent'];
        
        // Validate input
        const validationErrors = validateInput(requestBody);
        console.log('🔍 Validation result:', validationErrors);
        if (validationErrors.length > 0) {
            console.log('❌ Validation failed:', validationErrors);
            return {
                statusCode: 400,
                headers: corsHeaders,
                body: JSON.stringify({ 
                    error: 'Validation failed', 
                    details: validationErrors 
                })
            };
        }
        
        // Save to database
        console.log('💾 Saving to database...');
        const savedItem = await saveToDatabase(requestBody);
        console.log('✅ Saved to database:', savedItem.id);
        
        // Send notification email
        console.log('📧 Sending notification email...');
        await sendNotificationEmail(requestBody);
        console.log('✅ Notification email sent');
        
        // Return success response
        console.log('🎉 Returning success response');
        return {
            statusCode: 200,
            headers: corsHeaders,
            body: JSON.stringify({
                message: 'Contact form submitted successfully',
                id: savedItem.id,
                timestamp: savedItem.created_at
            })
        };
        
    } catch (error) {
        console.error('💥 Error processing request:', error);
        console.error('📊 Error stack:', error.stack);
        
        return {
            statusCode: 500,
            headers: corsHeaders,
            body: JSON.stringify({
                error: 'Internal server error',
                message: 'Failed to process contact form submission'
            })
        };
    }
};