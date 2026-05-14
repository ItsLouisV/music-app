# Tài Liệu API - Backend Streaming Nhạc

## URL Cơ Bản
```
Phát triển: http://localhost:5000
Sản xuất: https://music-api.example.com
```

## Xác Thực
Tất cả các điểm cuối được bảo vệ yêu cầu:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

---

## Các Điểm Cuối Xác Thực

### Đăng Ký Người Dùng
```
POST /api/auth/register
```

**Yêu Cầu:**
```json
{
  "email": "user@example.com",
  "password": "securepassword123",
  "username": "johndoe"
}
```

**Phản Hồi (201):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "username": "johndoe"
    },
    "token": "eyJhbGc..."
  },
  "message": "Người dùng được đăng ký thành công"
}
```

### Đăng Nhập Người Dùng
```
POST /api/auth/login
```

**Yêu Cầu:**
```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

**Phản Hồi (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "username": "johndoe"
    },
    "token": "eyJhbGc...",
    "expiresIn": 86400
  },
  "message": "Đăng nhập thành công"
}
```

### Lấy Người Dùng Hiện Tại
```
GET /api/auth/me
Authorization: Bearer <token>
```

**Phản Hồi (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "username": "johndoe",
      "profile_image_url": "https://..."
    }
  }
}
```

---

## Các Điểm Cuối Bài Hát

### Lấy Tất Cả Bài Hát
```
GET /api/songs?page=1&limit=20
```

**Phản Hồi (200):**
```json
{
  "success": true,
  "data": {
    "songs": [
      {
        "id": "uuid",
        "title": "Tiêu Đề Bài",
        "artist": "Tên Nghệ Sĩ",
        "album": "Album",
        "duration_seconds": 180,
        "image_url": "https://...",
        "stream_url": "https://...",
        "source": "public_api"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100
    }
  }
}
```

### Tìm Kiếm Bài Hát
```
GET /api/songs/search?q=beatles
```

**Phản Hồi (200):**
```json
{
  "success": true,
  "data": {
    "songs": [ ... ],
    "query": "beatles"
  }
}
```

### Tải Lên Bài Hát
```
POST /api/songs
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Yêu Cầu:**
- Tệp: file MP3
- title: Tiêu đề bài
- artist: Tên nghệ sĩ

**Phản Hồi (201):**
```json
{
  "success": true,
  "data": {
    "song": {
      "id": "uuid",
      "title": "...",
      "artist": "...",
      "stream_url": "https://...",
      "source": "user_upload"
    }
  }
}
```

---

## Các Điểm Cuối Danh Sách Phát

### Lấy Danh Sách Phát Của Người Dùng
```
GET /api/playlists
Authorization: Bearer <token>
```

**Phản Hồi (200):**
```json
{
  "success": true,
  "data": {
    "playlists": [
      {
        "id": "uuid",
        "name": "Danh Sách Phát Của Tôi",
        "description": "...",
        "song_count": 15,
        "is_public": false
      }
    ]
  }
}
```

### Tạo Danh Sách Phát
```
POST /api/playlists
Authorization: Bearer <token>
```

**Yêu Cầu:**
```json
{
  "name": "Danh Sách Phát Mới",
  "description": "Mô tả",
  "is_public": false
}
```

**Phản Hồi (201):**
```json
{
  "success": true,
  "data": {
    "playlist": {
      "id": "uuid",
      "name": "Danh Sách Phát Mới",
      "user_id": "user-uuid"
    }
  }
}
```

### Thêm Bài Hát Vào Danh Sách Phát
```
POST /api/playlists/{playlistId}/songs
Authorization: Bearer <token>
```

**Yêu Cầu:**
```json
{
  "songId": "song-uuid"
}
```

**Phản Hồi (201):**
```json
{
  "success": true,
  "message": "Bài hát được thêm vào danh sách phát"
}
```

---

## Các Điểm Cuối Yêu Thích

### Lấy Yêu Thích Của Người Dùng
```
GET /api/favorites
Authorization: Bearer <token>
```

**Phản Hồi (200):**
```json
{
  "success": true,
  "data": {
    "favorites": [
      {
        "id": "uuid",
        "song_id": "song-uuid",
        "created_at": "2024-01-01T00:00:00Z"
      }
    ]
  }
}
```

### Thích Bài Hát
```
POST /api/favorites/{songId}
Authorization: Bearer <token>
```

**Phản Hồi (201):**
```json
{
  "success": true,
  "message": "Bài hát được thêm vào yêu thích"
}
```

### Bỏ Thích Bài Hát
```
DELETE /api/favorites/{songId}
Authorization: Bearer <token>
```

**Phản Hồi (200):**
```json
{
  "success": true,
  "message": "Bài hát được xóa khỏi yêu thích"
}
```

---

## Các Điểm Cuối API Công Khai

### Tìm Kiếm Deezer
```
GET /api/public/deezer/search?q=beatles
```

**Phản Hồi (200):**
```json
{
  "success": true,
  "data": {
    "songs": [
      {
        "id": "deezer-id",
        "title": "...",
        "artist": "...",
        "image_url": "...",
        "stream_url": "..."
      }
    ]
  }
}
```

---

## Mã Lỗi

| Mã | Ý Nghĩa |
|----|---------|
| 400 | Yêu Cầu Sai |
| 401 | Không Được Phép |
| 403 | Bị Cấm |
| 404 | Không Tìm Thấy |
| 422 | Lỗi Xác Nhân |
| 500 | Lỗi Máy Chủ |

---

## Định Dạng Phản Hồi

Tất cả các phản hồi tuân theo định dạng:
```json
{
  "success": true/false,
  "data": { ... },
  "message": "...",
  "error": null
}
```

---

## Kiểm Tra Với cURL

### Đăng Ký
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@test.com",
    "password": "password123",
    "username": "testuser"
  }'
```

### Đăng Nhập
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@test.com",
    "password": "password123"
  }'
```

### Lấy Bài Hát
```bash
curl http://localhost:5000/api/songs?page=1&limit=20
```

### Tìm Kiếm
```bash
curl "http://localhost:5000/api/songs/search?q=beatles"
```

### Tạo Danh Sách Phát (cần token)
```bash
curl -X POST http://localhost:5000/api/playlists \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Danh Sách Phát Của Tôi"}'
```

---

## Giới Hạn Tỷ Lệ

- 100 yêu cầu mỗi phút trên mỗi IP
- 10 tải lên mỗi giờ trên mỗi người dùng
- 1000 tìm kiếm mỗi ngày trên mỗi người dùng

---

## Xác Thực

JWT tokens hết hạn sau 24 giờ. Sử dụng điểm cuối `/api/auth/refresh` để lấy token mới.
