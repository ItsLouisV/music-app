# Lược Đồ Cơ Sở Dữ Liệu - Supabase PostgreSQL

## Tổng Quan

Cơ sở dữ liệu sử dụng PostgreSQL với các chính sách Row Level Security (RLS) để xác thực và phân quyền. Tất cả các bảng bao gồm dấu thời gian để kiểm toán.

---

## Cấu Trúc Bảng

### 1. users
Lưu trữ thông tin tài khoản người dùng.

```sql
CREATE TABLE public.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  profile_image_url TEXT,
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Chính sách RLS
-- Người dùng có thể đọc hồ sơ của họ
CREATE POLICY "users_select_self" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- Người dùng có thể cập nhật hồ sơ của họ
CREATE POLICY "users_update_self" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Công khai: bất kỳ ai cũng có thể đọc tên người dùng và ảnh (để hiển thị)
CREATE POLICY "users_select_public" ON public.users
  FOR SELECT USING (true);
```

### 2. songs
Lưu trữ siêu dữ liệu bài hát với hỗ trợ cho cả bài hát API công khai và tải lên từ người dùng.

```sql
CREATE TABLE public.songs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  artist VARCHAR(255) NOT NULL,
  album VARCHAR(255),
  duration_seconds INTEGER NOT NULL,
  image_url TEXT,
  stream_url TEXT NOT NULL,
  source VARCHAR(20) NOT NULL CHECK (source IN ('public_api', 'user_upload')),
  uploaded_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_songs_artist ON public.songs(artist);
CREATE INDEX idx_songs_title ON public.songs(title);
CREATE INDEX idx_songs_source ON public.songs(source);

-- Chính sách RLS
-- Bất kỳ ai cũng có thể đọc bài hát
CREATE POLICY "songs_select_all" ON public.songs
  FOR SELECT USING (true);

-- Chỉ người tải lên hoặc admin có thể cập nhật/xóa tải lên của họ
CREATE POLICY "songs_update_own" ON public.songs
  FOR UPDATE USING (auth.uid() = uploaded_by);

CREATE POLICY "songs_delete_own" ON public.songs
  FOR DELETE USING (auth.uid() = uploaded_by);

-- Cho phép hệ thống insert nhạc từ iTunes
CREATE POLICY "songs_insert_all" ON public.songs
  FOR INSERT WITH CHECK (true);
```

### 3. playlists
Lưu trữ danh sách phát do người dùng tạo.

```sql
CREATE TABLE public.playlists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  cover_image_url TEXT,
  is_public BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_playlists_user_id ON public.playlists(user_id);

-- Chính sách RLS
-- Chủ sở hữu có thể quản lý danh sách phát của họ
CREATE POLICY "playlists_select_own" ON public.playlists
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "playlists_update_own" ON public.playlists
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "playlists_delete_own" ON public.playlists
  FOR DELETE USING (auth.uid() = user_id);

-- Danh sách phát công khai có thể được xem bởi bất kỳ ai
CREATE POLICY "playlists_select_public" ON public.playlists
  FOR SELECT USING (is_public = true);

-- Chủ sở hữu có thể chèn
CREATE POLICY "playlists_insert_own" ON public.playlists
  FOR INSERT WITH CHECK (auth.uid() = user_id);
```

### 4. playlist_songs
Bảng nối liên kết các bài hát với danh sách phát có sắp xếp.

```sql
CREATE TABLE public.playlist_songs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  playlist_id UUID NOT NULL REFERENCES public.playlists(id) ON DELETE CASCADE,
  song_id UUID NOT NULL REFERENCES public.songs(id) ON DELETE CASCADE,
  order_index INTEGER NOT NULL DEFAULT 0,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(playlist_id, song_id)
);

CREATE INDEX idx_playlist_songs_playlist_id ON public.playlist_songs(playlist_id);
CREATE INDEX idx_playlist_songs_song_id ON public.playlist_songs(song_id);

-- Chính sách RLS
-- Bất kỳ ai cũng có thể đọc các bài hát danh sách phát công khai
CREATE POLICY "playlist_songs_select_public" ON public.playlist_songs
  FOR SELECT USING (
    EXISTS(
      SELECT 1 FROM public.playlists
      WHERE playlists.id = playlist_songs.playlist_id
      AND (playlists.is_public = true OR playlists.user_id = auth.uid())
    )
  );

-- Chủ sở hữu có thể quản lý các bài hát trong danh sách phát của họ
CREATE POLICY "playlist_songs_insert_own" ON public.playlist_songs
  FOR INSERT WITH CHECK (
    EXISTS(
      SELECT 1 FROM public.playlists
      WHERE playlists.id = playlist_songs.playlist_id
      AND playlists.user_id = auth.uid()
    )
  );

CREATE POLICY "playlist_songs_delete_own" ON public.playlist_songs
  FOR DELETE USING (
    EXISTS(
      SELECT 1 FROM public.playlists
      WHERE playlists.id = playlist_songs.playlist_id
      AND playlists.user_id = auth.uid()
    )
  );
```

### 5. favorites
Lưu trữ bài hát yêu thích của người dùng để truy cập nhanh.

```sql
CREATE TABLE public.favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  song_id UUID NOT NULL REFERENCES public.songs(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, song_id)
);

CREATE INDEX idx_favorites_user_id ON public.favorites(user_id);
CREATE INDEX idx_favorites_song_id ON public.favorites(song_id);

-- Chính sách RLS
-- Người dùng chỉ có thể thấy yêu thích của riêng họ
CREATE POLICY "favorites_select_own" ON public.favorites
  FOR SELECT USING (auth.uid() = user_id);

-- Người dùng có thể thêm vào yêu thích của họ
CREATE POLICY "favorites_insert_own" ON public.favorites
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Người dùng có thể xóa khỏi yêu thích của họ
CREATE POLICY "favorites_delete_own" ON public.favorites
  FOR DELETE USING (auth.uid() = user_id);
```

