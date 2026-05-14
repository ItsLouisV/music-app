# Hướng Dẫn Tham Khảo Nhanh

## Các Lệnh Thiết Yếu

### Thiết Lập Backend
```bash
cd backend
npm install
npm start                    # Chạy trên http://localhost:5000
npm run dev                  # Phát triển với tự động tải lại
```

### Thiết Lập Frontend
```bash
cd frontend
npm install
npm run dev                  # Chạy trên http://localhost:3000
npm run build               # Build sản xuất
```

### Cơ Sở Dữ Liệu
```bash
# Trong trình chỉnh sửa SQL của bảng điều khiển Supabase, chạy di chuyển từ DATABASE_SCHEMA.md
# Hoặc sử dụng Supabase CLI:
supabase migration list
supabase migration up
```

---

## Vị Trí Tệp

### Tệp Backend Quan Trọng
```
backend/
├── src/server.js                    # Vào máy chủ chính
├── src/config/supabase.js          # Khách hàng Supabase
├── src/middleware/auth.js          # Xác minh JWT
├── src/routes/                     # Tất cả tuyến API
├── src/controllers/                # Trình xử lý yêu cầu
├── src/services/                   # Logic kinh doanh
└── migrations/                     # Tệp lược đồ SQL
```

### Tệp Frontend Quan Trọng
```
frontend/
├── app/layout.tsx                   # Bố cục gốc
├── app/(auth)/                      # Đăng nhập/Đăng ký
├── app/(app)/                       # Trang ứng dụng chính
├── components/                      # Thành phần tái sử dụng
├── lib/api.ts                       # Khách hàng API
├── lib/supabase.ts                  # Khách hàng Supabase
├── context/                         # Nhà cung cấp trạng thái
└── hooks/                           # Custom hooks
```

---

## Tham Khảo API Nhanh

### Xác Thực
```bash
# Đăng Ký
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"pass","username":"user"}'

# Đăng Nhập
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"pass"}'
```

### Bài Hát
```bash
# Lấy tất cả bài hát
curl http://localhost:5000/api/songs?page=1&limit=20

# Tìm kiếm bài hát
curl "http://localhost:5000/api/songs/search?q=beatles"

# Lấy bài hát theo ID
curl http://localhost:5000/api/songs/{id}
```

### Danh Sách Phát (cần tiêu đề auth)
```bash
# Lấy danh sách phát của người dùng
curl -H "Authorization: Bearer {token}" \
  http://localhost:5000/api/playlists

# Tạo danh sách phát
curl -X POST -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"name":"Danh Sách Phát Của Tôi"}' \
  http://localhost:5000/api/playlists
```

---

## Các Tác Vụ Phổ Biến

### Thêm Bài Hát Mới Vào Cơ Sở Dữ Liệu
1. Đi đến bảng điều khiển Supabase
2. Chuyển đến trang SQL Editor
3. Chèn bài hát:
```sql
INSERT INTO songs (title, artist, duration_seconds, stream_url, source)
VALUES ('Tên Bài', 'Tên Nghệ Sĩ', 180, 'http://url-mp3.com', 'public_api');
```

### Tạo Danh Sách Phát Mới
```bash
curl -X POST http://localhost:5000/api/playlists \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Danh Sách Phát Mới"}'
```

### Thêm Bài Hát Vào Danh Sách Phát
```bash
curl -X POST http://localhost:5000/api/playlists/{playlistId}/songs \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"songId":"song-uuid"}'
```

### Thích Bài Hát
```bash
curl -X POST http://localhost:5000/api/favorites/{songId} \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Mẹo Gỡ Lỗi

### Backend Không Phản Hồi
```bash
# Kiểm tra xem backend có chạy không
curl http://localhost:5000/health

# Xem quy trình chạy
lsof -i :5000

# Dừng quá trình
kill -9 <PID>
```

### Lỗi Xác Thực
- Kiểm tra xem JWT_SECRET có trong .env không
- Xác minh token không hết hạn
- Kiểm tra xem Supabase có kết nối không

### Lỗi CORS
- Xác nhân CORS_ORIGIN trong .env backend
- Kiểm tra kế tên máy chủ frontend
- Xóa bộ đệm trình duyệt

### Lỗi Cơ Sở Dữ Liệu
- Xác minh kết nối Supabase
- Kiểm tra RLS policies
- Kiểm tra quyền người dùng

### Lỗi Tệp
```bash
# Kiểm tra xem Node modules có tồn tại không
ls node_modules

