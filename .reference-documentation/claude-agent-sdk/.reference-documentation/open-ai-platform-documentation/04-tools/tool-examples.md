# OpenAI Platform - Tool Examples

**Source:** https://platform.openai.com/docs/guides/tools-examples
**Fetched:** 2025-10-11

## Overview

This guide provides complete, ready-to-use examples of tools for common use cases. Each example includes tool definition, implementation, and integration with OpenAI APIs.

---

## E-Commerce Tools

### Product Search

```python
from openai import OpenAI
import json

client = OpenAI()

# Tool definition
product_search_tool = {
    "type": "function",
    "function": {
        "name": "search_products",
        "description": "Search products by name, category, or keywords",
        "parameters": {
            "type": "object",
            "properties": {
                "query": {
                    "type": "string",
                    "description": "Search query"
                },
                "category": {
                    "type": "string",
                    "enum": ["electronics", "clothing", "books", "home"],
                    "description": "Product category filter"
                },
                "max_price": {
                    "type": "number",
                    "description": "Maximum price filter"
                },
                "in_stock_only": {
                    "type": "boolean",
                    "default": true,
                    "description": "Only show in-stock products"
                }
            },
            "required": ["query"]
        }
    }
}

# Implementation
def search_products(query, category=None, max_price=None, in_stock_only=True):
    """Search product database."""
    # Your database query here
    products = Product.objects.filter(name__icontains=query)

    if category:
        products = products.filter(category=category)

    if max_price:
        products = products.filter(price__lte=max_price)

    if in_stock_only:
        products = products.filter(stock__gt=0)

    return [
        {
            "id": p.id,
            "name": p.name,
            "price": p.price,
            "category": p.category,
            "in_stock": p.stock > 0
        }
        for p in products[:10]
    ]

# Usage
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Find me wireless headphones under $200"
        }
    ],
    tools=[product_search_tool]
)
```

### Order Management

```python
# Create Order Tool
create_order_tool = {
    "type": "function",
    "function": {
        "name": "create_order",
        "description": "Create a new order for a customer",
        "parameters": {
            "type": "object",
            "properties": {
                "customer_email": {
                    "type": "string",
                    "description": "Customer email address"
                },
                "items": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "product_id": {"type": "string"},
                            "quantity": {"type": "integer", "minimum": 1}
                        },
                        "required": ["product_id", "quantity"]
                    },
                    "description": "List of items to order"
                },
                "shipping_address": {
                    "type": "object",
                    "properties": {
                        "street": {"type": "string"},
                        "city": {"type": "string"},
                        "state": {"type": "string"},
                        "zip": {"type": "string"},
                        "country": {"type": "string"}
                    },
                    "required": ["street", "city", "state", "zip"]
                }
            },
            "required": ["customer_email", "items", "shipping_address"]
        }
    }
}

def create_order(customer_email, items, shipping_address):
    """Create order in system."""
    # Validate inventory
    for item in items:
        product = Product.objects.get(id=item["product_id"])
        if product.stock < item["quantity"]:
            return {
                "success": False,
                "error": f"Insufficient stock for {product.name}"
            }

    # Create order
    order = Order.objects.create(
        customer_email=customer_email,
        shipping_address=shipping_address,
        total=calculate_total(items)
    )

    for item in items:
        OrderItem.objects.create(
            order=order,
            product_id=item["product_id"],
            quantity=item["quantity"]
        )

    return {
        "success": True,
        "order_id": order.id,
        "total": order.total,
        "estimated_delivery": order.estimated_delivery.isoformat()
    }
```

---

## Customer Support Tools

### Ticket Management

