package e1;

import A.C0003c;
import D2.AbstractActivityC0029d;
import Q3.C0151x;
import Q3.D;
import T2.C0164i;
import android.app.AppOpsManager;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Typeface;
import android.os.Binder;
import android.os.Build;
import android.os.Environment;
import android.os.Process;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.android.gms.internal.p002firebaseauthapi.zzafq;
import com.google.android.gms.internal.p002firebaseauthapi.zzagq;
import com.google.android.gms.internal.p002firebaseauthapi.zzags;
import e2.C0371C;
import e2.C0377I;
import j1.AbstractC0458c;
import j1.C0455E;
import j1.C0460e;
import j1.u;
import j1.v;
import j1.x;
import j1.y;
import java.io.File;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;
import k.r0;
import l1.C0522a;
import l1.r;
import u1.C0688a;
import x.C0710g;
import y3.C0768i;
import y3.InterfaceC0762c;
import y3.InterfaceC0765f;
import y3.InterfaceC0766g;
import y3.InterfaceC0767h;

/* JADX INFO: renamed from: e1.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0367g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static int f3993a = Integer.MAX_VALUE;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static short f3994b = 32;

    public AbstractC0367g() {
        new ConcurrentHashMap();
    }

    public static InterfaceC0767h A(InterfaceC0765f interfaceC0765f, InterfaceC0767h interfaceC0767h) {
        J3.i.e(interfaceC0767h, "context");
        return interfaceC0767h == C0768i.f6945a ? interfaceC0765f : (InterfaceC0767h) interfaceC0767h.h(interfaceC0765f, new C0151x(10));
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object C(io.ktor.utils.io.o r6, A3.c r7) {
        /*
            boolean r0 = r7 instanceof o3.C0600h
            if (r0 == 0) goto L13
            r0 = r7
            o3.h r0 = (o3.C0600h) r0
            int r1 = r0.f6101d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f6101d = r1
            goto L18
        L13:
            o3.h r0 = new o3.h
            r0.<init>(r7)
        L18:
            java.lang.Object r7 = r0.f6100c
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f6101d
            r3 = 2
            r4 = 1
            if (r2 == 0) goto L3a
            if (r2 == r4) goto L34
            if (r2 != r3) goto L2c
            int r6 = r0.f6099b
            M(r7)
            goto L61
        L2c:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r7)
            throw r6
        L34:
            io.ktor.utils.io.o r6 = r0.f6098a
            M(r7)
            goto L48
        L3a:
            M(r7)
            r0.f6098a = r6
            r0.f6101d = r4
            java.lang.Object r7 = io.ktor.utils.io.z.e(r6, r0)
            if (r7 != r1) goto L48
            goto L5d
        L48:
            java.lang.Number r7 = (java.lang.Number) r7
            byte r7 = r7.byteValue()
            r7 = r7 & 255(0xff, float:3.57E-43)
            r2 = 0
            r0.f6098a = r2
            r0.f6099b = r7
            r0.f6101d = r3
            java.lang.Object r6 = io.ktor.utils.io.z.e(r6, r0)
            if (r6 != r1) goto L5e
        L5d:
            return r1
        L5e:
            r5 = r7
            r7 = r6
            r6 = r5
        L61:
            java.lang.Number r7 = (java.lang.Number) r7
            byte r7 = r7.byteValue()
            r7 = r7 & 255(0xff, float:3.57E-43)
            int r6 = r6 << 8
            int r6 = r6 + r7
            java.lang.Integer r7 = new java.lang.Integer
            r7.<init>(r6)
            return r7
        */
        throw new UnsupportedOperationException("Method not decompiled: e1.AbstractC0367g.C(io.ktor.utils.io.o, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:37:0x00af  */
    /* JADX WARN: Removed duplicated region for block: B:40:0x00c2  */
    /* JADX WARN: Removed duplicated region for block: B:46:0x00da  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object D(io.ktor.utils.io.C0449m r9, A3.c r10) throws o3.C0590F {
        /*
            Method dump skipped, instruction units count: 243
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: e1.AbstractC0367g.D(io.ktor.utils.io.m, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Enum E(io.ktor.utils.io.o r5, A3.c r6) {
        /*
            boolean r0 = r6 instanceof o3.C0602j
            if (r0 == 0) goto L13
            r0 = r6
            o3.j r0 = (o3.C0602j) r0
            int r1 = r0.f6108c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f6108c = r1
            goto L18
        L13:
            o3.j r0 = new o3.j
            r0.<init>(r6)
        L18:
            java.lang.Object r6 = r0.f6107b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f6108c
            r3 = 1
            if (r2 == 0) goto L31
            if (r2 != r3) goto L29
            o3.H r5 = r0.f6106a
            M(r6)
            goto L44
        L29:
            java.lang.IllegalStateException r5 = new java.lang.IllegalStateException
            java.lang.String r6 = "call to 'resume' before 'invoke' with coroutine"
            r5.<init>(r6)
            throw r5
        L31:
            M(r6)
            o3.H r6 = o3.W.f6061b
            r0.f6106a = r6
            r0.f6108c = r3
            java.lang.Object r5 = C(r5, r0)
            if (r5 != r1) goto L41
            return r1
        L41:
            r4 = r6
            r6 = r5
            r5 = r4
        L44:
            java.lang.Number r6 = (java.lang.Number) r6
            int r6 = r6.intValue()
            r0 = 65535(0xffff, float:9.1834E-41)
            r6 = r6 & r0
            r5.getClass()
            o3.W r5 = o3.C0592H.a(r6)
            return r5
        */
        throw new UnsupportedOperationException("Method not decompiled: e1.AbstractC0367g.E(io.ktor.utils.io.o, A3.c):java.lang.Enum");
    }

    public static void K(View view, CharSequence charSequence) {
        if (Build.VERSION.SDK_INT >= 26) {
            view.setTooltipText(charSequence);
            return;
        }
        r0 r0Var = r0.f5441p;
        if (r0Var != null && r0Var.f5443a == view) {
            r0.b(null);
        }
        if (!TextUtils.isEmpty(charSequence)) {
            new r0(view, charSequence);
            return;
        }
        r0 r0Var2 = r0.f5442q;
        if (r0Var2 != null && r0Var2.f5443a == view) {
            r0Var2.a();
        }
        view.setOnLongClickListener(null);
        view.setLongClickable(false);
        view.setOnHoverListener(null);
    }

    public static Integer L(HashSet hashSet) {
        if (hashSet.contains(4)) {
            return 4;
        }
        if (hashSet.contains(2)) {
            return 2;
        }
        if (hashSet.contains(0)) {
            return 0;
        }
        return hashSet.contains(3) ? 3 : 1;
    }

    public static final void M(Object obj) {
        if (obj instanceof w3.d) {
            throw ((w3.d) obj).f6720a;
        }
    }

    public static int N(AbstractActivityC0029d abstractActivityC0029d, String str, int i4) {
        if (i4 == -1) {
            return p(abstractActivityC0029d, str);
        }
        return 1;
    }

    public static final boolean O(String str, I3.a aVar) {
        try {
            boolean zBooleanValue = ((Boolean) aVar.a()).booleanValue();
            if (!zBooleanValue && str != null) {
                Log.e("ReflectionGuard", str);
            }
            return zBooleanValue;
        } catch (ClassNotFoundException unused) {
            if (str == null) {
                str = "";
            }
            Log.e("ReflectionGuard", "ClassNotFound: ".concat(str));
            return false;
        } catch (NoSuchMethodException unused2) {
            if (str == null) {
                str = "";
            }
            Log.e("ReflectionGuard", "NoSuchMethod: ".concat(str));
            return false;
        }
    }

    public static ArrayList P(Throwable th) {
        ArrayList arrayList = new ArrayList(3);
        arrayList.add(th.toString());
        arrayList.add(th.getClass().getSimpleName());
        arrayList.add("Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
        return arrayList;
    }

    public static final void W(ByteBuffer byteBuffer, ByteBuffer byteBuffer2, ByteBuffer byteBuffer3, int i4) {
        if (i4 < 0 || byteBuffer2.remaining() < i4 || byteBuffer3.remaining() < i4 || byteBuffer.remaining() < i4) {
            throw new IllegalArgumentException("That combination of buffers, offsets and length to xor result in out-of-bond accesses.");
        }
        for (int i5 = 0; i5 < i4; i5++) {
            byteBuffer.put((byte) (byteBuffer2.get() ^ byteBuffer3.get()));
        }
    }

    public static final byte[] X(byte[] bArr, int i4, byte[] bArr2, int i5, int i6) {
        if (i6 < 0 || bArr.length - i6 < i4 || bArr2.length - i6 < i5) {
            throw new IllegalArgumentException("That combination of buffers, offsets and length to xor result in out-of-bond accesses.");
        }
        byte[] bArr3 = new byte[i6];
        for (int i7 = 0; i7 < i6; i7++) {
            bArr3[i7] = (byte) (bArr[i7 + i4] ^ bArr2[i7 + i5]);
        }
        return bArr3;
    }

    public static final byte[] Y(byte[] bArr, byte[] bArr2) {
        if (bArr.length == bArr2.length) {
            return X(bArr, 0, bArr2, 0, bArr.length);
        }
        throw new IllegalArgumentException("The lengths of x and y should match.");
    }

    public static zzags Z(AbstractC0458c abstractC0458c, String str) {
        if (j1.n.class.isAssignableFrom(abstractC0458c.getClass())) {
            j1.n nVar = (j1.n) abstractC0458c;
            return new zzags(nVar.f5203a, nVar.f5204b, "google.com", null, null, null, str, null, null);
        }
        if (C0460e.class.isAssignableFrom(abstractC0458c.getClass())) {
            return new zzags(null, ((C0460e) abstractC0458c).f5197a, "facebook.com", null, null, null, str, null, null);
        }
        if (y.class.isAssignableFrom(abstractC0458c.getClass())) {
            y yVar = (y) abstractC0458c;
            return new zzags(null, yVar.f5218a, "twitter.com", null, yVar.f5219b, null, str, null, null);
        }
        if (j1.m.class.isAssignableFrom(abstractC0458c.getClass())) {
            return new zzags(null, ((j1.m) abstractC0458c).f5202a, "github.com", null, null, null, str, null, null);
        }
        if (v.class.isAssignableFrom(abstractC0458c.getClass())) {
            return new zzags(null, null, "playgames.google.com", null, null, ((v) abstractC0458c).f5213a, str, null, null);
        }
        if (!C0455E.class.isAssignableFrom(abstractC0458c.getClass())) {
            throw new IllegalArgumentException("Unsupported credential type.");
        }
        C0455E c0455e = (C0455E) abstractC0458c;
        zzags zzagsVar = c0455e.f5173d;
        if (zzagsVar != null) {
            return zzagsVar;
        }
        return new zzags(c0455e.f5171b, c0455e.f5172c, c0455e.f5170a, null, c0455e.f5174f, null, str, c0455e.e, c0455e.f5175m);
    }

    public static void a(Object obj, String str) {
        if (obj == null) {
            throw new NullPointerException(str);
        }
    }

    public static j1.p a0(zzafq zzafqVar) {
        if (zzafqVar == null) {
            return null;
        }
        if (!TextUtils.isEmpty(zzafqVar.zze())) {
            String strZzd = zzafqVar.zzd();
            String strZzc = zzafqVar.zzc();
            long jZza = zzafqVar.zza();
            String strZze = zzafqVar.zze();
            F.d(strZze);
            return new u(strZzd, strZzc, jZza, strZze);
        }
        if (zzafqVar.zzb() == null) {
            return null;
        }
        String strZzd2 = zzafqVar.zzd();
        String strZzc2 = zzafqVar.zzc();
        long jZza2 = zzafqVar.zza();
        zzagq zzagqVarZzb = zzafqVar.zzb();
        F.h(zzagqVarZzb, "totpInfo cannot be null.");
        return new x(strZzd2, strZzc2, jZza2, zzagqVarZzb);
    }

    public static int b(Context context, String str) {
        int iC;
        int iMyPid = Process.myPid();
        int iMyUid = Process.myUid();
        String packageName = context.getPackageName();
        if (context.checkPermission(str, iMyPid, iMyUid) != -1) {
            String strD = q.g.d(str);
            if (strD != null) {
                if (packageName == null) {
                    String[] packagesForUid = context.getPackageManager().getPackagesForUid(iMyUid);
                    if (packagesForUid != null && packagesForUid.length > 0) {
                        packageName = packagesForUid[0];
                    }
                }
                int iMyUid2 = Process.myUid();
                String packageName2 = context.getPackageName();
                if (iMyUid2 == iMyUid && Objects.equals(packageName2, packageName) && Build.VERSION.SDK_INT >= 29) {
                    AppOpsManager appOpsManagerC = q.h.c(context);
                    iC = q.h.a(appOpsManagerC, strD, Binder.getCallingUid(), packageName);
                    if (iC == 0) {
                        iC = q.h.a(appOpsManagerC, strD, iMyUid, q.h.b(context));
                    }
                } else {
                    iC = q.g.c((AppOpsManager) q.g.a(context, AppOpsManager.class), strD, packageName);
                }
                if (iC != 0) {
                    return -2;
                }
            }
            return 0;
        }
        return -1;
    }

    public static ArrayList b0(List list) {
        if (list == null || list.isEmpty()) {
            return new ArrayList();
        }
        ArrayList arrayList = new ArrayList();
        Iterator it = list.iterator();
        while (it.hasNext()) {
            j1.p pVarA0 = a0((zzafq) it.next());
            if (pVarA0 != null) {
                arrayList.add(pVarA0);
            }
        }
        return arrayList;
    }

    public static byte[] e(byte[]... bArr) throws GeneralSecurityException {
        int length = 0;
        for (byte[] bArr2 : bArr) {
            if (length > com.google.android.gms.common.api.f.API_PRIORITY_OTHER - bArr2.length) {
                throw new GeneralSecurityException("exceeded size limit");
            }
            length += bArr2.length;
        }
        byte[] bArr3 = new byte[length];
        int length2 = 0;
        for (byte[] bArr4 : bArr) {
            System.arraycopy(bArr4, 0, bArr3, length2, bArr4.length);
            length2 += bArr4.length;
        }
        return bArr3;
    }

    public static C0522a g(String str, String str2) {
        C0688a c0688a = new C0688a(str, str2);
        HashSet hashSet = new HashSet();
        HashSet hashSet2 = new HashSet();
        HashSet hashSet3 = new HashSet();
        hashSet.add(r.a(C0688a.class));
        return new C0522a(new HashSet(hashSet), new HashSet(hashSet2), 1, new D2.u(c0688a, 11), hashSet3);
    }

    public static final w3.d h(Throwable th) {
        J3.i.e(th, "exception");
        return new w3.d(th);
    }

    public static String m(Object obj, String str) {
        J3.i.e(obj, "value");
        return str + " value: " + obj;
    }

    public static io.ktor.network.util.c n(D d5, String str, long j4, I3.l lVar) {
        defpackage.c cVar = new defpackage.c(1);
        J3.i.e(d5, "<this>");
        return new io.ktor.network.util.c(str, j4, cVar, d5, lVar);
    }

    /* JADX WARN: Removed duplicated region for block: B:18:0x002b A[RETURN] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static java.lang.String o(android.content.Context r3, java.lang.String r4) {
        /*
            int r0 = android.os.Build.VERSION.SDK_INT
            r1 = 31
            r2 = 0
            if (r0 < r1) goto Le
            boolean r1 = w(r3, r2, r4)
            if (r1 == 0) goto Le
            return r4
        Le:
            r4 = 29
            java.lang.String r1 = "android.permission.ACCESS_FINE_LOCATION"
            if (r0 >= r4) goto L24
            boolean r4 = w(r3, r2, r1)
            if (r4 == 0) goto L1b
            goto L2a
        L1b:
            java.lang.String r4 = "android.permission.ACCESS_COARSE_LOCATION"
            boolean r3 = w(r3, r2, r4)
            if (r3 == 0) goto L2b
            return r4
        L24:
            boolean r3 = w(r3, r2, r1)
            if (r3 == 0) goto L2b
        L2a:
            return r1
        L2b:
            return r2
        */
        throw new UnsupportedOperationException("Method not decompiled: e1.AbstractC0367g.o(android.content.Context, java.lang.String):java.lang.String");
    }

    public static int p(AbstractActivityC0029d abstractActivityC0029d, String str) {
        if (abstractActivityC0029d != null) {
            boolean z4 = abstractActivityC0029d.getSharedPreferences(str, 0).getBoolean("sp_permission_handler_permission_was_denied_before", false);
            boolean zB = q.e.b(abstractActivityC0029d, str);
            if (z4) {
                zB = !zB;
            }
            if (!z4 && zB) {
                abstractActivityC0029d.getSharedPreferences(str, 0).edit().putBoolean("sp_permission_handler_permission_was_denied_before", true).apply();
            }
            if (z4 && zB) {
                return 4;
            }
        }
        return 0;
    }

    public static boolean q(Method method, J3.e eVar) {
        Class clsA = eVar.a();
        J3.i.c(clsA, "null cannot be cast to non-null type java.lang.Class<T of kotlin.jvm.JvmClassMappingKt.<get-java>>");
        return method.getReturnType().equals(clsA);
    }

    public static C0522a t(String str, C0003c c0003c) {
        HashSet hashSet = new HashSet();
        HashSet hashSet2 = new HashSet();
        HashSet hashSet3 = new HashSet();
        hashSet.add(r.a(C0688a.class));
        for (Class cls : new Class[0]) {
            a(cls, "Null interface");
            hashSet.add(r.a(cls));
        }
        l1.j jVar = new l1.j(Context.class, 1, 0);
        if (hashSet.contains(jVar.f5611a)) {
            throw new IllegalArgumentException("Components are not allowed to depend on interfaces they themselves provide.");
        }
        hashSet2.add(jVar);
        return new C0522a(new HashSet(hashSet), new HashSet(hashSet2), 1, new C0164i(str, c0003c), hashSet3);
    }

    public static InterfaceC0765f u(InterfaceC0765f interfaceC0765f, InterfaceC0766g interfaceC0766g) {
        J3.i.e(interfaceC0766g, "key");
        if (J3.i.a(interfaceC0765f.getKey(), interfaceC0766g)) {
            return interfaceC0765f;
        }
        return null;
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    public static ArrayList v(Context context, int i4) {
        String strO;
        String strO2;
        String strO3;
        ArrayList arrayList = new ArrayList();
        switch (i4) {
            case 0:
            case 37:
                if (w(context, arrayList, "android.permission.WRITE_CALENDAR")) {
                    arrayList.add("android.permission.WRITE_CALENDAR");
                }
                if (w(context, arrayList, "android.permission.READ_CALENDAR")) {
                    arrayList.add("android.permission.READ_CALENDAR");
                }
                return arrayList;
            case 1:
                if (w(context, arrayList, "android.permission.CAMERA")) {
                    arrayList.add("android.permission.CAMERA");
                    return arrayList;
                }
                return arrayList;
            case 2:
                if (w(context, arrayList, "android.permission.READ_CONTACTS")) {
                    arrayList.add("android.permission.READ_CONTACTS");
                }
                if (w(context, arrayList, "android.permission.WRITE_CONTACTS")) {
                    arrayList.add("android.permission.WRITE_CONTACTS");
                }
                if (w(context, arrayList, "android.permission.GET_ACCOUNTS")) {
                    arrayList.add("android.permission.GET_ACCOUNTS");
                    return arrayList;
                }
                return arrayList;
            case 3:
            case 4:
            case 5:
                if (i4 != 4 || Build.VERSION.SDK_INT < 29) {
                    if (w(context, arrayList, "android.permission.ACCESS_COARSE_LOCATION")) {
                        arrayList.add("android.permission.ACCESS_COARSE_LOCATION");
                    }
                    if (w(context, arrayList, "android.permission.ACCESS_FINE_LOCATION")) {
                        arrayList.add("android.permission.ACCESS_FINE_LOCATION");
                        return arrayList;
                    }
                } else if (w(context, arrayList, "android.permission.ACCESS_BACKGROUND_LOCATION")) {
                    arrayList.add("android.permission.ACCESS_BACKGROUND_LOCATION");
                    return arrayList;
                }
                return arrayList;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
            case 20:
                return null;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
            case 14:
                if (w(context, arrayList, "android.permission.RECORD_AUDIO")) {
                    arrayList.add("android.permission.RECORD_AUDIO");
                    return arrayList;
                }
                return arrayList;
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                if (w(context, arrayList, "android.permission.READ_PHONE_STATE")) {
                    arrayList.add("android.permission.READ_PHONE_STATE");
                }
                int i5 = Build.VERSION.SDK_INT;
                if (i5 > 29 && w(context, arrayList, "android.permission.READ_PHONE_NUMBERS")) {
                    arrayList.add("android.permission.READ_PHONE_NUMBERS");
                }
                if (w(context, arrayList, "android.permission.CALL_PHONE")) {
                    arrayList.add("android.permission.CALL_PHONE");
                }
                if (w(context, arrayList, "android.permission.READ_CALL_LOG")) {
                    arrayList.add("android.permission.READ_CALL_LOG");
                }
                if (w(context, arrayList, "android.permission.WRITE_CALL_LOG")) {
                    arrayList.add("android.permission.WRITE_CALL_LOG");
                }
                if (w(context, arrayList, "com.android.voicemail.permission.ADD_VOICEMAIL")) {
                    arrayList.add("com.android.voicemail.permission.ADD_VOICEMAIL");
                }
                if (w(context, arrayList, "android.permission.USE_SIP")) {
                    arrayList.add("android.permission.USE_SIP");
                }
                if (i5 >= 26 && w(context, arrayList, "android.permission.ANSWER_PHONE_CALLS")) {
                    arrayList.add("android.permission.ANSWER_PHONE_CALLS");
                    return arrayList;
                }
                return arrayList;
            case 9:
                if (Build.VERSION.SDK_INT >= 33 && w(context, arrayList, "android.permission.READ_MEDIA_IMAGES")) {
                    arrayList.add("android.permission.READ_MEDIA_IMAGES");
                    return arrayList;
                }
                return arrayList;
            case 10:
            case 25:
            case 26:
            default:
                return arrayList;
            case 12:
                if (w(context, arrayList, "android.permission.BODY_SENSORS")) {
                    arrayList.add("android.permission.BODY_SENSORS");
                    return arrayList;
                }
                return arrayList;
            case 13:
                if (w(context, arrayList, "android.permission.SEND_SMS")) {
                    arrayList.add("android.permission.SEND_SMS");
                }
                if (w(context, arrayList, "android.permission.RECEIVE_SMS")) {
                    arrayList.add("android.permission.RECEIVE_SMS");
                }
                if (w(context, arrayList, "android.permission.READ_SMS")) {
                    arrayList.add("android.permission.READ_SMS");
                }
                if (w(context, arrayList, "android.permission.RECEIVE_WAP_PUSH")) {
                    arrayList.add("android.permission.RECEIVE_WAP_PUSH");
                }
                if (w(context, arrayList, "android.permission.RECEIVE_MMS")) {
                    arrayList.add("android.permission.RECEIVE_MMS");
                    return arrayList;
                }
                return arrayList;
            case 15:
                if (w(context, arrayList, "android.permission.READ_EXTERNAL_STORAGE")) {
                    arrayList.add("android.permission.READ_EXTERNAL_STORAGE");
                }
                int i6 = Build.VERSION.SDK_INT;
                if ((i6 < 29 || (i6 == 29 && Environment.isExternalStorageLegacy())) && w(context, arrayList, "android.permission.WRITE_EXTERNAL_STORAGE")) {
                    arrayList.add("android.permission.WRITE_EXTERNAL_STORAGE");
                    return arrayList;
                }
                return arrayList;
            case 16:
                if (w(context, arrayList, "android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS")) {
                    arrayList.add("android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS");
                    return arrayList;
                }
                return arrayList;
            case 17:
                if (Build.VERSION.SDK_INT >= 33 && w(context, arrayList, "android.permission.POST_NOTIFICATIONS")) {
                    arrayList.add("android.permission.POST_NOTIFICATIONS");
                    return arrayList;
                }
                return arrayList;
            case 18:
                if (Build.VERSION.SDK_INT < 29) {
                    return null;
                }
                if (w(context, arrayList, "android.permission.ACCESS_MEDIA_LOCATION")) {
                    arrayList.add("android.permission.ACCESS_MEDIA_LOCATION");
                    return arrayList;
                }
                return arrayList;
            case 19:
                if (Build.VERSION.SDK_INT < 29) {
                    return null;
                }
                if (w(context, arrayList, "android.permission.ACTIVITY_RECOGNITION")) {
                    arrayList.add("android.permission.ACTIVITY_RECOGNITION");
                    return arrayList;
                }
                return arrayList;
            case 21:
                if (w(context, arrayList, "android.permission.BLUETOOTH")) {
                    arrayList.add("android.permission.BLUETOOTH");
                    return arrayList;
                }
                return arrayList;
            case 22:
                if (Build.VERSION.SDK_INT >= 30 && w(context, arrayList, "android.permission.MANAGE_EXTERNAL_STORAGE")) {
                    arrayList.add("android.permission.MANAGE_EXTERNAL_STORAGE");
                    return arrayList;
                }
                return arrayList;
            case 23:
                if (w(context, arrayList, "android.permission.SYSTEM_ALERT_WINDOW")) {
                    arrayList.add("android.permission.SYSTEM_ALERT_WINDOW");
                    return arrayList;
                }
                return arrayList;
            case 24:
                if (w(context, arrayList, "android.permission.REQUEST_INSTALL_PACKAGES")) {
                    arrayList.add("android.permission.REQUEST_INSTALL_PACKAGES");
                    return arrayList;
                }
                return arrayList;
            case 27:
                if (w(context, arrayList, "android.permission.ACCESS_NOTIFICATION_POLICY")) {
                    arrayList.add("android.permission.ACCESS_NOTIFICATION_POLICY");
                    return arrayList;
                }
                return arrayList;
            case 28:
                if (Build.VERSION.SDK_INT >= 31 && (strO = o(context, "android.permission.BLUETOOTH_SCAN")) != null) {
                    arrayList.add(strO);
                    return arrayList;
                }
                return arrayList;
            case 29:
                if (Build.VERSION.SDK_INT >= 31 && (strO2 = o(context, "android.permission.BLUETOOTH_ADVERTISE")) != null) {
                    arrayList.add(strO2);
                    return arrayList;
                }
                return arrayList;
            case 30:
                if (Build.VERSION.SDK_INT >= 31 && (strO3 = o(context, "android.permission.BLUETOOTH_CONNECT")) != null) {
                    arrayList.add(strO3);
                    return arrayList;
                }
                return arrayList;
            case 31:
                if (Build.VERSION.SDK_INT >= 33 && w(context, arrayList, "android.permission.NEARBY_WIFI_DEVICES")) {
                    arrayList.add("android.permission.NEARBY_WIFI_DEVICES");
                    return arrayList;
                }
                return arrayList;
            case 32:
                if (Build.VERSION.SDK_INT >= 33 && w(context, arrayList, "android.permission.READ_MEDIA_VIDEO")) {
                    arrayList.add("android.permission.READ_MEDIA_VIDEO");
                    return arrayList;
                }
                return arrayList;
            case 33:
                if (Build.VERSION.SDK_INT >= 33 && w(context, arrayList, "android.permission.READ_MEDIA_AUDIO")) {
                    arrayList.add("android.permission.READ_MEDIA_AUDIO");
                    return arrayList;
                }
                return arrayList;
            case 34:
                if (w(context, arrayList, "android.permission.SCHEDULE_EXACT_ALARM")) {
                    arrayList.add("android.permission.SCHEDULE_EXACT_ALARM");
                    return arrayList;
                }
                return arrayList;
            case 35:
                if (Build.VERSION.SDK_INT >= 33 && w(context, arrayList, "android.permission.BODY_SENSORS_BACKGROUND")) {
                    arrayList.add("android.permission.BODY_SENSORS_BACKGROUND");
                    return arrayList;
                }
                return arrayList;
            case 36:
                if (w(context, arrayList, "android.permission.WRITE_CALENDAR")) {
                    arrayList.add("android.permission.WRITE_CALENDAR");
                    return arrayList;
                }
                return arrayList;
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:13:0x0020 A[Catch: Exception -> 0x001c, TryCatch #0 {Exception -> 0x001c, blocks: (B:4:0x0005, B:5:0x0009, B:7:0x000f, B:13:0x0020, B:15:0x0026, B:17:0x0030, B:20:0x0049, B:22:0x004f, B:23:0x005e, B:25:0x0064, B:18:0x003d), top: B:31:0x0005 }] */
    /* JADX WARN: Removed duplicated region for block: B:15:0x0026 A[Catch: Exception -> 0x001c, TryCatch #0 {Exception -> 0x001c, blocks: (B:4:0x0005, B:5:0x0009, B:7:0x000f, B:13:0x0020, B:15:0x0026, B:17:0x0030, B:20:0x0049, B:22:0x004f, B:23:0x005e, B:25:0x0064, B:18:0x003d), top: B:31:0x0005 }] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static boolean w(android.content.Context r4, java.util.ArrayList r5, java.lang.String r6) {
        /*
            r0 = 0
            java.lang.String r1 = "permissions_handler"
            if (r5 == 0) goto L1e
            java.util.Iterator r5 = r5.iterator()     // Catch: java.lang.Exception -> L1c
        L9:
            boolean r2 = r5.hasNext()     // Catch: java.lang.Exception -> L1c
            if (r2 == 0) goto L1e
            java.lang.Object r2 = r5.next()     // Catch: java.lang.Exception -> L1c
            java.lang.String r2 = (java.lang.String) r2     // Catch: java.lang.Exception -> L1c
            boolean r2 = r2.equals(r6)     // Catch: java.lang.Exception -> L1c
            if (r2 == 0) goto L9
            goto L70
        L1c:
            r4 = move-exception
            goto L72
        L1e:
            if (r4 != 0) goto L26
            java.lang.String r4 = "Unable to detect current Activity or App Context."
            android.util.Log.d(r1, r4)     // Catch: java.lang.Exception -> L1c
            return r0
        L26:
            android.content.pm.PackageManager r5 = r4.getPackageManager()     // Catch: java.lang.Exception -> L1c
            int r2 = android.os.Build.VERSION.SDK_INT     // Catch: java.lang.Exception -> L1c
            r3 = 33
            if (r2 < r3) goto L3d
            java.lang.String r4 = r4.getPackageName()     // Catch: java.lang.Exception -> L1c
            android.content.pm.PackageManager$PackageInfoFlags r2 = B.c.u()     // Catch: java.lang.Exception -> L1c
            android.content.pm.PackageInfo r4 = B.c.b(r5, r4, r2)     // Catch: java.lang.Exception -> L1c
            goto L47
        L3d:
            java.lang.String r4 = r4.getPackageName()     // Catch: java.lang.Exception -> L1c
            r2 = 4096(0x1000, float:5.74E-42)
            android.content.pm.PackageInfo r4 = r5.getPackageInfo(r4, r2)     // Catch: java.lang.Exception -> L1c
        L47:
            if (r4 != 0) goto L4f
            java.lang.String r4 = "Unable to get Package info, will not be able to determine permissions to request."
            android.util.Log.d(r1, r4)     // Catch: java.lang.Exception -> L1c
            return r0
        L4f:
            java.util.ArrayList r5 = new java.util.ArrayList     // Catch: java.lang.Exception -> L1c
            java.lang.String[] r4 = r4.requestedPermissions     // Catch: java.lang.Exception -> L1c
            java.util.List r4 = java.util.Arrays.asList(r4)     // Catch: java.lang.Exception -> L1c
            r5.<init>(r4)     // Catch: java.lang.Exception -> L1c
            java.util.Iterator r4 = r5.iterator()     // Catch: java.lang.Exception -> L1c
        L5e:
            boolean r5 = r4.hasNext()     // Catch: java.lang.Exception -> L1c
            if (r5 == 0) goto L77
            java.lang.Object r5 = r4.next()     // Catch: java.lang.Exception -> L1c
            java.lang.String r5 = (java.lang.String) r5     // Catch: java.lang.Exception -> L1c
            boolean r5 = r5.equals(r6)     // Catch: java.lang.Exception -> L1c
            if (r5 == 0) goto L5e
        L70:
            r4 = 1
            return r4
        L72:
            java.lang.String r5 = "Unable to check manifest for permission: "
            android.util.Log.d(r1, r5, r4)
        L77:
            return r0
        */
        throw new UnsupportedOperationException("Method not decompiled: e1.AbstractC0367g.w(android.content.Context, java.util.ArrayList, java.lang.String):boolean");
    }

    public static InterfaceC0767h y(InterfaceC0765f interfaceC0765f, InterfaceC0766g interfaceC0766g) {
        J3.i.e(interfaceC0766g, "key");
        return J3.i.a(interfaceC0765f.getKey(), interfaceC0766g) ? C0768i.f6945a : interfaceC0765f;
    }

    /* JADX WARN: Code restructure failed: missing block: B:35:0x0088, code lost:
    
        if (((Q3.q0) r8).y(r0) == r1) goto L36;
     */
    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Type inference failed for: r6v0, types: [io.ktor.network.sockets.y] */
    /* JADX WARN: Type inference failed for: r6v1 */
    /* JADX WARN: Type inference failed for: r6v12 */
    /* JADX WARN: Type inference failed for: r6v13 */
    /* JADX WARN: Type inference failed for: r6v14 */
    /* JADX WARN: Type inference failed for: r6v15 */
    /* JADX WARN: Type inference failed for: r6v2, types: [java.lang.Throwable] */
    /* JADX WARN: Type inference failed for: r6v7 */
    /* JADX WARN: Type inference failed for: r7v10, types: [java.io.Closeable] */
    /* JADX WARN: Type inference failed for: r7v14 */
    /* JADX WARN: Type inference failed for: r7v15 */
    /* JADX WARN: Type inference failed for: r7v16 */
    /* JADX WARN: Type inference failed for: r7v17 */
    /* JADX WARN: Type inference failed for: r7v5 */
    /* JADX WARN: Type inference failed for: r7v7 */
    /* JADX WARN: Type inference failed for: r7v8, types: [io.ktor.network.sockets.y] */
    /* JADX WARN: Type inference failed for: r7v9, types: [io.ktor.network.sockets.y] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object z(io.ktor.network.sockets.y r6, io.ktor.utils.io.C0449m r7, io.ktor.utils.io.C0449m r8, I.C0053n r9, X3.d r10, A3.c r11) throws o3.C0590F {
        /*
            boolean r0 = r11 instanceof o3.C0589E
            if (r0 == 0) goto L13
            r0 = r11
            o3.E r0 = (o3.C0589E) r0
            int r1 = r0.f6000f
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f6000f = r1
            goto L18
        L13:
            o3.E r0 = new o3.E
            r0.<init>(r11)
        L18:
            java.lang.Object r11 = r0.e
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f6000f
            r3 = 2
            r4 = 1
            if (r2 == 0) goto L46
            if (r2 == r4) goto L38
            if (r2 != r3) goto L30
            java.lang.Throwable r6 = r0.f5999d
            io.ktor.network.sockets.y r7 = r0.f5996a
            M(r11)     // Catch: java.lang.Throwable -> L2e
            goto L8b
        L2e:
            r7 = move-exception
            goto L8f
        L30:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r7)
            throw r6
        L38:
            o3.D r6 = r0.f5998c
            y3.h r10 = r0.f5997b
            io.ktor.network.sockets.y r7 = r0.f5996a
            M(r11)     // Catch: java.lang.Throwable -> L42
            goto L5f
        L42:
            r8 = move-exception
            r11 = r6
            r6 = r8
            goto L6b
        L46:
            M(r11)
            o3.D r11 = new o3.D
            r11.<init>(r7, r8, r9, r10)
            r0.f5996a = r6     // Catch: java.lang.Throwable -> L69
            r0.f5997b = r10     // Catch: java.lang.Throwable -> L69
            r0.f5998c = r11     // Catch: java.lang.Throwable -> L69
            r0.f6000f = r4     // Catch: java.lang.Throwable -> L69
            java.lang.Object r7 = r11.e(r0)     // Catch: java.lang.Throwable -> L69
            if (r7 != r1) goto L5d
            goto L8a
        L5d:
            r7 = r6
            r6 = r11
        L5f:
            o3.V r8 = new o3.V
            r8.<init>(r6, r7, r10)
            return r8
        L65:
            r5 = r7
            r7 = r6
            r6 = r5
            goto L6b
        L69:
            r7 = move-exception
            goto L65
        L6b:
            S3.t r8 = r11.f5992n     // Catch: java.lang.Throwable -> L2e
            r9 = 0
            r8.a(r9)     // Catch: java.lang.Throwable -> L2e
            S3.a r8 = r11.f5994p     // Catch: java.lang.Throwable -> L2e
            r8.j(r9)     // Catch: java.lang.Throwable -> L2e
            Q3.t r8 = r11.f5988c     // Catch: java.lang.Throwable -> L2e
            r0.f5996a = r7     // Catch: java.lang.Throwable -> L2e
            r0.f5997b = r9     // Catch: java.lang.Throwable -> L2e
            r0.f5998c = r9     // Catch: java.lang.Throwable -> L2e
            r0.f5999d = r6     // Catch: java.lang.Throwable -> L2e
            r0.f6000f = r3     // Catch: java.lang.Throwable -> L2e
            Q3.q0 r8 = (Q3.q0) r8     // Catch: java.lang.Throwable -> L2e
            java.lang.Object r8 = r8.y(r0)     // Catch: java.lang.Throwable -> L2e
            if (r8 != r1) goto L8b
        L8a:
            return r1
        L8b:
            r7.close()     // Catch: java.lang.Throwable -> L2e
            goto L92
        L8f:
            h(r7)
        L92:
            boolean r7 = r6 instanceof S3.p
            if (r7 == 0) goto L9e
            o3.F r7 = new o3.F
            java.lang.String r8 = "Negotiation failed due to EOS"
            r7.<init>(r8, r6)
            throw r7
        L9e:
            throw r6
        */
        throw new UnsupportedOperationException("Method not decompiled: e1.AbstractC0367g.z(io.ktor.network.sockets.y, io.ktor.utils.io.m, io.ktor.utils.io.m, I.n, X3.d, A3.c):java.lang.Object");
    }

    public abstract Object B(A3.c cVar);

    public abstract Object F(InterfaceC0762c interfaceC0762c);

    public abstract Object G(InterfaceC0762c interfaceC0762c);

    public abstract Object H(InterfaceC0762c interfaceC0762c);

    public abstract Object I(byte[] bArr, A3.c cVar);

    public abstract AbstractC0367g J(String str, I3.l lVar);

    public abstract Object Q(int i4, A3.c cVar);

    public abstract Object R(byte[] bArr, int i4, int i5, g2.n nVar);

    public abstract Object S(byte[] bArr, A3.c cVar);

    public abstract Object T(int i4, g2.i iVar);

    public abstract Object U(int i4, g2.i iVar);

    public abstract Object V(int i4, g2.i iVar);

    public abstract Object c(C0371C c0371c);

    public abstract Object d();

    public abstract Object f(C0377I c0377i);

    public abstract Typeface i(Context context, s.f fVar, Resources resources, int i4);

    public abstract Typeface j(Context context, C0710g[] c0710gArr, int i4);

    public Typeface k(Context context, InputStream inputStream) {
        File fileV = k.v(context);
        if (fileV == null) {
            return null;
        }
        try {
            if (k.k(fileV, inputStream)) {
                return Typeface.createFromFile(fileV.getPath());
            }
            return null;
        } catch (RuntimeException unused) {
            return null;
        } finally {
            fileV.delete();
        }
    }

    public Typeface l(Context context, Resources resources, int i4, String str, int i5) {
        File fileV = k.v(context);
        if (fileV == null) {
            return null;
        }
        try {
            if (k.j(fileV, resources, i4)) {
                return Typeface.createFromFile(fileV.getPath());
            }
            return null;
        } catch (RuntimeException unused) {
            return null;
        } finally {
            fileV.delete();
        }
    }

    public C0710g r(C0710g[] c0710gArr, int i4) {
        int i5 = (i4 & 1) == 0 ? 400 : 700;
        boolean z4 = (i4 & 2) != 0;
        C0710g c0710g = null;
        int i6 = com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
        for (C0710g c0710g2 : c0710gArr) {
            int iAbs = (Math.abs(c0710g2.f6745c - i5) * 2) + (c0710g2.f6746d == z4 ? 0 : 1);
            if (c0710g == null || i6 > iAbs) {
                c0710g = c0710g2;
                i6 = iAbs;
            }
        }
        return c0710g;
    }

    public abstract Object s(boolean z4, A3.c cVar);

    public abstract boolean x();
}
