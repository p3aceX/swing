package A2;

import D2.v;
import J3.i;
import N2.j;
import O2.f;
import O2.m;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.content.pm.SigningInfo;
import android.os.Build;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import x3.AbstractC0726f;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class a implements m, K2.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Context f84a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0747k f85b;

    public static String b(byte[] bArr) throws NoSuchAlgorithmException {
        MessageDigest messageDigest = MessageDigest.getInstance("SHA-256");
        messageDigest.update(bArr);
        byte[] bArrDigest = messageDigest.digest();
        i.b(bArrDigest);
        char[] cArr = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
        char[] cArr2 = new char[bArrDigest.length * 2];
        int length = bArrDigest.length;
        for (int i4 = 0; i4 < length; i4++) {
            byte b5 = bArrDigest[i4];
            int i5 = i4 * 2;
            cArr2[i5] = cArr[(b5 & 255) >>> 4];
            cArr2[i5 + 1] = cArr[b5 & 15];
        }
        return new String(cArr2);
    }

    public final String a(PackageManager packageManager) {
        try {
            if (Build.VERSION.SDK_INT < 28) {
                Context context = this.f84a;
                i.b(context);
                Signature[] signatureArr = packageManager.getPackageInfo(context.getPackageName(), 64).signatures;
                if (signatureArr != null && signatureArr.length != 0 && AbstractC0726f.h0(signatureArr) != null) {
                    byte[] byteArray = ((Signature) AbstractC0726f.h0(signatureArr)).toByteArray();
                    i.d(byteArray, "toByteArray(...)");
                    return b(byteArray);
                }
                return null;
            }
            Context context2 = this.f84a;
            i.b(context2);
            SigningInfo signingInfo = packageManager.getPackageInfo(context2.getPackageName(), 134217728).signingInfo;
            if (signingInfo == null) {
                return null;
            }
            if (signingInfo.hasMultipleSigners()) {
                Signature[] apkContentsSigners = signingInfo.getApkContentsSigners();
                i.d(apkContentsSigners, "getApkContentsSigners(...)");
                byte[] byteArray2 = ((Signature) AbstractC0726f.h0(apkContentsSigners)).toByteArray();
                i.d(byteArray2, "toByteArray(...)");
                return b(byteArray2);
            }
            Signature[] signingCertificateHistory = signingInfo.getSigningCertificateHistory();
            i.d(signingCertificateHistory, "getSigningCertificateHistory(...)");
            byte[] byteArray3 = ((Signature) AbstractC0726f.h0(signingCertificateHistory)).toByteArray();
            i.d(byteArray3, "toByteArray(...)");
            return b(byteArray3);
        } catch (PackageManager.NameNotFoundException | NoSuchAlgorithmException unused) {
            return null;
        }
    }

    @Override // K2.a
    public final void c(C0747k c0747k) {
        i.e(c0747k, "binding");
        this.f84a = (Context) c0747k.f6831b;
        C0747k c0747k2 = new C0747k((f) c0747k.f6832c, "dev.fluttercommunity.plus/package_info", 11);
        this.f85b = c0747k2;
        c0747k2.Y(this);
    }

    @Override // O2.m
    public final void g(v vVar, j jVar) {
        String string;
        CharSequence charSequenceLoadLabel;
        i.e(vVar, "call");
        try {
            if (!i.a((String) vVar.f260b, "getAll")) {
                jVar.b();
                return;
            }
            Context context = this.f84a;
            i.b(context);
            PackageManager packageManager = context.getPackageManager();
            Context context2 = this.f84a;
            i.b(context2);
            PackageInfo packageInfo = packageManager.getPackageInfo(context2.getPackageName(), 0);
            String strA = a(packageManager);
            Context context3 = this.f84a;
            i.b(context3);
            PackageManager packageManager2 = context3.getPackageManager();
            Context context4 = this.f84a;
            i.b(context4);
            String packageName = context4.getPackageName();
            int i4 = Build.VERSION.SDK_INT;
            String initiatingPackageName = i4 >= 30 ? packageManager2.getInstallSourceInfo(packageName).getInitiatingPackageName() : packageManager2.getInstallerPackageName(packageName);
            long j4 = packageInfo.firstInstallTime;
            long j5 = packageInfo.lastUpdateTime;
            HashMap map = new HashMap();
            ApplicationInfo applicationInfo = packageInfo.applicationInfo;
            String str = "";
            if (applicationInfo == null || (charSequenceLoadLabel = applicationInfo.loadLabel(packageManager)) == null || (string = charSequenceLoadLabel.toString()) == null) {
                string = "";
            }
            map.put("appName", string);
            Context context5 = this.f84a;
            i.b(context5);
            map.put("packageName", context5.getPackageName());
            String str2 = packageInfo.versionName;
            if (str2 != null) {
                str = str2;
            }
            map.put("version", str);
            map.put("buildNumber", String.valueOf(i4 >= 28 ? packageInfo.getLongVersionCode() : packageInfo.versionCode));
            if (strA != null) {
                map.put("buildSignature", strA);
            }
            if (initiatingPackageName != null) {
                map.put("installerStore", initiatingPackageName);
            }
            map.put("installTime", String.valueOf(j4));
            map.put("updateTime", String.valueOf(j5));
            jVar.c(map);
        } catch (PackageManager.NameNotFoundException e) {
            jVar.a(null, "Name not found", e.getMessage());
        }
    }

    @Override // K2.a
    public final void m(C0747k c0747k) {
        i.e(c0747k, "binding");
        this.f84a = null;
        C0747k c0747k2 = this.f85b;
        i.b(c0747k2);
        c0747k2.Y(null);
        this.f85b = null;
    }
}
