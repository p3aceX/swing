package G0;

import android.app.Application;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.os.Build;
import android.os.Process;
import android.os.StrictMode;
import com.google.android.gms.common.internal.F;
import java.io.BufferedReader;
import java.io.Closeable;
import java.io.FileReader;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public abstract class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final char[] f484a = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static Boolean f485b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static Boolean f486c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static Boolean f487d;
    public static Boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static String f488f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public static int f489g;

    public static String a(byte[] bArr) {
        int length = bArr.length;
        StringBuilder sb = new StringBuilder(length + length);
        for (int i4 = 0; i4 < length; i4++) {
            char[] cArr = f484a;
            sb.append(cArr[(bArr[i4] & 240) >>> 4]);
            sb.append(cArr[bArr[i4] & 15]);
        }
        return sb.toString();
    }

    public static void b(Closeable closeable) {
        if (closeable != null) {
            try {
                closeable.close();
            } catch (IOException unused) {
            }
        }
    }

    public static String c() throws Throwable {
        BufferedReader bufferedReader;
        if (f488f == null) {
            if (Build.VERSION.SDK_INT >= 28) {
                f488f = Application.getProcessName();
            } else {
                int iMyPid = f489g;
                if (iMyPid == 0) {
                    iMyPid = Process.myPid();
                    f489g = iMyPid;
                }
                String strTrim = null;
                strTrim = null;
                strTrim = null;
                BufferedReader bufferedReader2 = null;
                if (iMyPid > 0) {
                    try {
                        String str = "/proc/" + iMyPid + "/cmdline";
                        StrictMode.ThreadPolicy threadPolicyAllowThreadDiskReads = StrictMode.allowThreadDiskReads();
                        try {
                            bufferedReader = new BufferedReader(new FileReader(str));
                            try {
                                String line = bufferedReader.readLine();
                                F.g(line);
                                strTrim = line.trim();
                            } catch (IOException unused) {
                            } catch (Throwable th) {
                                th = th;
                                bufferedReader2 = bufferedReader;
                                b(bufferedReader2);
                                throw th;
                            }
                        } finally {
                            StrictMode.setThreadPolicy(threadPolicyAllowThreadDiskReads);
                        }
                    } catch (IOException unused2) {
                        bufferedReader = null;
                    } catch (Throwable th2) {
                        th = th2;
                    }
                    b(bufferedReader);
                }
                f488f = strTrim;
            }
        }
        return f488f;
    }

    public static byte[] d(Context context, String str) throws PackageManager.NameNotFoundException {
        MessageDigest messageDigest;
        PackageInfo packageInfo = H0.c.a(context).f515a.getPackageManager().getPackageInfo(str, 64);
        Signature[] signatureArr = packageInfo.signatures;
        if (signatureArr != null && signatureArr.length == 1) {
            int i4 = 0;
            while (true) {
                if (i4 >= 2) {
                    messageDigest = null;
                    break;
                }
                try {
                    messageDigest = MessageDigest.getInstance("SHA1");
                } catch (NoSuchAlgorithmException unused) {
                }
                if (messageDigest != null) {
                    break;
                }
                i4++;
            }
            if (messageDigest != null) {
                return messageDigest.digest(packageInfo.signatures[0].toByteArray());
            }
        }
        return null;
    }

    public static boolean e(Context context) {
        PackageManager packageManager = context.getPackageManager();
        if (f485b == null) {
            f485b = Boolean.valueOf(packageManager.hasSystemFeature("android.hardware.type.watch"));
        }
        f485b.booleanValue();
        if (f486c == null) {
            f486c = Boolean.valueOf(context.getPackageManager().hasSystemFeature("cn.google"));
        }
        if (!f486c.booleanValue()) {
            return false;
        }
        int i4 = Build.VERSION.SDK_INT;
        return i4 < 26 || i4 >= 30;
    }

    public static void f(StringBuilder sb, HashMap map) {
        sb.append("{");
        boolean z4 = true;
        for (String str : map.keySet()) {
            if (!z4) {
                sb.append(",");
            }
            String str2 = (String) map.get(str);
            sb.append("\"");
            sb.append(str);
            sb.append("\":");
            if (str2 == null) {
                sb.append("null");
            } else {
                sb.append("\"");
                sb.append(str2);
                sb.append("\"");
            }
            z4 = false;
        }
        sb.append("}");
    }
}
