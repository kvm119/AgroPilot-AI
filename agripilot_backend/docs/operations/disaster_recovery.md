# Disaster Recovery Plan

## 1. Database Corruption
**Objective**: Restore PostgreSQL database from S3 backups with < 1 hour of data loss.
**Procedure**:
1. Take the API offline to prevent bad writes: `docker-compose stop api`
2. Pull latest backup: `aws s3 cp s3://agripilot-backups/latest.sql .`
3. Execute restore script: `python scripts/restore_database.py latest.sql`
4. Bring API online: `docker-compose start api`

## 2. Redis Failure (Cache Stampede)
**Objective**: Prevent database overload if Redis crashes.
**Procedure**:
1. The `RedisManager` is designed to gracefully fallback to direct DB calls if the connection drops.
2. Restart Redis container: `docker-compose restart redis`
3. The L2 cache will self-warm over the next 15 minutes as traffic arrives.

## 3. Worker Node Failure
**Objective**: Resume processing background analytics.
**Procedure**:
1. Celery tasks are configured with `acks_late=True`. If a worker dies mid-task, the message remains in the Redis queue.
2. Spin up a new worker node. The task will be automatically consumed and retried.
