# Hướng Dẫn Triển Khai - Thiết Lập Từng Bước

## Giai Đoạn 1: Thiết Lập Backend (1-2 ngày)

### Bước 1.1: Khởi Tạo Dự Án Backend
```bash
mkdir backend
cd backend
npm init -y
npm install express @supabase/supabase-js jsonwebtoken bcryptjs joi cors dotenv axios uuid

mkdir -p src/{config,middleware,controllers,services,routes,models,utils}
mkdir migrations
```

### Bước 1.2: Thiết Lập Biến Môi Trường
Tạo `backend/.env`:
```
NODE_ENV=development
PORT=5000

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRY=24h

CORS_ORIGIN=http://localhost:3000

DEEZER_API_BASE=https://api.deezer.com

MAX_FILE_SIZE=52428800
ALLOWED_MIME_TYPES=audio/mpeg,audio/wav,audio/ogg
```

### Bước 1.3: Tạo Lược Đồ Cơ Sở Dữ Liệu trong Supabase
1. Đi đến Bảng Điều Khiển Supabase
2. Điều Hướng đến SQL Editor
3. Chạy mỗi di chuyển từ `DATABASE_SCHEMA.md` theo thứ tự:
   - Tạo bảng người dùng
   - Tạo bảng bài hát
   - Tạo bảng danh sách phát
   - Tạo bảng playlist_songs
   - Tạo bảng yêu thích
   - Tạo bảng user_uploads
4. Bật RLS trên tất cả các bảng
5. Tạo tất cả các chính sách (xem DATABASE_SCHEMA.md)

### Bước 1.4: Thiết Lập Supabase Storage
1. Đi đến phần Storage
2. Tạo bucket mới: `uploads` (làm cho nó riêng tư)
3. Tạo thư mục con:
   - `uploads/mp3` - cho tệp MP3
   - `uploads/images` - cho ảnh bìa
4. Đặt chính sách CORS cho bucket

### Bước 1.5: Tạo Tệp Cấu Hình Lõi

**src/config/supabase.js:**
```javascript
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabaseClient = createClient(supabaseUrl, supabaseKey);
const supabaseAdmin = createClient(supabaseUrl, supabaseServiceRoleKey);

module.exports = { supabaseClient, supabaseAdmin };
```

**src/config/environment.js:**
```javascript
module.exports = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: process.env.PORT || 5000,
  jwtSecret: process.env.JWT_SECRET,
  jwtExpiry: process.env.JWT_EXPIRY || '24h',
  corsOrigin: process.env.CORS_ORIGIN.split(','),
  maxFileSize: parseInt(process.env.MAX_FILE_SIZE),
  allowedMimeTypes: process.env.ALLOWED_MIME_TYPES.split(','),
};
```

### Bước 1.6: Tạo Tệp Middleware

**src/middleware/auth.js:**
- Xác minh JWT tokens
- Trích xuất người dùng từ token
- Thêm người dùng vào đối tượng yêu cầu
- Xử lý lỗi xác thực

**src/middleware/errorHandler.js:**
- Bắt tất cả lỗi
- Định dạng phản hồi lỗi
- Ghi nhật ký lỗi
- Trả về mã trạng thái thích hợp

### Bước 1.7: Tạo Tệp Điều Khiển

**src/controllers/authController.js:**
- `register(req, res)` - Đăng ký người dùng
- `login(req, res)` - Đăng nhập người dùng
- `refresh(req, res)` - Làm mới token
- `getCurrentUser(req, res)` - Lấy người dùng hiện tại

**src/controllers/songController.js:**
- `getSongs(req, res)` - Danh sách tất cả bài hát
- `getSongById(req, res)` - Lấy bài hát theo ID
- `searchSongs(req, res)` - Tìm kiếm bài hát
- `uploadSong(req, res)` - Tải lên bài hát mới
- `streamSong(req, res)` - Phát bài hát

### Bước 1.8: Tạo Dịch Vụ

**src/services/authService.js:**
- Xác thực người dùng
- Hash mật khẩu
- Tạo JWT token
- Xác minh token

**src/services/songService.js:**
- Truy vấn bài hát từ Supabase
- Phân trang kết quả
- Tìm kiếm bài hát
- Tạo bài hát mới

**src/services/deezerService.js:**
- Tìm kiếm API Deezer
- Lấy thông tin bài hát
- Xử lý lỗi API

### Bước 1.9: Tạo Tuyến API

**src/routes/auth.js:**
```javascript
router.post('/register', authController.register);
router.post('/login', authController.login);
router.get('/me', auth, authController.getCurrentUser);
router.post('/refresh', authController.refresh);
```

