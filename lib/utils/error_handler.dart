import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      
      if (message.contains('invalid login credentials')) {
        return 'Incorrect email or password. Please try again.';
      } else if (message.contains('user already registered') || message.contains('already exists')) {
        return 'This email is already registered. Please log in instead.';
      } else if (message.contains('password should be at least')) {
        return 'Password is too short. It must be at least 6 characters.';
      } else if (message.contains('invalid email') || message.contains('email format')) {
        return 'Please enter a valid email address.';
      } else if (message.contains('email rate limit exceeded')) {
        return 'Too many requests. Please wait a moment and try again.';
      }
      
      return error.message; // Return the original Supabase message if we don't have a custom one
    }
    
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('socketexception') || errorString.contains('failed host lookup') || errorString.contains('connection')) {
      return 'No internet connection. Please check your network and try again.';
    }
    
    return 'An unexpected error occurred. Please try again later.';
  }
}
