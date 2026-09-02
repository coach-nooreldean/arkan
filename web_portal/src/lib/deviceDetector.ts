export type PlatformType = 'android' | 'ios' | 'windows' | 'mac' | 'linux' | 'unknown';

export interface DeviceInfo {
  platform: PlatformType;
  label: string;
  badge: string;
  recommendedFile: string;
  downloadUrl: string;
  isMobile: boolean;
}

export function detectDevice(): DeviceInfo {
  if (typeof window === 'undefined') {
    return {
      platform: 'android',
      label: 'أندرويد',
      badge: 'APK مباشر',
      recommendedFile: 'Arkan-1.0.0-universal.apk',
      downloadUrl: '#download-android',
      isMobile: true,
    };
  }

  const userAgent = window.navigator.userAgent.toLowerCase();

  if (/android/i.test(userAgent)) {
    return {
      platform: 'android',
      label: 'أندرويد',
      badge: 'APK مباشر وسريع',
      recommendedFile: 'Arkan-1.0.0-universal.apk',
      downloadUrl: '#download-android',
      isMobile: true,
    };
  }

  if (/iphone|ipad|ipod/i.test(userAgent)) {
    return {
      platform: 'ios',
      label: 'آيفون / آيباد',
      badge: 'Web App / PWA',
      recommendedFile: 'نسخة الويب السريعة',
      downloadUrl: '#web-version',
      isMobile: true,
    };
  }

  if (/windows/i.test(userAgent)) {
    return {
      platform: 'windows',
      label: 'ويندوز',
      badge: 'Windows 64-bit Zip',
      recommendedFile: 'Arkan-Windows-x64-1.0.0.zip',
      downloadUrl: '#download-windows',
      isMobile: false,
    };
  }

  if (/macintosh|mac os x/i.test(userAgent)) {
    return {
      platform: 'mac',
      label: 'ماك (macOS)',
      badge: 'Web PWA',
      recommendedFile: 'نسخة الويب الكاملة',
      downloadUrl: '#web-version',
      isMobile: false,
    };
  }

  if (/linux/i.test(userAgent)) {
    return {
      platform: 'linux',
      label: 'لينكس',
      badge: 'Linux tar.gz',
      recommendedFile: 'Arkan-linux-x64-1.0.0.tar.gz',
      downloadUrl: '#download-linux',
      isMobile: false,
    };
  }

  return {
    platform: 'android',
    label: 'أندرويد',
    badge: 'APK مباشر',
    recommendedFile: 'Arkan-1.0.0-universal.apk',
    downloadUrl: '#download-android',
    isMobile: true,
  };
}
