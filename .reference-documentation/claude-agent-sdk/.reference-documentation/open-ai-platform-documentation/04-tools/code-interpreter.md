# OpenAI Platform - Code Interpreter

**Source:** https://platform.openai.com/docs/guides/tools-code-interpreter
**Fetched:** 2025-10-11

## Overview

Code Interpreter enables agents to write and execute Python code in a secure, sandboxed environment. It supports data analysis, visualization, file processing, mathematical calculations, and iterative problem-solving.

**Key Features:**
- Secure Python sandbox
- File upload and processing
- Data visualization
- Mathematical computations
- Iterative code execution with debugging
- File generation and download

**Pricing**: $0.03 per session (1 hour)

---

## Quick Start

### Basic Usage

```python
from openai import OpenAI

client = OpenAI()

# Enable code interpreter
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Calculate the first 20 Fibonacci numbers and plot them"
        }
    ],
    tools=[{"type": "code_interpreter"}]
)

print(response.choices[0].message.content)
```

### With File Upload

```python
# Upload file
file = client.files.create(
    file=open("sales_data.csv", "rb"),
    purpose="assistants"
)

# Analyze file with code interpreter
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Analyze this sales data and create a revenue trend chart"
        }
    ],
    tools=[
        {
            "type": "code_interpreter",
            "container": {
                "type": "auto",
                "file_ids": [file.id]
            }
        }
    ]
)
```

---

## How It Works

### Code Execution Flow

1. **Request**: User sends message requesting code execution
2. **Code Generation**: Model writes Python code
3. **Execution**: Code runs in secure sandbox
4. **Results**: Output returned to model
5. **Iteration**: Model can debug and retry if needed
6. **Response**: Final answer with results

```python
# Example: Model iterates to fix errors
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Read data.csv and calculate the average of the 'sales' column"
        }
    ],
    tools=[
        {
            "type": "code_interpreter",
            "container": {
                "type": "auto",
                "file_ids": [file.id]
            }
        }
    ]
)

# Model may:
# 1. Try: pd.read_csv('data.csv')
# 2. Get error: File not found
# 3. Retry: pd.read_csv('/mnt/data/data.csv')  # Correct path
# 4. Success: Return average
```

---

## Container Management

### What is a Container?

A container is a fully sandboxed virtual machine where Python code executes. Each container:
- Has isolated filesystem
- Persists for 1 hour (idle timeout: 20 minutes)
- Costs $0.03 per session
- Can store uploaded files and generated files

### Auto Container Mode

```python
# Automatic container creation/reuse
response = client.responses.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Analyze my data"}],
    tools=[
        {
            "type": "code_interpreter",
            "container": {
                "type": "auto",
                "file_ids": [file1.id, file2.id]
            }
        }
    ]
)

# Container is created automatically
# Files are uploaded to /mnt/data/
# Container persists for follow-up requests
```

### Manual Container Management

```python
# Create container explicitly
container = client.containers.create(
    file_ids=[file1.id, file2.id]
)

# Use in multiple requests
response1 = client.responses.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Load the data"}],
    tools=[
        {
            "type": "code_interpreter",
            "container": {
                "type": "existing",
                "container_id": container.id
            }
        }
    ]
)

# Files and variables persist
response2 = client.responses.create(
    model="gpt-5",
    messages=[
        response1.choices[0].message,  # Include previous context
        {"role": "user", "content": "Now create a chart"}
    ],
    tools=[
        {
            "type": "code_interpreter",
            "container": {
                "type": "existing",
                "container_id": container.id
            }
        }
    ]
)
```

### Container Lifecycle

```python
# Check container status
container = client.containers.retrieve(container.id)
print(f"Status: {container.status}")  # active, idle, expired

# Container expires after 1 hour
# Idle timeout: 20 minutes

# Clean up
client.containers.delete(container.id)
```

---

## File Handling

### Supported File Types

**Data Files:**
- CSV, TSV, Excel (.xlsx, .xls)
- JSON, JSONL
- XML
- SQLite databases
- Parquet, HDF5

**Image Files:**
- PNG, JPEG, GIF
- SVG
- WebP

**Document Files:**
- PDF (text extraction)
- TXT, Markdown
- HTML

**Other:**
- ZIP archives
- Pickle files
- NumPy arrays (.npy)

### Upload Files

```python
# Upload single file
file = client.files.create(
    file=open("data.csv", "rb"),
    purpose="assistants"
)

# Upload multiple files
files = []
for filename in ["data1.csv", "data2.csv", "data3.csv"]:
    file = client.files.create(
        file=open(filename, "rb"),
        purpose="assistants"
    )
    files.append(file.id)

# Use in code interpreter
response = client.responses.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Merge these CSV files"}],
    tools=[
        {
            "type": "code_interpreter",
            "container": {
                "type": "auto",
                "file_ids": files
            }
        }
    ]
)
```

### Access Files in Code

