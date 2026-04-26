package o3;

import I.C0053n;
import a.AbstractC0184a;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import com.google.firebase.components.ComponentRegistrar;
import java.io.Closeable;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import l1.C0522a;
import t2.EnumC0679d;
import x3.AbstractC0726f;
import x3.AbstractC0728h;
import y1.EnumC0755e;
import z1.C0786a;
import z1.EnumC0787b;

/* JADX INFO: renamed from: o3.H, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0592H {
    public static W a(int i4) {
        if (768 > i4 || i4 >= 772) {
            throw new IllegalArgumentException(com.google.crypto.tink.shaded.protobuf.S.d(i4, "Invalid TLS version code "));
        }
        return (W) W.f6062c.get(i4 - 768);
    }

    public static void b(Closeable closeable) {
        if (closeable != null) {
            try {
                closeable.close();
            } catch (IOException unused) {
            }
        }
    }

    public static com.google.android.gms.common.internal.r c(Context context, String[] strArr, String str, C0053n c0053n) {
        String[] strArrK = k(context);
        int length = strArrK.length;
        int i4 = 0;
        while (true) {
            ZipFile zipFile = null;
            if (i4 >= length) {
                return null;
            }
            String str2 = strArrK[i4];
            int i5 = 0;
            while (true) {
                int i6 = i5 + 1;
                if (i5 >= 5) {
                    break;
                }
                try {
                    zipFile = new ZipFile(new File(str2), 1);
                    break;
                } catch (IOException unused) {
                    i5 = i6;
                }
            }
            if (zipFile != null) {
                int i7 = 0;
                while (true) {
                    int i8 = i7 + 1;
                    if (i7 < 5) {
                        for (String str3 : strArr) {
                            StringBuilder sb = new StringBuilder("lib");
                            char c5 = File.separatorChar;
                            sb.append(c5);
                            sb.append(str3);
                            sb.append(c5);
                            sb.append(str);
                            String string = sb.toString();
                            c0053n.n("Looking for %s in APK %s...", string, str2);
                            ZipEntry entry = zipFile.getEntry(string);
                            if (entry != null) {
                                com.google.android.gms.common.internal.r rVar = new com.google.android.gms.common.internal.r(17, false);
                                rVar.f3597b = zipFile;
                                rVar.f3598c = entry;
                                return rVar;
                            }
                        }
                        i7 = i8;
                    } else {
                        try {
                            zipFile.close();
                            break;
                        } catch (IOException unused2) {
                        }
                    }
                }
            }
            i4++;
        }
    }

    public static s2.c d(int i4) throws IOException {
        Object next;
        B3.b bVar = s2.c.e;
        bVar.getClass();
        J3.a aVar = new J3.a(bVar);
        while (true) {
            if (!aVar.hasNext()) {
                next = null;
                break;
            }
            next = aVar.next();
            if (((s2.c) next).f6492a == i4) {
                break;
            }
        }
        s2.c cVar = (s2.c) next;
        if (cVar != null) {
            return cVar;
        }
        throw new IOException(com.google.crypto.tink.shaded.protobuf.S.d(i4, "unknown packet type: "));
    }

    public static EnumC0679d e(int i4) {
        Object next;
        B3.b bVar = EnumC0679d.f6581t;
        bVar.getClass();
        J3.a aVar = new J3.a(bVar);
        while (true) {
            if (!aVar.hasNext()) {
                next = null;
                break;
            }
            next = aVar.next();
            if (((EnumC0679d) next).f6582a == i4) {
                break;
            }
        }
        EnumC0679d enumC0679d = (EnumC0679d) next;
        if (enumC0679d != null) {
            return enumC0679d;
        }
        throw new IOException(com.google.crypto.tink.shaded.protobuf.S.d(i4, "unknown control type: "));
    }

    public static EnumC0787b f(byte b5) {
        Object next;
        int i4 = (b5 & 120) >>> 3;
        B3.b bVar = EnumC0787b.f6989f;
        bVar.getClass();
        J3.a aVar = new J3.a(bVar);
        while (true) {
            if (!aVar.hasNext()) {
                next = null;
                break;
            }
            next = aVar.next();
            if (((EnumC0787b) next).f6990a == i4) {
                break;
            }
        }
        EnumC0787b enumC0787b = (EnumC0787b) next;
        return enumC0787b == null ? EnumC0787b.f6986b : enumC0787b;
    }

    public static ArrayList g(byte[] bArr) {
        byte b5;
        J3.i.e(bArr, "av1Data");
        ArrayList arrayList = new ArrayList();
        int length = 0;
        while (length < bArr.length) {
            ArrayList arrayList2 = new ArrayList();
            byte b6 = bArr[length];
            arrayList2.add(Byte.valueOf(b6));
            if (((b6 >>> 2) & 1) == 1) {
                arrayList2.add(Byte.valueOf(bArr[length + 1]));
            }
            byte[] bArrF0 = AbstractC0728h.f0(arrayList2);
            int length2 = length + bArrF0.length;
            long j4 = 0;
            int i4 = 0;
            do {
                b5 = bArr[length2 + i4];
                j4 |= (((long) b5) & 127) << (i4 * 7);
                i4++;
            } while ((b5 & 128) != 0);
            Long lValueOf = Long.valueOf(j4);
            byte[] bArrK0 = AbstractC0726f.k0(bArr, AbstractC0184a.Z(length2, Integer.valueOf(i4).intValue() + length2));
            int length3 = length2 + bArrK0.length;
            byte[] bArrK02 = AbstractC0726f.k0(bArr, AbstractC0184a.Z(length3, ((int) lValueOf.longValue()) + length3));
            length = length3 + bArrK02.length;
            arrayList.add(new C0786a(bArrF0, bArrK0, bArrK02));
        }
        return arrayList;
    }

    public static String[] h(Context context, String str) {
        StringBuilder sb = new StringBuilder("lib");
        char c5 = File.separatorChar;
        sb.append(c5);
        sb.append("([^\\");
        sb.append(c5);
        sb.append("]*)");
        sb.append(c5);
        sb.append(str);
        Pattern patternCompile = Pattern.compile(sb.toString());
        HashSet hashSet = new HashSet();
        for (String str2 : k(context)) {
            try {
                Enumeration<? extends ZipEntry> enumerationEntries = new ZipFile(new File(str2), 1).entries();
                while (enumerationEntries.hasMoreElements()) {
                    Matcher matcher = patternCompile.matcher(enumerationEntries.nextElement().getName());
                    if (matcher.matches()) {
                        hashSet.add(matcher.group(1));
                    }
                }
            } catch (IOException unused) {
            }
        }
        return (String[]) hashSet.toArray(new String[hashSet.size()]);
    }

    public static EnumC0755e i(String str) {
        return (P3.m.q0(str, "network is unreachable", true) || P3.m.q0(str, "software caused connection abort", true) || P3.m.q0(str, "no route to host", true)) ? EnumC0755e.f6850f : P3.m.q0(str, "broken pipe", true) ? EnumC0755e.e : P3.m.q0(str, "connection refused", true) ? EnumC0755e.f6849d : P3.m.q0(str, "endpoint malformed", true) ? EnumC0755e.f6847b : (P3.m.q0(str, "timeout", true) || P3.m.q0(str, "timed out", true)) ? EnumC0755e.f6848c : EnumC0755e.f6851m;
    }

    public static String[] k(Context context) {
        ApplicationInfo applicationInfo = context.getApplicationInfo();
        String[] strArr = applicationInfo.splitSourceDirs;
        if (strArr == null || strArr.length == 0) {
            return new String[]{applicationInfo.sourceDir};
        }
        String[] strArr2 = new String[strArr.length + 1];
        strArr2[0] = applicationInfo.sourceDir;
        System.arraycopy(strArr, 0, strArr2, 1, strArr.length);
        return strArr2;
    }

    public List j(ComponentRegistrar componentRegistrar) {
        ArrayList arrayList = new ArrayList();
        for (C0522a c0522a : componentRegistrar.getComponents()) {
            c0522a.getClass();
            arrayList.add(c0522a);
        }
        return arrayList;
    }
}
