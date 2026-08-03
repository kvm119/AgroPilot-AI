import uuid
from contextvars import ContextVar

# Thread-safe global variables for async request contexts
trace_id_ctx: ContextVar[str] = ContextVar("trace_id", default="unknown")
request_id_ctx: ContextVar[str] = ContextVar("request_id", default="unknown")
user_id_ctx: ContextVar[str] = ContextVar("user_id", default="anonymous")

def generate_trace_id() -> str:
    return uuid.uuid4().hex

def generate_request_id() -> str:
    return uuid.uuid4().hex[:8]

def get_trace_id() -> str:
    return trace_id_ctx.get()

def get_request_id() -> str:
    return request_id_ctx.get()