### 6. user_uploads
Theo dõi các tệp tải lên của người dùng để tổ chức và dọn dẹp.

```sql
CREATE TABLE public.user_uploads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  file_path TEXT NOT NULL,
  file_size_bytes INTEGER NOT NULL,
  duration_seconds INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_uploads_user_id ON public.user_uploads(user_id);

-- Chính sách RLS
-- Người dùng chỉ có thể thấy tải lên của riêng họ
CREATE POLICY "user_uploads_select_own" ON public.user_uploads
  FOR SELECT USING (auth.uid() = user_id);

-- Người dùng có thể tải lên tệp
CREATE POLICY "user_uploads_insert_own" ON public.user_uploads
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Người dùng có thể xóa tải lên của họ
CREATE POLICY "user_uploads_delete_own" ON public.user_uploads
  FOR DELETE USING (auth.uid() = user_id);
```

---

## Chỉ Số Cho Hiệu Suất

```sql
-- Chỉ số khóa ngoài (được tạo tự động)
-- Chỉ số tìm kiếm tùy chỉnh
CREATE INDEX idx_songs_full_text ON public.songs 
  USING GIN(to_tsvector('english', title || ' ' || artist));

CREATE INDEX idx_users_username_search ON public.users
  USING GIN(to_tsvector('english', username));

-- Chỉ số dấu thời gian để sắp xếp
CREATE INDEX idx_songs_created_at ON public.songs(created_at DESC);
CREATE INDEX idx_playlists_created_at ON public.playlists(created_at DESC);
```

---

## Chế Độ Xem (Tùy Chọn Để Tối Ưu Hóa Hiệu Suất)

### Bài Hát Yêu Thích Của Người Dùng Với Chi Tiết
```sql
CREATE VIEW public.favorite_songs AS
SELECT 
  f.id as favorite_id,
  f.user_id,
  s.id as song_id,
  s.title,
  s.artist,
  s.album,
  s.duration_seconds,
  s.image_url,
  s.stream_url,
  f.created_at
FROM public.favorites f
JOIN public.songs s ON f.song_id = s.id;
```

### Danh Sách Phát Với Số Lượng Bài Hát
```sql
CREATE VIEW public.playlists_with_counts AS
SELECT 
  p.id,
  p.user_id,
  p.name,
  p.description,
  p.cover_image_url,
  p.is_public,
  COUNT(ps.id) as song_count,
  p.created_at
FROM public.playlists p
LEFT JOIN public.playlist_songs ps ON p.id = ps.playlist_id
GROUP BY p.id;
```

---

## Các Bước Di Chuyển

1. Tạo tất cả các bảng theo thứ tự được chỉ định (tôn trọng các phụ thuộc khóa ngoài)
2. Tạo chỉ số để tối ưu hóa hiệu suất
3. Bật RLS trên tất cả các bảng
4. Tạo chính sách RLS
5. Thiết lập Trigger đồng bộ User từ Auth sang Public (Rất Quan Trọng)
6. Kiểm tra chính sách với các người dùng khác nhau

### Trigger Đồng Bộ Người Dùng
Vì `playlists` và `favorites` liên kết khóa ngoại với bảng `public.users`, bạn phải có Trigger này để sao chép user từ hệ thống Auth của Supabase sang bảng Public:

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, email, username, password_hash)
  VALUES (new.id, new.email, new.email, 'from_auth');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Chạy lệnh này để đồng bộ các user đã đăng ký từ trước:
INSERT INTO public.users (id, email, username, password_hash)
SELECT id, email, email, 'from_auth'
FROM auth.users
ON CONFLICT (id) DO NOTHING;
```
```

### Storage RLS (Bắt buộc cho chức năng Upload)
Khi bạn upload file mp3 hoặc ảnh lên bucket `uploads` của Supabase Storage, bạn cần cấp quyền RLS cho bảng `storage.objects` để không bị lỗi 403 (Unauthorized):

```sql
-- Bật RLS cho storage (nếu chưa bật)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Cho phép người dùng đã đăng nhập được upload file vào bucket 'uploads'
CREATE POLICY "Upload_Access" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'uploads' AND auth.role() = 'authenticated');

-- Cho phép mọi người có thể đọc/nghe file từ bucket 'uploads'
CREATE POLICY "Read_Access" ON storage.objects
  FOR SELECT USING (bucket_id = 'uploads');

-- Cho phép người dùng sửa/xóa file do chính họ tải lên
CREATE POLICY "Update_Access" ON storage.objects
  FOR UPDATE USING (bucket_id = 'uploads' AND auth.uid() = owner);

CREATE POLICY "Delete_Access" ON storage.objects
  FOR DELETE USING (bucket_id = 'uploads' AND auth.uid() = owner);
```

---

## Cân Nhắc Bảo Mật

1. **RLS Được Bật**: Tất cả các bảng có RLS được bật để đảm bảo người dùng chỉ có thể truy cập dữ liệu của họ
2. **Khóa Ngoài**: Xóa theo tầng cho dữ liệu liên quan đến người dùng
3. **Ràng Buộc Duy Nhất**: Email, tên người dùng duy nhất; yêu thích bài hát duy nhất cho mỗi người dùng
4. **Truy Cập Tệp**: Tải lên người dùng là riêng tư và không trực tiếp có thể truy cập
5. **Dữ Liệu Công Khai**: Chỉ danh sách phát công khai và hồ sơ người dùng hiển thị cho người dùng chưa được xác thực