# Cài đặt lại các phụ thuộc
rm -rf node_modules package-lock.json
npm install
```

---

## Danh Sách Kiểm Tra Triển Khai

### Trước Khi Triển Khai
- [ ] Tất cả các kiểm tra vượt qua
- [ ] Biến môi trường được thiết lập
- [ ] Cơ sở dữ liệu được di chuyển
- [ ] RLS policies được bật
- [ ] CORS được cấu hình cho sản xuất
- [ ] JWT_SECRET không phải chuỗi mặc định
- [ ] Không có nhật ký gỡ lỗi
- [ ] Kiểm tra bảo mật

### Backend Triển Khai
- [ ] Biến môi trường sẽ được đặt
- [ ] Máy chủ sẽ được khởi động trên cổng chính xác
- [ ] Cơ sở dữ liệu Supabase có thể truy cập được
- [ ] API hoạt động từ bên ngoài

### Frontend Triển Khai
- [ ] NEXT_PUBLIC_API_URL được cập nhật
- [ ] Supabase credentials được đặt
- [ ] Xây dựng thành công không có cảnh báo
- [ ] Các tuyến hoạt động đúng cách

---

## Biến Môi Trường Bắt Buộc

### Backend
```
NODE_ENV=production
PORT=5000
SUPABASE_URL=...
SUPABASE_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...
JWT_SECRET=... (tối thiểu 32 ký tự)
JWT_EXPIRY=24h
CORS_ORIGIN=https://your-domain.com
DEEZER_API_BASE=https://api.deezer.com
```

### Frontend
```
NEXT_PUBLIC_API_URL=https://your-api.vercel.app
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_KEY=...
```

---

## Liên Kết Nhanh

- [Tài liệu Supabase](https://supabase.com/docs)
- [Tài liệu Express.js](https://expressjs.com)
- [Tài liệu Next.js](https://nextjs.org/docs)
- [Tailwind CSS](https://tailwindcss.com)
- [Deezer API](https://developers.deezer.com)

---

## Lệnh Hữu Ích

### Git
```bash
git status
git add .
git commit -m "Mô tả thay đổi"
git push origin main
```

### npm
```bash
npm install package-name
npm update
npm audit
npm run build
npm start
```

### Supabase CLI (nếu được cài đặt)
```bash
supabase login
supabase migration list
supabase migration new migration_name
supabase migration up
```

---

## Cấu Trúc Phản Hồi API

### Thành Công
```json
{
  "success": true,
  "data": { ... },
  "message": "Thành công",
  "error": null
}
```

### Lỗi
```json
{
  "success": false,
  "data": null,
  "message": "Lỗi",
  "error": { "code": "ERROR_CODE", "details": "..." }
}
```

---

## Mã Lỗi API Phổ Biến

| Mã | Ý Nghĩa |
|----|---------|
| 400 | Yêu cầu Sai |
| 401 | Không Được Phép (xác thực) |
| 403 | Bị Cấm (phân quyền) |
| 404 | Không Tìm Thấy |
| 422 | Lỗi Xác Nhân |
| 500 | Lỗi Máy Chủ Nội Bộ |

---

## Bảo Mật

### Mật Khẩu
- Tối thiểu 8 ký tự
- Bao gồm chữ hoa, chữ thường, số
- Không được để trong mã

### Token
- Lưu trữ trong sessionStorage (không localStorage)
- Gửi trong Authorization header
- Làm mới trước khi hết hạn

### API Keys
- Không bao giờ commit vào Git
- Sử dụng biến môi trường
- Xoay vòng định kỳ
- Tách apiKey và serviceRoleKey

---

## Hiệu Suất

### Frontend
- Hãy sử dụng Next/Image cho ảnh
- Tối ưu hóa bundle (kiểm tra với `npm run build`)
- Hãy sử dụng dynamic imports cho thành phần lớn
- Ghi nhớ các thành phần nặng

### Backend
- Sử dụng chỉ số cơ sở dữ liệu
- Paginate danh sách lớn
- Lưu trữ câu trả lời tĩnh
- Đóng kết nối đúng cách

---

## Đó là tất cả! Chúc bạn viết mã vui vẻ! 🎵