```python
# Files are available at /mnt/data/ in the container
import pandas as pd

# Read uploaded file
df = pd.read_csv('/mnt/data/data.csv')

# List uploaded files
import os
files = os.listdir('/mnt/data/')
print(files)  # ['data.csv']
```

### Generate and Download Files

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Create a visualization of this data and save it as chart.png"
        }
    ],
    tools=[
        {
            "type": "code_interpreter",
            "container": {
                "type": "auto",
                "file_ids": [file.id]
            }
        }
    ]
)

# Check for generated files
if response.tool_outputs:
    for output in response.tool_outputs:
        if output.files:
            for file in output.files:
                print(f"Generated file: {file.file_id}")

                # Download file
                file_data = client.files.content(file.file_id)
                with open(f"downloaded_{file.filename}", "wb") as f:
                    f.write(file_data.read())
```

---

## Data Analysis Examples

### CSV Analysis

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": """
Analyze sales_data.csv:
1. Calculate total revenue
2. Find top 5 products by sales
3. Create a monthly revenue trend chart
4. Identify any anomalies
"""
        }
    ],
    tools=[
        {
            "type": "code_interpreter",
            "container": {
                "type": "auto",
                "file_ids": [file.id]
            }
        }
    ]
)
```

**What the model might do:**
```python
import pandas as pd
import matplotlib.pyplot as plt

# Load data
df = pd.read_csv('/mnt/data/sales_data.csv')

# 1. Total revenue
total_revenue = df['revenue'].sum()

# 2. Top 5 products
top_products = df.groupby('product')['revenue'].sum().nlargest(5)

# 3. Monthly trend
df['date'] = pd.to_datetime(df['date'])
monthly = df.groupby(df['date'].dt.to_period('M'))['revenue'].sum()
monthly.plot(kind='line', title='Monthly Revenue Trend')
plt.savefig('/mnt/data/trend.png')

# 4. Detect anomalies
mean = df['revenue'].mean()
std = df['revenue'].std()
anomalies = df[abs(df['revenue'] - mean) > 3 * std]

print(f"Total Revenue: ${total_revenue:,.2f}")
print(f"Top Products:\n{top_products}")
print(f"Anomalies: {len(anomalies)}")
```

### Statistical Analysis

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Perform statistical analysis on user_metrics.csv: mean, median, std dev, correlations, and hypothesis testing"
        }
    ],
    tools=[
        {
            "type": "code_interpreter",
            "container": {
                "type": "auto",
                "file_ids": [file.id]
            }
        }
    ]
)
```

### Image Processing

```python
# Upload image
image_file = client.files.create(
    file=open("photo.jpg", "rb"),
    purpose="assistants"
)

response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Resize this image to 800x600, apply a blur filter, and save it"
        }
    ],
    tools=[
        {
            "type": "code_interpreter",
            "container": {
                "type": "auto",
                "file_ids": [image_file.id]
            }
        }
    ]
)
```

---

## Visualization Examples

### Charts and Graphs

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": """
Create visualizations from this data:
1. Bar chart of sales by category
2. Pie chart of market share
3. Scatter plot of price vs. quantity
4. Box plot of revenue distribution
"""
        }
    ],
    tools=[
        {
            "type": "code_interpreter",
            "container": {
                "type": "auto",
                "file_ids": [file.id]
            }
        }
    ]
)
```

**Libraries Available:**
- **Matplotlib**: Basic plotting
- **Seaborn**: Statistical visualizations
- **Plotly**: Interactive charts
- **Pandas plotting**: Quick data viz

### Interactive Visualizations

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Create an interactive dashboard with plotly showing sales trends and product performance"
        }
    ],
    tools=[{"type": "code_interpreter"}]
)

# Model generates:
import plotly.graph_objects as go
from plotly.subplots import make_subplots

fig = make_subplots(
    rows=2, cols=1,
    subplot_titles=('Sales Trend', 'Product Performance')
)

# ... plotting code ...

fig.write_html('/mnt/data/dashboard.html')
```

---

## Mathematical Computations

### Numerical Calculations

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": """
Solve these mathematical problems:
1. Calculate compound interest: principal=$10000, rate=5%, years=10
2. Find roots of polynomial: x^3 - 6x^2 + 11x - 6 = 0
3. Integrate: ∫(x^2 + 2x + 1)dx from 0 to 5
4. Solve system of equations:
   2x + 3y = 12
   x - y = 1
"""
        }
    ],
    tools=[{"type": "code_interpreter"}]
)
```

**Libraries Available:**
- **NumPy**: Numerical computing
- **SciPy**: Scientific computing
- **SymPy**: Symbolic mathematics
- **Math**: Standard math functions

### Scientific Computing

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": "Simulate a random walk with 10000 steps and plot the results"
        }
    ],
    tools=[{"type": "code_interpreter"}]
)
```

---

## Machine Learning

### Data Preprocessing

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": """
Prepare this dataset for ML:
1. Handle missing values
2. Encode categorical variables
3. Normalize numerical features
4. Split into train/test sets
5. Show preprocessing summary
"""
        }
    ],
    tools=[
        {
            "type": "code_interpreter",
            "container": {
                "type": "auto",
                "file_ids": [file.id]
            }
        }
    ]
)
```

