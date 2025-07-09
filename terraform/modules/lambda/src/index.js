const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const ses = new AWS.SES();

exports.handler = async (event) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    const corsHeaders = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'POST, OPTIONS'
    };
    
    try {
        // Handle OPTIONS request for CORS
        if (event.httpMethod === 'OPTIONS') {
            return {
                statusCode: 200,
                headers: corsHeaders,
                body: JSON.stringify({ message: 'OK' })
            };
        }
        
        // Parse the request body
        let body;
        try {
            body = JSON.parse(event.body || '{}');
        } catch (parseError) {
            console.error('JSON parse error:', parseError);
            return {
                statusCode: 400,
                headers: corsHeaders,
                body: JSON.stringify({
                    error: 'Invalid JSON in request body'
                })
            };
        }
        
        const { name, email, subject, message } = body;
        
        // Validate required fields
        if (!name || !email || !subject || !message) {
            return {
                statusCode: 400,
                headers: corsHeaders,
                body: JSON.stringify({
                    error: 'All fields are required: name, email, subject, message'
                })
            };
        }
        
        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return {
                statusCode: 400,
                headers: corsHeaders,
                body: JSON.stringify({
                    error: 'Invalid email format'
                })
            };
        }
        
        // Create unique ID and timestamp
        const id = uuidv4();
        const timestamp = Date.now();
        
        // Check if environment variables are set
        if (!process.env.DYNAMODB_TABLE) {
            console.error('DYNAMODB_TABLE environment variable not set');
            return {
                statusCode: 500,
                headers: corsHeaders,
                body: JSON.stringify({
                    error: 'Server configuration error'
                })
            };
        }
        
        // Store in DynamoDB
        const dynamoParams = {
            TableName: process.env.DYNAMODB_TABLE,
            Item: {
                id: id,
                timestamp: timestamp,
                name: name,
                email: email,
                subject: subject,
                message: message,
                created_at: new Date().toISOString()
            }
        };
        
        console.log('Storing in DynamoDB with params:', JSON.stringify(dynamoParams, null, 2));
        await dynamodb.put(dynamoParams).promise();
        console.log('Successfully stored in DynamoDB');
        
        // Send notification email via SES (only if SES_SOURCE_EMAIL is configured)
        if (process.env.SES_SOURCE_EMAIL) {
            try {
                const sesParams = {
                    Destination: {
                        ToAddresses: [process.env.SES_SOURCE_EMAIL]
                    },
                    Message: {
                        Body: {
                            Html: {
                                Charset: 'UTF-8',
                                Data: `
                                    <h2>New Contact Form Submission</h2>
                                    <p><strong>Name:</strong> ${name}</p>
                                    <p><strong>Email:</strong> ${email}</p>
                                    <p><strong>Subject:</strong> ${subject}</p>
                                    <p><strong>Message:</strong></p>
                                    <p>${message.replace(/\n/g, '<br>')}</p>
                                    <p><strong>Timestamp:</strong> ${new Date(timestamp).toLocaleString()}</p>
                                `
                            },
                            Text: {
                                Charset: 'UTF-8',
                                Data: `
                                    New Contact Form Submission
                                    
                                    Name: ${name}
                                    Email: ${email}
                                    Subject: ${subject}
                                    Message: ${message}
                                    Timestamp: ${new Date(timestamp).toLocaleString()}
                                `
                            }
                        },
                        Subject: {
                            Charset: 'UTF-8',
                            Data: `New Contact Form: ${subject}`
                        }
                    },
                    Source: process.env.SES_SOURCE_EMAIL
                };
                
                await ses.sendEmail(sesParams).promise();
                console.log('Successfully sent notification email');
            } catch (sesError) {
                console.error('SES Error (non-fatal):', sesError);
                // Don't fail the request if email fails
            }
        } else {
            console.log('SES_SOURCE_EMAIL not configured, skipping email notification');
        }
        
        return {
            statusCode: 200,
            headers: corsHeaders,
            body: JSON.stringify({
                message: 'Contact form submitted successfully',
                id: id
            })
        };
        
    } catch (error) {
        console.error('Error:', error);
        
        return {
            statusCode: 500,
            headers: corsHeaders,
            body: JSON.stringify({
                error: 'Internal server error',
                details: error.message
            })
        };
    }
};