```python
# Create Ticket Tool
create_ticket_tool = {
    "type": "function",
    "function": {
        "name": "create_support_ticket",
        "description": "Create a customer support ticket",
        "parameters": {
            "type": "object",
            "properties": {
                "customer_email": {
                    "type": "string",
                    "description": "Customer email"
                },
                "subject": {
                    "type": "string",
                    "description": "Ticket subject"
                },
                "description": {
                    "type": "string",
                    "description": "Detailed description of the issue"
                },
                "priority": {
                    "type": "string",
                    "enum": ["low", "medium", "high", "urgent"],
                    "description": "Ticket priority"
                },
                "category": {
                    "type": "string",
                    "enum": ["technical", "billing", "account", "general"],
                    "description": "Issue category"
                }
            },
            "required": ["customer_email", "subject", "description"]
        }
    }
}

def create_support_ticket(customer_email, subject, description, priority="medium", category="general"):
    """Create support ticket."""
    ticket = SupportTicket.objects.create(
        customer_email=customer_email,
        subject=subject,
        description=description,
        priority=priority,
        category=category,
        status="open"
    )

    # Send confirmation email
    send_email(
        to=customer_email,
        subject=f"Support Ticket Created: {ticket.id}",
        body=f"Your ticket has been created. Ticket ID: {ticket.id}"
    )

    return {
        "ticket_id": ticket.id,
        "status": "open",
        "expected_response_time": "24 hours"
    }

# Check Ticket Status Tool
check_ticket_tool = {
    "type": "function",
    "function": {
        "name": "check_ticket_status",
        "description": "Check the status of a support ticket",
        "parameters": {
            "type": "object",
            "properties": {
                "ticket_id": {
                    "type": "string",
                    "description": "Support ticket ID"
                }
            },
            "required": ["ticket_id"]
        }
    }
}

def check_ticket_status(ticket_id):
    """Get ticket status."""
    ticket = SupportTicket.objects.get(id=ticket_id)

    return {
        "ticket_id": ticket.id,
        "status": ticket.status,
        "created_at": ticket.created_at.isoformat(),
        "last_updated": ticket.updated_at.isoformat(),
        "assigned_to": ticket.assigned_to_name if ticket.assigned_to else None
    }
```

### Knowledge Base Search

```python
# Search KB Tool
kb_search_tool = {
    "type": "function",
    "function": {
        "name": "search_knowledge_base",
        "description": "Search the customer support knowledge base",
        "parameters": {
            "type": "object",
            "properties": {
                "query": {
                    "type": "string",
                    "description": "Search query"
                },
                "category": {
                    "type": "string",
                    "enum": ["troubleshooting", "how-to", "faq", "policies"],
                    "description": "Knowledge base category"
                }
            },
            "required": ["query"]
        }
    }
}

def search_knowledge_base(query, category=None):
    """Search KB articles."""
    # Use vector search
    query_embedding = client.embeddings.create(
        model="text-embedding-3-large",
        input=query
    ).data[0].embedding

    # Search articles
    articles = Article.objects.all()
    if category:
        articles = articles.filter(category=category)

    results = []
    for article in articles:
        similarity = cosine_similarity(query_embedding, article.embedding)
        if similarity > 0.7:
            results.append({
                "title": article.title,
                "summary": article.summary,
                "url": article.url,
                "relevance": similarity
            })

    return sorted(results, key=lambda x: x["relevance"], reverse=True)[:5]
```

---

## Calendar & Scheduling Tools

### Create Event

```python
create_event_tool = {
    "type": "function",
    "function": {
        "name": "create_calendar_event",
        "description": "Create a new calendar event",
        "parameters": {
            "type": "object",
            "properties": {
                "title": {
                    "type": "string",
                    "description": "Event title"
                },
                "date": {
                    "type": "string",
                    "description": "Event date (YYYY-MM-DD)"
                },
                "start_time": {
                    "type": "string",
                    "description": "Start time (HH:MM)"
                },
                "duration_minutes": {
                    "type": "integer",
                    "description": "Event duration in minutes"
                },
                "location": {
                    "type": "string",
                    "description": "Event location or meeting link"
                },
                "attendees": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "List of attendee email addresses"
                },
                "reminder_minutes": {
                    "type": "integer",
                    "default": 15,
                    "description": "Send reminder X minutes before event"
                }
            },
            "required": ["title", "date", "start_time", "duration_minutes"]
        }
    }
}

def create_calendar_event(title, date, start_time, duration_minutes, location=None, attendees=None, reminder_minutes=15):
    """Create calendar event."""
    from datetime import datetime, timedelta

    # Parse datetime
    start_datetime = datetime.fromisoformat(f"{date}T{start_time}")
    end_datetime = start_datetime + timedelta(minutes=duration_minutes)

    # Create event
    event = CalendarEvent.objects.create(
        title=title,
        start_time=start_datetime,
        end_time=end_datetime,
        location=location or "",
        reminder_minutes=reminder_minutes
    )

    # Add attendees
    if attendees:
        for email in attendees:
            event.attendees.create(email=email)

        # Send invitations
        send_calendar_invites(event, attendees)

    return {
        "event_id": event.id,
        "title": title,
        "start": start_datetime.isoformat(),
        "end": end_datetime.isoformat(),
        "calendar_link": event.get_calendar_link()
    }
```

### Check Availability

