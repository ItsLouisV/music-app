import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/supabase_service.dart';
import '../auth/login_screen.dart';
import '../../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _supabaseService = SupabaseService();

  void _confirmLogout() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Đăng xuất'),
            onPressed: () async {
              Navigator.pop(context); // Đóng Dialog
              
              // Lấy NavigatorState trước khi await để tránh dùng BuildContext qua async gap
              final nav = Navigator.of(this.context, rootNavigator: true);

              await _supabaseService.signOut();
              
              // Chuyển về màn Login (hàm này sẽ xóa sạch các route cũ bao gồm cả SettingsScreen)
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabaseService.currentUser;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.chevron_down, color: Theme.of(context).iconTheme.color ?? Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Cài đặt', style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.white)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          // User Info Section
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFA243C), Color(0xFF8E2DE2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(CupertinoIcons.person_fill, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.email ?? 'Người dùng ẩn danh',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white),
          ),
          const SizedBox(height: 40),
          
          _buildSettingsGroup(
            title: 'Thông tin người thực hiện', 
            items: [
              _buildSettingsItem(icon: CupertinoIcons.person, title: 'Họ và tên', subtitle: 'Nguyễn Văn Linh'),
              _buildSettingsItem(icon: CupertinoIcons.info, title: 'Mã sinh viên', subtitle: '2224802010841'),
            ]),

          const SizedBox(height: 24),

          // Settings Groups
          _buildSettingsGroup(
            title: 'Tài khoản',
            items: [
              _buildSettingsItem(icon: CupertinoIcons.person, title: 'Hồ sơ cá nhân'),
              _buildSettingsItem(icon: CupertinoIcons.lock, title: 'Đổi mật khẩu'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSettingsGroup(
            title: 'Ứng dụng',
            items: [
              _buildSettingsItem(
                icon: CupertinoIcons.moon_fill, 
                title: 'Giao diện tối', 
                hasSwitch: true, 
                switchValue: Provider.of<ThemeProvider>(context).isDarkMode,
                onSwitchChanged: (val) {
                  Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                },
              ),
              _buildSettingsItem(icon: CupertinoIcons.music_note_list, title: 'Chất lượng âm thanh', subtitle: 'Cao'),
            ],
          ),

          const SizedBox(height: 48),
          
          // Logout Button
          CupertinoButton(
            color: Colors.white.withValues(alpha: 0.1),
            onPressed: _confirmLogout,
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
          
          const SizedBox(height: 24),
          Text(
            'Phiên bản 1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.4), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon, 
    required String title, 
    String? subtitle,
    bool hasSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    return ListTile(
      leading: Icon(icon, color: textColor.withValues(alpha: 0.7)),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null) ...[
            Text(subtitle, style: TextStyle(color: textColor.withValues(alpha: 0.5))),
            const SizedBox(width: 8),
          ],
          if (hasSwitch)
            CupertinoSwitch(value: switchValue, onChanged: onSwitchChanged)
          else
            Icon(CupertinoIcons.chevron_forward, color: textColor.withValues(alpha: 0.2), size: 20),
        ],
      ),
      onTap: hasSwitch ? null : () {},
    );
  }
}
