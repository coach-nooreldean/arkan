export type PlatformType = 'android' | 'ios' | 'windows' | 'mac' | 'linux' | 'unknown';

export interface DeviceInfo {
  platform: PlatformType;
  label: string;
  badge: string;
  recommendedFile: string;
  downloadUrl: string;
  isMobile: boolean;
  isAndroid: boolean;
}

export function detectDevice(): DeviceInfo {
  if (typeof window === 'undefined') {
    return {
      platform: 'android',
      label: 'أندرويد',
      badge: 'APK الشامل',
      recommendedFile: 'Arkan-1.0.0-universal.apk',
      downloadUrl: '#releases',
      isMobile: true,
      isAndroid: true,
    };
  }

  const userAgent = window.navigator.userAgent.toLowerCase();
  const isAndroid = /android/i.test(userAgent);
  const isIos = /iphone|ipad|ipod/i.test(userAgent);
  const isMac = /macintosh|mac os x/i.test(userAgent);
  const isWindows = /windows/i.test(userAgent);
  const isLinux = /linux/i.test(userAgent) && !isAndroid;

  let platform: PlatformType = 'android';
  let label = 'أندرويد';

  if (isAndroid) {
    platform = 'android';
    label = 'أندرويد';
  } else if (isIos) {
    platform = 'ios';
    label = 'آيفون / آيباد (iOS)';
  } else if (isMac) {
    platform = 'mac';
    label = 'ماك (macOS)';
  } else if (isWindows) {
    platform = 'windows';
    label = 'ويندوز (Windows)';
  } else if (isLinux) {
    platform = 'linux';
    label = 'لينكس (Linux)';
  } else {
    platform = 'unknown';
    label = 'جهازك';
  }

  return {
    platform,
    label,
    badge: isAndroid ? 'APK مباشر' : 'نسخة الويب',
    recommendedFile: 'Arkan-1.0.0-universal.apk',
    downloadUrl: isAndroid 
      ? 'https://github.com/coach-nooreldean/arkan/releases/download/v1.0.0/Arkan-1.0.0-universal.apk'
      : 'https://arkan-app.vercel.app/',
    isMobile: isAndroid || isIos,
    isAndroid,
  };
}

