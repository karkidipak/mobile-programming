# Learn With Me — Flutter + Supabase starter

This project is a modular Flutter starter for a two-role learning platform.

## Included
- Student/tutor registration and role-based login
- Student course discovery and search
- Tutor dashboard, course creation/edit/delete, thumbnail upload
- Free-course enrollment
- Lesson creation and network video playback
- Student list for each tutor course
- Course reviews
- Realtime course chat
- PDF certificate generation after the app detects all lessons completed
- Supabase schema and basic Row Level Security policies

## 1. Open in Android Studio
1. Extract the ZIP.
2. Android Studio → Open → select the `learn_with_me` folder.
3. Open Terminal in that folder and run:
   ```bash
   flutter create . --platforms=android
   flutter pub get
   ```

## 2. Configure Supabase
1. Create a Supabase project.
2. Open SQL Editor and run `supabase/schema.sql`.
3. In Project Settings → API, copy the Project URL and anon/public key.
4. Run the app:
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
   ```
5. In Authentication settings, choose whether email confirmation is required.
6. Enable Realtime for the `messages` table in the Supabase publication if it is not already enabled.

Never put the Supabase `service_role` key in a Flutter app.

## 3. Android permissions
Add these inside `android/app/src/main/AndroidManifest.xml`, above `<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```
For older Android versions, image_picker manages the platform picker flow. Use HTTPS video URLs.

## 4. Important implementation notes
- Free enrollment is connected to Supabase.
- Paid-course checkout is intentionally not activated. The UI shows a clear message until a secure server-side checkout is configured.
- Do not collect card details directly in Flutter. Use Stripe or Razorpay SDK with a trusted backend/Edge Function that creates a payment session and verifies signed webhooks before creating the enrollment.
- Tutor lesson upload currently stores a video URL. For production, upload video files to a private Supabase Storage bucket or a video hosting provider and issue signed URLs.
- Certificate generation is currently a manual action from My Learning. Before issuing a certificate, the app must verify on the server that every lesson is complete. A production certificate should include a unique certificate ID and server-verified completion date.
- FCM push notification setup needs Firebase project configuration, Android `google-services.json`, FCM device-token storage, and an Edge Function. No fake push delivery is claimed in this starter.
- Chat uses Supabase Realtime database streaming. Add moderation, reporting, pagination, and attachment controls before public launch.

## 5. Recommended next production steps
1. Implement secure Stripe Checkout or Razorpay Orders + webhook verification.
2. Add lesson upload UI and private video storage.
3. Enforce course completion on the backend before issuing certificates.
4. Add Firebase Cloud Messaging and notification preferences.
5. Add tutor profile, course publishing/draft controls, analytics, and admin moderation.
6. Tighten RLS policies after deciding whether course previews and lesson metadata are public.

## 6. Known scope
This is a connected MVP foundation, not a fully audited production marketplace. Test RLS with separate student and tutor accounts before publishing.


## Registration white-screen fix
The app now has a stable auth-role loading state and an error/retry screen instead of an indefinite blank white page. The role resolver checks `profiles.role` first and falls back to the role metadata stored during sign-up.

If you already created test accounts before applying the updated registration code:
1. Run `supabase/schema.sql` in Supabase SQL Editor (or confirm its profile trigger already exists).
2. Run `supabase/fix_registration_profiles.sql` to repair missing profile rows for existing users.
3. In Supabase Authentication settings, check whether email confirmation is enabled. If enabled, the user must confirm their email before signing in.
4. Sign out of the app, then sign in again using the same account type selected during registration.

## UI refresh
The login, registration, student discovery page, and tutor dashboard have been refreshed with a consistent navy/teal visual system, stronger typography, gradient hero panels, rounded cards, and clearer loading/error/empty states.
