# Hướng Dẫn Triển Khai - Thiết Lập Sản Xuất

## Tổng Quan

Hướng dẫn này bao gồm việc triển khai cả Node.js/Express backend và Next.js frontend sang sản xuất.

---

## Các Tùy Chọn Triển Khai Backend

### Tùy Chọn 1: Vercel (Khuyến Nghị Để Đơn Giản)

**Ưu Điểm:**
- Tích hợp dễ dàng với frontend Next.js
- Miễn phí
- Triển khai tự động từ GitHub
- Quản lý biến môi trường tích hợp

**Các Bước:**
1. Đẩy mã backend lên kho lưu trữ GitHub
2. Đi đến vercel.com và đăng nhập
3. Nhập dự án dưới dạng "Khác" (Node.js)
4. Cấu hình:
   - Thư mục gốc: `backend/`
   - Lệnh xây dựng: `npm run build` hoặc bỏ qua
   - Lệnh bắt đầu: `npm start`
5. Thêm biến môi trường:
   - SUPABASE_URL
   - SUPABASE_KEY
   - SUPABASE_SERVICE_ROLE_KEY
   - JWT_SECRET
   - NODE_ENV=production
   - CORS_ORIGIN=https://your-frontend-domain.vercel.app
6. Triển khai

**Truy Cập:**
```
API URL: https://your-backend.vercel.app/api
```

---

### Tùy Chọn 2: Railway.app

**Ưu Điểm:**
- Giao diện thân thiện với nhà phát triển
- Miễn phí hay
- Quản lý biến môi trường dễ dàng
- Tích hợp PostgreSQL

**Các Bước:**
1. Đăng ký tại railway.app
2. Kết nối kho lưu trữ GitHub
3. Tạo dự án mới
4. Cấu hình:
   - Gốc: `backend/`
   - Lệnh xây dựng: `npm install && npm run build`
   - Lệnh bắt đầu: `npm start`
5. Thêm biến môi trường
6. Triển khai

---

### Tùy Chọn 3: Render.com

**Ưu Điểm:**
- Miễn phí
- Hỗ trợ PostgreSQL gốc
- Bảng điều khiển tốt

**Các Bước:**
1. Đăng ký tại render.com
2. Tạo Web Service mới
3. Kết nối kho lưu trữ GitHub
4. Cấu hình:
   - Runtime: Node
   - Lệnh xây dựng: `npm install`
   - Lệnh bắt đầu: `npm start`
5. Thêm biến môi trường
6. Triển khai

---

### Tùy Chọn 4: Heroku (Cũ Nhưng Ổn Định)

**Ưu Điểm:**
- Lâu đời
- Dễ sử dụng
- Tài liệu tốt

**Các Bước:**
1. Tạo tài khoản tại heroku.com
2. Cài đặt Heroku CLI
3. Đăng nhập: `heroku login`
4. Tạo ứng dụng: `heroku create your-app-name`
5. Thêm buildpack: `heroku buildpacks:add heroku/nodejs`
6. Đặt biến môi trường:
   ```bash
   heroku config:set SUPABASE_URL=your_url
   heroku config:set SUPABASE_KEY=your_key
   # ... các biến khác
   ```
7. Triển khai: `git push heroku main`

---

## Triển Khai Frontend Sang Vercel

### Khuyến Nghị: Vercel (Tích Hợp Hoàn Hảo)

**Các Bước:**
1. Đẩy mã frontend lên GitHub
2. Đi đến vercel.com
3. Nhập dự án Next.js
4. Cấu hình:
   - Framework: Next.js
   - Thư mục gốc: `frontend/`
5. Thêm biến môi trường:
   - NEXT_PUBLIC_API_URL=https://your-backend.vercel.app
   - NEXT_PUBLIC_SUPABASE_URL=...
   - NEXT_PUBLIC_SUPABASE_KEY=...
6. Triển khai

**Truy Cập:**
```
Frontend: https://your-app.vercel.app
```

---

## Triển Khai Sang Netlify (Thay Thế)

1. Đẩy lên GitHub
2. Kết nối Netlify với kho lưu trữ
3. Cấu hình xây dựng:
   - Lệnh: `npm run build`
   - Thư mục xuất bản: `.next`
4. Thêm biến môi trường
5. Triển khai

---

## Thiết Lập Tên Miền

### Vercel
1. Đi đến Cài Đặt Dự Án
2. Chuyển đến Domains
3. Thêm tên miền tùy chỉnh của bạn
4. Cập nhật DNS tại nhà cung cấp tên miền
5. Chờ xác minh (2-48 giờ)

### Tên Miền Riêng Cho Backend & Frontend
- Frontend: `app.yourdomain.com`
- Backend: `api.yourdomain.com`

---

## Biến Môi Trường Sản Xuất