### Simple Models

```python
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": """
Train a simple linear regression model to predict house prices.
Show model performance metrics and feature importance.
"""
        }
    ],
    tools=[
        {
            "type": "code_interpreter",
            "container": {
                "type": "auto",
                "file_ids": [file.id]
            }
        }
    ]
)
```

**Available Libraries:**
- **Scikit-learn**: ML algorithms
- **Pandas**: Data manipulation
- **NumPy**: Numerical operations

---

## Best Practices

### 1. Clear Instructions

```python
# ✅ Good: Specific instructions
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": """
Analyze sales_data.csv:
- Calculate total revenue and average order value
- Create a bar chart showing revenue by product category
- Save the chart as 'revenue_by_category.png'
- Show top 10 products by revenue in a table
"""
        }
    ],
    tools=[{"type": "code_interpreter"}]
)

# ❌ Poor: Vague request
response = client.responses.create(
    model="gpt-5",
    messages=[
        {"role": "user", "content": "Analyze this data"}
    ],
    tools=[{"type": "code_interpreter"}]
)
```

### 2. Reuse Containers for Multi-Step Analysis

```python
# Create container once
container = client.containers.create(file_ids=[file.id])

# Step 1: Load and explore
response1 = client.responses.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Load data and show summary statistics"}],
    tools=[
        {
            "type": "code_interpreter",
            "container": {"type": "existing", "container_id": container.id}
        }
    ]
)

# Step 2: Create visualization (data already loaded)
response2 = client.responses.create(
    model="gpt-5",
    messages=[
        response1.choices[0].message,
        {"role": "user", "content": "Now create a correlation heatmap"}
    ],
    tools=[
        {
            "type": "code_interpreter",
            "container": {"type": "existing", "container_id": container.id}
        }
    ]
)
```

### 3. Handle Large Files Efficiently

```python
# For large files, use chunking or sampling
response = client.responses.create(
    model="gpt-5",
    messages=[
        {
            "role": "user",
            "content": """
This CSV has 10M rows. Sample 10,000 random rows for analysis.
Show: distribution of key metrics, identify outliers, create summary visualizations.
"""
        }
    ],
    tools=[
        {
            "type": "code_interpreter",
            "container": {
                "type": "auto",
                "file_ids": [large_file.id]
            }
        }
    ]
)
```

### 4. Error Handling

```python
try:
    response = client.responses.create(
        model="gpt-5",
        messages=[{"role": "user", "content": "Analyze data.csv"}],
        tools=[{"type": "code_interpreter"}]
    )

    # Check for errors in code execution
    if response.tool_outputs:
        for output in response.tool_outputs:
            if output.error:
                print(f"Code execution error: {output.error}")

except Exception as e:
    print(f"API error: {e}")
```

---

## Limitations

### Environment Constraints

- **Timeout**: Code execution timeout (typically 60 seconds)
- **Memory**: Limited RAM (varies by container)
- **Storage**: Limited disk space
- **No network**: Cannot make external API calls
- **No persistence**: Containers expire after 1 hour

### Library Restrictions

**Available:**
- Standard library
- Data: NumPy, Pandas, SciPy
- Viz: Matplotlib, Seaborn, Plotly
- ML: Scikit-learn
- Image: PIL, OpenCV

**Not Available:**
- TensorFlow, PyTorch (too large)
- Custom pip packages
- System commands
- Network libraries

### Workarounds

```python
# ❌ Cannot do this
# import requests  # Not available
# data = requests.get('https://api.example.com/data')

# ✅ Instead: Upload data as file
file = client.files.create(
    file=open("api_data.json", "rb"),
    purpose="assistants"
)
```

---

## Pricing and Billing

### Cost Structure

- **Base**: $0.03 per container session
- **Session duration**: 1 hour
- **Idle timeout**: 20 minutes

### Cost Optimization

```python
# Use auto mode for single requests
# Creates one container per conversation

# ✅ Cost-effective
response = client.responses.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Analyze data"}],
    tools=[
        {
            "type": "code_interpreter",
            "container": {"type": "auto"}
        }
    ]
)

# Multiple requests in same container = same session cost
response2 = client.responses.create(
    model="gpt-5",
    messages=[
        response.choices[0].message,
        {"role": "user", "content": "Create a chart"}
    ],
    tools=[
        {
            "type": "code_interpreter",
            "container": {"type": "auto"}
        }
    ]
)
# Still one container, one session fee
```

---

## Additional Resources

- **Code Interpreter Docs**: https://platform.openai.com/docs/guides/tools-code-interpreter
- **Examples**: https://cookbook.openai.com/examples/code_interpreter
- **File Upload Guide**: https://platform.openai.com/docs/api-reference/files

---

**Next**: [File Search →](./file-search.md)