**src/routes/songs.js:**
```javascript
router.get('/', songController.getSongs);
router.get('/:id', songController.getSongById);
router.get('/search', songController.searchSongs);
router.post('/', auth, songController.uploadSong);
router.get('/stream/:id', songController.streamSong);
```

### Bước 1.10: Tạo Server.js Chính

```javascript
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const routes = require('./routes');

dotenv.config();

const app = express();

// Middleware
app.use(cors({ origin: process.env.CORS_ORIGIN }));
app.use(express.json());

// Routes
app.use('/api', routes);

// Error Handler
app.use(errorHandler);

// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});
```

## Giai Đoạn 2: Thiết Lập Frontend (1-2 ngày)

### Bước 2.1: Khởi Tạo Dự Án Next.js
```bash
npx create-next-app@latest frontend --typescript --tailwind
cd frontend
npm install @supabase/supabase-js swr react-h5-audio-player
```

### Bước 2.2: Thiết Lập Biến Môi Trường
Tạo `frontend/.env.local`:
```
NEXT_PUBLIC_API_URL=http://localhost:5000
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_KEY=your-anon-key
```

### Bước 2.3: Tạo Nhà Cung Cấp Xác Thực

**app/providers.tsx:**
```typescript
'use client';
import { createContext, useState, useEffect } from 'react';

export const AuthContext = createContext({});

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Kiểm tra xem người dùng có đăng nhập không
    const token = localStorage.getItem('token');
    if (token) {
      // Xác minh token với backend
    }
    setLoading(false);
  }, []);

  return (
    <AuthContext.Provider value={{ user, loading }}>
      {children}
    </AuthContext.Provider>
  );
}
```

### Bước 2.4: Tạo Bố Cục Chính

**app/layout.tsx:**
```typescript
import { AuthProvider } from './providers';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}
```

### Bước 2.5: Tạo Khách Hàng API

**lib/api.ts:**
```typescript
const API_URL = process.env.NEXT_PUBLIC_API_URL;

export const api = {
  async request(endpoint: string, options = {}) {
    const token = localStorage.getItem('token');
    const headers = {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
    };

    const response = await fetch(`${API_URL}${endpoint}`, {
      ...options,
      headers,
    });

    return response.json();
  },

  songs: {
    getAll: () => api.request('/api/songs'),
    search: (q: string) => api.request(`/api/songs/search?q=${q}`),
  },

  auth: {
    login: (email: string, password: string) =>
      api.request('/api/auth/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      }),
  },
};
```

### Bước 2.6: Tạo Trang Chính

**app/(app)/home/page.tsx:**
```typescript
'use client';
import useSWR from 'swr';
import { api } from '@/lib/api';

export default function HomePage() {
  const { data, error } = useSWR('/api/songs', () => api.songs.getAll());

  if (error) return <div>Error loading songs</div>;
  if (!data) return <div>Loading...</div>;

  return (
    <div>
      {data.songs.map(song => (
        <div key={song.id}>{song.title} - {song.artist}</div>
      ))}
    </div>
  );
}
```

## Giai Đoạn 3: Kiểm Tra Tích Hợp (1 ngày)

### Kiểm Tra Xác Thực
- Đăng ký tài khoản mới
- Đăng nhập
- Xác minh token được lưu trữ
- Làm mới token
- Đăng xuất

### Kiểm Tra Bài Hát
- Lấy danh sách bài hát
- Tìm kiếm bài hát
- Lấy bài hát đơn lẻ
- Phát trực tuyến bài hát

### Kiểm Tra Danh Sách Phát
- Tạo danh sách phát
- Thêm bài hát
- Xóa bài hát
- Xóa danh sách phát

## Giai Đoạn 4: Triển Khai (1 ngày)

Xem DEPLOYMENT_GUIDE.md cho hướng dẫn chi tiết.

---

## Danh Sách Kiểm Tra Triển Khai Hoàn Chỉnh

- [ ] Tất cả các biến môi trường được thiết lập
- [ ] Cơ sở dữ liệu được di chuyển hoàn toàn
- [ ] Backend bắt đầu không lỗi
- [ ] Frontend xây dựng không cảnh báo
- [ ] Tất cả các tuyến API kiểm tra
- [ ] RLS policies được kiểm tra
- [ ] Tính năng xác thực hoạt động
- [ ] Giới hạn tỷ lệ được triển khai
- [ ] Ghi nhật ký được thiết lập
- [ ] Sản xuất biến môi trường được thiết lập
