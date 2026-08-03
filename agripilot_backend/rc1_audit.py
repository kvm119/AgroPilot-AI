import io
import time
from app.main import app
from fastapi.testclient import TestClient

client = TestClient(app, raise_server_exceptions=True)
results = {}

# 1. Health
h = client.get('/api/v1/health')
results['health'] = h.status_code

# 2. Register with unique email
unique_email = f"rc1_{int(time.time())}@agripilot.ai"
r = client.post('/api/v1/auth/register', json={'name':'RC1 Tester','email':unique_email,'password':'RC1Pass123!'})
results['register'] = r.status_code

# 3. Login
l = client.post('/api/v1/auth/login', json={'email':unique_email,'password':'RC1Pass123!'})
results['login'] = l.status_code
token = l.json().get('access_token', '')
headers = {'Authorization': f'Bearer {token}'}

# 4. Profile /me
m = client.get('/api/v1/auth/me', headers=headers)
results['me'] = m.status_code

# 5. Weather
w = client.get('/api/v1/weather', headers=headers)
results['weather'] = w.status_code

# 6. Market
mk = client.get('/api/v1/market', headers=headers)
results['market'] = mk.status_code

# 7. Recommendations
rec = client.get('/api/v1/recommendations', headers=headers)
results['recommendations'] = rec.status_code

# 8. Notifications
notif = client.get('/api/v1/notifications', headers=headers)
results['notifications'] = notif.status_code

# 9. Copilot Chat
chat = client.post('/api/v1/copilot/chat', json={'message':'What fertilizer for Rice?','conversation_id':'rc1_session'}, headers=headers)
results['copilot'] = chat.status_code

# 10. Analytics
ana = client.get('/api/v1/analytics/summary', headers=headers)
results['analytics'] = ana.status_code

# 11. Alerts
alt = client.get('/api/v1/alerts', headers=headers)
results['alerts'] = alt.status_code

# 12. Vision with dummy byte file
dummy_img = io.BytesIO(b"fake_image_bytes_for_testing")
files = {'file': ('test_crop.jpg', dummy_img, 'image/jpeg')}
vis = client.post('/api/v1/vision/analyze', headers=headers, files=files)
results['vision'] = vis.status_code

print('=== AGRI-RC1 API AUDIT REPORT ===')
for k, v in results.items():
    print(f'  {k}: {v}')

all_ok = all([
    results['health'] == 200,
    results['register'] in [200, 201],
    results['login'] == 200,
    results['me'] == 200,
    results['weather'] == 200,
    results['market'] == 200,
    results['recommendations'] == 200,
    results['notifications'] == 200,
    results['copilot'] == 200,
    results['analytics'] == 200,
    results['alerts'] == 200,
    results['vision'] == 200,
])
status = '100% ALL PASS - RELEASE CANDIDATE 1 READY' if all_ok else 'FAILURES DETECTED'
print('\nOVERALL: ' + status)
