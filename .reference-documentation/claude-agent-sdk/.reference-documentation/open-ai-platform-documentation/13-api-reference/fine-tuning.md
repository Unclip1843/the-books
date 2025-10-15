# OpenAI Platform - Fine-tuning API Reference

**Source:** https://platform.openai.com/docs/api-reference/fine-tuning
**Fetched:** 2025-10-11

## Create Fine-tuning Job

**POST** `/v1/fine_tuning/jobs`

```python
client.fine_tuning.jobs.create(
    training_file="file-abc123",
    model="gpt-4o-mini-2025-07-18"
)
```

## List Jobs

**GET** `/v1/fine_tuning/jobs`

```python
client.fine_tuning.jobs.list()
```

## Retrieve Job

**GET** `/v1/fine_tuning/jobs/{fine_tuning_job_id}`

```python
client.fine_tuning.jobs.retrieve("ftjob-abc123")
```

## Cancel Job

**POST** `/v1/fine_tuning/jobs/{fine_tuning_job_id}/cancel`

```python
client.fine_tuning.jobs.cancel("ftjob-abc123")
```

---

**Source:** https://platform.openai.com/docs/api-reference/fine-tuning