```python
check_availability_tool = {
    "type": "function",
    "function": {
        "name": "check_availability",
        "description": "Check if a time slot is available",
        "parameters": {
            "type": "object",
            "properties": {
                "date": {
                    "type": "string",
                    "description": "Date to check (YYYY-MM-DD)"
                },
                "start_time": {
                    "type": "string",
                    "description": "Start time (HH:MM)"
                },
                "duration_minutes": {
                    "type": "integer",
                    "description": "Duration in minutes"
                }
            },
            "required": ["date", "start_time", "duration_minutes"]
        }
    }
}

def check_availability(date, start_time, duration_minutes):
    """Check if time slot is available."""
    from datetime import datetime, timedelta

    start_datetime = datetime.fromisoformat(f"{date}T{start_time}")
    end_datetime = start_datetime + timedelta(minutes=duration_minutes)

    # Check for conflicts
    conflicts = CalendarEvent.objects.filter(
        start_time__lt=end_datetime,
        end_time__gt=start_datetime
    )

    return {
        "available": not conflicts.exists(),
        "conflicts": [
            {
                "title": event.title,
                "start": event.start_time.isoformat(),
                "end": event.end_time.isoformat()
            }
            for event in conflicts
        ]
    }
```

---

## Data Analysis Tools

### Query Database

```python
query_db_tool = {
    "type": "function",
    "function": {
        "name": "query_database",
        "description": "Execute a SQL query on the database (SELECT only)",
        "parameters": {
            "type": "object",
            "properties": {
                "query": {
                    "type": "string",
                    "description": "SQL SELECT query to execute"
                },
                "limit": {
                    "type": "integer",
                    "default": 100,
                    "description": "Maximum number of rows to return"
                }
            },
            "required": ["query"]
        }
    }
}

def query_database(query, limit=100):
    """Execute read-only database query."""
    import sqlite3

    # Validate query (ensure SELECT only)
    if not query.strip().upper().startswith("SELECT"):
        return {"error": "Only SELECT queries are allowed"}

    # Add limit
    if "LIMIT" not in query.upper():
        query = f"{query} LIMIT {limit}"

    try:
        conn = sqlite3.connect("app.db")
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()

        cursor.execute(query)
        rows = cursor.fetchall()

        results = [dict(row) for row in rows]
        conn.close()

        return {
            "success": True,
            "row_count": len(results),
            "data": results
        }

    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }
```

### Export Data

```python
export_data_tool = {
    "type": "function",
    "function": {
        "name": "export_data",
        "description": "Export data to CSV or Excel format",
        "parameters": {
            "type": "object",
            "properties": {
                "data_source": {
                    "type": "string",
                    "enum": ["sales", "users", "products", "orders"],
                    "description": "Data source to export"
                },
                "format": {
                    "type": "string",
                    "enum": ["csv", "xlsx"],
                    "default": "csv",
                    "description": "Export format"
                },
                "date_from": {
                    "type": "string",
                    "description": "Start date (YYYY-MM-DD)"
                },
                "date_to": {
                    "type": "string",
                    "description": "End date (YYYY-MM-DD)"
                }
            },
            "required": ["data_source"]
        }
    }
}

def export_data(data_source, format="csv", date_from=None, date_to=None):
    """Export data to file."""
    import pandas as pd
    from datetime import datetime

    # Query data
    query = f"SELECT * FROM {data_source}"
    if date_from and date_to:
        query += f" WHERE created_at BETWEEN '{date_from}' AND '{date_to}'"

    df = pd.read_sql(query, conn)

    # Export
    filename = f"{data_source}_{datetime.now().strftime('%Y%m%d')}.{format}"

    if format == "csv":
        filepath = f"/tmp/{filename}"
        df.to_csv(filepath, index=False)
    elif format == "xlsx":
        filepath = f"/tmp/{filename}"
        df.to_excel(filepath, index=False)

    return {
        "success": True,
        "filename": filename,
        "filepath": filepath,
        "row_count": len(df)
    }
```

---

## Communication Tools

### Send Email

```python
send_email_tool = {
    "type": "function",
    "function": {
        "name": "send_email",
        "description": "Send an email to one or more recipients",
        "parameters": {
            "type": "object",
            "properties": {
                "to": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Recipient email addresses"
                },
                "subject": {
                    "type": "string",
                    "description": "Email subject"
                },
                "body": {
                    "type": "string",
                    "description": "Email body content"
                },
                "cc": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "CC recipients"
                },
                "attachments": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "File paths for attachments"
                }
            },
            "required": ["to", "subject", "body"]
        }
    }
}

def send_email(to, subject, body, cc=None, attachments=None):
    """Send email via SMTP."""
    import smtplib
    from email.mime.text import MIMEText
    from email.mime.multipart import MIMEMultipart
    from email.mime.base import MIMEBase
    from email import encoders

    msg = MIMEMultipart()
    msg['From'] = os.environ["EMAIL_FROM"]
    msg['To'] = ", ".join(to)
    msg['Subject'] = subject

    if cc:
        msg['Cc'] = ", ".join(cc)

    msg.attach(MIMEText(body, 'plain'))

    # Add attachments
    if attachments:
        for filepath in attachments:
            with open(filepath, "rb") as f:
                part = MIMEBase('application', 'octet-stream')
                part.set_payload(f.read())
                encoders.encode_base64(part)
                part.add_header(
                    'Content-Disposition',
                    f'attachment; filename= {os.path.basename(filepath)}'
                )
                msg.attach(part)

    # Send
    with smtplib.SMTP(os.environ["SMTP_HOST"], int(os.environ["SMTP_PORT"])) as server:
        server.starttls()
        server.login(os.environ["SMTP_USER"], os.environ["SMTP_PASSWORD"])
        server.send_message(msg)

    return {
        "success": True,
        "sent_to": to,
        "subject": subject
    }
```

