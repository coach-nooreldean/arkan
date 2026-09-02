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
      badge: 'APK الشامل',
      recommendedFile: 'Arkan-1.0.0-universal.apk',
      downloadUrl: '#releases',
      isMobile: true,
    };
  }

  const userAgent = window.navigator.userAgent.toLowerCase();
  const isMobile = /android|iphone|ipad|ipod/i.test(userAgent);

  return {
    platform: 'android',
    label: 'أندرويد',
    badge: 'ملف APK مباشر',
    recommendedFile: 'Arkan-1.0.0-universal.apk',
    downloadUrl: '#releases',
    isMobile,
  };
}