### Backend
```
NODE_ENV=production
PORT=5000 (hoặc cổng được chỉ định)

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-prod-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-prod-service-role-key

JWT_SECRET=your-strong-secret-key-min-32-chars
JWT_EXPIRY=24h

CORS_ORIGIN=https://your-domain.com,https://app.your-domain.com

DEEZER_API_BASE=https://api.deezer.com

MAX_FILE_SIZE=52428800
ALLOWED_MIME_TYPES=audio/mpeg,audio/wav
```

### Frontend
```
NEXT_PUBLIC_API_URL=https://api.your-domain.com
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_KEY=your-prod-anon-key
```

---

## Danh Sách Kiểm Tra Sản Xuất

### Trước Triển Khai
- [ ] Tất cả kiểm tra vượt qua
- [ ] Không có cảnh báo linter/build
- [ ] Biến môi trường được xác minh
- [ ] Cơ sở dữ liệu được sao lưu
- [ ] RLS policies được kiểm tra
- [ ] Rate limiting được bật
- [ ] SSL/HTTPS được bật
- [ ] Nhật ký được cấu hình
- [ ] Giám sát được thiết lập

### Backend
- [ ] Server khởi động không lỗi
- [ ] Kết nối Supabase hoạt động
- [ ] Các điểm cuối API phản hồi
- [ ] CORS được cấu hình đúng
- [ ] Giới hạn tỷ lệ hoạt động
- [ ] Xác thực JWT hoạt động

### Frontend
- [ ] Xây dựng thành công
- [ ] Không có cảnh báo
- [ ] Các tuyến hoạt động
- [ ] API được kết nối
- [ ] Supabase được xác thực

---

## Giám Sát & Logging

### Vercel
- Log được xem trong Dashboard Vercel
- Analytics tự động
- Error tracking tích hợp

### Backend Tùy Chỉnh
Thiết lập Winston/Morgan:
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
});
```

---

## Khả Năng Mở Rộng

### Khi Lượng Dữ Liệu Tăng
1. Thêm chỉ số cơ sở dữ liệu
2. Triển khai bộ nhớ đệm Redis
3. Phân trang lớn hơn
4. Nén phản hồi

### Khi Lưu Lượng Tăng
1. Bật Serverless Functions tự động (Vercel)
2. Bộ cân bằng tải
3. CDN cho tài sản tĩnh
4. Giới hạn tỷ lệ

---

## Danh Sách Kiểm Tra Bảo Mật

- [ ] HTTPS/SSL được bật
- [ ] Mật khẩu được hash với bcryptjs
- [ ] JWT_SECRET là chuỗi mạnh mẽ
- [ ] RLS được bật trên tất cả các bảng
- [ ] CORS được hạn chế cho các tên miền đã biết
- [ ] Rate limiting được triển khai
- [ ] Các headers bảo mật được đặt
- [ ] Không có thông tin nhạy cảm trong nhật ký
- [ ] Tệp .env không được commit
- [ ] Supabase API keys được xoay vòng

---

## Khắc Phục Sự Cố Sản Xuất

### Backend Không Phản Hồi
1. Kiểm tra Logs trong Vercel/Railway/Render
2. Xác minh biến môi trường
3. Kiểm tra kết nối Supabase
4. Kiểm tra giới hạn bộ nhớ

### Lỗi Cơ Sở Dữ Liệu
1. Đi đến bảng điều khiển Supabase
2. Kiểm tra RLS policies
3. Kiểm tra các truy vấn trong SQL Editor
4. Kiểm tra nhật ký sản xuất

### Vấn Đề Frontend
1. Kiểm tra Console trình duyệt
2. Xác minh NEXT_PUBLIC_API_URL
3. Kiểm tra Vercel Logs
4. Xóa bộ nhớ đệm .next

---

## Cập Nhật và Duy Trì

### Cập Nhật Định Kỳ
```bash
# Cập nhật các phụ thuộc
npm update
npm audit fix

# Kiểm tra tính tương thích
npm test

# Xây dựng mới
npm run build

# Triển khai
git push origin main
```

### Sao Lưu Cơ Sở Dữ Liệu
- Supabase: Bảo sao lưu tự động hàng ngày
- Tải xuống sao lưu thủ công định kỳ

### Xoay Vòng Bảo Mật
- Thay đổi JWT_SECRET mỗi 3 tháng
- Xoay vòng Supabase API keys
- Xem xét các chính sách RLS

---

## Chúc Mừng!

Ứng dụng của bạn đang chạy trên sản xuất! 🎉

Theo dõi logs, giám sát hiệu suất và cập nhật thường xuyên để giữ ứng dụng an toàn và nhanh chóng.

---

**Bất kỳ câu hỏi? Tham khảo tài liệu khác hoặc mở vấn đề trên GitHub!**