### Send SMS

```python
send_sms_tool = {
    "type": "function",
    "function": {
        "name": "send_sms",
        "description": "Send an SMS text message",
        "parameters": {
            "type": "object",
            "properties": {
                "to": {
                    "type": "string",
                    "description": "Phone number (E.164 format)"
                },
                "message": {
                    "type": "string",
                    "description": "SMS message content (max 160 characters)"
                }
            },
            "required": ["to", "message"]
        }
    }
}

def send_sms(to, message):
    """Send SMS via Twilio."""
    from twilio.rest import Client

    # Validate message length
    if len(message) > 160:
        return {
            "success": False,
            "error": "Message exceeds 160 character limit"
        }

    client = Client(
        os.environ["TWILIO_ACCOUNT_SID"],
        os.environ["TWILIO_AUTH_TOKEN"]
    )

    sms = client.messages.create(
        to=to,
        from_=os.environ["TWILIO_PHONE_NUMBER"],
        body=message
    )

    return {
        "success": True,
        "message_sid": sms.sid,
        "status": sms.status
    }
```

---

## File Management Tools

### Upload File

```python
upload_file_tool = {
    "type": "function",
    "function": {
        "name": "upload_file",
        "description": "Upload a file to cloud storage",
        "parameters": {
            "type": "object",
            "properties": {
                "file_path": {
                    "type": "string",
                    "description": "Local file path"
                },
                "destination": {
                    "type": "string",
                    "description": "Destination path in storage"
                },
                "public": {
                    "type": "boolean",
                    "default": false,
                    "description": "Make file publicly accessible"
                }
            },
            "required": ["file_path", "destination"]
        }
    }
}

def upload_file(file_path, destination, public=False):
    """Upload file to S3."""
    import boto3

    s3 = boto3.client('s3')

    bucket = os.environ["S3_BUCKET"]

    # Upload
    s3.upload_file(
        file_path,
        bucket,
        destination,
        ExtraArgs={'ACL': 'public-read'} if public else {}
    )

    # Generate URL
    if public:
        url = f"https://{bucket}.s3.amazonaws.com/{destination}"
    else:
        url = s3.generate_presigned_url(
            'get_object',
            Params={'Bucket': bucket, 'Key': destination},
            ExpiresIn=3600
        )

    return {
        "success": True,
        "destination": destination,
        "url": url,
        "public": public
    }
```

---

## Complete Agent Example

### Multi-Tool Shopping Assistant

```python
from openai_agents import Agent, Runner

# All tools
shopping_tools = [
    product_search_tool,
    create_order_tool,
    check_ticket_tool,
    create_ticket_tool,
    kb_search_tool
]

# Tool implementations
tool_implementations = {
    "search_products": search_products,
    "create_order": create_order,
    "create_support_ticket": create_support_ticket,
    "check_ticket_status": check_ticket_status,
    "search_knowledge_base": search_knowledge_base
}

# Create agent
shopping_agent = Agent(
    name="ShoppingAssistant",
    instructions="""
You are a helpful shopping assistant. You can:
- Help customers find products
- Create orders
- Answer questions using the knowledge base
- Create and check support tickets

Always be polite and helpful. Confirm order details before creating an order.
""",
    model="gpt-5",
    tools=shopping_tools
)

# Run agent
runner = Runner()

response = runner.run(
    agent=shopping_agent,
    messages=[
        {
            "role": "user",
            "content": "I'm looking for wireless headphones under $150"
        }
    ],
    tool_implementations=tool_implementations
)

print(response.messages[-1].content)
```

---

## Additional Resources

- **Tool Design Guide**: https://platform.openai.com/docs/guides/tools
- **Function Calling**: https://platform.openai.com/docs/guides/function-calling
- **More Examples**: https://cookbook.openai.com/examples/tools

---

**Previous**: [Custom Tools ←](./custom-tools.md)
