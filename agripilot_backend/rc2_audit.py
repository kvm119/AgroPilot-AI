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
unique_email = f"rc2_{int(time.time())}@agripilot.ai"
r = client.post('/api/v1/auth/register', json={'name':'RC2 Tester','email':unique_email,'password':'RC2Pass123!'})
results['register'] = r.status_code

# 3. Login
l = client.post('/api/v1/auth/login', json={'email':unique_email,'password':'RC2Pass123!'})
results['login'] = l.status_code
token = l.json().get('access_token', '')
headers = {'Authorization': f'Bearer {token}'}

# 4. Profile /me
m = client.get('/api/v1/auth/me', headers=headers)
results['me'] = m.status_code

# 5. Weather
w = client.get('/api/v1/weather', headers=headers)
results['weather'] = w.status_code

# 6. Market Summary
mk = client.get('/api/v1/market', headers=headers)
results['market_summary'] = mk.status_code

# 7. NEW Indian Market Analysis
mka = client.get('/api/v1/market/analysis', headers=headers)
results['market_analysis'] = mka.status_code
if mka.status_code == 200:
    results['categories_count'] = len(mka.json().get('categories', []))
    results['commodities_count'] = len(mka.json().get('commodities', []))

# 8. Recommendations
rec = client.get('/api/v1/recommendations', headers=headers)
results['recommendations'] = rec.status_code

# 9. Notifications
notif = client.get('/api/v1/notifications', headers=headers)
results['notifications'] = notif.status_code

# 10. Copilot Chat
chat = client.post('/api/v1/copilot/chat', json={'message':'What is the market price of Rice in Guntur?','conversation_id':'rc2_session'}, headers=headers)
results['copilot'] = chat.status_code

# 11. Analytics
ana = client.get('/api/v1/analytics/summary', headers=headers)
results['analytics'] = ana.status_code

# 12. Alerts
alt = client.get('/api/v1/alerts', headers=headers)
results['alerts'] = alt.status_code

# 13. Vision Multipart Image Upload
dummy_img = io.BytesIO(b"fake_crop_leaf_image_bytes")
files = {'file': ('test_leaf.jpg', dummy_img, 'image/jpeg')}
vis = client.post('/api/v1/vision/analyze', headers=headers, files=files)
results['vision'] = vis.status_code

print('=== AGRI-RC2 SYSTEM AUDIT REPORT ===')
for k, v in results.items():
    print(f'  {k}: {v}')

all_ok = all([
    results['health'] == 200,
    results['register'] in [200, 201],
    results['login'] == 200,
    results['me'] == 200,
    results['weather'] == 200,
    results['market_summary'] == 200,
    results['market_analysis'] == 200,
    results['recommendations'] == 200,
    results['notifications'] == 200,
    results['copilot'] == 200,
    results['analytics'] == 200,
    results['alerts'] == 200,
    results['vision'] == 200,
])
status = '100% ALL PASS - AGRI-RC2 READY' if all_ok else 'FAILURES DETECTED'
print('\nOVERALL: ' + status)
