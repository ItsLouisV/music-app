# Cấu Trúc Backend - Node.js/Express Âm Nhạc API

## Thiết Lập Dự Án

```
backend/
├── src/
│   ├── config/
│   │   ├── database.js          # Kết nối PostgreSQL Supabase
│   │   ├── supabase.js          # Khởi tạo khách hàng Supabase
│   │   └── environment.js       # Xác nhận biến môi trường
│   │
│   ├── middleware/
│   │   ├── auth.js              # Xác minh JWT
│   │   ├── errorHandler.js      # Xử lý lỗi toàn cầu
│   │   ├── validation.js        # Xác nhân yêu cầu (Joi/Zod)
│   │   └── cors.js              # Cấu hình CORS
│   │
│   ├── controllers/
│   │   ├── authController.js    # Logic auth (đăng ký, đăng nhập, làm mới)
│   │   ├── songController.js    # Song CRUD + tìm kiếm
│   │   ├── playlistController.js # Quản lý danh sách phát
│   │   ├── favoriteController.js # Thích/bỏ thích bài hát
│   │   └── uploadController.js  # Tải lên tệp MP3
│   │
│   ├── services/
│   │   ├── authService.js       # Logic kinh doanh auth
│   │   ├── songService.js       # Truy vấn và logic bài hát
│   │   ├── playlistService.js   # Hoạt động danh sách phát
│   │   ├── favoriteService.js   # Hoạt động yêu thích
│   │   ├── deezerService.js     # Tích hợp Deezer API
│   │   ├── spotifyService.js    # Tích hợp Spotify API (tùy chọn)
│   │   └── uploadService.js     # Tải lên tệp sang Supabase Storage
│   │
│   ├── routes/
│   │   ├── auth.js              # POST /api/auth/*
│   │   ├── songs.js             # GET/POST /api/songs/*
│   │   ├── playlists.js         # GET/POST/PUT/DELETE /api/playlists/*
│   │   ├── favorites.js         # GET/POST/DELETE /api/favorites/*
│   │   ├── public.js            # GET /api/public/* (Deezer, Spotify)
│   │   └── index.js             # Tập hợp tuyến
│   │
│   ├── models/
│   │   ├── User.js              # Lược đồ/xác nhân người dùng
│   │   ├── Song.js              # Lược đồ/xác nhân bài hát
│   │   ├── Playlist.js          # Lược đồ/xác nhân danh sách phát
│   │   └── Favorite.js          # Lược đồ/xác nhân yêu thích
│   │
│   ├── utils/
│   │   ├── jwt.js               # Tạo/xác minh JWT token
│   │   ├── validators.js        # Trợ giúp xác nhân
│   │   ├── errorHandler.js      # Lớp lỗi tùy chỉnh
│   │   ├── logger.js            # Tiện ích ghi nhật ký
│   │   └── helpers.js           # Tiện ích chung
│   │
│   └── server.js                # Điểm vào ứng dụng Express
│
├── migrations/
│   ├── 001_create_users_table.sql
│   ├── 002_create_songs_table.sql
│   ├── 003_create_playlists_table.sql
│   ├── 004_create_playlist_songs_table.sql
│   ├── 005_create_favorites_table.sql
│   └── 006_create_user_uploads_table.sql
│
├── .env.example
├── .gitignore
├── package.json
├── server.js (hoặc index.js)
└── README.md
```

## Mô Tả Chi Tiết Các Tệp Chính

### 1. server.js (Điểm Vào)
- Khởi tạo ứng dụng Express
- Tải middleware (CORS, auth, xác nhân)
- Gắn kết các tuyến
- Bắt đầu máy chủ trên PORT

### 2. config/supabase.js
- Khởi tạo khách hàng Supabase với thông tin xác thực
- Xuất khách hàng để sử dụng trong dịch vụ
- Xử lý pooling kết nối

### 3. middleware/auth.js
- Trích xuất JWT token từ Authorization header
- Xác minh token bằng Supabase Auth
- Gắn người dùng vào đối tượng yêu cầu
- Trả về 401 nếu không hợp lệ/hết hạn

### 4. controllers/songController.js
- GET /api/songs (liệt kê có phân trang)
- GET /api/songs/:id (bài hát đơn)
- GET /api/songs/search?q=query (tìm kiếm)
- POST /api/songs (tải lên mới)
- GET /api/songs/stream/:id (phát trực tuyến)

### 5. services/deezerService.js
- Tìm kiếm Deezer API cho bài hát
- Tải URL phát trực tuyến theo dõi
- Xử lý giới hạn tỷ lệ
- Kết quả bộ đệm (tùy chọn)

### 6. services/uploadService.js
- Xác nhân tệp MP3
- Tải lên Supabase Storage bucket: `uploads/mp3`
- Tạo bản ghi bài hát với URL Supabase
- Xử lý trích xuất siêu dữ liệu

## Định Dạng Phản Hồi API

Tất cả các phản hồi theo định dạng JSON:

```json
{
  "success": true,
  "data": { ... },
  "message": "Thông báo thành công",
  "error": null
}
```

Phản hồi lỗi:
```json
{
  "success": false,
  "data": null,
  "message": "Hoạt động thất bại",
  "error": { "code": "VALIDATION_ERROR", "details": "..." }
}
```

## Luồng Xác Thực

1. Người dùng đăng ký: `POST /api/auth/register`
2. Backend tạo người dùng trong Supabase Auth + bảng người dùng
3. Người dùng đăng nhập: `POST /api/auth/login`
4. Backend trả về JWT token
5. Frontend lưu trữ token (lưu trữ an toàn)
6. Tất cả các yêu cầu được bảo vệ bao gồm: `Authorization: Bearer <token>`
7. Backend xác minh token bằng Supabase Auth
8. Làm mới token: `POST /api/auth/refresh`

## Phụ Thuộc

```json
{
  "express": "^4.18.2",
  "@supabase/supabase-js": "^2.38.0",
  "jsonwebtoken": "^9.0.2",
  "bcryptjs": "^2.4.3",
  "joi": "^17.10.0",
  "cors": "^2.8.5",
  "dotenv": "^16.3.1",
  "axios": "^1.5.0",
  "uuid": "^9.0.0"
}
```

## Biến Môi Trường (.env)

```
NODE_ENV=development
PORT=5000

# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRY=24h

# CORS
CORS_ORIGIN=http://localhost:3000,http://localhost:3001

# API Bên Ngoài
DEEZER_API_BASE=https://api.deezer.com

# Tải Lên Tệp
MAX_FILE_SIZE=50000000
ALLOWED_MIME_TYPES=audio/mpeg,audio/wav
```

## Kiểm Tra

Tạo thư mục `tests/` với Jest/Mocha kiểm tra cho:
- Các điểm cuối xác thực
- Hoạt động CRUD bài hát
- Chức năng tìm kiếm
- Tải lên tệp
- Hoạt động danh sách phát
- Xử lý lỗi
